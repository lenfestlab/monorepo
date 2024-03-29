import { h } from "@cycle/react";
import { span } from "@cycle/react-dom"
import { Edition } from "components/admin/shared"
import { get } from "fp"
import { Preview as SmsPreview  } from "../../shared/EditionBodyInput/SmsBodyInput/Preview"

interface Props {
  addLabel: boolean
  label: string
  record?: Edition
  source: string
  lang: string
}

export const EditionPreviewField: React.FunctionComponent<Props> = ({
  source,
  record,
}) => {
  const __html = get(record, source) || "<h1>WIP</h1>"
  const doc = { __html }
  const text = get(record, `sms_body_es`)
  return span({ style: {display: "flex", flexDirection: "row", wrap: "nonwrap" }}, [
    span({ dangerouslySetInnerHTML: doc }),
    text && h(SmsPreview, { text })
  ])
}
