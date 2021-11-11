import { h } from "@cycle/react"
import {  Button } from "@material-ui/core"
import { DoubleArrow } from "@material-ui/icons"
import { px } from "csx"
import { useState } from "react"

interface TranslateResponseJSON {
  es: string
}

interface Props {
  sourceBody?: string
  onTranslate: (es: string) => void
}

export const TranslateButton = ({ sourceBody, onTranslate }: Props) => {
  const [loading, setLoading] = useState(false)
  return h(Button, {
    onClick: async (_) => {
      setLoading(true)
      const url = process.env.TRANSLATE_ENDPOINT! as string
      const en = sourceBody
      const response = await fetch(url, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ en }),
      })
      const { es }: TranslateResponseJSON = await response.json()
      setLoading(false)
      onTranslate(es)
    },
    variant: "outlined",
    color: "primary",
    endIcon: h(DoubleArrow),
    disabled: loading,
    style: {
      margin: px(10)
    }
  }, "es")
}
