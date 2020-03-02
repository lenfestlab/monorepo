import { Button } from "react-admin"
import ContentCreate from "@material-ui/icons/Create"
import { h } from "@cycle/react"

export const OpenEditionBodyEditorButton = ({ id, record, resource }) => {
  const editorHost = process.env.EDITOR_HOST
  const href = `${editorHost}/${resource}/${id}`
  const icon = h(ContentCreate)
  const onClick = e => e.stopPropagation()
  const props = {
    icon,
    onClick,
    href,
    target: "_blank",
    label: "Edit Body",
  }
  return h(Button, props, [icon])
}
