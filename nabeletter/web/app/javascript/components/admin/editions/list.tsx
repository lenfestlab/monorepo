import React, { Fragment } from "react"
import { h } from "@cycle/react"
import {
  DateField,
  Datagrid,
  List,
  ReferenceField,
  TextField,
} from "react-admin"

export const EditionList = props =>
  h(
    List,
    {
      ...props,
      sort: { field: "publish_at", order: "DESC" },
      bulkActionButtons: false,
      exporter: false,
    },
    [
      h(Datagrid, { rowClick: "show" }, [
        h(TextField, { source: "id" }, []),
        h(
          ReferenceField,
          {
            label: "Newsletter",
            source: "newsletter.id",
            reference: "newsletters",
          },
          [h(TextField, { source: "name" })]
        ),
        h(TextField, { source: "subject" }, []),
        h(
          DateField,
          { source: "publish_at", label: "Publish/Send at", showTime: true },
          []
        ),
      ]),
    ]
  )
