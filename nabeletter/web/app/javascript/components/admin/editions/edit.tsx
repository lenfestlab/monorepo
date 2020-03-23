import React from "react"
import { h } from "@cycle/react"
import { span } from "@cycle/react-dom"
import {
  DateTimeInput,
  Edit,
  SimpleForm,
  TextInput,
  required,
  Toolbar,
  SaveButton,
} from "react-admin"
import { addHours, startOfTomorrow } from "date-fns"
import split from "lodash/split"
import last from "lodash/last"
import trim from "lodash/trim"
import { humanize } from "inflected"

import { EditionTestDeliveryButton } from "./shared"
import { NewsletterReferenceInput } from "../shared/NewsletterReferenceInput"

const EditPostTitle = ({ record }) => span(record?.subject ?? "")

// transforms JSON:API errors into notification message
const humanizeJsonApiError = ({
  code,
  detail,
  source: { pointer },
  status,
  title,
}) => trim(humanize(`${last(split(pointer, "/"))} ${title}`))

// NOTE: omits default Delete button
const EditionEditToolbar = props =>
  h(Toolbar, { ...props }, [h(SaveButton), h(EditionTestDeliveryButton)])

import { OpenEditionBodyEditorButton } from "./shared"

export const EditionEdit = props =>
  h(Edit, { ...props, undoable: false, title: h(EditPostTitle) }, [
    h(
      SimpleForm,
      {
        redirect: "show",
        toolbar: h(EditionEditToolbar),
      },
      [
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
        h(OpenEditionBodyEditorButton, props),
      ]
    ),
  ])
