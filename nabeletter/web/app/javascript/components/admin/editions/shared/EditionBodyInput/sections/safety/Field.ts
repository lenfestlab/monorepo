import { h } from "@cycle/react"
import { FunctionComponent } from "react"

import { translate } from "i18n"
import { Config, Field as ImagesField } from "../images"
import { SectionFieldProps } from "../section/SectionField"

export interface Props extends SectionFieldProps {
  config: Config
}
export const Field: FunctionComponent<Props> = (props) => {
  const titlePlaceholder = translate("safety-input-title-placeholder")
  return h(ImagesField, { ...props, titlePlaceholder })
}
