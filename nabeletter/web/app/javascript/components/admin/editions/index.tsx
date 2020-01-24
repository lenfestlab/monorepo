import React from "react"
import { h } from "@cycle/react"
import {
  Create,
  DateTimeInput,
  Edit,
  ReferenceInput,
  SelectInput,
  SimpleForm,
  TextInput,
  required,
} from "react-admin"
import { addHours, startOfTomorrow } from "date-fns"

export { EditionList } from "./list"
export { EditionShow } from "./show"

import { BodyInput } from "./body"

export const EditionCreate = props =>
  h(Create, { ...props }, [
    h(SimpleForm, { redirect: "show" }, [
      h(
        ReferenceInput,
        {
          label: "Newsletter",
          source: "newsletter_id",
          reference: "newsletters",
          allowEmpty: false,
          validate: [required("Newsletter required.")],
        },
        [h(SelectInput, { optionText: "name" })]
      ),
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
      h(BodyInput),
    ]),
  ])

import { Toolbar, SaveButton } from "react-admin"
const EditionEditToolbar = props => h(Toolbar, { ...props }, [h(SaveButton)])

const EditPostTitle = ({ record }) => {
  return <span>Post {record ? `"${record.subject}"` : ""}</span>
}

export const EditionEdit = props =>
  h(Edit, { ...props, undoable: false, title: h(EditPostTitle) }, [
    h(
      SimpleForm,
      {
        redirect: "show",
        toolbar: h(EditionEditToolbar),
      },
      [
        h(
          ReferenceInput,
          {
            label: "Newsletter",
            source: "newsletter.id",
            reference: "newsletters",
            allowEmpty: false,
            validate: [required("Newsletter required.")],
          },
          [h(SelectInput, { optionText: "name" })]
        ),
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
        h(BodyInput),
      ]
    ),
  ])
