import { h } from "@cycle/react"
import { h1 } from "@cycle/react-dom"
import {
  Box,
  Grid,
  IconButton,
  Link,
  List,
  ListItem,
  ListItemSecondaryAction,
  ListItemText,
  ListSubheader,
  TextField,
} from "@material-ui/core"
import { ArrowDownward, ArrowUpward, OpenInNew } from "@material-ui/icons"
import { dataProvider } from "components/admin/providers"
import { Page, PageSection } from "components/admin/shared"
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
  record: Page
}

interface State {
  id: number | string
  header_image_url: string
  title: string
  pre: string
  post: string
  sections: PageSection[]
}

export class Input extends Component<Props, State> {
  subscription: Subscription | null = null

  header_image_url$$ = new BehaviorSubject<string>("")
  header_image_url$ = this.header_image_url$$.pipe(
    tag("header_image_url$"),
    shareReplay()
  )

  title$$ = new BehaviorSubject<string>("")
  title$ = this.title$$.pipe(tag("title$"), shareReplay())

  pre$$ = new BehaviorSubject<string>("")
  pre$ = this.pre$$.pipe(tag("pre$"), shareReplay())

  post$$ = new BehaviorSubject<string>("")
  post$ = this.post$$.pipe(tag("post$"), shareReplay())

  sections$$ = new BehaviorSubject<PageSection[]>([])
  sections$ = this.sections$$.pipe(tag("sections$"), shareReplay())

  onChange = (event: InputEvent) => {
    const { name, value } = event.target
    if (name === "header_image_url") this.header_image_url$$.next(value)
    if (name === "title") this.title$$.next(value)
    if (name === "pre") this.pre$$.next(value)
    if (name === "post") this.post$$.next(value)
  }

  onSwap = (index1: number, index2: number) => {
    const sections = this.sections$$.value
    const temp = sections[index1]
    sections[index1] = sections[index2]
    sections[index2] = temp
    this.sections$$.next(sections)
  }

  constructor(props: Props) {
    super(props)
    const {
      record: { id, header_image_url, title, pre, post, sections },
    } = props
    this.header_image_url$$.next(header_image_url)
    this.title$$.next(title)
    this.pre$$.next(pre)
    this.post$$.next(post)
    this.sections$$.next(sections)
    this.state = {
      id,
      header_image_url,
      title,
      pre,
      post,
      sections,
    }
  }

  componentDidMount() {
    const { header_image_url$, title$, pre$, post$, sections$ } = this

    const setState$ = combineLatest(
      header_image_url$,
      title$,
      pre$,
      post$,
      sections$
    ).pipe(
      tap(([header_image_url, title, pre, post, sections]) => {
        this.setState((prior: State) => {
          return {
            ...prior,
            header_image_url,
            title,
            pre,
            post,
            sections,
          }
        })
      }),
      tag("page.input.setState$")
    )

    const sync$ = combineLatest(
      header_image_url$,
      title$,
      pre$,
      post$,
      sections$
    ).pipe(
      switchMap(([header_image_url, title, pre, post, sections]) => {
        const id = this.props.record?.id
        const data = {
          header_image_url,
          title,
          pre,
          post,
          sections,
        }
        const request = dataProvider("UPDATE", "pages", { id, data })
        return onErrorResumeNext(from(request))
      }),
      tag("page.input.sync$")
    )

    this.subscription = zip(setState$, sync$).subscribe()
  }

  componentWillUnmount() {
    this.subscription?.unsubscribe()
  }

  render() {
    const { onChange, onSwap } = this
    const { id, header_image_url, title, pre, post, sections } = this.state
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
                value: header_image_url,
                ...{
                  onChange,
                  label: translate("page-input-image-label"),
                  name: "header_image_url",
                  fullWidth: true,
                  placeholder: translate("page-input-image-placeholder"),
                  variant: "filled",
                },
              }),
              h(TextField, {
                value: title,
                required: true,
                ...{
                  onChange,
                  label: translate("page-input-title-label"),
                  name: "title",
                  fullWidth: true,
                  placeholder: translate("page-input-title-placeholder"),
                  variant: "filled",
                },
              }),
              h(TextField, {
                value: pre,
                ...{
                  onChange,
                  label: translate("page-input-pre-label"),
                  name: "pre",
                  fullWidth: true,
                  multiline: true,
                  rows: 10,
                  placeholder: translate("page-input-pre-placeholder"),
                  variant: "filled",
                },
              }),
              h(
                List,
                {
                  dense: true,
                  subheader: h(ListSubheader, ["Sections"]),
                },
                sections.map((section: PageSection, idx: number) => {
                  const id = section.id
                  const primary = section.title
                  const onClickOpen = () =>
                    window.open(`admin#/page_sections/${id}`)
                  const onClickDown = () => onSwap(idx, idx + 1)
                  const onClickUp = () => onSwap(idx, idx - 1)
                  return h(ListItem, [
                    h(ListItemText, { primary }),
                    h(ListItemSecondaryAction, [
                      h(
                        IconButton,
                        {
                          onClick: onClickDown,
                          disabled: idx === sections.length - 1,
                        },
                        [h(ArrowDownward)]
                      ),
                      h(
                        IconButton,
                        { onClick: onClickUp, disabled: idx === 0 },
                        [h(ArrowUpward)]
                      ),
                      h(IconButton, { onClick: onClickOpen }, [h(OpenInNew)]),
                    ]),
                  ])
                })
              ),
              h(TextField, {
                value: post,
                ...{
                  onChange,
                  label: translate("page-input-post-label"),
                  name: "post",
                  fullWidth: true,
                  multiline: true,
                  rows: 10,
                  placeholder: translate("page-input-post-placeholder"),
                  variant: "filled",
                },
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
          },
          [
            h(
              IconButton,
              { size: "small", onClick: () => window.open(`/pages/${id}`) },
              [h(OpenInNew, {})]
            ),
            h1(title),
            h(ReactMarkdown, {
              source: pre,
              escapeHtml: false,
              linkTarget: "_blank",
            }),
            "...",
            h(ReactMarkdown, {
              source: post,
              escapeHtml: false,
              linkTarget: "_blank",
            }),
          ]
        ),
      ]
    )
  }
}
