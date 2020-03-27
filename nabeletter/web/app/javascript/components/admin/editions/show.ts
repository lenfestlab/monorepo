import { h } from "@cycle/react"
import {
  DateField,
  ReferenceField,
  Show,
  SimpleShowLayout,
  TextField,
} from "react-admin"

import { EditionPreviewField } from "./shared"

interface Props {}

export const EditionShow = (props: Props) =>
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
      h(DateField, {
        label: "Publish/send at",
        source: "publish_at",
        showTime: true,
      }),
      h(EditionPreviewField, {
        label: "Preview",
        source: "body_html",
        addLabel: true,
      }),
    ]),
  ])
