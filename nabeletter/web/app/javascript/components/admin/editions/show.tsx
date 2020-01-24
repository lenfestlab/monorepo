import React, { Fragment } from "react"
import { h } from "@cycle/react"
import {
  DateField,
  ReferenceField,
  Show,
  SimpleShowLayout,
  TextField,
} from "react-admin"

import { MarkdownField } from "./body"

export const EditionShow = props =>
  h(Show, { ...props }, [
    h(SimpleShowLayout, {}, [
      h(
        ReferenceField,
        {
          label: "Newsletter",
          source: "newsletter.id",
          reference: "newsletters",
        },
        [h(TextField, { source: "name" })]
      ),
      h(TextField, { label: "Email subject", source: "subject" }),
      h(DateField, { label: "Publish/send at", source: "publish_at" }),
      h(MarkdownField, { label: "Email body", source: "body_data" }),
    ]),
  ])
