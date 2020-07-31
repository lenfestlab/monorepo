import { h } from "@cycle/react"
import { dataProvider } from "components/admin/providers"
import { Edition } from "components/admin/shared"
import { body, formatErrorHTML, mj, MjApiResult, mjml, Node } from "mj"
import { Component, createRef, RefObject } from "react"
import {
  BehaviorSubject,
  from,
  of,
  onErrorResumeNext,
  Subject,
  Subscription,
  zip,
} from "rxjs"
import { tag } from "rxjs-spy/operators"
import { ajax, AjaxResponse } from "rxjs/ajax"
import {
  debounceTime,
  distinctUntilChanged,
  map as map$,
  share,
  skip,
  switchMap,
  tap,
} from "rxjs/operators"
import { colors, fonts, queries } from "styles"

import { AnalyticsProps as AllAnalyticsProps } from "analytics"
import { Record as ApiRecord } from "components/admin/shared"
import { compact, find, get, isEmpty, map, reduce, values } from "fp"
import { Editor } from "./Editor"
import { PreviewRef, SectionField, SectionInput } from "./types"

import { important, px } from "csx"
import { createTypeStyle, media } from "typestyle"
import {
  Field as AnswerField,
  Input as AnswerInput,
  node as answerNode,
} from "./sections/answer"
import {
  Field as AskField,
  Input as AskInput,
  node as askNode,
} from "./sections/ask"
import {
  Field as EventsField,
  Input as EventsInput,
  node as eventsNode,
} from "./sections/events"
import {
  Field as FacebookField,
  Input as FacebookInput,
  node as facebookNode,
} from "./sections/facebook"
import {
  Field as FooterField,
  Input as FooterInput,
  node as footerNode,
} from "./sections/footer"
import {
  Field as HeaderField,
  Input as HeaderInput,
  node as headerNode,
} from "./sections/header"
import {
  Field as HistoryField,
  Input as HistoryInput,
  node as historyNode,
} from "./sections/history"
import {
  Field as InstagramField,
  Input as InstagramInput,
  node as instagramNode,
} from "./sections/instagram"
import {
  Field as IntroField,
  Input as IntroInput,
  node as introNode,
} from "./sections/intro"
import {
  Field as MeetingsField,
  Input as MeetingsInput,
  node as meetingsNode,
} from "./sections/meetings"
import {
  Field as NewsField,
  Input as NewsInput,
  node as newsNode,
} from "./sections/news"
import {
  Field as PermitsField,
  Input as PermitsInput,
  node as permitsNode,
} from "./sections/permits"
import {
  Field as PreviewField,
  Input as PreviewInput,
  node as previewNode,
} from "./sections/preview"
import { SaleField, SaleInput, saleNode } from "./sections/properties"
import { SoldField, SoldInput, soldNode } from "./sections/properties"
import {
  Field as SafetyField,
  Input as SafetyInput,
  node as safetyNode,
} from "./sections/safety"
import {
  Field as TweetsField,
  Input as TweetsInput,
  node as twitterNode,
} from "./sections/tweets"
import {
  Field as WeatherField,
  Input as WeatherInput,
  node as weatherNode,
} from "./sections/weather"

export const PREVIEW = "preview"
export const HEADER = "header"
export const INTRO = "intro"
export const WEATHER = "weather"
export const EVENTS = "events"
export const NEWS = "news"
export const SAFETY = "safety"
export const HISTORY = "history"
export const TWEETS = "tweets"
export const FACEBOOK = "facebook"
export const INSTAGRAM = "instagram"
export const PERMITS = "permits"
export const ASK = "ask"
export const ANSWER = "answer"
export const MEETINGS = "meetings"
export const PROPERTIES_SALE = "properties_sale"
export const PROPERTIES_SOLD = "properties_sold"
export const FOOTER = "footer"

export type Kind =
  | "preview"
  | "header"
  | "intro"
  | "weather"
  | "events"
  | "news"
  | "safety"
  | "history"
  | "tweets"
  | "facebook"
  | "instagram"
  | "permits"
  | "ask"
  | "answer"
  | "meetings"
  | "properties_sale"
  | "properties_sold"
  | "footer"

type AnalyticsProps = Omit<AllAnalyticsProps, "title">

