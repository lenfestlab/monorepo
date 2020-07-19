import { h } from "@cycle/react"

import { translate } from "i18n"
import { Input as BaseInput, Props as BaseInputProps } from "../Input"

type Props = BaseInputProps

export const Input = (props: Props) => {
  const headerText = translate(`properties_sold-input-header`)
  const titlePlaceholder = translate(`properties_sold-input-title-placeholder`)
  return h(BaseInput, {
    headerText,
    titlePlaceholder,
    ...props,
  })
}
