import { h } from "@cycle/react"
import { required, TextInput } from "react-admin"
import { Create as _Create, SimpleForm } from "react-admin"

export const Create = (props: {}) =>
  h(_Create, { ...props }, [
    h(SimpleForm, { redirect: "show", submitOnEnter: true }, [
      h(TextInput, {
        label: "Title",
        source: "title",
        fullWidth: true,
        validate: [required("Title required.")],
      }),
    ]),
  ])
