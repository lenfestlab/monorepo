import React, { Fragment } from "react"
import { h } from "@cycle/react"
// list
import {
  DateField,
  Datagrid,
  List,
  ReferenceField,
  TextField,
} from "react-admin"
// create
import {
  Create,
  ReferenceInput,
  SelectInput,
  SimpleForm,
  TextInput,
  required,
  email,
} from "react-admin"
// show
import { Show, SimpleShowLayout } from "react-admin"

export const SubscriptionList = props =>
  h(
    List,
    {
      ...props,
      sort: { field: "subscribed_at", order: "DESC" },
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
        h(TextField, { source: "email_address" }),
        h(TextField, { source: "name" }),
        h(DateField, {
          source: "subscribed_at",
          showTime: true,
        }),
        h(DateField, {
          source: "unsubscribed_at",
          showTime: true,
        }),
      ]),
    ]
  )

const initialValues = { newsletter_id: 1 } // NOTE: default to first newsletter
export const SubscriptionCreate = props =>
  h(Create, { ...props }, [
    h(SimpleForm, { initialValues, redirect: "list" }, [
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
        source: "email_address",
        fullWidth: true,
        validate: [required("Address required."), email()],
      }),
      h(TextInput, {
        source: "name",
        fullWidth: true,
      }),
    ]),
  ])

export const SubscriptionShow = props =>
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
      h(TextField, { source: "email_address" }),
      h(TextField, { source: "name" }),
      h(DateField, {
        label: "Subscribed at",
        source: "subscribed_at",
      }),
      h(DateField, {
        label: "Unsubscribed at",
        source: "unsubscribed_at",
      }),
    ]),
  ])