function getSectionComponents(kind: Kind) {
  switch (kind) {
    case PREVIEW:
      return { field: PreviewField, input: PreviewInput, node: previewNode }
    case HEADER:
      return { field: HeaderField, input: HeaderInput, node: headerNode }
    case INTRO:
      return { field: IntroField, input: IntroInput, node: introNode }
    case WEATHER:
      return { field: WeatherField, input: WeatherInput, node: weatherNode }
    case EVENTS:
      return { field: EventsField, input: EventsInput, node: eventsNode }
    case NEWS:
      return { field: NewsField, input: NewsInput, node: newsNode }
    case SAFETY:
      return { field: SafetyField, input: SafetyInput, node: safetyNode }
    case HISTORY:
      return { field: HistoryField, input: HistoryInput, node: historyNode }
    case TWEETS:
      return { field: TweetsField, input: TweetsInput, node: twitterNode }
    case FACEBOOK:
      return { field: FacebookField, input: FacebookInput, node: facebookNode }
    case INSTAGRAM:
      return {
        field: InstagramField,
        input: InstagramInput,
        node: instagramNode,
      }
    case PERMITS:
      return { field: PermitsField, input: PermitsInput, node: permitsNode }
    case MEETINGS:
      return { field: MeetingsField, input: MeetingsInput, node: meetingsNode }
    case ANSWER:
      return { field: AnswerField, input: AnswerInput, node: answerNode }
    case ASK:
      return { field: AskField, input: AskInput, node: askNode }
    case PROPERTIES_SALE:
      return { field: SaleField, input: SaleInput, node: saleNode }
    case PROPERTIES_SOLD:
      return { field: SoldField, input: SoldInput, node: soldNode }
    case FOOTER:
      return { field: FooterField, input: FooterInput, node: footerNode }
    default:
      throw new Error("Unsupported section")
  }
}

type URLHash = string
type URL = string
type URLMap = Record<URLHash, URL>

type Config = object
type SetConfig = (config: Config) => void

interface SectionConfig {
  kind: Kind
  config: Config
}
interface BodyConfig {
  sections: SectionConfig[]
}

interface SectionRefMap {
  inputRef: RefObject<any>
  fieldRef: RefObject<any>
}
type SectionRefsMap = Record<string, SectionRefMap>

interface Props {
  record?: ApiRecord
}
interface State {
  sections: SectionConfig[]
  syncing: boolean
  html: string
}
export class EditionBodyInput extends Component<Props, State> {
  subscription: Subscription | null = null
  configs$ = new BehaviorSubject<SectionConfig[]>([])
  html$$ = new Subject<string>()
  htmlRef: PreviewRef = createRef<HTMLDivElement>()
  ampRef: PreviewRef = createRef<HTMLDivElement>()
  sectionObserver: IntersectionObserver | null = null
  sectionRefsMap: SectionRefsMap = {}

  constructor(props: Props) {
    super(props)
    // NOTE: set state from server-side config
    const { record } = this.props
    const bodyConfig: BodyConfig = get(record, "body_data") ?? {}
    const sections: SectionConfig[] = get(bodyConfig, "sections", [])
    const existingSectionKinds = map(sections, "kind")
    const allKinds = [
      PREVIEW,
      HEADER,
      INTRO,
      WEATHER,
      EVENTS,
      NEWS,
      SAFETY,
      HISTORY,
      TWEETS,
      FACEBOOK,
      INSTAGRAM,
      ANSWER,
      ASK,
      PERMITS,
      MEETINGS,
      PROPERTIES_SALE,
      PROPERTIES_SOLD,
      FOOTER,
    ]
    allKinds.forEach((kind) => {
      if (!existingSectionKinds.includes(kind as Kind)) {
        sections.push({ kind: kind as Kind, config: {} })
      }
    })

    this.state = { sections, syncing: false, html: "" }
    // NOTE: sync section visibility
    this.sectionRefsMap = sections.reduce<SectionRefsMap>(
      (prior, current, _idx, _configs): SectionRefsMap => {
        const inputRef = createRef<HTMLElement>()
        const fieldRef = createRef()
        const { kind } = current
        const result: SectionRefsMap = {
          ...prior,
          [kind]: { inputRef, fieldRef },
        }
        return result
      },
      {}
    )
    this.sectionObserver = new IntersectionObserver(
      (entries) => {
        const firstIntersecting = find(
          entries,
          ({ isIntersecting }) => isIntersecting
        )
        // fetch field corresponding to this input
        const target = firstIntersecting?.target
        if (!target) {
          // NOOP
        } else {
          const inputId: string = target.id
          const fieldId = inputId.replace("input", "field")
          const frame = document.getElementById(
            "preview-frame"
          ) as HTMLIFrameElement
          const innerDoc = frame.contentWindow?.document
          const field = innerDoc?.getElementById(fieldId)
          field?.scrollIntoView(true)
        }
      },
      {
        root: null, // viewport by default
        threshold: 0.5,
      }
    )
  }

