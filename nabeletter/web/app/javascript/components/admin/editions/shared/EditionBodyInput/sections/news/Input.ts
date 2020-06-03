import { h } from "@cycle/react"
import {
  Divider,
  Grid,
  IconButton,
  List,
  ListItem,
  ListItemSecondaryAction,
  ListItemText,
  TextField,
} from "@material-ui/core"
import { Delete } from "@material-ui/icons"
import { RefObject, useEffect, useState } from "react"
import { useMount, useObservable } from "react-use"
import {
  BehaviorSubject,
  combineLatest,
  from,
  merge,
  Notification,
  Observable,
  onErrorResumeNext,
  Subject,
} from "rxjs"
import { tag } from "rxjs-spy/operators"
import { ajax, AjaxError } from "rxjs/ajax"
import {
  dematerialize,
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
import { SectionInput } from "../SectionInput"

type URL = string
interface UrlError {
  error: boolean
  helperText: string
}
const noError: UrlError = { error: false, helperText: "" }

type InputEvent = React.ChangeEvent<HTMLInputElement>
type ButtonEvent = React.MouseEvent<HTMLButtonElement>

const url$$ = new BehaviorSubject<string>("")
const onChange = (event: InputEvent) => url$$.next(event.target.value)
const url$: Observable<string> = url$$.pipe(tag("url$"), shareReplay())

const add$$ = new Subject<void>()
const onClickAdd = (event: React.MouseEvent) => add$$.next()
const add$ = add$$.pipe(tag("add$"), shareReplay())

const delete$$ = new Subject<string>()
const onClickDelete = (event: ButtonEvent) =>
  delete$$.next(event.currentTarget.id)
const delete$: Observable<URL> = delete$$.pipe(tag("delete$"), share())

const response$ = merge(add$).pipe(
  withLatestFrom(url$),
  map(([_, url]) => url),
  switchMap((url) =>
    ajax.getJSON<Article>(`${process.env.SECTION_NEWS_ENDPOINT}?url=${url}`)
  ),
  materialize(),
  tag("response$"),
  shareReplay()
)

const addArticle$ = onErrorResumeNext(response$).pipe(
  dematerialize(),
  tag("addArticle$"),
  share()
)

const error$ = merge(
  url$.pipe(mapTo(noError)), // clear on touch
  response$.pipe(
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

const pending$ = merge(
  add$.pipe(mapTo(true)),
  response$.pipe(mapTo(false))
).pipe(distinctUntilChanged(), startWith(false), tag("pending$"), shareReplay())

const invalid$: Observable<boolean> = from([false]) // NOTE: any URL might work
const disabled$ = combineLatest(invalid$, pending$).pipe(
  map(([invalid, pending]) => invalid || pending),
  distinctUntilChanged(),
  startWith(true),
  tag("disabled$"),
  shareReplay()
)

const articles$$ = new BehaviorSubject<Article[]>([])
const articles$: Observable<Article[]> = merge(
  articles$$, // inital value
  addArticle$.pipe(
    map((article) => uniqBy(articles$$.value.concat([article]), "url"))
  ),
  delete$.pipe(
    map((url: URL) => articles$$.value.filter((article) => article.url !== url))
  )
).pipe(tag("articles$"), shareReplay())

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  kind: string
  id: string
}
export const Input = ({ config, setConfig, inputRef, id, kind }: Props) => {
  const [title, setTitle] = useState(config.title)
  const url = useObservable(url$, "")
  const articles = useObservable(articles$, [])
  useMount(() => {
    url$$.next(either(config.url, ""))
    articles$$.next(config.articles ?? [])
  })
  const pending = useObservable(pending$, false)
  const disabled = useObservable(disabled$, true)
  const { error, helperText } = useObservable(error$, noError)

  useEffect(() => {
    setConfig({ title, url, articles })
  }, [title, url, articles])

  const headerText = translate(`news-input-header`)
  const titlePlaceholder = translate(`news-input-title-placeholder`)
  const placeholder = translate(`news-input-url-placeholder`)
  const urls = compact(
    (process.env.SECTION_NEWS_SOURCE_URLS ?? "").split(/\s+/)
  )
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
      h(QuickLinks, { urls }),
      h(TextField, {
        value: url,
        error,
        helperText,
        ...{
          onChange,
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
