import { h } from "@cycle/react"
import { RefObject } from "react"

import { translate } from "i18n"
import { Config, Input as ImagesInput, SetConfig } from "../images"
import { SectionInputContext } from "../section"

interface Props {
  context: SectionInputContext
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}

export const Input = (props: Props) => {
  const headerText = translate(`stats-input-header`)
  const NABE_NAME = props.context.newsletter?.name ?? "???"
  const titlePlaceholder = translate(`stats-input-title-placeholder`).replace(
    "NABE_NAME",
    NABE_NAME
  )
  const urlPlaceholder = translate(`stats-input-url-placeholder`)
  const captionPlaceholder = translate(`stats-input-caption-placeholder`)
  const markdownPlaceholder = translate(`stats-input-md-placeholder`)
  return h(ImagesInput, {
    ...props,
    urlPlaceholder,
    headerText,
    titlePlaceholder,
    captionPlaceholder,
    markdownPlaceholder,
  })
}
