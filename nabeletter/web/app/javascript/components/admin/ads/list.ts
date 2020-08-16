import { h } from "@cycle/react"
import { Datagrid, DateField, List as _List, TextField } from "react-admin"

export const List = (props: {}) =>
  h(_List, { ...props, bulkActionButtons: false, exporter: false }, [
    h(Datagrid, { rowClick: "show" }, [
      h(TextField, { source: "title" }, []),
      h(TextField, { source: "body" }, []),
      h(DateField, { source: "created_at", label: "Created", showTime: true }),
      h(DateField, { source: "updated_at", label: "Updated", showTime: true }),
    ]),
  ])
