import { h } from "@cycle/react"
import { required, TextInput } from "react-admin"

interface Props {}
export const EditionSubjectInput = (props: Props) =>
  h(TextInput, {
    ...props,
    label: "Subject",
    source: "subject",
    fullWidth: true,
    validate: [required("Subject required for email.")],
  })
