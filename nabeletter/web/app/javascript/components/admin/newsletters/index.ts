import { h } from "@cycle/react"
import { Datagrid, List, TextField } from "react-admin"

interface Props {}

export const NewsletterList = (props: Props) =>
  h(List, { ...props, bulkActionButtons: false, exporter: false }, [
    h(Datagrid, {}, [h(TextField, { source: "name" }, [])]),
  ])
