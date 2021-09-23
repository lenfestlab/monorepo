import { h } from "@cycle/react"
import { Box } from "@material-ui/core"
import { useState } from "react"
import { useDebounce } from "react-use"

import { dataProvider } from "components/admin/providers"
import { Edition } from "components/admin/shared"
import { get } from "fp"
import { Form } from "./Form"
import { Preview } from "./Preview"

export type Config = { text: string }
export type SetConfig = (config: Config) => void
export type SetPayload = (payload: string) => void

interface Props {
  record?: Edition
  visibility?: string
}

export const SmsBodyInput = ({ record, visibility }: Props) => {
  console.debug("SmsBodyInput")
  const id = record?.id
  const config: Config = get(record, "sms_data") ?? {}
  const [text, setText] = useState(config.text ?? "")
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
      display: "flex",
      flexDirection: "row",
      justifyContent: "flex-start",
      flexWrap: "nowrap",
      height: "60vh",
      paddingTop: 1,
      visibility
    },
    [
      h(Form, { text, onChange }),
      h(Box, { paddingLeft: 1 }, [h(Preview, { text })]),
    ]
  )
}
