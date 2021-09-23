import { h } from "@cycle/react"
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  TextField,
} from "@material-ui/core"
import { format, parseISO } from "date-fns"
import { stringifyUrl } from "query-string"
import { Component, createRef, RefObject } from "react"
import { BehaviorSubject, combineLatest, merge, Subscription } from "rxjs"
import { tag } from "rxjs-spy/operators"
import { ajax, AjaxError } from "rxjs/ajax"
import { map, share, shareReplay, skip, switchMap, tap } from "rxjs/operators"
import { humanize } from "underscore.string"

import { compact, find, isEmpty, sortBy, union } from "fp"
import { translate } from "i18n"
import {
  Config,
  EditablePermit,
  OpenDataPhillyPermit,
  OpenDataPhillyResponse,
  Permit,
  SetConfig,
} from "."
import { SectionConfig } from "../section"
import { SectionInput } from "../section/SectionInput"
import { Item, TransferList } from "../TransferList"

const mapToItems = (permits: Permit[]): Item[] =>
  permits.map((permit) => {
    const id = permit.id
    const title = `${permit.type} - ${permit.address}`
    return { id, title }
  })

const mapToPermits = (items: Item[], permits: Permit[]): Permit[] =>
  compact(
    items.map((item: Item) => permits.find((permit) => permit.id === item.id))
  )

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}

type EditDialogProps = {
  open: boolean
  selectionID?: string
  selectionDescriptionPlaceholder?: string
}

interface State extends SectionConfig, EditDialogProps {
  selections: EditablePermit[]
  left: Item[]
  right: Item[]
}

export class Input extends Component<Props, State> {
  subscription: Subscription | null = null

  title$$ = new BehaviorSubject<string>("")
  title$ = this.title$$.pipe(tag("title$"), shareReplay())
  setTitle = (val: string) => this.title$$.next(val)

  pre$$ = new BehaviorSubject<string>("")
  pre$ = this.pre$$.pipe(tag("pre$"), shareReplay())
  setPre = (val: string) => this.pre$$.next(val)

  post$$ = new BehaviorSubject<string>("")
  post$ = this.post$$.pipe(tag("post$"), shareReplay())
  setPost = (val: string) => this.post$$.next(val)

  post_es$$ = new BehaviorSubject<string>("")
  post_es$ = this.post_es$$.pipe(tag("post_es$"), shareReplay())
  setPost_es = (val: string) => this.post_es$$.next(val)

  selections$$ = new BehaviorSubject<EditablePermit[]>([])
  selections$ = this.selections$$.pipe(
    tag("permits.selections$"),
    shareReplay()
  )
  setSelection = (val: EditablePermit[]) => this.selections$$.next(val)

  response$ = ajax
    .getJSON<OpenDataPhillyResponse>(
      stringifyUrl({
        url: "https://phl.carto.com/api/v2/sql",
        query: {
          q:
            "SELECT * FROM permits WHERE zip SIMILAR TO '(19125|19122|19123|19106)%' AND typeofwork SIMILAR TO '(NEW|DEMO)%' ORDER BY permitissuedate DESC LIMIT 50",
        },
      })
    )
    .pipe(tag("permits.response$"), shareReplay())

  permits$$ = new BehaviorSubject<Permit[]>([])
  permits$ = this.response$.pipe(
    switchMap(({ rows }) => {
      const permits: Permit[] = rows.map(
        ({
          permitnumber,
          address: rawAddress,
          typeofwork,
          permitissuedate,
          approvedscopeofwork,
          opa_owner,
          contractorname,
        }: OpenDataPhillyPermit) => {
          const id = permitnumber
          const address = rawAddress
          const type = humanize(typeofwork)
          const date = format(parseISO(permitissuedate), "MMMM d, y")
          const description = (approvedscopeofwork ?? "")
            .split(/\./)
            .map((sentence) => humanize(sentence))
            .join(". ")
          const property_owner = opa_owner
          const contractor_name = contractorname
          const image = `https://maps.googleapis.com/maps/api/streetview?key=AIzaSyA0zzOuoJnfsAJ1YIfPJ7RrtXeiYbdW-ZQ&size=505x240&location=${address}`
          return {
            id,
            type,
            address,
            date,
            description,
            property_owner,
            contractor_name,
            image,
          }
        }
      )
      return [permits]
    }),
    tap((permits) => this.permits$$.next(permits)),
    tag("permits.permits$"),
    share()
  )

