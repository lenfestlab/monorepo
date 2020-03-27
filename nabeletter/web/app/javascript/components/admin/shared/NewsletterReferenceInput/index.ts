import { h } from "@cycle/react"
import { ReferenceInput, SelectInput, required } from "react-admin"

export const NewsletterReferenceInput = (props: object) =>
  h(
    ReferenceInput,
    {
      label: "Newsletter",
      source: "newsletter.id",
      reference: "newsletters",
      allowEmpty: false,
      validate: [required("Newsletter required.")],
      sort: { field: "name", order: "ASC" },
    },
    [
      h(SelectInput, {
        optionText: "name",
      }),
    ]
  )
