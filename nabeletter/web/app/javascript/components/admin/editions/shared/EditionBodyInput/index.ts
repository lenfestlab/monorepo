import { h } from "@cycle/react"
import { dataProvider } from "components/admin/providers"
import {
  Edition,
  Newsletter,
  NewsletterReferenceField,
} from "components/admin/shared"
import {
  all,
  attributes,
  body,
  column,
  font,
  head,
  image,
  mjml,
  Node,
  preview,
  section,
  style,
  text,
  wrapper,
} from "mjml-json"
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
import { colors, fonts } from "styles"

import { AnalyticsProps as AllAnalyticsProps } from "analytics"
import { Record as ApiRecord } from "components/admin/shared"
import { compact, get, isEmpty, map } from "fp"
import { Editor } from "./Editor"
import { PreviewRef, SectionInput } from "./types"

import { px } from "csx"
import { createTypeStyle } from "typestyle"
import { Input as AnswerInput, node as answerNode } from "./sections/answer"
import { Input as AskInput, node as askNode } from "./sections/ask"
import { Input as EventsInput, node as eventsNode } from "./sections/events"
import {
  Input as FacebookInput,
  node as facebookNode,
} from "./sections/facebook"
import { Input as FooterInput, node as footerNode } from "./sections/footer"
import { Input as HeaderInput, node as headerNode } from "./sections/header"
import { Input as HistoryInput, node as historyNode } from "./sections/history"
import {
  Input as InstagramInput,
  node as instagramNode,
} from "./sections/instagram"
import { Input as IntroInput, node as introNode } from "./sections/intro"
import {
  Input as MeetingsInput,
  node as meetingsNode,
} from "./sections/meetings"
import { Input as NewsInput, node as newsNode } from "./sections/news"
import { Input as PermitsInput, node as permitsNode } from "./sections/permits"
import { Input as PreviewInput, node as previewNode } from "./sections/preview"
import { SaleInput, saleNode } from "./sections/properties"
import { SoldInput, soldNode } from "./sections/properties"
import { Input as SafetyInput, node as safetyNode } from "./sections/safety"
import { SectionInputContext } from "./sections/section"
import { Input as StatsInput, node as statsNode } from "./sections/stats"
import { Input as TweetsInput, node as twitterNode } from "./sections/tweets"
import { Input as WeatherInput, node as weatherNode } from "./sections/weather"

export const PREVIEW = "preview"
export const HEADER = "header"
export const INTRO = "intro"
export const WEATHER = "weather"
export const EVENTS = "events"
export const NEWS = "news"
export const STATS = "stats"
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
  | "stats"
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
      return { input: PreviewInput, node: previewNode }
    case HEADER:
      return { input: HeaderInput, node: headerNode }
    case INTRO:
      return { input: IntroInput, node: introNode }
    case WEATHER:
      return { input: WeatherInput, node: weatherNode }
    case EVENTS:
      return { input: EventsInput, node: eventsNode }
    case NEWS:
      return { input: NewsInput, node: newsNode }
    case STATS:
      return { input: StatsInput, node: statsNode }
    case SAFETY:
      return { input: SafetyInput, node: safetyNode }
    case HISTORY:
      return { input: HistoryInput, node: historyNode }
    case TWEETS:
      return { input: TweetsInput, node: twitterNode }
    case FACEBOOK:
      return { input: FacebookInput, node: facebookNode }
    case INSTAGRAM:
      return { input: InstagramInput, node: instagramNode }
    case PERMITS:
      return { input: PermitsInput, node: permitsNode }
    case MEETINGS:
      return { input: MeetingsInput, node: meetingsNode }
    case ANSWER:
      return { input: AnswerInput, node: answerNode }
    case ASK:
      return { input: AskInput, node: askNode }
    case PROPERTIES_SALE:
      return { input: SaleInput, node: saleNode }
    case PROPERTIES_SOLD:
      return { input: SoldInput, node: soldNode }
    case FOOTER:
      return { input: FooterInput, node: footerNode }
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

