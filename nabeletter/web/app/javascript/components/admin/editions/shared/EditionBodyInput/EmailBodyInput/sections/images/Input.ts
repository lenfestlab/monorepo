import { h } from "@cycle/react"
import { TextField } from "@material-ui/core"
import { Component, RefObject } from "react"
import {
  BehaviorSubject,
  combineLatest,
  merge,
  Observable,
  Subject,
  Subscription,
} from "rxjs"
import { tag } from "rxjs-spy/operators"
import {
  map,
  mapTo,
  share,
  shareReplay,
  startWith,
  tap,
  withLatestFrom,
} from "rxjs/operators"

import { uniqBy } from "fp"
import { translate } from "i18n"
import { Config, Image, SetConfig, URL } from "."
import { ImageList } from "../ImageList"
import { MarkdownInput } from "../MarkdownInput"
import { ProgressButton } from "../ProgressButton"
import { SectionConfig } from "../section"
import { SectionInput } from "../section/SectionInput"

type InputEvent = React.ChangeEvent<HTMLInputElement>
type ButtonEvent = React.MouseEvent<HTMLButtonElement>

interface UrlError {
  error: boolean
  helperText: string
}
const noError: UrlError = { error: false, helperText: "" }

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
  headerText: string
  titlePlaceholder: string
  urlPlaceholder: string
  captionPlaceholder: string
  markdownPlaceholder: string
  captionsEnabled?: boolean
}

interface State extends SectionConfig {
  url: string
  caption: string
  error: UrlError
  images: Image[]
  markdown?: string
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

  markdown$$ = new BehaviorSubject<string>("")
  markdown$ = this.markdown$$.pipe(tag("markdown$"), shareReplay())
  setMarkdown = (value: string) => this.markdown$$.next(value)

  url$$ = new BehaviorSubject<string>("")
  url$: Observable<string> = this.url$$.pipe(tag("url$"), shareReplay())
  onChangeURL = (event: InputEvent) => this.url$$.next(event.target.value)

  caption$$ = new BehaviorSubject<string>("")
  caption$: Observable<string> = this.caption$$.pipe(
    tag("caption$"),
    shareReplay()
  )
  onChangeCaption = (event: InputEvent) =>
    this.caption$$.next(event.target.value)

  images$$ = new BehaviorSubject<Image[]>([])
  images$: Observable<Image[]> = this.images$$.pipe(
    tag("images$"),
    shareReplay()
  )

  add$$ = new Subject<void>()
  addImage$ = this.add$$.pipe(
    withLatestFrom(this.url$),
    map(([_, url]) => url),
    tap((url) => {
      const image = { url, caption: this.caption$$.value }
      this.images$$.next(uniqBy(this.images$$.value.concat([image]), "url"))
      this.url$$.next("")
      this.caption$$.next("")
    }),
    tag("addImage$"),
    share()
  )

  onClickAdd = (event: React.MouseEvent) => {
    const url = this.url$$.value
    const image = { url, caption: this.caption$$.value }
    this.images$$.next(uniqBy(this.images$$.value.concat([image]), "url"))
    this.add$$.next()
  }

  onClickDelete = (event: ButtonEvent) => {
    const url: URL = event.currentTarget.id
    this.images$$.next(this.images$$.value.filter((image) => image.url !== url))
  }

  error$: Observable<UrlError> = merge(
    this.url$.pipe(mapTo(noError)), // clear on touch
    this.addImage$.pipe(
      map((url) => {
        const valid = true // /(png|jpg|jpeg)/.test(url)
        return valid
          ? noError
          : { error: true, helperText: "Invalid image URL" }
      })
    )
  ).pipe(startWith(noError), tag("error$"), share())

  constructor(props: Props) {
    super(props)
    const { config } = props
    const { title, pre, post, post_es, markdown: _md, images: _images } = config
    const images = _images ?? []
    const markdown = _md ?? ""
    this.title$$.next(title ?? "")
    this.pre$$.next(pre ?? "")
    this.post$$.next(post ?? "")
    this.post_es$$.next(post_es ?? "")
    this.images$$.next(images)
    this.markdown$$.next(markdown)
    this.state = {
      title,
      pre,
      post,
      url: "",
      caption: "",
      error: noError,
      images,
      markdown,
    }
  }

  componentDidMount() {
    const state$ = combineLatest([
      this.title$,
      this.pre$,
      this.post$,
      this.post_es$,
      this.url$,
      this.caption$,
      this.error$,
      this.images$$,
      this.markdown$,
    ]).pipe(
      tag("combineLatest$"),
      tap(
        ([
          title,
          pre,
          post,
          post_es,
          url,
          caption,
          error,
          images,
          markdown,
        ]) => {
          // @ts-ignore
          this.setState((prior) => {
            const next = {
              ...prior,
              title,
              pre,
              post,
              post_es,
              url,
              caption,
              error,
              images,
              markdown,
            }
            return next
          })
        }
      ),
      tag("state$"),
      share()
    )

    const sync$ = combineLatest(
      this.title$,
      this.pre$,
      this.post$,
      this.post_es$,
      this.images$,
      this.markdown$
    ).pipe(
      tap(([title, pre, post, post_es, images, markdown]) => {
        this.props.setConfig({ title, pre, post, post_es, images, markdown })
      }),
      tag("sync$")
    )

    this.subscription = merge(state$, sync$).subscribe()
  }

  componentWillUnmount() {
    this.subscription?.unsubscribe()
  }

  render() {
    const {
      inputRef,
      id,
      urlPlaceholder,
      headerText,
      titlePlaceholder,
      captionPlaceholder,
      markdownPlaceholder,
      captionsEnabled = false,
    } = this.props

    const {
      title,
      pre,
      post,
      post_es,
      markdown,
      url,
      caption,
      error: { error, helperText },
      images,
    } = this.state

    const onChangeMarkdown = (event: React.ChangeEvent<HTMLInputElement>) => {
      this.setMarkdown(event.target.value as string)
    }

    const {
      setTitle,
      setPre,
      setPost,
      setPost_es,
      onChangeCaption,
      onChangeURL,
      onClickAdd,
      onClickDelete,
    } = this

    const tiles = images.map(({ url, caption }) => {
      return {
        url,
        caption,
        onClickDelete,
      }
    })

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
        post_es,
        setPost_es,
        headerText,
        titlePlaceholder,
      },
      [
        // URL
        h(TextField, {
          value: url,
          error,
          helperText,
          ...{
            fullWidth: true,
            onChange: onChangeURL,
            placeholder: urlPlaceholder,
            variant: "filled",
          },
        }),
        // caption
        captionsEnabled &&
          h(TextField, {
            value: caption,
            ...{
              fullWidth: true,
              onChange: onChangeCaption,
              placeholder: captionPlaceholder,
              variant: "filled",
            },
          }),
        h(
          ProgressButton,
          { disabled: false, pending: false, onClick: onClickAdd },
          translate(`history-button-add`)
        ),
        h(ImageList, { tiles }),
        h(MarkdownInput, {
          markdown,
          onChange: onChangeMarkdown,
          placeholder: markdownPlaceholder,
        }),
      ]
    )
  }
}
