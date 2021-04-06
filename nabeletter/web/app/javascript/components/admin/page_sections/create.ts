import { h } from "@cycle/react"
import { ReferenceInput, required, SelectInput, TextInput } from "react-admin"
import { Create as _Create, SimpleForm } from "react-admin"

const PageReferenceInput = (props: {}) =>
  h(
    ReferenceInput,
    {
      ...props,
      label: "Page",
      source: "page.id",
      reference: "pages",
      allowEmpty: false,
      perPage: 100,
      validate: [required("Page required.")],
      sort: { field: "created_at", order: "DESC" },
    },
    [
      h(SelectInput, {
        optionText: "title",
      }),
    ]
  )

export const Create = (props: {}) =>
  h(_Create, { ...props }, [
    h(SimpleForm, { redirect: "edit", submitOnEnter: true }, [
      h(PageReferenceInput),
      h(TextInput, {
        label: "Title",
        source: "title",
        fullWidth: true,
        validate: [required("Title required.")],
      }),
    ]),
  ])
