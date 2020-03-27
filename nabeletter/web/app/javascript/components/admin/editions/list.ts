import { h } from "@cycle/react"
import React, { Fragment } from "react"
import {
  Datagrid,
  DateField,
  List,
  ReferenceField,
  TextField,
} from "react-admin"

interface Props {}

export const EditionList = (props: Props) =>
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
        // TODO: EditionPreviewButton
      ]),
    ]
  )
