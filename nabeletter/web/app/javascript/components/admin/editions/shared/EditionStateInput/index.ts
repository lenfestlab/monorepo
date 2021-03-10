import { h } from "@cycle/react"
import { AutocompleteInput } from "react-admin"

export const EditionStateInput = (props: {}) => {
  return h(AutocompleteInput, {
    ...props,
    source: "state",
    allowEmpty: false,
    choices: [
      { id: "deliverable", name: "Deliverable" },
      { id: "draft", name: "Draft" },
    ],
  })
}
