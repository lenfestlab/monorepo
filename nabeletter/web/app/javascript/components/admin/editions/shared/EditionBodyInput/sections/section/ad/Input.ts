import { h } from "@cycle/react"
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  TextField,
} from "@material-ui/core"
import { anyEmpty, compact } from "fp"
import { translate } from "i18n"
import { Fragment, useCallback, useMemo, useState } from "react"
import { AdOpt } from "."
import { ImageList } from "../../ImageList"

interface Props {
  ad: AdOpt
  setAd: (ad: AdOpt) => void
}

export const Input = ({ ad, setAd }: Props) => {
  const [open, setOpen] = useState<boolean>(false)
  const onClickOpen = (_: any) => setOpen(true)
  const onClickCancel = (_: any) => setOpen(false)
  const onClickDelete = (el: any) => {
    setAd(undefined)
  }
  const onClickSave = (ad: AdOpt) => {
    setAd(ad)
    setOpen(false)
  }

  return h(
    Fragment,
    compact([
      h(
        Button,
        { onClick: onClickOpen, color: "primary" },
        translate(ad ? `ad-input-edit` : `ad-input-set`)
      ),
      ad &&
        h(ImageList, {
          cellHeight: "auto",
          tiles: [
            {
              url: ad.image.src,
              caption: `alt: "${ad.image.alt}"`,
              onClickDelete,
            },
          ],
        }),
      h(AdDialogue, { ad, onClickCancel, onClickSave, open }),
    ])
  )
}

interface AdDialogueProps {
  ad: AdOpt
  onClickCancel: (_: any) => void
  onClickSave: (ad: AdOpt) => void
  open: boolean
}

function AdDialogue({ ad, onClickSave, onClickCancel, open }: AdDialogueProps) {
  const [alt, setAlt] = useState(ad?.image.alt ?? "")
  const [href, setHref] = useState(ad?.image.href ?? "")
  const [src, setSrc] = useState(ad?.image.src ?? "")

  const onClick = useCallback(() => {
    onClickSave({
      image: {
        alt,
        href,
        src,
      },
    })
  }, [alt, href, src])

  const disabled = useMemo<boolean>(() => {
    return anyEmpty([alt, href, src])
  }, [alt, href, src])

  return h(Dialog, { open, fullWidth: true, maxWidth: "md" }, [
    h(DialogContent, [
      h(TextField, {
        label: translate("ad-input-dialogue-url-label"),
        autoFocus: true,
        margin: "dense",
        fullWidth: true,
        multiline: false,
        variant: "filled",
        required: true,
        placeholder: translate("ad-input-dialogue-url-placeholder"),
        value: src,
        onChange: (event: React.ChangeEvent<HTMLInputElement>) => {
          setSrc(event.target.value as string)
        },
      }),
      h(TextField, {
        label: translate("ad-input-dialogue-href-label"),
        margin: "dense",
        fullWidth: true,
        multiline: false,
        variant: "filled",
        required: true,
        placeholder: translate("ad-input-dialogue-href-placeholder"),
        value: href,
        onChange: (event: React.ChangeEvent<HTMLInputElement>) => {
          setHref(event.target.value as string)
        },
      }),
      h(TextField, {
        label: translate("ad-input-dialogue-alt-label"),
        margin: "dense",
        fullWidth: true,
        multiline: false,
        variant: "filled",
        required: true,
        placeholder: translate("ad-input-dialogue-alt-placeholder"),
        value: alt,
        onChange: (event: React.ChangeEvent<HTMLInputElement>) => {
          setAlt(event.target.value as string)
        },
      }),
    ]),
    h(DialogActions, [
      h(Button, { color: "primary", onClick: onClickCancel }, "Cancel"),
      h(Button, { color: "primary", onClick, disabled }, "Save"),
    ]),
  ])
}
