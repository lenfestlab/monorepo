import { h } from "@cycle/react"
import { TextField } from "@material-ui/core"
import { format, parseISO } from "date-fns"
import { RefObject, useEffect, useState } from "react"
import { useObservable } from "react-use"
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
  distinctUntilChanged,
  map,
  mapTo,
  materialize,
  share,
  shareReplay,
  startWith,
  switchMap,
  withLatestFrom,
} from "rxjs/operators"

import { compact, either } from "fp"
import { translate } from "i18n"
import { Config, Event, SetConfig } from "."
import { ProgressButton } from "../ProgressButton"
import { SectionInput } from "../section/SectionInput"
import { Item, TransferList } from "../TransferList"

interface UrlError {
  error: boolean
  helperText: string
}
const noError: UrlError = { error: false, helperText: "" }
const errorStart: UrlError = {
  error: false,
  helperText: translate("events-input-webcal-helper"),
}

type InputEvent = React.ChangeEvent<HTMLInputElement>

const webcalDefault = process.env.SECTION_EVENTS_DEFAULT_WEBCAL ?? ""
const webcal$$ = new BehaviorSubject<string>(webcalDefault)
const onChange = (event: InputEvent) => webcal$$.next(event.target.value)
const webcal$: Observable<string> = webcal$$.pipe(tag("webcal$"), shareReplay())

const publicURLDefault = process.env.SECTION_EVENTS_DEFAULT_PUBLIC_URL ?? ""
const publicURL$$ = new BehaviorSubject<string>(publicURLDefault)
const onChangePublicURL = (event: InputEvent) =>
  publicURL$$.next(event.target.value)
const publicURL$: Observable<string> = publicURL$$.pipe(
  tag("publicURL$"),
  shareReplay()
)

const download$$ = new Subject<void>()
const onClick = (event: React.MouseEvent) => download$$.next()
const download$ = download$$.pipe(tag("download$"), shareReplay())

const invalid$ = webcal$.pipe(
  map((url) => !/(\.ics)$/.test(url)),
  tag("invalid$"),
  shareReplay()
)

const initialLoad$: Observable<string> = from(webcal$)
const response$ = merge(initialLoad$, download$).pipe(
  withLatestFrom(webcal$),
  map(([_, webcal]) => webcal),
  switchMap((webcal) =>
    ajax.getJSON<Event[]>(`${process.env.SECTION_EVENTS_JSON}?url=${webcal}`)
  ),
  tag("response$"),
  shareReplay()
)

const pending$ = merge(
  download$.pipe(mapTo(true)),
  response$.pipe(mapTo(false))
).pipe(distinctUntilChanged(), startWith(false), tag("pending$"), shareReplay())

const disabled$ = combineLatest(invalid$, pending$).pipe(
  map(([invalid, pending]) => invalid || pending),
  distinctUntilChanged(),
  startWith(true),
  tag("disabled$"),
  shareReplay()
)

const error$ = merge(
  webcal$.pipe(mapTo(noError)), // clear on touch
  response$.pipe(
    materialize(),
    map((notification: Notification<any>) => {
      if (notification.kind === "E") {
        const { response: data, responseType } = notification.error as AjaxError
        const error = true
        return responseType === "json"
          ? { error, helperText: data.message }
          : { error, helperText: "Server error" }
      } else {
        return noError
      }
    })
  )
).pipe(startWith(errorStart), tag("error$"), share())

const events$: Observable<Event[]> = onErrorResumeNext(response$).pipe(
  tag("events$"),
  share()
)

const mapItems = (events: Event[]): Item[] =>
  events.map((event) => {
    const start = parseISO(event.start)
    const formatted = format(start, "L/d/yy h':'mmaa")
    return { id: event.uid, title: `${formatted} ${event.summary}` }
  })

const left$$ = new Subject<Item[]>()
const setLeft = (items: Item[]) => left$$.next(items)
const left$ = merge(
  // NOTE: "reset" on webcal refresh
  events$.pipe(map((events: Event[]) => mapItems(events))),
  left$$
).pipe(share())

const right$$ = new BehaviorSubject<Item[]>([])
const setRight = (items: Item[]) => right$$.next(items)
const right$ = right$$.pipe(share())

const selections$: Observable<Event[]> = right$.pipe(
  withLatestFrom(events$),
  map(([items, events]) => {
    return compact(
      items.map((item) => {
        return events.find((event) => event.uid === item.id)
      })
    )
  }),
  tag("selections$"),
  share()
)

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}
export const Input = ({ config, setConfig, inputRef, id }: Props) => {
  const [title, setTitle] = useState(config.title)
  const [pre, setPre] = useState(config.pre)
  const [post, setPost] = useState(config.post)
  const webcal = useObservable(webcal$, either(config.webcal, ""))
  const publicURL = useObservable(publicURL$, either(config.publicURL, ""))
  const selections = useObservable(selections$, config.selections ?? [])
  const pending = useObservable(pending$, false)
  const disabled = useObservable(disabled$, true)
  const { error, helperText } = useObservable(error$, noError)
  const left = useObservable(left$, [])
  const right = useObservable(right$, mapItems(selections))

  useEffect(
    () => setConfig({ title, pre, post, webcal, publicURL, selections }),
    [title, pre, post, webcal, publicURL, selections]
  )

  const headerText = translate("events-input-header")
  const titlePlaceholder = translate("events-input-title-placeholder")
  const placeholder = translate(`events-input-url-placeholder`)

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
      h(TextField, {
        value: webcal,
        error,
        helperText,
        ...{
          fullWidth: true,
          onChange,
          placeholder,
          variant: "filled",
        },
      }),
      h(
        ProgressButton,
        { disabled, pending, onClick },
        translate(`events-input-download`)
      ),
      h(TransferList, {
        left,
        right,
        onChange: (left: Item[], right: Item[]) => {
          setLeft(left)
          setRight(right)
        },
      }),
      h(TextField, {
        value: publicURL,
        helperText: translate("events-input-public-helper"),
        ...{
          fullWidth: true,
          onChange: onChangePublicURL,
          placeholder,
          variant: "filled",
        },
      }),
    ]
  )
}
