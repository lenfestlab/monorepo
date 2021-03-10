import { h } from "@cycle/react"
import { DeleteForever } from "@material-ui/icons"
import {
  ChangeEvent,
  Fragment,
  MouseEvent,
  useCallback,
  useEffect,
  useState,
} from "react"
import { Button, useDataProvider } from "react-admin"

import { Edition } from "components/admin/shared"

interface Props {
  record: Edition
}

export const EditionTrashButton = ({ record }: Props) => {
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
        data: { trash: true },
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
        label: "Trash",
        onClick,
        disabled,
      },
      [h(DeleteForever)]
    ),
  ])
}
