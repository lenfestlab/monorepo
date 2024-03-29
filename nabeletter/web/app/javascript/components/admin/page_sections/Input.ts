import { h } from "@cycle/react"
import {
  Box,
  FormControlLabel,
  Grid,
  Switch,
  TextField,
} from "@material-ui/core"
import { dataProvider } from "components/admin/providers"
import { PageSection } from "components/admin/shared"
import { translate } from "i18n"
import { Component, createRef, RefObject } from "react"
import ReactMarkdown from "react-markdown"
import {
  BehaviorSubject,
  combineLatest,
  from,
  onErrorResumeNext,
  Subscription,
  zip,
} from "rxjs"
import { tag } from "rxjs-spy/operators"
import { shareReplay, switchMap, tap } from "rxjs/operators"

type InputEvent = React.ChangeEvent<HTMLInputElement>

interface Props {
  record: PageSection
}

interface State {
  title: string
  body: string
  hidden: boolean
}

export class Input extends Component<Props, State> {
  subscription: Subscription | null = null

  title$$ = new BehaviorSubject<string>("")
  title$ = this.title$$.pipe(tag("title$"), shareReplay())

  body$$ = new BehaviorSubject<string>("")
  body$ = this.body$$.pipe(tag("body$"), shareReplay())

  hidden$$ = new BehaviorSubject<boolean>(false)
  hidden$ = this.hidden$$.pipe(tag("hidden$"), shareReplay())

  onChange = (event: InputEvent) => {
    const { name, value } = event.target
    if (name === "title") this.title$$.next(value)
    if (name === "body") this.body$$.next(value)
  }

  onSwitch = (event: InputEvent) => {
    const { name, checked } = event.target
    if (name === "hidden") this.hidden$$.next(checked)
  }

  htmlRef: RefObject<HTMLDivElement> = createRef<HTMLDivElement>()

  constructor(props: Props) {
    super(props)
    const {
      record: { title, body, hidden },
    } = props
    this.title$$.next(title)
    this.body$$.next(body)
    this.hidden$$.next(hidden)
    this.state = {
      title,
      body,
      hidden,
    }
  }

  componentDidMount() {
    const { title$, body$, hidden$ } = this

    const setState$ = combineLatest(title$, body$, hidden$).pipe(
      tap(([title, body, hidden]) => {
        this.setState((prior: State) => {
          return {
            ...prior,
            title,
            body,
            hidden,
          }
        })
      }),
      tag("page_section.input.setState$")
    )

    const sync$ = combineLatest(title$, body$, hidden$).pipe(
      switchMap(([title, body, hidden]) => {
        const id = this.props.record?.id
        const data = {
          title,
          body,
          hidden,
        }
        const request = dataProvider("UPDATE", "page_sections", { id, data })
        return onErrorResumeNext(from(request))
      }),
      tag("page_section.input.sync$")
    )

    this.subscription = zip(setState$, sync$).subscribe()
  }

  componentWillUnmount() {
    this.subscription?.unsubscribe()
  }

  render() {
    const { onChange, onSwitch } = this
    const { title, body, hidden } = this.state
    let source = `## ${title}`
    if (body) {
      source = source + `\n ${body}`
    }

    return h(
      Box,
      {
        id: "panel-container",
        display: "flex",
        flexDirection: "row",
        justifyContent: "flex-start",
        flexWrap: "nowrap",
      },
      [
        h(
          Box,
          {
            id: "panel-inputs",
            flex: "1 0",
            paddingRight: 2,
          },
          [
            h(Grid, { container: true, direction: "column", spacing: 1 }, [
              h(TextField, {
                value: title,
                ...{
                  onChange,
                  label: translate("page-section-input-title-label"),
                  name: "title",
                  placeholder: translate(
                    "page-section-input-title-placeholder"
                  ),
                  variant: "filled",
                },
              }),
              h(TextField, {
                value: body,
                ...{
                  onChange,
                  label: translate("page-section-input-body-label"),
                  name: "body",
                  fullWidth: true,
                  multiline: true,
                  rows: 40,
                  placeholder: translate("page-section-input-body-placeholder"),
                  variant: "filled",
                },
              }),
              h(FormControlLabel, {
                label: "hide",
                control: h(Switch, {
                  checked: hidden,
                  name: "hidden",
                  value: hidden,
                  onChange: onSwitch,
                }),
              }),
            ]),
          ]
        ),
        h(
          Box,
          {
            id: "panel-fields",
            flex: "0 0 content",
            width: 620,
            ...{ ref: this.htmlRef },
          },
          [
            h(ReactMarkdown, {
              source,
              escapeHtml: false,
              linkTarget: "_blank",
            }),
          ]
        ),
      ]
    )
  }
}
