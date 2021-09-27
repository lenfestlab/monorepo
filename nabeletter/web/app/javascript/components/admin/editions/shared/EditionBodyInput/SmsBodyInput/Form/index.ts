import { h } from "@cycle/react"
import { TextField } from "@material-ui/core"
import { isPresent } from "fp"
import { translate } from "i18n"

interface Props {
  text?: string
  onChange?: React.ChangeEventHandler<HTMLInputElement>
  textError?: string
}

export const Form = ({ text: value, onChange, textError }: Props) => {
  const error = isPresent(textError)
  const label = textError || translate("sms-input-label")
  return h(TextField, {
    value,
    ...{
      onChange,
      color: "secondary",
      label,
      name: "text",
      fullWidth: true,
      multiline: true,
      rows: 35,
      placeholder: translate("sms-input-placeholder"),
      variant: "outlined",
      error,
    },
  })
}
