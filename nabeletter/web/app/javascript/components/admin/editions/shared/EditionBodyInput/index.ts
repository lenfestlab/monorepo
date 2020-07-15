import { h } from "@cycle/react"
import { dataProvider } from "components/admin/providers"
import { body, mj, mjml, Node } from "mj"
import { Component, createRef, RefObject } from "react"
import { BehaviorSubject, from, Subject, Subscription, zip } from "rxjs"
import { tag } from "rxjs-spy/operators"
import {
  debounceTime,
  distinctUntilChanged,
  share,
  skip,
  switchMap,
  tap,
} from "rxjs/operators"
import { colors, fonts } from "styles"

import { AnalyticsProps as AllAnalyticsProps } from "analytics"
import { Record as ApiRecord } from "components/admin/shared"
import { compact, find, get, isEmpty, map, values } from "fp"
import { Editor } from "./Editor"
import { PreviewRef, SectionField, SectionInput } from "./types"

import { px } from "csx"
import { createTypeStyle } from "typestyle"
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
      PERMITS,
      MEETINGS,
      PROPERTIES_SALE,
      PROPERTIES_SOLD,
      ASK,
      ANSWER,
      FOOTER,
    ]
    allKinds.forEach((kind) => {
      if (!existingSectionKinds.includes(kind as Kind)) {
        sections.push({ kind: kind as Kind, config: {} })
      }
    })

    this.state = { sections, syncing: false }
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
      tap((_) => {
        this.setState((prior: State) => {
          return {
            ...prior,
            syncing: true,
          }
        })
      }),
      debounceTime(500),
      switchMap((sections) => {
        const body_data = { sections }
        const id = this.props.record?.id
        const data = { body_data }
        const request = dataProvider("UPDATE", "editions", { id, data })
        return from(request)
      }),
      tap((_) => {
        this.setState((prior: State) => {
          return {
            ...prior,
            syncing: false,
          }
        })
      }),
      tag("syncConfigs$"),
      share()
    )

    // NOTE: sync sections' config & html with server
    const syncHTML$ = this.html$$.pipe(
      debounceTime(500),
      distinctUntilChanged(),
      switchMap((html) => {
        const id = this.props.record?.id
        const data = { body_html: html }
        const request = dataProvider("UPDATE", "editions", { id, data })
        return from(request)
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
    const nodes: Node[] = []
    const edition = get(this.props.record, "id", "") as string
    const { sections, syncing } = this.state
    let previewText: string | null = null
    const typestyle = createTypeStyle()
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
      const { input, field, node: makeNode } = getSectionComponents(kind)
      const { inputRef, fieldRef } = this.sectionRefsMap[kind]
      const key = `section-${kind}`

      const section = kind
      const sectionRank = idx + 1
      const analytics: AnalyticsProps = {
        section,
        sectionRank, // TODO: verify sectionRank
        edition,
      }

      inputs.push(
        // @ts-ignore
        h(input, { key, kind, config, setConfig, inputRef, id: `${key}-input` })
      )

      // fields.push(
      //   // @ts-ignore
      //   h(field, {
      //     key,
      //     kind,
      //     config,
      //     id: `${key}-field`,
      //     analytics,
      //   })
      // )

      if (kind === PREVIEW) {
        previewText = get(config, "text")
      } else {
        if (makeNode) {
          // @ts-ignore
          const node = makeNode({ analytics, config, typestyle })
          if (node) nodes.push(node)
        }
      }
    })

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
            mj("mj-text", {
              paddingTop: px(0),
              paddingBottom: px(0),
              lineHeight: 1.5,
            }),
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
            mj("mj-preview", {}, `${previewText} ${`&nbsp;&zwnj;`.repeat(90)}`),
        ])
      ),
      body(
        {
          backgroundColor: colors.veryLightGray,
          width: "600px",
        },
        nodes
      ),
    ])

    const { htmlRef, ampRef } = this
    const html$$ = this.html$$
    return [
      h(Editor, { syncing, inputs, fields, htmlRef, ampRef, mjNode, html$$ }),
    ]
  }
}
