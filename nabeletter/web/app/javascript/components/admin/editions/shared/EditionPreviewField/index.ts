import { div } from "@cycle/react-dom"

import { Record } from "components/admin/shared"
import { get } from "fp"

interface Props {
  addLabel: boolean
  label: string
  record?: Record
  source: string
}

// NOTE: https://marmelab.com/react-admin/Fields.html
export const EditionPreviewField: React.FunctionComponent<Props> = ({
  source,
  record,
  ...rest
}) => {
  const __html = get(record, source) || "<h1>WIP</h1>"
  const doc = { __html }
  return div({ dangerouslySetInnerHTML: doc })
}
