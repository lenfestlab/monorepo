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
  const [markdown, setMarkdown] = useState(config.markdown)
  const [title, setTitle] = useState(config.title)
  const [pre, setPre] = useState(config.pre)
  const [post, setPost] = useState(config.post)
  const [post_es, setPost_es] = useState(config.post_es)
  const [ad, setAd] = useState(config.ad)

  useEffect(() => {
    setConfig({ title, markdown, pre, post, post_es, ad })
  }, [title, markdown, pre, post, post_es, ad])

  const headerText = translate("intro-input-header")
  const titlePlaceholder = translate("intro-input-title-placeholder")
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
      pre,
      setPre,
      post,
      setPost,
      post_es,
      setPost_es,
      headerText,
      titlePlaceholder,
      ad,
      setAd,
    },
    [h(MarkdownInput, { markdown, onChange })]
  )
}
