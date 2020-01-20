import React, { Fragment } from "react"
import { h } from "@cycle/react"
import {
  Create,
  DateField,
  Datagrid,
  DateTimeInput,
  Edit,
  List,
  ReferenceField,
  ReferenceInput,
  SelectInput,
  Show,
  SimpleForm,
  SimpleShowLayout,
  TextField,
  TextInput,
  required,
} from "react-admin"
import { addHours, startOfTomorrow } from "date-fns"

export const EditionList = props =>
  h(
    List,
    {
      ...props,
      sort: { field: "publish_at", order: "DESC" },
    },
    [
      h(Datagrid, { rowClick: "show" }, [
        h(TextField, { source: "id" }, []),
        h(
          ReferenceField,
          {
            label: "Newsletter",
            source: "newsletter.id",
            reference: "newsletters",
          },
          [h(TextField, { source: "name" })]
        ),
        h(
          DateField,
          { source: "publish_at", label: "Publish/Send at", showTime: true },
          []
        ),
        h(TextField, { source: "subject" }, []),
      ]),
    ]
  )

const initialValues = { newsletter_id: 1 } // NOTE: default to first newsletter
export const EditionCreate = props =>
  h(Create, { ...props }, [
    h(SimpleForm, { initialValues }, [
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
    ]),
  ])

// NOTE: by default react-admin waits to send a few seconds and provides "undo"
// Disable in favor of faster feedback from API
export const EditionEdit = props =>
  h(Edit, { ...props, undoable: false }, [
    h(SimpleForm, {}, [
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
    ]),
  ])

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
    ]),
  ])
