import { h } from "@cycle/react"
import { RefObject } from "react"

import { translate } from "i18n"
import { Config, Input as ImagesInput, SetConfig } from "../images"

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}
export const Input = (props: Props) => {
  const headerText = translate(`safety-input-header`)
  const titlePlaceholder = translate(`safety-input-title-placeholder`)
  const urlPlaceholder = translate(`safety-input-url-placeholder`)
  const captionPlaceholder = translate(`safety-input-caption-placeholder`)
  const markdownPlaceholder = translate(`safety-input-md-placeholder`)
  return h(ImagesInput, {
    ...props,
    urlPlaceholder,
    headerText,
    titlePlaceholder,
    captionPlaceholder,
    markdownPlaceholder,
  })
}
