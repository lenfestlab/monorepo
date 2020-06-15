import { h } from "@cycle/react"
import { dataProvider } from "components/admin/providers"
import { Component, createRef, RefObject } from "react"
import { BehaviorSubject, from, Subscription, zip } from "rxjs"
import { tag } from "rxjs-spy/operators"
import { debounceTime, share, skip, switchMap } from "rxjs/operators"

import { AnalyticsProps as AllAnalyticsProps } from "analytics"
import { Record as ApiRecord } from "components/admin/shared"
import { find, get, isEmpty, values } from "fp"

import { Editor } from "./Editor"
import { Field as EventsField, Input as EventsInput } from "./sections/events"
import {
  Field as FacebookField,
  Input as FacebookInput,
} from "./sections/facebook"
import {
  Field as InstagramField,
  Input as InstagramInput,
} from "./sections/facebook"
import {
  Field as HistoryField,
  Input as HistoryInput,
} from "./sections/history"
import { Field as IntroField, Input as IntroInput } from "./sections/intro"
import { Field as NewsField, Input as NewsInput } from "./sections/news"
import { Field as SafetyField, Input as SafetyInput } from "./sections/safety"
import { Field as TweetsField, Input as TweetsInput } from "./sections/tweets"
import {
  Field as WeatherField,
  Input as WeatherInput,
} from "./sections/weather"
import { PreviewRef, SectionField, SectionInput } from "./types"

export const INTRO = "intro"
export const WEATHER = "weather"
export const EVENTS = "events"
export const NEWS = "news"
export const SAFETY = "safety"
export const HISTORY = "history"
export const TWEETS = "tweets"
export const FACEBOOK = "facebook"
export const INSTAGRAM = "instagram"
export const FOOTER = "footer"

export type Kind =
  | "header"
  | "intro"
  | "weather"
  | "events"
  | "news"
  | "safety"
  | "history"
  | "tweets"
  | "instagram"
  | "facebook"
  | "footer"

type AnalyticsProps = Omit<AllAnalyticsProps, "title">

function getSectionComponents(kind: Kind) {
  switch (kind) {
    case INTRO:
      return { field: IntroField, input: IntroInput }
    case WEATHER:
      return { field: WeatherField, input: WeatherInput }
    case EVENTS:
      return { field: EventsField, input: EventsInput }
    case NEWS:
      return { field: NewsField, input: NewsInput }
    case SAFETY:
      return { field: SafetyField, input: SafetyInput }
    case HISTORY:
      return { field: HistoryField, input: HistoryInput }
    case TWEETS:
      return { field: TweetsField, input: TweetsInput }
    case FACEBOOK:
      return { field: FacebookField, input: FacebookInput }
    case INSTAGRAM:
      return { field: InstagramField, input: InstagramInput }
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
}
export class EditionBodyInput extends Component<Props, State> {
  subscription: Subscription | null = null
  configs$ = new BehaviorSubject<SectionConfig[]>([])
  previewRef: PreviewRef = createRef<HTMLDivElement>()
  sectionObserver: IntersectionObserver | null = null
  sectionRefsMap: SectionRefsMap = {}

  constructor(props: Props) {
    super(props)
    // NOTE: set state from server-side config
    const { record } = this.props
    let bodyConfig: BodyConfig = get(record, "body_data")
    if (isEmpty(bodyConfig)) {
      bodyConfig = {
        sections: [
          { kind: INTRO, config: {} },
          { kind: WEATHER, config: {} },
          { kind: EVENTS, config: {} },
          { kind: NEWS, config: {} },
          { kind: SAFETY, config: {} },
          { kind: HISTORY, config: {} },
          { kind: TWEETS, config: {} },
          { kind: FACEBOOK, config: {} },
          { kind: INSTAGRAM, config: {} },
        ],
      }
    }
    const sections: SectionConfig[] = get(bodyConfig, "sections", [])
    this.state = { sections }
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
      skip(1),
      debounceTime(1000),
      tag("configs$"),
      switchMap((sections) => {
        const node = this.previewRef.current
        const body_html = node?.innerHTML
        const body_data = { sections }
        const id = this.props.record?.id
        const data = { body_data, body_html }
        const request = dataProvider("UPDATE", "editions", { id, data })
        return from(request)
      }),
      tag("syncConfigs$"),
      share()
    )

    this.subscription = zip(syncConfigs$).subscribe()
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
    const edition = get(this.props.record, "id", "") as string
    const { sections } = this.state
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
      const { input, field } = getSectionComponents(kind)
      const { inputRef, fieldRef } = this.sectionRefsMap[kind]
      const key = `section-${kind}`

      const section = kind
      const sectionRank = idx + 1
      const fieldAnalytics: AnalyticsProps = {
        section,
        sectionRank,
        edition,
      }
      inputs.push(
        // @ts-ignore
        h(input, { key, kind, config, setConfig, inputRef, id: `${key}-input` })
      )
      fields.push(
        // @ts-ignore
        h(field, {
          key,
          kind,
          config,
          id: `${key}-field`,
          analytics: fieldAnalytics,
        })
      )
    })
    const previewRef = this.previewRef
    const analytics = { edition }
    return h(Editor, { inputs, fields, previewRef, analytics })
  }
}
