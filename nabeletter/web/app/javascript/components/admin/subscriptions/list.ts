import { h } from "@cycle/react"
import {
  Datagrid,
  DateField,
  List,
  ReferenceField,
  TextField,
} from "react-admin"
import { Filter, TextInput } from "react-admin"

const EmailFilter = (props: {}) =>
  h(Filter, { ...props }, [
    h(TextInput, { label: "Email", source: "email_address", alwaysOn: true }),
    h(TextInput, {
      label: "Last name",
      source: "name_last",
    }),
  ])

export const SubscriptionList = (props: {}) =>
  h(
    List,
    {
      ...props,
      sort: { field: "subscribed_at", order: "DESC" },
      bulkActionButtons: false,
      exporter: false,
      filters: h(EmailFilter),
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
        h(TextField, { source: "name_first", label: "First name" }),
        h(TextField, { source: "name_last", label: "Last name" }),
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
