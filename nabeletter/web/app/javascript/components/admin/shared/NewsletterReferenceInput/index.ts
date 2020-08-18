import { h } from "@cycle/react"
import { ReferenceInput, required, SelectInput } from "react-admin"

export const NewsletterReferenceInput = (props: {}) =>
  h(
    ReferenceInput,
    {
      ...props,
      label: "Newsletter",
      source: "newsletter.id",
      reference: "newsletters",
      allowEmpty: false,
      perPage: 100,
      validate: [required("Newsletter required.")],
      sort: { field: "name", order: "ASC" },
    },
    [
      h(SelectInput, {
        optionText: "name",
      }),
    ]
  )
