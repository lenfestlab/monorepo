import { h } from "@cycle/react"
import React, { RefObject, useEffect, useState } from "react"

import { translate } from "i18n"
import { Config, SetConfig } from "."
import { MarkdownInput } from "../MarkdownInput"
import { SectionInput } from "../SectionInput"

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}
export const Input = ({ config, setConfig, inputRef, id }: Props) => {
  const [markdown, setMarkdown] = useState(config.markdown)
  const [title, setTitle] = useState(config.title)

  useEffect(() => {
    setConfig({ title, markdown })
  }, [title, markdown])

  const headerText = translate("weather-input-header")
  const titlePlaceholder = translate("weather-input-title-placeholder")
  const placeholder = translate("weather-input-markdown-placeholder")
  const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setMarkdown(event.target.value as string)
  }

  return h(
    SectionInput,
    {
      id,
      inputRef,
      title,
      setTitle,
      headerText,
      titlePlaceholder,
    },
    [h(MarkdownInput, { markdown, onChange, placeholder })]
  )
}
