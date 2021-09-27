import { h } from "@cycle/react"
import { Box, FormLabel } from "@material-ui/core"
import { get, truncate } from "fp"
import { useEffect, useState } from "react"
import { useDebounce } from "react-use"

import { dataProvider } from "components/admin/providers"
import { Channel, Edition, Lang } from "components/admin/shared"
import { TestDeliveryButton } from "../TestDeliveryButton"
import { Form } from "./Form"
import { Preview } from "./Preview"

export type Config = { text: string }
export type SetConfig = (config: Config) => void
export type SetPayload = (payload: string) => void

interface Props {
  record?: Edition
  visibility: string
  lang: Lang
}

// NOTE: Twilio body max characters: https://bit.ly/3ihwCEx
const TWILIO_MAX_CHARS = 1600

export const SmsBodyInput = ({ record, lang, visibility }: Props) => {
  const id = record?.id
  const config: Config = get(record, "sms_data") ?? {}
  const [text, setText] = useState(config.text ?? "")
  const [textError, setTextError] = useState<string>()

  useEffect(() => {
    if (text.length >= TWILIO_MAX_CHARS) {
      setTextError(`${TWILIO_MAX_CHARS} characters max`)
    } else {
      setTextError(undefined)
    }
  }, [text])

  const [_isReady, _cancel] = useDebounce(
    async () => {
      const sms_data = { text }
      const data = { sms_data }
      await dataProvider("UPDATE", "editions", { id, data })
    },
    2000,
    [text]
  )
  const onChange: React.ChangeEventHandler<HTMLInputElement> = (event) => {
    const newText = event.target.value
    setText(newText)
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
          h(TestDeliveryButton, { record, lang, channel: Channel.sms })
        ]),
        h(Preview, { text: truncate(text, { length: TWILIO_MAX_CHARS }) }),
      ]),
    ]
  )
}
