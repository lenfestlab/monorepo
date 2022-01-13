import { h } from "@cycle/react"
import { Box, Button, TextField } from "@material-ui/core"
import { SaveAlt } from "@material-ui/icons"
import Autolinker from "autolinker"
import { get, truncate } from "fp"
import { createRef, useState} from "react"
import { useEffectOnce, useObservable } from "react-use"
import { BehaviorSubject, Observable, Subscription } from "rxjs"
import { tag } from "rxjs-spy/operators"
import { debounceTime, map, share, startWith, tap } from "rxjs/operators"

import { span } from "@cycle/react-dom"
import { AnalyticsProps as AllAnalyticsProps, rewriteURL, shortenerPrefix } from "analytics"
import { dataProvider } from "components/admin/providers"
import { Channel, Edition, Lang } from "components/admin/shared"
import { percent, px } from "csx"
import { colors } from "styles"
import { TestDeliveryButton } from "../TestDeliveryButton"
import { Preview } from "./Preview"
import { TranslateButton } from "./TranslateButton";

type AnalyticsProps = Omit<AllAnalyticsProps, "section" | "sectionRank" | "title">

export interface Section {
  kind: string
  origin: string | null
  translation: string | null
}

export interface Config {
  sections: Section[]
}

// NOTE: Twilio body max characters: https://bit.ly/3ihwCEx
const TWILIO_MAX_CHARS = 1600

// @ts-ignore
const sections$$: BehaviorSubject<Section[]> = new BehaviorSubject([])
const sections$: Observable<Section[]> = sections$$.asObservable().pipe(
  tag("sections$"),
  share()
)

const setSectionOrigin = (kind: string, body: string) => {
  const sections = sections$$.value
  const section = sections.find(section => section.kind === kind)
  if (section) section.origin = body
  sections$$.next(sections)
}

const setSectionTranslation = (kind: string, body: string) => {
  const sections = sections$$.value
  const section = sections.find(section => section.kind === kind)
  if (section) section.translation = body
  sections$$.next(sections)
}

