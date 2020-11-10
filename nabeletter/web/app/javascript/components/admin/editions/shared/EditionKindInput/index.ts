import { h } from "@cycle/react"
import { addHours, startOfTomorrow } from "date-fns"
import { AutocompleteInput, required } from "react-admin"

export const EditionKindInput = (props: {}) =>
  h(AutocompleteInput, {
    ...props,
    source: "kind",
    allowEmpty: false,
    choices: [
      { id: "normal", name: "Normal" },
      { id: "adhoc", name: "Ad hoc" },
      { id: "personal", name: "Personal" },
    ],
  })