  left$$ = new BehaviorSubject<Item[]>([])
  left$ = merge(
    this.permits$.pipe(map((permits) => mapToItems(permits))),
    this.left$$
  ).pipe(tag("permits.left$"), shareReplay())
  setLeft = (val: Item[]) => this.left$$.next(val)

  right$ = this.selections$.pipe(
    map((selections) => mapToItems(selections)),
    tag("permits.right$"),
    shareReplay()
  )
  setRight = (items: Item[]) => {
    const available: Permit[] = this.permits$$.value
    const selected: Permit[] = this.selections$$.value
    const all = union(available, selected)
    this.selections$$.next(mapToPermits(items, all))
  }

  dialogProps$$ = new BehaviorSubject<EditDialogProps>({ open: false })
  dialogProps$ = this.dialogProps$$.pipe(
    tag("permits.dialogProps$"),
    shareReplay()
  )
  onClickEdit = (id: string) => {
    const selection = find(this.selections$$.value, (item) => item.id === id)
    const selectionDescriptionPlaceholder = selection?.description
    this.dialogProps$$.next({
      open: true,
      selectionID: id,
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
    const newSelections = this.selections$$.value.map((selection) => {
      return selection.id === this.dialogProps$$.value.selectionID
        ? { ...selection, description_custom }
        : selection
    })
    this.selections$$.next(newSelections)
    this.onClose()
  }

  constructor(props: Props) {
    super(props)
    const { config } = props
    const { title, pre, post, post_es, selections } = config
    this.title$$.next(title ?? "")
    this.pre$$.next(pre ?? "")
    this.post$$.next(post ?? "")
    this.post_es$$.next(post_es ?? "")
    this.selections$$.next(selections ?? [])
    this.setRight(mapToItems(selections ?? []))
    this.state = {
      title,
      pre,
      post,
      selections,
      left: [],
      right: [],
      ...{ open: false },
    }
  }

  componentDidMount() {
    const state$ = combineLatest([
      this.title$,
      this.pre$,
      this.post$,
      this.post_es$,
      this.selections$,
      this.left$,
      this.right$,
    ]).pipe(
      tap(([title, pre, post, post_es, selections, left, right]) => {
        // @ts-ignore
        this.setState((prior) => {
          const next = {
            ...prior,
            title,
            pre,
            post,
            post_es,
            selections,
            left,
            right,
          }
          return next
        })
      }),
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
      this.post_es$,
      this.selections$
    ).pipe(
      skip(1),
      tap(([title, pre, post, post_es, selections]) => {
        this.props.setConfig({ title, pre, post, post_es, selections })
      }),
      tag("permits.sync$")
    )

    this.subscription = merge(state$, dialogState$, sync$).subscribe()
  }
  componentWillUnmount() {
    this.subscription?.unsubscribe()
  }

  render() {
    const { setTitle, setPre, setPost, setPost_es, setLeft, setRight } = this
    const { onClickEdit, onClose, onSave } = this
    const { title, pre, post, post_es, left, right } = this.state
    const { open, selectionDescriptionPlaceholder } = this.state
    const { inputRef, id } = this.props
    const headerText = translate("permits-input-header")
    const titlePlaceholder = translate("permits-input-title-placeholder")

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
        h(TransferList, {
          left,
          right,
          onClickEdit,
          onChange: (left: Item[], right: Item[]) => {
            setLeft(left)
            setRight(right)
          },
        }),
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
