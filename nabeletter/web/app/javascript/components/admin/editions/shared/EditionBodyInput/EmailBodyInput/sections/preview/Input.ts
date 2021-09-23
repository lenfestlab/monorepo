import { h } from "@cycle/react"
import {
  Card,
  CardContent,
  Grid,
  TextField,
  Typography,
} from "@material-ui/core"
import React, { RefObject, useEffect, useState } from "react"

import { translate } from "i18n"
import { Config, SetConfig } from "."

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}
export const Input = ({ config, setConfig, inputRef, id }: Props) => {
  const [text, setText] = useState(config.text)

  useEffect(() => {
    setConfig({ text })
  }, [text])

  const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setText(event.target.value as string)
  }
  const value = text
  const ref = inputRef
  const placeholder = translate("preview-input-placeholder")
  const fullWidth = true

  return h(Grid, { item: true, ref: inputRef, id }, [
    h(Card, {}, [
      h(CardContent, {}, [
        h(
          Typography,
          { variant: "h5", gutterBottom: true },
          translate("preview-title")
        ),
        h(TextField, {
          id,
          ref,
          value,
          onChange,
          placeholder,
          fullWidth,
          variant: "filled",
        }),
      ]),
    ]),
  ])
}
