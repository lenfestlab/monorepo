import { h } from "@cycle/react"
import {
  Card,
  CardContent,
  Grid,
  TextField,
  Typography,
} from "@material-ui/core"
import { translate } from "i18n"
import React, { RefObject, useEffect, useState } from "react"
import { Config, SetConfig } from "."

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}
export const Input = ({ config, setConfig }: Props) => {
  const [subtitle, setSubtitle] = useState(config.subtitle)

  useEffect(() => {
    setConfig({ subtitle })
  }, [subtitle])

  const titlePlaceholder = translate("header-input-subtitle-placeholder")
  const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setSubtitle(event.target.value as string)
  }

  return h(Grid, { item: true }, [
    h(Card, {}, [
      h(CardContent, {}, [
        h(Typography, { variant: "h5", gutterBottom: true }, "Header"),
        h(TextField, {
          value: subtitle,
          onChange,
          ...{
            placeholder: titlePlaceholder,
            fullWidth: true,
            variant: "filled",
          },
        }),
      ]),
    ]),
  ])
}
