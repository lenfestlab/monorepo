import { h } from "@cycle/react"
import {
  Box,
  Popover,
  PopoverOrigin,
  TextareaAutosize,
  TextField,
  Typography,
} from "@material-ui/core"
import { Drafts, PhoneCallback } from "@material-ui/icons"
import {
  ChangeEvent,
  Fragment,
  MouseEvent,
  useCallback,
  useEffect,
  useState,
} from "react"
import { Button, useDataProvider } from "react-admin"

import { Channel, Edition, Lang } from "components/admin/shared"

interface Props {
  record?: Edition
  channel: Channel
  lang: Lang
}

export const TestDeliveryButton = ({ record, channel, lang }: Props) => {
  if (!record) return null

  // recipients textfield
  const cacheKey = `edition.test.${channel}`
  const [value, setValue] = useState<string>(
    localStorage.getItem(cacheKey) ?? ""
  )
  const onChange = (event: ChangeEvent<HTMLTextAreaElement>) => {
    const newValue = event.target.value as string
    localStorage.setItem(cacheKey, newValue)
    setValue(newValue)
  }
  const placeholder = {
    email: "foo@example.com, bar@example.com, ...",
    sms: "123-456-7890, ...",
  }[channel]

  // popover
  const [anchorEl, setAnchorEl] = useState<HTMLButtonElement | null>(null)
  const openPopover = (event: MouseEvent<HTMLButtonElement>) => {
    setAnchorEl(event.currentTarget)
  }
  const onClose = () => {
    setAnchorEl(null)
  }
  const open = Boolean(anchorEl)
  const id = open ? "popover" : undefined
  const anchorOrigin: PopoverOrigin = {
    vertical: "top",
    horizontal: "right",
  }
  const transformOrigin: PopoverOrigin = {
    vertical: "top",
    horizontal: "right",
  }

  // action
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)
  const dataProvider = useDataProvider()
  const onClick = useCallback(() => {
    setLoading(true)
    dataProvider
      .update("editions", {
        id: record.id,
        data: { test: true, recipients: value, channel, lang },
      })
      .then((edition: Edition) => {
        setError(null)
        onClose()
      })
      .catch((error: Error) => {
        setError(error)
      })
      .finally(() => {
        setLoading(false)
      })
  }, [value])
  const isDeliverable: boolean = record.body_html && true
  const disabled = !isDeliverable || loading
  const icon = {
    email: h(Drafts),
    sms: h(PhoneCallback),
  }[channel]

  return h(Fragment, [
    h(
      Button,
      {
        label: isDeliverable
          ? "Test delivery"
          : "Please edit body to test delivery",
        onClick: openPopover,
        disabled,
      },
      [icon]
    ),
    h(
      Popover,
      {
        key: "pop",
        id,
        open,
        onClose,
        anchorEl,
        anchorOrigin,
        transformOrigin,
      },
      [
        h(Box, { display: "flex", flexDirection: "column", padding: 1 }, [
          h(Typography, { gutterBottom: true }, "Recipients"),
          h(TextareaAutosize, {
            onChange,
            value,
            placeholder,
            rowsMin: 10,
            style: { width: 300 },
          }),
          h(Button, {
            label: "Send",
            disabled,
            onClick,
          }),
          error && h(Typography, { color: "error" }, JSON.stringify(error)),
        ]),
      ]
    ),
  ])
}
