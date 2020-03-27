import { h } from "@cycle/react"
import {
  DateField,
  TextField,
  ReferenceField,
  Show,
  SimpleShowLayout,
} from "react-admin"

interface Props {}

export const SubscriptionShow = (props: Props) =>
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
      h(TextField, { source: "name_first", label: "First name" }),
      h(TextField, { source: "name_last", label: "Last name" }),
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
