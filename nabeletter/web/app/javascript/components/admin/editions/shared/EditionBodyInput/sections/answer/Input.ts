import { h } from "@cycle/react"
import {
  Grid,
  IconButton,
  List,
  ListItem,
  ListItemSecondaryAction,
  ListItemText,
  TextField,
} from "@material-ui/core"
import { Delete } from "@material-ui/icons"
import { Component, RefObject } from "react"
import {
  BehaviorSubject,
  combineLatest,
  from,
  merge,
  Notification,
  Observable,
  Subject,
  Subscription,
} from "rxjs"
import { tag } from "rxjs-spy/operators"
import { ajax, AjaxError } from "rxjs/ajax"
import {
  distinctUntilChanged,
  filter,
  map,
  mapTo,
  materialize,
  share,
  shareReplay,
  startWith,
  switchMap,
  tap,
  withLatestFrom,
} from "rxjs/operators"

import { compact, either, isEmpty, unionWith, uniqBy } from "fp"
import { translate } from "i18n"
import { Article, Config, SetConfig } from "."
import { ProgressButton } from "../ProgressButton"
import { QuickLinks } from "../QuickLinks"
import { SectionConfig } from "../section"
import { SectionInput } from "../section/SectionInput"

type URL = string
interface UrlError {
  error: boolean
  helperText: string
}
const noError: UrlError = { error: false, helperText: "" }

type InputEvent = React.ChangeEvent<HTMLInputElement>
type ButtonEvent = React.MouseEvent<HTMLButtonElement>

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  kind: string
  id: string
}

interface State extends SectionConfig {
  url: string
  pending: boolean
  disabled: boolean
  error: UrlError
  articles: Article[]
}

export class Input extends Component<Props, State> {
  subscription: Subscription | null = null

  title$$ = new BehaviorSubject<string>("")
  title$ = this.title$$.pipe(tag("title$"), shareReplay())
  setTitle = (title: string) => this.title$$.next(title)

  pre$$ = new BehaviorSubject<string>("")
  pre$ = this.pre$$.pipe(tag("pre$"), shareReplay())
  setPre = (val: string) => this.pre$$.next(val)

  post$$ = new BehaviorSubject<string>("")
  post$ = this.post$$.pipe(tag("post$"), shareReplay())
  setPost = (val: string) => this.post$$.next(val)

  url$$ = new BehaviorSubject<string>("")
  url$: Observable<string> = this.url$$.pipe(tag("url$"), shareReplay())
  onChangeURL = (event: InputEvent) => this.url$$.next(event.target.value)

  add$$ = new Subject<void>()
  onClickAdd = (event: React.MouseEvent) => this.add$$.next()
  add$ = this.add$$.pipe(tag("add$"), shareReplay())

  onClickDelete = (event: ButtonEvent) => {
    const url: URL = event.currentTarget.id
    const newValues = this.articles$$.value.filter((i) => i.url !== url)
    this.articles$$.next(newValues)
  }

  response$ = merge(this.add$).pipe(
    withLatestFrom(this.url$),
    map(([_, url]) => url),
    switchMap((url) =>
      ajax.getJSON<Article>(`${process.env.SECTION_NEWS_ENDPOINT}?url=${url}`)
    ),
    materialize(),
    tag("response$"),
    tap((notification) => {
      const newValue = notification.value
      if (notification.kind === "N" && !!newValue) {
        const existing = this.articles$$.value
        const union = uniqBy(existing.concat([newValue]), "url")
        this.articles$$.next(union)
      }
    }),
    shareReplay()
  )

  error$ = merge(
    this.url$.pipe(mapTo(noError)), // clear on touch
    this.response$.pipe(
      filter((notification) => notification.kind === "E"),
      map((notification: Notification<any>) => {
        const error = notification.error
        const { response: data } = notification.error as AjaxError
        const helperText = isEmpty(data) ? error.message : data.message
        return {
          error: true,
          helperText,
        }
      })
    )
  ).pipe(startWith(noError), tag("error$"), share())