interface Props {
  record?: Edition
  visibility: string
  lang: Lang
}
export const SmsBodyInput = ({ record, lang, visibility }: Props) => {
  const channel = Channel.sms
  const id = String(record?.id)
  const config: Config = get(record, `sms_data_${lang}`) ?? {}
  const translatedSections = get(config, `sections`)
  const emailSections = parseEmailHtml(get(record, `email_html_en_preprocessed`) ?? "")
  emailSections.unshift({ kind: "pre", origin: null, translation: null })
  emailSections.push({ kind: "post", origin: null, translation: null })
  const cleanedEmailSections: Section[] = emailSections.map(section => {
    return { ...section, origin: null, translation: null }
  })
  const initialSections = translatedSections ?? cleanedEmailSections
  useEffectOnce(() => sections$$.next(initialSections))

  const edition = record! as Edition
  const neighborhood = edition.newsletter_analytics_name
  const analytics: AnalyticsProps = {
    edition: id,
    neighborhood,
    channel,
    lang,
  }

  const [sections, setSections] = useState<Section[]>([])
  const [body, setBody] = useState(get(record, `sms_body_${lang}`) ?? "")

  useEffectOnce(() => {
    const subscription: Subscription = sections$.pipe(
      tap(s => setSections([...s])),
      debounceTime(500),
      tag("debounced$"),
      map(async sections => {
        const mergedSectionBodies = sections.reduce((prev, section, idx) => {
          const rawText = section.translation ?? ""
          const analyzedText = analyze(rawText, {
            ...analytics,
            section: section.kind,
            sectionRank: idx,
          })
          return `${prev}\n\n ${analyzedText}`.trim()
        }, "")
        const data = {
          [`sms_data_${lang}`]: { sections },
          [`sms_body_${lang}`]: mergedSectionBodies,
        }
        const res = await dataProvider("UPDATE", "editions", { id, data })
        const shortenedBody = get(res, ["data", `sms_body_${lang}`])
        setBody(shortenedBody)
        return shortenedBody
      }),
      tag("processed body$"),
      startWith(get(record, `sms_body_${lang}`)),
    ).subscribe()
    return () => subscription.unsubscribe()
  })

  const originRefs = sections$$.value.map(i=> createRef<HTMLTextAreaElement>())
  const translationRefs = sections$$.value.map(i=> createRef<HTMLTextAreaElement>())
  return h(
    Box,
    {
      display: visibility === "hidden" ? "none" : "flex",
      flexDirection: "row",
      justifyContent: "flex-start",
      flexWrap: "nowrap",
      height: "60vh",
      paddingTop: 1,
    },
    [
      h(Box, {
        width: percent(100),
        display: "flex",
        flexDirection: "column",
        overflow: "scroll"
      }, [
        sections?.map(({ kind, origin, translation }, idx) => {
          const emailSection = emailSections.find(section => section.kind === kind)
          const emailOrigin = emailSection?.origin ?? ""

          return h(Box, { display: "flex", flexDirection: "column", alignItems: "left", paddingTop: 4 }, [
            h(Box, { display: "flex", flexDirection: "row", }, [
              h(Button, {
                onClick: (_) => {
                  const ref: React.Ref<HTMLTextAreaElement> = originRefs[idx]
                  const textarea = ref.current
                  if (textarea) textarea.value = emailOrigin
                  setSectionOrigin(kind, emailOrigin)
                },
                variant: "outlined",
                color: "primary",
                endIcon: (kind === "pre") || (kind === "post") || h(SaveAlt),
                style: {
                  margin: px(10),
                  marginLeft: px(0)
                }
              }, kind),
            ]),

            h(Box, {
              key: kind,
              width: percent(100),
              display: "flex",
              flexDirection: "row-reverse",
              alignItems: "flex-start",
              justifyContent: "space-between",
            }, [

              h(TextField, {
                key: `translation-${kind}`,
                defaultValue: translation,
                inputRef: translationRefs[idx],
                ...{
                  onChange: (event) => {
                    const value = event.target.value
                    setSectionTranslation(kind, value)
                  },
                  color: "secondary",
                  name: "text",
                  multiline: true,
                  rows: Math.round((origin?.length ?? 30) / 29),
                  variant: "outlined",
                  label: null,
                  placeholder: kind,
                },
                style: { flexGrow: 1 },
              }),

              h(TranslateButton, {
                sourceBody: origin ?? "",
                onTranslate: (es) => {
                  const ref: React.Ref<HTMLTextAreaElement> = translationRefs[idx]
                  const textarea = ref.current
                  if (textarea) textarea.value = es
                  setSectionTranslation(kind, es)
                }
              }),

              h(TextField, {
                key: `origin-${kind}`,
                defaultValue: origin,
                inputRef: originRefs[idx],
                ...{
                  onChange: (event) => {
                    const value = event.target.value
                    setSectionOrigin(kind, value)
                  },
                  color: "secondary",
                  name: "text",
                  multiline: true,
                  rows: Math.round((origin?.length ?? 30) / 29),
                  variant: "outlined",
                  label: null,
                  placeholder: kind,
                },
                style: { flexGrow: 1 },
              }),

            ])
          ])
        })
      ]),

      h(Box, { paddingLeft: 1 }, [
        h(Box, { display: "flex", flexDirection: "row-reverse" }, [
          h(TestDeliveryButton, { record, lang, channel }),
        ]),
        h(Box, { display: "flex", flexDirection: "row-reverse" }, [
          span({
            style: {
              paddingLeft: px(40),
              fontSize: px(12),
              color: (body.length > TWILIO_MAX_CHARS) ? "red" : colors.lightGray,
            }
          }, `${body.length} of max ${TWILIO_MAX_CHARS} chars`),
        ]),
        h(Preview, { text: truncate(body, { length: TWILIO_MAX_CHARS }) }),
      ]),
    ]
  )
}


function analyze(body: string, analytics: AllAnalyticsProps): string {
  return Autolinker.link(body, {
    urls: true,
    phone: false,
    replaceFn: match => {
      const href = match.getAnchorHref()
      if (href.includes(shortenerPrefix)) return false
      switch(match.getType()) {
        case 'url': return rewriteURL(href, analytics)
        default: return false
      }
    }
  })
}

function parseEmailHtml(html: string): Section[] {
  const parser = new DOMParser()
  const doc = parser.parseFromString(html, "text/html")
  doc.querySelectorAll(".section-title").forEach(titleNode => titleNode.remove())
  const sections: Section[] = []
  doc.querySelectorAll("[class^='section-']").forEach(sectionNode => {
    const [_, sectionName] = sectionNode.className.split("-")
    // preserve links
    sectionNode.querySelectorAll("a").forEach((link) => {
      const { href, innerText } = link
      const queryString = href.split('?')[1]
      const params = new URLSearchParams(queryString)
      // NOTE: extract pre-shortened analytics urls, parse redirect param
      const redirect = params.get("redirect")
      link.innerHTML = `\n ${innerText} ${redirect} \n`
    })
    // add breaks for improved spacing
    sectionNode.querySelectorAll("tr").forEach((row) =>
     row.appendChild(doc.createElement("br")))
    const text = (sectionNode.textContent ?? "\n").trim().replace(/\n{2,}/g, '\n\n')
    sections.push({ kind: sectionName, origin: text, translation: null  })
  })
  return sections
}