  componentDidMount() {
    // NOTE: sync section visibility
    values(this.sectionRefsMap).forEach((refMap) => {
      const { inputRef } = refMap
      const node: Element = inputRef.current
      if (node) this.sectionObserver?.observe(node)
    })

    // NOTE: sync sections' config & html with server
    const syncConfigs$ = this.configs$.pipe(
      tag("configs$"),
      skip(1),
      debounceTime(500),
      switchMap((sections) => {
        const body_data = { sections }
        const id = this.props.record?.id
        const data = { body_data }
        const request = dataProvider("UPDATE", "editions", { id, data })
        return from(request)
      }),
      tag("syncConfigs$"),
      share()
    )

    const syncHTML$ = this.configs$.pipe(
      skip(1),
      debounceTime(500),
      tap((_) => {
        this.setState((prior: State) => {
          return {
            ...prior,
            syncing: true,
          }
        })
      }),
      switchMap((sections: SectionConfig[]) => {
        const nodes: Node[] = []
        const typestyle = createTypeStyle()
        const edition: Edition = this.props.record!
        const context = { edition }
        const editionId = get(edition, "id", "") as string
        let sectionRank = 0
        let previewText: string | null = null
        sections.map(({ kind, config }: SectionConfig) => {
          if (kind === PREVIEW) {
            previewText = get(config, "text")
          } else {
            const { node: makeNode } = getSectionComponents(kind)
            if (makeNode) {
              const node = makeNode({
                // @ts-ignore
                config,
                context,
                typestyle,
                analytics: {
                  section: kind,
                  sectionRank, // NOTE: temporary, need evaluate node first
                  edition: editionId,
                },
              })
              if (node) {
                const section = kind
                const analytics: AnalyticsProps = {
                  section,
                  sectionRank,
                  edition: editionId,
                }
                // @ts-ignore
                nodes.push(makeNode({ config, context, typestyle, analytics }))
                sectionRank++ // header == 0, footer coerceed to == -1
              }
            }
          }
        })

        const pad = 24
        const mjNode: Node = mjml([
          mj(
            "mj-head",
            {},
            compact([
              mj("mj-font", {
                href:
                  "https://fonts.googleapis.com/css?family=Roboto|Roboto+Slab&display=swap",
              }),
              mj("mj-attributes", {}, [
                mj("mj-text", { padding: px(0), lineHeight: 1.5 }),
                mj("mj-image", { padding: px(0) }),
                mj("mj-column", { padding: px(0) }),
                mj("mj-section", { padding: px(0) }),
                mj("mj-all", {
                  fontFamily: fonts.roboto,
                  fontSize: px(16) as string,
                }),
              ]),
              mj("mj-style", { inline: true }, typestyle.getStyles()),
              !isEmpty(previewText) &&
                mj(
                  "mj-preview",
                  {},
                  `${previewText} ${`&nbsp;&zwnj;`.repeat(90)}`
                ),
            ])
          ),
          body(
            {
              backgroundColor: colors.white,
              width: "600px",
            },
            nodes
          ),
        ])
        return of(mjNode)
      }),
      switchMap((mjNode: Node) => {
        const url = process.env.MJML_ENDPOINT! as string
        return onErrorResumeNext(
          ajax({
            url,
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: {
              mjml: mjNode,
            },
          })
        )
      }),
      map$((response: AjaxResponse): string => {
        const { html, errors }: MjApiResult = response.response
        return html ?? formatErrorHTML(errors)
      }),
      distinctUntilChanged(),
      tag("html$"),
      tap((html) => {
        this.setState((prior: State) => {
          return {
            ...prior,
            html,
          }
        })
      }),
      switchMap((html) => {
        const id = this.props.record?.id
        const data = { body_html: html }
        const request = dataProvider("UPDATE", "editions", { id, data })
        return onErrorResumeNext(from(request))
      }),
      tap((_) => {
        this.setState((prior: State) => {
          return {
            ...prior,
            syncing: false,
          }
        })
      }),
      share()
    )

    this.subscription = zip(syncConfigs$, syncHTML$).subscribe()
  }

  componentWillUnmount() {
    this.subscription?.unsubscribe()
    this.sectionObserver?.disconnect()
  }

  shouldComponentUpdate() {
    return true
  }

  render() {
    const inputs: SectionInput[] = []
    const fields: SectionField[] = []
    const { sections, syncing, html } = this.state

    sections.forEach((sectionConfig: SectionConfig, idx: number) => {
      const kind = get(sectionConfig, "kind")
      const config = get(sectionConfig, "config")
      // section input
      const setConfig: SetConfig = (config) => {
        const sections = this.state.sections
        sections[idx] = { kind, config }
        this.configs$.next(sections)
        this.setState((prior) => {
          return {
            ...prior,
            sections,
          }
        })
      }

      const { input } = getSectionComponents(kind)
      const { inputRef, fieldRef } = this.sectionRefsMap[kind]
      const key = `section-${kind}`

      inputs.push(
        // @ts-ignore
        h(input, { key, kind, config, setConfig, inputRef, id: `${key}-input` })
      )
    })

    const { htmlRef } = this
    return [h(Editor, { syncing, inputs, fields, html, htmlRef })]
  }
}
