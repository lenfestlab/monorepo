import React, { Fragment } from "react"
import { h } from "@cycle/react"
import get from "lodash/get"

// https://marmelab.com/react-admin/Fields.html
export const EditionPreviewField = ({
  label,
  source,
  record = {},
  addLabel = true,
}) => {
  const __html = get(record, source) || "<h1>WIP</h1>"
  const doc = { __html }
  return <div dangerouslySetInnerHTML={doc} />
}
