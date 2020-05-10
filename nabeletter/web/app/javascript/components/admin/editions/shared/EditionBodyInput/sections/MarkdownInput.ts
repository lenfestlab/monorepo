import { h } from "@cycle/react"
import { TextField } from "@material-ui/core"
import React from "react"

type ChangeEvent = React.ChangeEvent<HTMLInputElement>

interface Props {
  markdown?: string
  placeholder?: string
  onChange?: (event: ChangeEvent) => void
}

export const MarkdownInput = ({ markdown, placeholder, onChange }: Props) => {
  return h(TextField, {
    value: markdown,
    onChange,
    ...{
      fullWidth: true,
      multiline: true,
      rows: 4,
      variant: "filled",
      placeholder,
      helperText:
        "https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet",
    },
  })
}
