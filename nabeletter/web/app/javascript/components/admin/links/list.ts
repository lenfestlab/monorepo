import { h } from "@cycle/react"
import { a } from "@cycle/react-dom"
import { truncate } from "fp"
import {
  AutocompleteInput,
  Datagrid,
  DateField,
  FunctionField,
  List,
  ReferenceField,
  ReferenceInput,
  SelectInput,
  TextField,
} from "react-admin"
import { Filter, TextInput } from "react-admin"

const render = ({ redirect }: {redirect: string}) =>
  a({ href: redirect, target: "_blank" },
   truncate(redirect, {length: 100}))

const Filters = (props: {}) =>
  h(Filter, {...props}, [
    h(
      ReferenceInput,
      {
        alwaysOn: true,
        allowEmpty: true,
        source: "edition_id",
        reference: "editions",
        label: "Edition",
        perPage: 300
      },
      [
        h(SelectInput, {
          optionText: "id"
        }),
      ]
    ),
    // h(AutocompleteInput, {
    //   alwaysOn: true,
    //   choices: [
    //     { id: 0, name: "draft" },
    //     { id: 1, name: "live" },
    //   ],
    //   source: "state",
    // }),
    h(AutocompleteInput, {
      alwaysOn: true,
      choices: [
        { id: 0, name: "en" },
        { id: 1, name: "es" },
      ],
      source: "lang",
    }),
    h(AutocompleteInput, {
      alwaysOn: true,
      choices: [
        { id: 0, name: "email" },
        { id: 1, name: "sms" },
      ],
      source: "channel",
    }),
  ])

export const LinkList = (props: {}) =>
  h(
    List,
    {
      ...props,
      sort: { field: "edition.id", order: "DESC" },
      bulkActionButtons: false,
      exporter: false,
      perPage: 100,
      filters: h(Filters)
    },
    [
      h(Datagrid, { rowClick: "edit" }, [
        // h(TextField, { source: "id" }, []),
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
        // h(TextField, { source: "state" }, []),
        h(TextField, { source: "channel" }, []),
        h(TextField, { source: "lang" }, []),
        h(TextField, { source: "section" }, []),
        h(TextField, { source: "topic" }, []),
        h(TextField, { source: "subtopic" }, []),
        h(FunctionField, { label:"Redirect", render })
      ]),
    ]
  )
