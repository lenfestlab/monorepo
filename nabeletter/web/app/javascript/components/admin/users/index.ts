import * as React from "react"
import { h } from "@cycle/react"
import { DateField, Datagrid, List, TextField } from "react-admin"

export const UserList = (props) =>
  h(
    List,
    {
      ...props,
      // sort: { field: "publish_at", order: "DESC" },
      // bulkActionButtons: false,
      // exporter: false,
    },
    [
      h(
        Datagrid,
        {
          // rowClick: "show"
        },
        [
          h(TextField, { source: "email" }, []),
          h(
            DateField,
            { source: "created_at", label: "Created", showTime: true },
            []
          ),
          h(
            DateField,
            { source: "updated_at", label: "Updated", showTime: true },
            []
          ),
        ]
      ),
    ]
  )
