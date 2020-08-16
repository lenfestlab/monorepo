import { h } from "@cycle/react"
import { div, img, span } from "@cycle/react-dom"
import { Box, CircularProgress, Grid, TextField } from "@material-ui/core"
import { dataProvider } from "components/admin/providers"
import { Ad } from "components/admin/shared"
import { percent, px } from "csx"
import { translate } from "i18n"
import { Component, createRef, RefObject } from "react"
import {
  BehaviorSubject,
  combineLatest,
  from,
  onErrorResumeNext,
  Subscription,
  zip,
} from "rxjs"
import { tag } from "rxjs-spy/operators"
import { ajax, AjaxResponse } from "rxjs/ajax"
import {
  debounceTime,
  map,
  shareReplay,
  skip,
  switchMap,
  tap,
} from "rxjs/operators"
import { Unit } from "./Unit"

type InputEvent = React.ChangeEvent<HTMLInputElement>

interface ApiResponseData {
  screenshot_url: string
  image_id: string
}

interface Props {
  record: Ad
}

interface State {
  title: string
  body: string
  logo_image_url: string
  main_image_url: string
  html?: string
  screenshot_url?: string
  loading: boolean
}

export class Input extends Component<Props, State> {
  subscription: Subscription | null = null

  title$$ = new BehaviorSubject<string>("")
  title$ = this.title$$.pipe(tag("title$"), shareReplay())

  body$$ = new BehaviorSubject<string>("")
  body$ = this.body$$.pipe(tag("body$"), shareReplay())

  logo_image_url$$ = new BehaviorSubject<string>("")
  logo_image_url$ = this.logo_image_url$$.pipe(
    tag("logo_image_url$"),
    shareReplay()
  )

  main_image_url$$ = new BehaviorSubject<string>("")
  main_image_url$ = this.main_image_url$$.pipe(
    tag("main_image_url$"),
    shareReplay()
  )

  screenshot_url$$ = new BehaviorSubject<string | null>(null)
  screenshot_url$ = this.screenshot_url$$.pipe(
    tag("screenshot_url$"),
    shareReplay()
  )

  onChange = (event: InputEvent) => {
    const { name, value } = event.target
    if (name === "title") this.title$$.next(value)
    if (name === "body") this.body$$.next(value)
    if (name === "logo_image_url") this.logo_image_url$$.next(value)
    if (name === "main_image_url") this.main_image_url$$.next(value)
  }

  htmlRef: RefObject<HTMLDivElement> = createRef<HTMLDivElement>()

  constructor(props: Props) {
    super(props)
    const {
      record: { title, body, logo_image_url, main_image_url, screenshot_url },
    } = props
    this.title$$.next(title)
    this.body$$.next(body)
    this.logo_image_url$$.next(logo_image_url)
    this.main_image_url$$.next(main_image_url)
    this.screenshot_url$$.next(screenshot_url ?? null)
    this.state = {
      title,
      body,
      logo_image_url,
      main_image_url,
      screenshot_url,
      loading: false,
    }
  }

  componentDidMount() {
    const { title$, body$, logo_image_url$, main_image_url$ } = this

    const setState$ = combineLatest(
      title$,
      body$,
      logo_image_url$,
      main_image_url$
    ).pipe(
      tap(([title, body, logo_image_url, main_image_url]) => {
        this.setState((prior: State) => {
          return {
            ...prior,
            title,
            body,
            logo_image_url,
            main_image_url,
          }
        })
      }),
      tag("ad.input.setState$")
    )

    const screenshot_url$ = combineLatest(
      title$,
      body$,
      logo_image_url$,
      main_image_url$
    ).pipe(
      debounceTime(500),
      skip(1),
      tap((_) => {
        this.setState((prior: State) => {
          return {
            ...prior,
            loading: true,
          }
        })
      }),
      switchMap((_state) => {
        const identifier = this.props.record.id
        const html = this.htmlRef.current?.outerHTML
        const selector = "#ad"
        const url = process.env.AD_CAPATURE_ENDPOINT! as string
        return onErrorResumeNext(
          ajax({
            url,
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: {
              identifier,
              html,
              selector,
            },
          })
        )
      }),
      map((response: AjaxResponse): ApiResponseData => response.response),
      map(({ screenshot_url }) => screenshot_url),
      tap((screenshot_url) => {
        this.setState((prior: State) => {
          return {
            ...prior,
            screenshot_url,
            loading: false,
          }
        })
      }),
      tag("ad.input.screenshot$"),
      shareReplay()
    )

    const sync$ = combineLatest(
      title$,
      body$,
      logo_image_url$,
      main_image_url$,
      screenshot_url$
    ).pipe(
      switchMap(
        ([title, body, logo_image_url, main_image_url, screenshot_url]) => {
          const id = this.props.record?.id
          const data = {
            title,
            body,
            logo_image_url,
            main_image_url,
            screenshot_url,
          }
          const request = dataProvider("UPDATE", "ads", { id, data })
          return onErrorResumeNext(from(request))
        }
      ),
      tag("ad.input.sync$")
    )

    this.subscription = zip(setState$, screenshot_url$, sync$).subscribe()
  }

  componentWillUnmount() {
    this.subscription?.unsubscribe()
  }

  render() {
    const { onChange } = this
    const {
      title,
      body,
      logo_image_url,
      main_image_url,
      screenshot_url,
      loading,
    } = this.state
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
                  label: translate("ad-input-title-label"),
                  name: "title",
                  fullWidth: true,
                  placeholder: translate("ad-input-title-placeholder"),
                  variant: "filled",
                },
              }),
              h(TextField, {
                value: body,
                ...{
                  onChange,
                  label: translate("ad-input-body-label"),
                  name: "body",
                  fullWidth: true,
                  multiline: true,
                  rows: 2,
                  placeholder: translate("ad-input-body-placeholder"),
                  variant: "filled",
                },
              }),
              h(TextField, {
                value: logo_image_url,
                ...{
                  onChange,
                  label: translate("ad-input-logo-image-label"),
                  name: "logo_image_url",
                  fullWidth: true,
                  placeholder: translate("ad-input-logo-image-placeholder"),
                  variant: "filled",
                },
              }),
              h(TextField, {
                value: main_image_url,
                ...{
                  onChange,
                  label: translate("ad-input-main-image-label"),
                  name: "main_image_url",
                  fullWidth: true,
                  placeholder: translate("ad-input-main-image-placeholder"),
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
            ...{ ref: this.htmlRef },
          },
          [
            h(Unit, {
              title,
              body,
              logo_image_url,
              main_image_url,
            }),
            div({ style: { paddingTop: px(10) } }, [
              div("As image:"),
              loading
                ? h(CircularProgress, {
                    size: 20,
                    disableShrink: true,
                  })
                : img({
                    style: { width: percent(100), paddingTop: px(10) },
                    src: screenshot_url,
                  }),
            ]),
          ]
        ),
      ]
    )
  }
}
