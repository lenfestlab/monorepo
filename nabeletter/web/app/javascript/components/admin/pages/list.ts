import { h } from "@cycle/react"
import {
  Datagrid,
  ImageField,
  List as _List,
  ReferenceField,
  TextField,
} from "react-admin"

export const List = (props: {}) =>
  h(_List, { ...props, bulkActionButtons: false, exporter: false }, [
    h(Datagrid, { rowClick: "edit" }, [
      h(
        ReferenceField,
        {
          label: "Newsletter",
          source: "newsletter.id",
          reference: "newsletters",
        },
        [h(TextField, { source: "name" })]
      ),
      h(TextField, { source: "title" }),
      h(ImageField, { source: "header_image_url", label: "Header image" }),
    ]),
  ])
