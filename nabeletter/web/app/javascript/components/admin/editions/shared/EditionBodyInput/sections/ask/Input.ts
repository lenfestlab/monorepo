import { h } from "@cycle/react"
import React, { RefObject, useEffect, useState } from "react"

import { translate } from "i18n"
import { Config, SetConfig } from "."
import { MarkdownInput } from "../MarkdownInput"
import { SectionInput } from "../section/SectionInput"

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}

export const Input = ({ config, setConfig, inputRef, id }: Props) => {
  const [prompt, setPrompt] = useState(config.prompt)
  const [title, setTitle] = useState(config.title)
  const [pre, setPre] = useState(config.pre)
  const [post, setPost] = useState(config.post)
  const [post_es, setPost_es] = useState(config.post_es)

  useEffect(() => {
    setConfig({ title, prompt, pre, post })
  }, [title, prompt, pre, post])

  const headerText = translate("ask-input-header")
  const titlePlaceholder = translate("ask-input-title-placeholder")

  const placeholder = translate("ask-input-prompt-placeholder")
  const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setPrompt(event.target.value as string)
  }
  const markdown = prompt ?? ""

  return h(
    SectionInput,
    {
      id,
      inputRef,
      title,
      setTitle,
      pre,
      setPre,
      post,
      setPost,
      post_es,
      setPost_es,
      headerText,
      titlePlaceholder,
    },
    [h(MarkdownInput, { markdown, onChange, placeholder })]
  )
}
