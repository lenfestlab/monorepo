import { h } from "@cycle/react"
import React, { Fragment } from "react"
import {
  Datagrid,
  DateField,
  Filter,
  List,
  ReferenceField,
  ReferenceInput,
  SelectInput,
  TextField,
} from "react-admin"

const NewsletterFilter = (props: {}) =>
  h(Filter, { ...props }, [
    h(
      ReferenceInput,
      {
        alwaysOn: true,
        // allowEmpty: false,
        source: "newsletter_id",
        reference: "newsletters",
      },
      [
        h(SelectInput, {
          label: "Newsletter",
          source: "name",
        }),
      ]
    ),
  ])

export const EditionList = (props: {}) =>
  h(
    List,
    {
      ...props,
      sort: { field: "publish_at", order: "DESC" },
      bulkActionButtons: false,
      exporter: false,
      filters: h(NewsletterFilter),
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
        h(TextField, { source: "state" }, []),
        h(TextField, { source: "link_count", label: "Links" }, []),
        h(TextField, { source: "kind" }),
      ]),
    ]
  )
