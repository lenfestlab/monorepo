import { h } from "@cycle/react"
import { Box } from "@material-ui/core"
import Autolinker from "autolinker"
import { get, truncate } from "fp"
import { useEffect, useState } from "react"
import { useDebounce } from "react-use"

import { AnalyticsProps as AllAnalyticsProps, rewriteURL, shortenerPrefix } from "analytics"
import { dataProvider } from "components/admin/providers"
import { Channel, Edition, Lang } from "components/admin/shared"
import { TestDeliveryButton } from "../TestDeliveryButton"
import { Form } from "./Form"
import { Preview } from "./Preview"

export type Config = Record<Lang, { text: string }>
export type SetConfig = (config: Config) => void
export type SetPayload = (payload: string) => void

type AnalyticsProps = Omit<AllAnalyticsProps, "section" | "sectionRank" | "title">

interface Props {
  record?: Edition
  visibility: string
  lang: Lang
}

// NOTE: Twilio body max characters: https://bit.ly/3ihwCEx
const TWILIO_MAX_CHARS = 1600

export const SmsBodyInput = ({ record, lang, visibility }: Props) => {
  const channel = Channel.sms
  const id = String(record?.id)
  const config: Config = get(record, `sms_data_${lang}`) ?? {}
  const [text, setText] = useState(get(config, `text`, ""))
  const [body, setBody] = useState(get(record, `sms_body_${lang}`))
  const [textError, setTextError] = useState<string>()

  const edition = record! as Edition
  const neighborhood = edition.newsletter_analytics_name
  const analytics: AnalyticsProps = {
    edition: id,
    neighborhood,
    channel,
    lang,
  }

  useEffect(() => {
    if (body && (body.length >= TWILIO_MAX_CHARS)) {
      setTextError(`${TWILIO_MAX_CHARS} characters max`)
    } else {
      setTextError(undefined)
    }
  }, [body])

  const [_isReady, _cancel] = useDebounce(
    async () => {
      const analyzedText = Autolinker.link(text, {
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
      const data = {
        [`sms_data_${lang}`]: { text },
        [`sms_body_${lang}`]: analyzedText,
      }
      const res = await dataProvider("UPDATE", "editions", { id, data })
      const previewText = get(res, ["data", `sms_body_${lang}`])
      setBody(previewText)
    },
    2000,
    [text]
  )
  const onChange: React.ChangeEventHandler<HTMLInputElement> = (event) => {
    setText(event.target.value)
  }
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
      h(Form, { text, onChange, textError }),
      h(Box, { paddingLeft: 1 }, [
        h(Box, { display: "flex", flexDirection: "row-reverse" }, [
          h(TestDeliveryButton, { record, lang, channel }),
        ]),
        h(Preview, { text: truncate(body, { length: TWILIO_MAX_CHARS }) }),
      ]),
    ]
  )
}
