import React, { Fragment } from "react"
import { h } from "@cycle/react"
import {
  Admin,
  Create,
  DateField,
  Datagrid,
  DateTimeInput,
  EditButton,
  Edit,
  List,
  ListGuesser,
  Resource,
  ReferenceField,
  ReferenceInput,
  SelectInput,
  Show,
  SimpleForm,
  SimpleShowLayout,
  TextField,
  TextInput,
  TopToolbar,
  required,
} from "react-admin"
import jsonapiClient from "ra-jsonapi-client"
import { addHours, startOfTomorrow } from "date-fns"

// https://git.io/JvTHr
// eg: {"errors":[{"source":{"pointer":"/data/attributes/subject"},"detail":"can't be blank"},{"source":{"pointer":"/data/attributes/publish-at"},"detail":"can't be blank"}]}
const messageCreator = jsonapiErrorPayload => {
  // TODO: handle JSON:API formatted validation errors
  // return JSON.stringify(jsonapiErrorPayload)
  return null
}

// TODO: inject host via env var
const dataProvider = jsonapiClient("http://localhost:5000", { messageCreator })

const EditionList = props =>
  h(
    List,
    {
      ...props,
      sort: { field: "publish_at", order: "DESC" },
      bulkActionButtons: false,
    },
    [
      h(Datagrid, { rowClick: "show" }, [
        h(TextField, { source: "id" }, []),
        h(
          ReferenceField,
          {
            label: "Newsletter",
            source: "id",
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
const EditionCreate = props =>
  h(Create, { ...props }, [
    h(SimpleForm, { initialValues }, [
      h(
        ReferenceInput,
        {
          label: "Newsletter",
          source: "newsletter_id", // TODO: is this why newsletter create fails?
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
const EditionEdit = props =>
  h(Edit, { ...props, undoable: false }, [
    h(SimpleForm, {}, [
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
      //  TODO: extract, dupes Create
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

const EditionShow = props =>
  h(Show, { ...props }, [
    h(SimpleShowLayout, {}, [
      // TODO: newsletter isn't appearing, and only appears first row in List!?
      h(
        ReferenceField,
        {
          label: "Newsletter",
          source: "newsletter_id",
          reference: "newsletters",
        },
        [h(TextField, { source: "name" })]
      ),
      h(TextField, { label: "Email subject", source: "subject" }),
      h(DateField, { label: "Published and sent at", source: "publish_at" }),
    ]),
  ])

// TODO: disallow deleting Newsletter records
const NewsletterList = props =>
  h(List, { ...props, bulkActionButtons: false }, [
    h(Datagrid, {}, [h(TextField, { source: "name" }, [])]),
  ])

export const AdminApp = () =>
  h(Admin, { dataProvider: dataProvider }, [
    h(Resource, {
      name: "newsletters",
      list: NewsletterList,
    }),
    h(Resource, {
      name: "editions",
      list: EditionList,
      create: EditionCreate,
      show: EditionShow,
      edit: EditionEdit,
    }),
  ])
