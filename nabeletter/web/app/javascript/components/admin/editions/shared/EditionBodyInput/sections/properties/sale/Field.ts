import { h } from "@cycle/react"

import { translate } from "i18n"
import { Field as BaseField, Props as BaseFieldProps } from "../Field"

type Props = BaseFieldProps

export const Field = (props: Props) => {
  const titlePlaceholder = translate("properties_sale-input-title-placeholder")
  return h(BaseField, { titlePlaceholder, ...props })
}
