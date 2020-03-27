import { span } from "@cycle/react-dom"
import { Record } from "components/admin/shared"

interface Props {
  record: Record
}

export const Title = ({ record }: Props) => span(record?.subject ?? "")
