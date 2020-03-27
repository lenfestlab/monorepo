import { h } from "@cycle/react"
import { DateField, Datagrid, List, TextField } from "react-admin"

interface Props {}

export const UserList = (props: Props) =>
  h(List, { ...props }, [
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
  ])
