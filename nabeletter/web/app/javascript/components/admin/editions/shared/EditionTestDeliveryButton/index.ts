import { h } from "@cycle/react"
import { Button, useMutation } from "react-admin"

export const EditionTestDeliveryButton = ({ record }) => {
  const [approve, { loading }] = useMutation({
    type: "update",
    resource: "editions",
    payload: { id: record.id, data: { test: true } },
  })
  return h(Button, {
    label: "Test delivery",
    onClick: approve,
    disabled: loading,
  })
}
