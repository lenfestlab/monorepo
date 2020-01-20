import React, { Fragment } from "react"
import { h } from "@cycle/react"
import { Datagrid, List, Resource, TextField } from "react-admin"

export const NewsletterList = props =>
  h(List, { ...props }, [
    h(Datagrid, {}, [h(TextField, { source: "name" }, [])]),
  ])
