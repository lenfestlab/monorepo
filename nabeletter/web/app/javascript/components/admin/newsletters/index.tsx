import React, { cloneElement } from "react"
import { h } from "@cycle/react"
import { Datagrid, List, TextField } from "react-admin"

export const NewsletterList = props =>
  h(List, { ...props, bulkActionButtons: false, exporter: false }, [
    h(Datagrid, {}, [h(TextField, { source: "name" }, [])]),
  ])
