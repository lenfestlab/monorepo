import { h } from "@cycle/react"
import { ReferenceInput, required, SelectInput } from "react-admin"

interface Props {}
export const NewsletterReferenceInput = (props: Props) =>
  h(
    ReferenceInput,
    {
      ...props,
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
