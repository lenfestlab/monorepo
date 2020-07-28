import { h } from "@cycle/react"
import { Edition } from "components/admin/shared"
import { get } from "fp"
import {
  DateField,
  EditButton,
  ReferenceField,
  Show,
  SimpleShowLayout,
  TextField,
  TopToolbar,
} from "react-admin"
import { EditionPreviewField } from "./EditionPreviewField"

interface ActionProps {
  basePath: string
  data: Edition
}
const Actions = ({ basePath, data: record }: ActionProps) => {
  const state: string | null = get(record, "state")
  if (!state || state === "delivered") return null
  return h(TopToolbar, [h(EditButton, { basePath, record })])
}

export const EditionShow = (props: {}) =>
  h(Show, { ...props, actions: h(Actions) }, [
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
