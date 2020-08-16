import { h } from "@cycle/react"
import { required, TextInput } from "react-admin"

import { NewsletterReferenceInput } from "components/admin/shared"
import { Create as _Create, SimpleForm } from "react-admin"

export const Create = (props: {}) =>
  h(_Create, { ...props }, [
    h(SimpleForm, { redirect: "show", submitOnEnter: true }, [
      h(NewsletterReferenceInput),
      h(TextInput, {
        label: "Title",
        source: "title",
        fullWidth: true,
        validate: [required("Title required.")],
      }),
      h(TextInput, {
        label: "Body",
        source: "body",
        fullWidth: true,
        multiline: true,
        rows: 2,
        variant: "filled",
        validate: [required("Body required.")],
      }),
    ]),
  ])
