import { h } from "@cycle/react"
import { TextField } from "@material-ui/core"
import { translate } from "i18n"

interface Props {
  text?: string
  onChange?: React.ChangeEventHandler<HTMLInputElement>
}

export const Form = ({ text: value, onChange }: Props) => {
  return h(TextField, {
    value,
    ...{
      onChange,
      color: "secondary",
      label: translate("sms-input-label"),
      name: "text",
      fullWidth: true,
      multiline: true,
      rows: 30,
      placeholder: translate("sms-input-placeholder"),
      variant: "outlined",
    },
  })
}
