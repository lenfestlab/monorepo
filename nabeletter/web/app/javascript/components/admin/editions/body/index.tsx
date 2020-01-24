import React from "react"
import PropTypes from "prop-types"
import { h } from "@cycle/react"
import head from "lodash/head"

// Edit
// TODO: compose from multiple sections/inputs
import MarkdownInput from "ra-input-markdown"
const format = storedMarkdownArray => head(storedMarkdownArray)
const parse = inputMarkdown => [inputMarkdown]
export const BodyInput = props =>
  h(MarkdownInput, { format, parse, source: "body_data" })

// Show
// https://marmelab.com/react-admin/Fields.html
import ReactMarkdown from "react-markdown"
import get from "lodash/get"

export const MarkdownField = ({
  label,
  source,
  record = {},
  addLabel = true,
}) => {
  const md = get(record, `${source}[0]`, "")
  return h(ReactMarkdown, { source: md })
}
