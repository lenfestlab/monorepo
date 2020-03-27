import { h } from "@cycle/react"
import { Create, SimpleForm, TextInput, required, email } from "react-admin"

import { NewsletterReferenceInput } from "../shared/NewsletterReferenceInput"

interface Props {}

export const SubscriptionCreate = (props: Props) =>
  h(Create, { ...props }, [
    h(SimpleForm, { redirect: "list", submitOnEnter: true }, [
      h(NewsletterReferenceInput),
      h(TextInput, {
        source: "email_address",
        fullWidth: true,
        validate: [required("Email address required."), email()],
      }),
      h(TextInput, {
        label: "First name",
        source: "name_first",
        fullWidth: true,
        validate: [required("First name required.")],
      }),
      h(TextInput, {
        label: "Last name",
        source: "name_last",
        fullWidth: true,
        validate: [required("Last name required.")],
      }),
    ]),
  ])
