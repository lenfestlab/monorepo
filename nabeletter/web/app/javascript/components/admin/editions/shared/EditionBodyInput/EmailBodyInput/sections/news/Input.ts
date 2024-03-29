import { h } from "@cycle/react"
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  Grid,
  IconButton,
  List,
  ListItem,
  ListItemSecondaryAction,
  ListItemText,
  TextField,
} from "@material-ui/core"
import { Delete, Edit } from "@material-ui/icons"
import { Component, createRef, RefObject } from "react"
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

import { compact, either, find, isEmpty, unionWith, uniqBy } from "fp"
import { translate } from "i18n"
import { Article, Config, EditableArticle, SetConfig } from "."
import { ProgressButton } from "../ProgressButton"
import { QuickLinks } from "../QuickLinks"
import { AdOpt, SectionConfig, SectionInputContext } from "../section"
import { SectionInput } from "../section/SectionInput"

type URL = string
interface UrlError {
  error: boolean
  helperText: string
}
const noError: UrlError = { error: false, helperText: "" }

type InputEvent = React.ChangeEvent<HTMLInputElement>
type ButtonEvent = React.MouseEvent<HTMLButtonElement>

type EditDialogProps = {
  open: boolean
  selectionID?: string
  selectionSitePlaceholder?: string
  selectionImagePlaceholder?: string
}

interface Props {
  context: SectionInputContext
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  kind: string
  id: string
}

interface State extends SectionConfig, EditDialogProps {
  url: string
  pending: boolean
  disabled: boolean
  error: UrlError
  articles: EditableArticle[]
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

  post_es$$ = new BehaviorSubject<string>("")
  post_es$ = this.post_es$$.pipe(tag("post_es$"), shareReplay())
  setPost_es = (val: string) => this.post_es$$.next(val)

  ad$$ = new BehaviorSubject<AdOpt>(undefined)
  ad$ = this.ad$$.pipe(tag("ad$"), shareReplay())
  setAd = (val: AdOpt) => this.ad$$.next(val)

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

  // Edit
  dialogProps$$ = new BehaviorSubject<EditDialogProps>({ open: false })
  dialogProps$ = this.dialogProps$$.pipe(
    tag("permits.dialogProps$"),
    shareReplay()
  )
  onClickEdit = (url: string) => {
    const selection = find(this.articles$$.value, (item) => item.url === url)
    const selectionSitePlaceholder = selection?.site_name
    const selectionImagePlaceholder = selection?.image
    this.dialogProps$$.next({
      open: true,
      selectionID: url,
      selectionSitePlaceholder,
      selectionImagePlaceholder,
    })
  }
  onClose = () =>
    this.dialogProps$$.next({
      open: false,
    })

  siteRef = createRef<HTMLTextAreaElement>()
  imageRef = createRef<HTMLInputElement>()
  onSave = () => {
    const siteValue = this.siteRef.current?.value
    const imageValue = this.imageRef.current?.value
    const site_name_custom = isEmpty(siteValue) ? null : siteValue
    const image_custom = isEmpty(imageValue) ? null : imageValue
    const newSelections = this.articles$$.value.map((article) => {
      return article.url === this.dialogProps$$.value.selectionID
        ? { ...article, site_name_custom, image_custom }
        : article
    })
    this.articles$$.next(newSelections)
    this.onClose()
  }

  constructor(props: Props) {
    super(props)
    const { config } = props
    const {
      title = "",
      pre = "",
      post = "",
      post_es = "",
      ad,
      url = "",
      articles = [],
    } = config
    this.title$$.next(title)
    this.pre$$.next(pre)
    this.post$$.next(post)
    this.post_es$$.next(post_es)
    this.ad$$.next(ad)
    this.url$$.next(url)
    this.articles$$.next(articles)
    this.state = {
      title,
      pre,
      post,
      post_es,
      ad,
      url,
      pending: false,
      disabled: false,
      error: noError,
      articles,
      ...{ open: false },
    }
  }

