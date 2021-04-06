import { h } from "@cycle/react"
import { Edit as _Edit, SimpleForm } from "react-admin"
import { Input } from "./Input"

export const Edit = (props: {}) =>
  h(
    _Edit,
    {
      ...props,
      undoable: false,
    },
    [
      h(SimpleForm, { submitOnEnter: false, redirect: false, toolbar: null }, [
        h(Input),
      ]),
    ]
  )
