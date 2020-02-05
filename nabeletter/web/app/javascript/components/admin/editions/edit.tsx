import React from "react"
import { h } from "@cycle/react"
import {
  DateTimeInput,
  Edit,
  SimpleForm,
  TextInput,
  required,
} from "react-admin"
import { addHours, startOfTomorrow } from "date-fns"

import { EditionEditorInput } from "./shared"
import { NewsletterReferenceInput } from "../shared/NewsletterReferenceInput"

const EditPostTitle = ({ record }) => {
  return <span>Post {record ? `"${record.subject}"` : ""}</span>
}

// TODO: derive & set body_html from body_data on submit

import { Toolbar } from "react-admin"

import {
  useRefresh,
  useMutation,
  useNotify,
  useRedirect,
  SaveButton,
} from "react-admin"
import join from "lodash/join"
import map from "lodash/map"
import split from "lodash/split"
import last from "lodash/last"
import compact from "lodash/compact"
import trim from "lodash/trim"
import isEmpty from "lodash/isEmpty"
import { humanize } from "inflected"

// transforms JSON:API errors into notification message
const humanizeJsonApiError = ({
  code,
  detail,
  source: { pointer },
  status,
  title,
}) => trim(humanize(`${last(split(pointer, "/"))} ${title}`))

// NOTE: handles server-side error messages - https://git.io/JvZkE
const EditionSaveButton = ({ record, basePath }) => {
  const { id } = record
  const notify = useNotify()
  const redirect = useRedirect()
  const refresh = useRefresh()
  const [update, { data, total, error, loading, loaded }] = useMutation(
    {
      type: "update",
      resource: "editions",
      payload: { id, data: record },
    },
    {
      onSuccess: data => {
        console.info(data)
        redirect("show", basePath, id)
        notify("Updated")
      },
      onFailure: ({ response }) => {
        console.log(`response`)
        console.log(response)
        const {
          data: { errors },
          status,
          statusText,
          headers,
          config,
          request,
        } = response
        // display statusText by default, prefer error messages if present
        // TODO: attribute validation messages on fields
        let message = isEmpty(errors)
          ? statusText
          : join(map(errors, humanizeJsonApiError), ", ")
        console.error(message)
        notify(message, "warning")
      },
    }
  )
  return h(SaveButton, { handleSubmitWithRedirect: update, disabled: loading })
}

// NOTE: omits default Delete button
const EditionEditToolbar = props =>
  h(Toolbar, { ...props }, [h(EditionSaveButton)])

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
        h(EditionEditorInput, { source: "body_data" }),
      ]
    ),
  ])
