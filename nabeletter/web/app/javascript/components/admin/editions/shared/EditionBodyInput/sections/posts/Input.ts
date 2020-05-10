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
import { Component, createRef, RefObject } from "react"
import {
  combineLatest,
  fromEvent,
  merge,
  Notification,
  Observable,
  onErrorResumeNext,
  Subject,
  Subscription,
} from "rxjs"
import { tag } from "rxjs-spy/operators"
import { ajax, AjaxError } from "rxjs/ajax"
import {
  distinctUntilChanged,
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

import { either, find, omit, values } from "fp"
import { translate } from "i18n"
import type { Config, Post, PostMap, SetConfig, URL } from "."
import { SectionInput } from "../SectionInput"
import { ProgressButton } from "./ProgressButton"

type InputChangeEvent = React.ChangeEvent<HTMLInputElement>
type ButtonEvent = React.MouseEvent<HTMLButtonElement>

interface URLError {
  error: boolean
  helperText: string
}
const urlErrorDefault = { error: false, helperText: "" }

export interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
  kind: string
}
interface State {
  disabled: boolean
  pending: boolean
  title: string
  url: URL
  urlError: URLError
  postmap: PostMap
}

export class Input extends Component<Props, State> {
  subscription: Subscription | null = null
  refTitle = createRef<HTMLDivElement>()
  refURL = createRef<HTMLDivElement>()
  refAdd = createRef<HTMLButtonElement>()
  remove$$ = new Subject<URL>()
  title$$ = new Subject<string>()

  constructor(props: Props) {
    super(props)
    const { config } = props
    const title = either(config.title, "")
    const postmap = either(config.postmap, {})
    this.state = {
      disabled: true,
      pending: false,
      title,
      url: "",
      urlError: { error: false, helperText: "" },
      postmap,
    }
  }

  componentDidMount() {
    const { title, url, disabled, postmap } = this.state

    const title$ = this.title$$
      .asObservable()
      .pipe(startWith(title), tag("title$"), shareReplay())

    if (!this.refURL.current) {
      throw new Error("MIA: refUrl")
    }
    const urlInput$ = fromEvent<InputChangeEvent>(
      this.refURL.current!,
      "input"
    ).pipe(
      map((event: InputChangeEvent) => {
        return event.target.value as string
      }),
      tag("urlInput$"),
      share()
    )

    const addButton$ = fromEvent(this.refAdd.current!, "click").pipe(
      tag("addButton$"),
      share()
    )

    const addRequest$: Observable<Post> = addButton$.pipe(
      withLatestFrom(urlInput$),
      map(([_, url]) => url),
      switchMap((url: URL) => {
        return ajax.getJSON<Post>(
          `${process.env.SCREENSHOT_ENDPOINT}?url=${url}`
        )
      }),
      tag("addRequest$"),
      share()
    )
    const add$ = onErrorResumeNext(addRequest$).pipe(tag("add$"), share())

    const clearUrl$ = add$.pipe(mapTo(""))
    const url$ = merge(urlInput$, clearUrl$).pipe(
      startWith(url),
      distinctUntilChanged(),
      tag("url$"),
      shareReplay()
    )

    const urlInvalid$: Observable<boolean> = url$.pipe(
      map((url) => {
        const pattern = /http(?:s)?:\/\/(?:www\.)?(twitter|instagram|facebook)\.com\/([a-zA-Z0-9_]+)/
        return !pattern.test(url)
      }),
      startWith(true),
      distinctUntilChanged(),
      tag("urlInvalid$"),
      shareReplay()
    )

    const pending$ = merge(
      addButton$.pipe(mapTo(true)),
      add$.pipe(mapTo(false))
    ).pipe(
      distinctUntilChanged(),
      startWith(false),
      tag("pending$"),
      shareReplay()
    )

    const disabled$ = combineLatest(urlInvalid$, pending$).pipe(
      map(([invalid, pending]) => {
        return invalid || pending
      }),
      distinctUntilChanged(),
      startWith(disabled),
      tag("disabled$"),
      shareReplay()
    )

    const urlError$: Observable<URLError> = merge(
      urlInput$.pipe(mapTo(urlErrorDefault)), // reset on URL edit
      add$.pipe(
        materialize(),
        map((notification: Notification<Post>) => {
          if (notification.kind === "E") {
            const {
              response: data,
              responseType,
            } = notification.error as AjaxError
            const error = true
            return responseType === "json"
              ? { error, helperText: data.message }
              : { error, helperText: "Server error" }
          } else {
            return urlErrorDefault
          }
        })
      )
    ).pipe(startWith(urlErrorDefault), tag("urlError$"), shareReplay())

    const remove$: Observable<URL> = this.remove$$
      .asObservable()
      .pipe(tag("remove$"), share())

    const postmap$ = merge(
      add$.pipe(
        map((post) => {
          return {
            ...this.state.postmap,
            [post.image_id]: post,
          }
        })
      ),
      remove$.pipe(
        map((url: URL) => {
          const { postmap } = this.state
          const found = find(postmap, (post) => post.url === url)
          return !found ? postmap : omit(postmap, found.image_id)
        }),
        tag("sanspost$")
      )
    ).pipe(startWith(postmap), tag("postmap$"), shareReplay())

    const state$ = combineLatest([
      title$,
      url$,
      disabled$,
      pending$,
      urlError$,
      postmap$,
    ]).pipe(
      tag("combineLatest$"),
      tap(([title, url, disabled, pending, urlError, postmap]) => {
        this.setState((prior) => {
          const next = {
            ...prior,
            title,
            url,
            disabled,
            pending,
            urlError,
            postmap,
          }
          return next
        })
      }),
      tag("state$"),
      share()
    )

    const sync$ = combineLatest(title$, postmap$).pipe(
      tap(([title, postmap]) => {
        this.props.setConfig({ title, postmap })
      }),
      tag("sync$")
    )

    this.subscription = merge(state$, sync$).subscribe()
  }

  componentWillUnmount() {
    this.subscription?.unsubscribe()
  }

  render() {
    const { refTitle, refURL, refAdd } = this
    const { inputRef, id, kind } = this.props
    const { disabled, pending, title, postmap, url, urlError } = this.state
    const posts = values(postmap)

    const setTitle = (title: string) => this.title$$.next(title)
    const headerText = translate(`${kind}-input-header`)
    const titlePlaceholder = translate(`${kind}-input-title-placeholder`)

    return h(
      SectionInput,
      {
        id,
        inputRef,
        title,
        setTitle,
        headerText,
        titlePlaceholder,
      },
      [
        h(TextField, {
          ref: refURL,
          value: url,
          error: urlError.error,
          helperText: urlError.helperText,
          ...{
            fullWidth: true,
            placeholder: translate(`${kind}-input-url-placeholder`),
            variant: "filled",
          },
        }),
        h(
          ProgressButton,
          { disabled, pending, forwardRef: refAdd },
          translate(`${kind}-input-url-add`)
        ),
        // posts
        h(Grid, { item: true }, [
          h(
            List,
            {
              dense: true,
            },
            posts.map((post: Post) => {
              const id = post.url
              const onClick = (event: ButtonEvent) => {
                const url: URL = event.currentTarget.id
                this.remove$$.next(url)
              }
              const primary = post.title
              const secondary = post.url
              return h(ListItem, [
                h(ListItemText, { primary, secondary }),
                h(ListItemSecondaryAction, [
                  h(IconButton, { id, onClick }, [h(Delete)]),
                ]),
              ])
            })
          ),
        ]),
      ]
    )
  }
}
