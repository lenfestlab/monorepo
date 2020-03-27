import { h } from "@cycle/react"
import {
  DateField,
  Datagrid,
  List,
  ReferenceField,
  TextField,
} from "react-admin"

interface Props {}

export const SubscriptionList = (props: Props) =>
  h(
    List,
    {
      ...props,
      sort: { field: "subscribed_at", order: "DESC" },
      bulkActionButtons: false,
      exporter: false,
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
