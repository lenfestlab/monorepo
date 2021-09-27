import { h } from "@cycle/react"
import { Edition } from "components/admin/shared"
import { ShowButton, TopToolbar } from "react-admin"

interface Props {
  basePath: string
  data: Edition
}
export const Actions = ({ basePath, data: record, ...rest }: Props) => {
  return h(TopToolbar, [
    h(ShowButton, { basePath, record }),
  ])
}
