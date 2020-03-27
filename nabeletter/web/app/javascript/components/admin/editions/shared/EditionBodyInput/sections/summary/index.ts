import { h } from "@cycle/react"
import { TextFieldProps } from "@material-ui/core"
import TextField from "@material-ui/core/TextField"
import React, { useState } from "react"
import ReactMarkdown from "react-markdown"

interface Config {
  markdown: string
}
type SetConfig = (config: Config) => void

export interface FieldProps {
  config: Config
}
export const Field = ({ config }: FieldProps) => {
  const source = config?.markdown || ""
  return h(ReactMarkdown, { source, escapeHtml: false })
}

interface InputProps {
  config: Config
  setConfig: SetConfig
}
export const Input = ({ config, setConfig }: InputProps) => {
  const [markdown, setMarkdown] = useState(config.markdown)
  const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const md = event.target.value as string
    setMarkdown(md)
    setConfig({ markdown: md })
  }
  const styleProps: TextFieldProps = {
    fullWidth: true,
    multiline: true,
    rows: 4,
    variant: "filled",
    label: "Headlines",
    placeholder: markdownPlaceholder(),
    helperText:
      "https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet",
  }
  return h(TextField, { value: markdown, onChange, ...styleProps })
}

function markdownPlaceholder() {
  return `# H1
## H2
### H3
#### H4
##### H5
###### H6

Emphasis, aka italics, with *asterisks* or _underscores_.

Strong emphasis, aka bold, with **asterisks** or __underscores__.

Combined emphasis with **asterisks and _underscores_**.

Strikethrough uses two tildes. ~~Scratch this.~~
`
}
