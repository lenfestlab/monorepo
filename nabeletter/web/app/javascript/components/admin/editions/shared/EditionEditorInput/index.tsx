import React from "react"
import { h } from "@cycle/react"
import head from "lodash/head"

export const EditionEditorInput = props => h("h1", "WIP")

// TODO: compose from multiple sections/inputs
import MarkdownInput from "ra-input-markdown"
const format = storedMarkdownArray => head(storedMarkdownArray)
const parse = inputMarkdown => [inputMarkdown]
export const BodyInput = props =>
  h(MarkdownInput, { format, parse, source: "body_data" })
