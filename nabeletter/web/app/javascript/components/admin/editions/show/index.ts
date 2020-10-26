import { h } from "@cycle/react"
import { a } from "@cycle/react-dom"
import { Edition } from "components/admin/shared"
import { get, truncate } from "fp"
import {
  Datagrid,
  DateField,
  EditButton,
  ReferenceField,
  ReferenceManyField,
  Show,
  Tab,
  TabbedShowLayout,
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

const CustomUrlField = ({
  record,
  source,
}: {
  record?: object
  source: string
}) => {
  const href = get(record, source)
  return a({ href, target: "_blank" }, truncate(href, { length: 50 }))
}

export const EditionShow = (props: {}) =>
  h(Show, { ...props, actions: h(Actions) }, [
    h(TabbedShowLayout, [
      h(Tab, { label: "Preview" }, [
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
      h(Tab, { label: "Links" }, [
        h(
          ReferenceManyField,
          { reference: "links", target: "edition_id", label: "Links" },
          [
            h(Datagrid, {}, [
              h(TextField, { source: "section" }, []),
              h(TextField, { source: "topic" }, []),
              h(TextField, { source: "subtopic" }, []),
              h(CustomUrlField, { source: "redirect" }, []),
              h(EditButton),
            ]),
          ]
        ),
      ]),
    ]),
  ])
