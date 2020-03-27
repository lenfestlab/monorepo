import { h } from "@cycle/react"
import ContentCreate from "@material-ui/icons/Create"
import { SyntheticEvent } from "react"
import { Button } from "react-admin"

import { Identifier } from "components/admin/shared"
type Props = {
  id: Identifier
  resource: string
}

export const EditionBodyButton = ({ id, resource }: Props) => {
  const editorHost = process.env.EDITOR_HOST
  const href = `${editorHost}/${resource}/${id}`
  const icon = h(ContentCreate)
  const onClick = (e: SyntheticEvent) => e.stopPropagation()
  const props = {
    icon,
    onClick,
    href,
    target: "_blank",
    label: "Edit Body",
  }
  return h(Button, props, [icon])
}
