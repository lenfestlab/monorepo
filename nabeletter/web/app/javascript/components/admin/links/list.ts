import { h } from "@cycle/react"
import {
  Datagrid,
  DateField,
  List,
  ReferenceField,
  TextField,
  UrlField,
} from "react-admin"

export const LinkList = (props: {}) =>
  h(
    List,
    {
      ...props,
      sort: { field: "edition.id", order: "DESC" },
      bulkActionButtons: false,
      exporter: false,
      perPage: 100,
    },
    [
      h(Datagrid, { rowClick: "edit" }, [
        h(
          ReferenceField,
          {
            label: "Edition",
            source: "edition.id",
            reference: "editions",
            link: "show",
          },
          [h(DateField, { source: "publish_at", label: "Published" }, [])]
        ),
        h(TextField, { source: "section" }, []),
        h(TextField, { source: "topic" }, []),
        h(TextField, { source: "subtopic" }, []),
        h(UrlField, { source: "redirect" }, []),
      ]),
    ]
  )
