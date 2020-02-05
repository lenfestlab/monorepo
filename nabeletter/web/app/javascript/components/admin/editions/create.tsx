import React from "react"
import { h } from "@cycle/react"
import {
  Create,
  DateTimeInput,
  SimpleForm,
  TextInput,
  required,
} from "react-admin"
import { addHours, startOfTomorrow } from "date-fns"

import { EditionEditorInput } from "./shared"
import { NewsletterReferenceInput } from "../shared/NewsletterReferenceInput"

export const EditionCreate = props =>
  h(Create, { ...props }, [
    h(SimpleForm, { redirect: "show" }, [
      h(NewsletterReferenceInput),
      h(TextInput, {
        label: "Subject",
        source: "subject",
        fullWidth: true,
        validate: [required("Subject required for email.")],
      }),
      h(DateTimeInput, {
        label: "Publish/send at",
        source: "publish_at",
        validate: [required("Publish date required.")],
        initialValue: addHours(startOfTomorrow(), 6),
      }),
      h(EditionEditorInput, { source: "body_data" }),
    ]),
  ])