  componentDidMount() {
    const state$ = combineLatest([
      this.title$,
      this.pre$,
      this.post$,
      this.post_es$,
      this.ad$,
      this.url$,
      this.pending$,
      this.disabled$,
      this.error$,
      this.articles$$,
    ]).pipe(
      tag("combineLatest$"),
      tap(
        ([
          title,
          pre,
          post,
          post_es,
          ad,
          url,
          pending,
          disabled,
          error,
          articles,
        ]) => {
          // @ts-ignore
          this.setState((prior) => {
            const next = {
              ...prior,
              title,
              pre,
              post,
              post_es,
              ad,
              url,
              error,
              pending,
              disabled,
              articles,
            }
            return next
          })
        }
      ),
      tag("state$"),
      share()
    )

    const dialogState$ = combineLatest([this.dialogProps$]).pipe(
      tap(([dialogProps]) => {
        this.setState((prior) => {
          const next = {
            ...prior,
            ...dialogProps,
          }
          return next
        })
      }),
      tag("dialogState$"),
      share()
    )

    const sync$ = combineLatest(
      this.title$,
      this.pre$,
      this.post$,
      // TODO: this.post_es$$ - seea SectionInput.ts
      this.ad$,
      this.url$,
      this.articles$
    ).pipe(
      tap(([title, pre, post, ad, url, articles]) => {
        this.props.setConfig({ title, pre, post, ad, url, articles })
      }),
      tag("sync$")
    )

    this.subscription = merge(state$, sync$, dialogState$).subscribe()
  }
  componentWillUnmount() {
    this.subscription?.unsubscribe()
  }

  render() {
    const {
      inputRef,
      id,
      kind,
      context,
      // TODO
      // urlPlaceholder,
      // headerText,
      // titlePlaceholder,
      // captionPlaceholder,
      // markdownPlaceholder,
      // captionsEnabled = false,
    } = this.props

    const {
      title,
      pre,
      post,
      post_es,
      ad,
      url,
      disabled,
      pending,
      error: { error, helperText },
      articles,
    } = this.state
    const {
      open,
      selectionSitePlaceholder,
      selectionImagePlaceholder
    } = this.state

    const {
      setTitle,
      setPre,
      setPost,
      setPost_es,
      setAd,
      onChangeURL,
      onClickAdd,
      onClickDelete,
    } = this
    const { onClickEdit, onClose, onSave } = this

    const headerText = translate(`news-input-header`)
    const titlePlaceholder = translate(`news-input-title-placeholder`)
    const placeholder = translate(`news-input-url-placeholder`)
    const urls: string[] = compact(
      (context.newsletter?.source_urls ?? "").split(/\s+/)
    )
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
        post_es,
        setPost_es,
        setPost,
        headerText,
        titlePlaceholder,
        ad,
        setAd,
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
          translate(`${kind}-input-url-add`)
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
              const onClick = (event: any) => {
                onClickEdit(id)
              }
              return h(ListItem, [
                h(ListItemText, { primary, secondary }),
                h(ListItemSecondaryAction, [
                  h(IconButton, { id, onClick }, [h(Edit)]),
                  h(IconButton, { id, onClick: onClickDelete }, [h(Delete)]),
                ]),
              ])
            })
          ),
        ]),
        h(Dialog, { open, fullWidth: true, maxWidth: "md" }, [
          h(DialogContent, [
            h(TextField, {
              label: "Source",
              autoFocus: true,
              margin: "dense",
              fullWidth: true,
              multiline: true,
              rows: 4,
              variant: "filled",
              placeholder: selectionSitePlaceholder,
              inputRef: this.siteRef,
            }),
            h(TextField, {
              label: "Image",
              autoFocus: true,
              margin: "dense",
              fullWidth: true,
              variant: "filled",
              placeholder: selectionImagePlaceholder,
              inputRef: this.imageRef
            }),
          ]),
          h(DialogActions, [
            h(Button, { onClick: onClose, color: "primary" }, "Cancel"),
            h(Button, { onClick: onSave, color: "primary" }, "Save"),
          ]),
        ]),
      ]
    )
  }
}
