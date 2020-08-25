import { h } from "@cycle/react"
import {
  DateField,
  ImageField,
  Show as _Show,
  SimpleShowLayout,
  TextField,
} from "react-admin"

import { NewsletterReferenceField } from "components/admin/shared"

export const Show = (props: {}) =>
  h(_Show, { ...props }, [
    h(SimpleShowLayout, {}, [
      h(NewsletterReferenceField),
      h(TextField, { source: "title" }),
      h(TextField, { source: "body" }),
      h(DateField, { source: "created_at", label: "Created", showTime: true }),
      h(DateField, { source: "updated_at", label: "Updated", showTime: true }),
      h(ImageField, { source: "screenshot_url" }),
    ]),
  ])
