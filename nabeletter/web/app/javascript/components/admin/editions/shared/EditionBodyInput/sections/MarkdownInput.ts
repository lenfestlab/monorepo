import { h } from "@cycle/react"
import { TextField } from "@material-ui/core"
import React from "react"

import { translate } from "i18n"

type ChangeEvent = React.ChangeEvent<HTMLInputElement>

interface Props {
  markdown?: string
  placeholder?: string
  onChange?: (event: ChangeEvent) => void
}

export const MarkdownInput = ({
  markdown,
  placeholder: _placeholder,
  onChange,
}: Props) => {
  const placeholder =
    _placeholder ?? translate("intro-input-markdown-placeholder")
  return h(TextField, {
    value: markdown,
    onChange,
    ...{
      fullWidth: true,
      multiline: true,
      rows: 4,
      variant: "filled",
      placeholder,
    },
  })
}
