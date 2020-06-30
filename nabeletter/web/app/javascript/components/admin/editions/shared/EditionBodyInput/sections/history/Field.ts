import { h } from "@cycle/react"
import { FunctionComponent } from "react"
import { TypeStyle } from "typestyle"

import { translate } from "i18n"
import { Config, Field as ImagesField } from "../images"
import { AnalyticsProps } from "../MarkdownField"

export interface Props {
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: AnalyticsProps
  isAmp?: boolean
}
export const Field: FunctionComponent<Props> = (props) => {
  const titlePlaceholder = translate("history-input-title-placeholder")
  return h(ImagesField, { ...props, titlePlaceholder })
}
