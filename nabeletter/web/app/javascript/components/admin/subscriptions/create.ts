import { h } from "@cycle/react"
import {
  AutocompleteInput,
  Create,
  email,
  required,
  SimpleForm,
  TextInput,
} from "react-admin"

import { NewsletterReferenceInput } from "../shared/NewsletterReferenceInput"

interface Props {}

export const SubscriptionCreate = (props: Props) =>
  h(Create, { ...props }, [
    h(SimpleForm, { redirect: "list", submitOnEnter: true }, [
      h(NewsletterReferenceInput),
      h(AutocompleteInput, {
        alwaysOn: true,
        choices: [
          { id: 0, name: "email" },
          { id: 1, name: "sms" },
        ],
        source: "channel",
        validate: [required("Channel required.")],
      }),
      h(TextInput, {
        source: "phone",
        type: "tel",
        fullWidth: true,
      }),
      h(TextInput, {
        source: "email_address",
        type: "email",
        fullWidth: true,
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
