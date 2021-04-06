import { h } from "@cycle/react"
import { Datagrid, List as _List, TextField } from "react-admin"

export const List = (props: {}) =>
  h(_List, { ...props, bulkActionButtons: false, exporter: false }, [
    h(Datagrid, { rowClick: "edit" }, [h(TextField, { source: "title" }, [])]),
  ])
