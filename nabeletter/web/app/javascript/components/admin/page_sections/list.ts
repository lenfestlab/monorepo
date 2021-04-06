import { h } from "@cycle/react"
import {
  Datagrid,
  DateField,
  List as _List,
  ReferenceField,
  TextField,
} from "react-admin"

export const List = (props: {}) =>
  h(
    _List,
    {
      ...props,
      sort: { field: "page.id,created_at", order: "DESC" },
      bulkActionButtons: false,
      exporter: false,
      perPage: 100,
    },
    [
      h(Datagrid, { rowClick: "edit" }, [
        h(TextField, { source: "title" }, []),
        h(
          ReferenceField,
          {
            label: "Page",
            source: "page.id",
            reference: "pages",
            link: "show",
          },
          [h(TextField, { source: "title", label: "Page" }, [])]
        ),
        h(DateField, {
          source: "created_at",
          label: "Created",
          showTime: true,
        }),
        h(DateField, {
          source: "updated_at",
          label: "Updated",
          showTime: true,
        }),
      ]),
    ]
  )
