import { h } from "@cycle/react"
import { DeleteForever, RestoreFromTrash } from "@material-ui/icons"
import {
  Fragment,
  useCallback,
  useState,
} from "react"
import { Button, useDataProvider } from "react-admin"

import { Edition } from "components/admin/shared"

interface Props {
  record: Edition
  state: "trash" | "untrash"
}

export const EditionTrashButton = ({ record, state }: Props) => {
  if (!record) return null

  // action
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)
  const dataProvider = useDataProvider()
  const onClick = useCallback(() => {
    setLoading(true)
    dataProvider
      .update("editions", {
        id: record.id,
        data: { trash: state  },
      })
      .then((edition: Edition) => {
        setError(null)
        window.location.reload()
      })
      .catch((error: Error) => {
        setError(error)
      })
      .finally(() => {
        setLoading(false)
      })
  }, [])
  const disabled = loading

  return h(Fragment, [
    h(
      Button,
      {
        label: (state === "trash" ? "Trash" : "Restore to draft"),
        onClick,
        disabled,
      },
      [state === "trash" ? h(DeleteForever) : h(RestoreFromTrash)]
    ),
  ])
}
