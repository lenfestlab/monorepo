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
import { ajax, AjaxError, AjaxResponse } from "rxjs/ajax"
import {
  distinctUntilChanged,
  map,
  mapTo,
  materialize,
  onErrorResumeNext,
  share,
  shareReplay,
  startWith,
  switchMap,
  tap,
  withLatestFrom,
} from "rxjs/operators"

import { compact, find, isEmpty, unionWith, uniqBy } from "fp"
import { translate } from "i18n"
import { Config, EditableProperty, SetConfig } from "."
import { ProgressButton } from "../ProgressButton"
import { QuickLinks } from "../QuickLinks"
import { AdOpt, SectionConfig } from "../section"
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
  selectionDescriptionPlaceholder?: string
}

export interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  kind: string
  id: string
  headerText: string
  titlePlaceholder: string
}

interface State extends SectionConfig, EditDialogProps {
  url: string
  pending: boolean
  disabled: boolean
  error: UrlError
  properties: EditableProperty[]
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
    const newValues = this.properties$$.value.filter((i) => i.url !== url)
    this.properties$$.next(newValues)
  }

  properties$$ = new BehaviorSubject<EditableProperty[]>([])
  properties$: Observable<EditableProperty[]> = this.properties$$.pipe(
    tag("properties$"),
    shareReplay()
  )

  response$ = merge(this.add$).pipe(
    withLatestFrom(this.url$),
    map(([_, url]) => url),
    switchMap((url) =>
      ajax.getJSON<EditableProperty>(
        `${process.env.SECTION_PROPERTIES_ENDPOINT}?url=${url}`
      )
    ),
    tag("properties.response$"),
    shareReplay()
  )

  values$ = this.response$.pipe(
    onErrorResumeNext(),
    tag("properties.values$"),
    tap((property) => {
      const existing = this.properties$$.value
      const union = uniqBy(existing.concat([property]), "url")
      this.properties$$.next(union)
    }),
    shareReplay()
  )

  error$ = merge(
    this.url$.pipe(mapTo(noError)), // clear on touch
    this.values$.pipe(mapTo(noError)),
    this.response$.pipe(
      materialize(),
      map((notification: Notification<any>) => {
        if (notification.kind === "E") {
          const error = notification.error
          const { response: data } = notification.error as AjaxError
          const helperText = isEmpty(data) ? error.message : data.message
          return {
            error: true,
            helperText,
          }
        } else {
          return noError
        }
      })
    )
  ).pipe(startWith(noError), tag("properties.error$"), share())

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

  // Edit
  dialogProps$$ = new BehaviorSubject<EditDialogProps>({ open: false })
  dialogProps$ = this.dialogProps$$.pipe(
    tag("permits.dialogProps$"),
    shareReplay()
  )
  onClickEdit = (url: string) => {
    const selection = find(this.properties$$.value, (item) => item.url === url)
    const selectionDescriptionPlaceholder = selection?.description
    this.dialogProps$$.next({
      open: true,
      selectionID: url,
      selectionDescriptionPlaceholder,
    })
  }
  onClose = () =>
    this.dialogProps$$.next({
      open: false,
    })

  descriptionRef = createRef<HTMLTextAreaElement>()
  onSave = () => {
    const descValue = this.descriptionRef.current?.value
    const description_custom = isEmpty(descValue) ? null : descValue
    const newSelections = this.properties$$.value.map((property) => {
      return property.url === this.dialogProps$$.value.selectionID
        ? { ...property, description_custom }
        : property
    })
    this.properties$$.next(newSelections)
    this.onClose()
  }

  constructor(props: Props) {
    super(props)
    const { config } = props
    const {
      title = "",
      pre = "",
      post = "",
      ad,
      url = "",
      properties = [],
    } = config
    this.title$$.next(title)
    this.pre$$.next(pre)
    this.post$$.next(post)
    this.ad$$.next(ad)
    this.url$$.next(url)
    this.properties$$.next(properties)
    this.state = {
      title,
      pre,
      post,
      ad,
      url,
      pending: false,
      disabled: false,
      error: noError,
      properties,
      ...{ open: false },
    }
  }

  componentDidMount() {
    const state$ = combineLatest([
      this.title$,
      this.pre$,
      this.post$,
      this.ad$,
      this.url$,
      this.pending$,
      this.disabled$,
      this.error$,
      this.properties$$,
    ]).pipe(
      tag("combineLatest$"),
      tap(
        ([title, pre, post, ad, url, pending, disabled, error, properties]) => {
          // @ts-ignore
          this.setState((prior) => {
            const next = {
              ...prior,
              title,
              pre,
              post,
              ad,
              url,
              error,
              pending,
              disabled,
              properties,
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
      this.ad$,
      this.url$,
      this.properties$
    ).pipe(
      tap(([title, pre, post, ad, url, properties]) => {
        this.props.setConfig({ title, pre, post, ad, url, properties })
      }),
      tag("sync$")
    )

    this.subscription = merge(sync$, state$, dialogState$).subscribe()
  }
  componentWillUnmount() {
    this.subscription?.unsubscribe()
  }

  render() {
    const { inputRef, id, headerText, titlePlaceholder } = this.props

    const {
      title,
      pre,
      post,
      ad,
      url,
      disabled,
      pending,
      error: { error, helperText },
      properties,
    } = this.state
    const { open, selectionDescriptionPlaceholder } = this.state

    const {
      setTitle,
      setPre,
      setPost,
      setAd,
      onChangeURL,
      onClickAdd,
      onClickDelete,
    } = this
    const { onClickEdit, onClose, onSave } = this

    const placeholder = translate(`properties-input-url-placeholder`)
    const urls = compact(
      (process.env.SECTION_PROPERTIES_SOURCE_URLS ?? "").split(/\s+/)
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
          translate(`properties-input-url-add`)
        ),
        h(Grid, { item: true }, [
          h(
            List,
            {
              dense: true,
            },
            properties.map((property: EditableProperty) => {
              const id = property.url
              const primary = property.address
              const secondary = property.url
              const onClick = (event: any) => onClickEdit(id)
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
              label: "Description",
              autoFocus: true,
              margin: "dense",
              fullWidth: true,
              multiline: true,
              rows: 4,
              variant: "filled",
              placeholder: selectionDescriptionPlaceholder,
              inputRef: this.descriptionRef,
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
