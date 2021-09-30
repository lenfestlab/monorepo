import { h } from "@cycle/react"
import { a } from "@cycle/react-dom"
import { EditionTrashButton } from "components/admin/editions/shared"
import { Edition, Lang } from "components/admin/shared";
import { get, truncate } from "fp"
import {
  Datagrid,
  DateField,
  DeleteButton,
  EditButton,
  Pagination,
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
  if (!state) return null
  return h(TopToolbar, [
    state !== "delivered" &&
      state !== "trashed" &&
      h(EditButton, { basePath, record }),
    state !== "trashed" && h(EditionTrashButton, { record }),
  ])
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

interface Props {
  record?: Edition
  lang: Lang
}
export const EditionShow = (props: Props) => {
  const { lang } = props
  return h(Show, { ...props, actions: h(Actions) }, [
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
        h(TextField, { label: "Kind", source: "kind" }),
        h(TextField, { label: "State", source: "state" }),
        h(TextField, { label: "Email subject", source: "subject" }),
        h(DateField, {
          label: "Publish/send at",
          source: "publish_at",
          showTime: true,
        }),
        h(EditionPreviewField, {
          label: "Preview",
          source: `email_html_${lang}`,
          addLabel: true,
        }),
      ]),
      h(Tab, { label: "Links" }, [
        h(
          ReferenceManyField,
          {
            perPage: 100,
            reference: "links",
            target: "edition_id",
            label: "Links",
            pagination: h(Pagination),
          },
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

}