  pending$ = merge(
    this.add$.pipe(mapTo(true)),
    this.response$.pipe(mapTo(false))
  ).pipe(
    distinctUntilChanged(),
    startWith(false),
    tag("pending$"),
    shareReplay()
  )

  invalid$: Observable<boolean> = from([false]) // NOTE: any URL might work
  disabled$ = combineLatest(this.invalid$, this.pending$).pipe(
    map(([invalid, pending]) => invalid || pending),
    distinctUntilChanged(),
    startWith(true),
    tag("disabled$"),
    shareReplay()
  )

  articles$$ = new BehaviorSubject<Article[]>([])
  articles$: Observable<Article[]> = this.articles$$.pipe(
    tag("articles$"),
    shareReplay()
  )

  constructor(props: Props) {
    super(props)
    const { config } = props
    const { title = "", pre = "", post = "", url = "", articles = [] } = config
    this.title$$.next(title)
    this.pre$$.next(pre)
    this.post$$.next(post)
    this.url$$.next(url)
    this.articles$$.next(articles)
    this.state = {
      title,
      pre,
      post,
      url,
      pending: false,
      disabled: false,
      error: noError,
      articles,
    }
  }

  componentDidMount() {
    const state$ = combineLatest([
      this.title$,
      this.pre$,
      this.post$,
      this.url$,
      this.pending$,
      this.disabled$,
      this.error$,
      this.articles$$,
    ]).pipe(
      tag("combineLatest$"),
      tap(([title, pre, post, url, pending, disabled, error, articles]) => {
        // @ts-ignore
        this.setState((prior) => {
          const next = {
            ...prior,
            title,
            pre,
            post,
            url,
            error,
            pending,
            disabled,
            articles,
          }
          return next
        })
      }),
      tag("state$"),
      share()
    )

    const sync$ = combineLatest(
      this.title$,
      this.pre$,
      this.post$,
      this.url$,
      this.articles$
    ).pipe(
      tap(([title, pre, post, url, articles]) => {
        this.props.setConfig({ title, pre, post, url, articles })
      }),
      tag("sync$")
    )

    this.subscription = merge(state$, sync$).subscribe()
  }
  componentWillUnmount() {
    this.subscription?.unsubscribe()
  }

  render() {
    const { inputRef, id, kind } = this.props

    const {
      title,
      pre,
      post,
      url,
      disabled,
      pending,
      error: { error, helperText },
      articles,
    } = this.state

    const {
      setTitle,
      setPre,
      setPost,
      onChangeURL,
      onClickAdd,
      onClickDelete,
    } = this

    const headerText = translate(`answer-input-header`)
    const titlePlaceholder = translate(`answer-input-title-placeholder`)
    const placeholder = translate(`answer-input-url-placeholder`)
    const addButtonText = translate(`answer-input-url-add`)
    const urls: string[] = []

    return h(
      SectionInput,
      {
        id,
        inputRef,
        title,
        setTitle,
        pre,
        setPre,
        post,
        setPost,
        headerText,
        titlePlaceholder,
      },
      [
        !isEmpty(urls) && h(QuickLinks, { urls }),
        h(TextField, {
          value: url,
          error,
          helperText,
          ...{
            onChange: onChangeURL,
            fullWidth: true,
            placeholder,
            variant: "filled",
          },
        }),
        h(
          ProgressButton,
          { disabled, pending, onClick: onClickAdd },
          addButtonText
        ),
        h(Grid, { item: true }, [
          h(
            List,
            {
              dense: true,
            },
            articles.map((article: Article) => {
              const id = article.url
              const primary = article.title
              const secondary = article.url
              return h(ListItem, [
                h(ListItemText, { primary, secondary }),
                h(ListItemSecondaryAction, [
                  h(IconButton, { id, onClick: onClickDelete }, [h(Delete)]),
                ]),
              ])
            })
          ),
        ]),
      ]
    )
  }
}
