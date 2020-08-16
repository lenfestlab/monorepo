import { h } from "@cycle/react"
import { ReferenceField, TextField } from "react-admin"

export const NewsletterReferenceField = (props: {}) =>
  h(
    ReferenceField,
    {
      ...props,
      label: "Newsletter",
      source: "newsletter.id",
      reference: "newsletters",
    },
    [h(TextField, { source: "name" })]
  )
