import { span } from "@cycle/react-dom"
import { Edition } from "components/admin/shared"
import { get } from "fp"

interface Props {
  addLabel: boolean
  label: string
  record?: Edition
  source: string
}

export const EditionPreviewField: React.FunctionComponent<Props> = ({
  source,
  record,
}) => {
  const __html = get(record, source) || "<h1>WIP</h1>"
  const doc = { __html }
  return span({ dangerouslySetInnerHTML: doc })
}