interface Props {
  record?: Edition
}
interface State {
  sections: SectionConfig[]
  syncing: boolean
  html: string
  htmlSizeError: string | null
}
export class EditionBodyInput extends Component<Props, State> {
  subscription: Subscription | null = null
  configs$ = new BehaviorSubject<SectionConfig[]>([])
  html$$ = new Subject<string>()
  htmlRef: PreviewRef = createRef<HTMLDivElement>()
  ampRef: PreviewRef = createRef<HTMLDivElement>()

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
      STATS,
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

    this.state = { sections, syncing: false, html: "", htmlSizeError: null }
  }

  componentDidMount() {
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
        const edition = this.props.record! as Edition
        const edition_id = edition.id
        const welcomeEditionId = process.env.WELCOME_EDITION_ID!
        const isWelcome = welcomeEditionId === edition_id
        const context = { edition, isWelcome }
        const neighborhood = edition.newsletter_analytics_name
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
                  neighborhood,
                  edition: editionId,
                },
              })
              if (node) {
                const section = kind
                const analytics: AnalyticsProps = {
                  section,
                  sectionRank,
                  neighborhood,
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
          head(
            compact([
              font({
                href:
                  "https://fonts.googleapis.com/css?family=Roboto|Roboto+Slab&display=swap",
              }),
              attributes([
                text({ padding: px(0), lineHeight: 1.5 }),
                image({ padding: px(0) }),
                column({ padding: px(0) }),
                section({ padding: px(0) }),
                wrapper({ padding: px(0) }),
                all({
                  fontFamily: fonts.roboto,
                  fontSize: px(16) as string,
                }),
              ]),
              style({ inline: true }, typestyle.getStyles()),
              !isEmpty(previewText) &&
                preview({}, `${previewText} ${`&nbsp;&zwnj;`.repeat(90)}`),
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
        const {
          html,
          errors,
        }: {
          html: string
          errors: JSON
        } = response.response
        return (
          html ??
          `<pre style="color: red">${JSON.stringify(errors, null, 2)}</pre>`
        )
      }),
      distinctUntilChanged(),
      // tag("html$"),
      tap((html) => {
        const kb = new Blob([html]).size / 1000
        // NOTE: warn if size Gmail's clip threshold. https://bit.ly/30q9ZFv
        const htmlSizeError =
          kb >= 102
            ? "Warning: size exceeds 102KB; clients may truncate."
            : null
        this.setState((prior: State) => {
          return {
            ...prior,
            html,
            htmlSizeError,
          }
        })
      }),
      switchMap((html) => {
        const id = this.props.record?.id
        const data = { body_html: html }
        const request = dataProvider("UPDATE", "editions", { id, data })
        return onErrorResumeNext(from(request))
      }),
      tap(() => {
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
  }

  shouldComponentUpdate() {
    return true
  }

  render() {
    const inputs: SectionInput[] = []
    const { sections, syncing, html, htmlSizeError } = this.state

    // TODO: embed JSONAPI edition.newsletter
    const edition: Edition | undefined = this.props.record
    const id = get(edition, ["newsletter", "id"]) || ""
    const name = edition?.newsletter_name || ""
    const lat = edition?.newsletter_lat || ""
    const lng = edition?.newsletter_lng || ""
    const source_urls = edition?.newsletter_source_urls || ""
    const newsletter = {
      id,
      name,
      lat,
      lng,
      source_urls,
    }
    const context: SectionInputContext = {
      newsletter,
    }

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
      const key = `section-${kind}`

      inputs.push(
        // @ts-ignore
        h(input, { key, kind, config, setConfig, id: `${key}-input`, context })
      )
    })

    const { htmlRef } = this
    return [h(Editor, { syncing, inputs, html, htmlRef, htmlSizeError })]
  }
}
