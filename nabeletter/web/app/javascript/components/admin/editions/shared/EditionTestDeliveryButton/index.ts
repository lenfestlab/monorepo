import { h } from "@cycle/react"
import { Button, useMutation } from "react-admin"

export const EditionTestDeliveryButton = ({ record }) => {
  const [approve, { loading }] = useMutation({
    type: "update",
    resource: "editions",
    payload: { id: record.id, data: { test: true } },
  })
  const isDeliverable: boolean = record.body_html && true
  return h(Button, {
    label: isDeliverable
      ? "Test delivery"
      : "Please edit body to test delivery",
    onClick: approve,
    disabled: !isDeliverable || loading,
  })
}
