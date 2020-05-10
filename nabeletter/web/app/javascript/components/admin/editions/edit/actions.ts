import { h } from "@cycle/react"
import { EditionTestDeliveryButton } from "components/admin/editions/shared"
import { Edition } from "components/admin/shared"
import { ShowButton, TopToolbar } from "react-admin"

interface Props {
  basePath: string
  data: Edition
}
export const Actions = ({ basePath, data: record, ...rest }: Props) => {
  return h(TopToolbar, [
    h(ShowButton, { basePath, record }),
    h(EditionTestDeliveryButton, { record }),
  ])
}
