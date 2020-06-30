import { h } from "@cycle/react"
import { dataProvider } from "components/admin/providers"
import { Component, createRef, RefObject } from "react"
import { BehaviorSubject, from, Subscription, zip } from "rxjs"
import { tag } from "rxjs-spy/operators"
import {
  debounceTime,
  distinctUntilChanged,
  share,
  shareReplay,
  skip,
  switchMap,
  tap,
} from "rxjs/operators"

import { AnalyticsProps as AllAnalyticsProps } from "analytics"
import { Record as ApiRecord } from "components/admin/shared"
import { find, get, map, values } from "fp"

import { Editor } from "./Editor"
import { Field as AnswerField, Input as AnswerInput } from "./sections/answer"
import { Field as AskField, Input as AskInput } from "./sections/ask"
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
import {
  Field as PermitsField,
  Input as PermitsInput,
} from "./sections/permits"
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
export const PERMITS = "permits"
export const ASK = "ask"
export const ANSWER = "answer"
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
  | "facebook"
  | "instagram"
  | "permits"
  | "ask"
  | "answer"
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
    case PERMITS:
      return { field: PermitsField, input: PermitsInput }
    case ANSWER:
      return { field: AnswerField, input: AnswerInput }
    case ASK:
      return { field: AskField, input: AskInput }
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
      ASK,
      ANSWER,
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
      tag("configs$"),
      switchMap((sections) => {
        const body_html = this.htmlRef?.current?.innerHTML
        let body_amp = this.ampRef?.current?.innerHTML
        // NOTE: amp markup unsupported by React
        if (body_amp) {
          body_amp = body_amp
            .replace("<html>", "<html amp4email>")
            .replace("FIX_VISIBILITY", "hidden")
            .replace(/\=\"true\"/g, "") // drop react cruft
          body_amp = `<!doctype html>${body_amp}`
        }
        const body_data = { sections }
        const id = this.props.record?.id
        const data = { body_data, body_html } // TODO: restore body_amp
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
    const { sections, syncing } = this.state
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
    const { htmlRef, ampRef } = this
    const analytics = { edition }
    return [h(Editor, { syncing, inputs, fields, htmlRef, ampRef, analytics })]
  }
}
