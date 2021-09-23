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
  const headerText = translate(`history-input-header`)
  const titlePlaceholder = translate(`history-input-title-placeholder`)
  const urlPlaceholder = translate(`history-input-url-placeholder`)
  const captionPlaceholder = translate(`history-input-caption-placeholder`)
  const markdownPlaceholder = translate(`history-input-md-placeholder`)
  return h(ImagesInput, {
    ...props,
    urlPlaceholder,
    headerText,
    titlePlaceholder,
    captionPlaceholder,
    markdownPlaceholder,
    captionsEnabled: true,
  })
}
