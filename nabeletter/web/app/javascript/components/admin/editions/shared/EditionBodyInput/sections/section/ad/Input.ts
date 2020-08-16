import { h } from "@cycle/react"
import {
  Button,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  TextField,
} from "@material-ui/core"
import { dataProvider } from "components/admin/providers"
import { Ad } from "components/admin/shared"
import { anyEmpty, compact, find, isEmpty, isPresent } from "fp"
import { translate } from "i18n"
import { Fragment, useCallback, useMemo, useState } from "react"
import { useAsync } from "react-use"
import { AdOpt } from "."
import { ImageList } from "../../ImageList"
import { Option, Select } from "./Select"

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

interface GetAdsResponse {
  data: Ad[]
  total: number
}

function AdDialogue({ ad, onClickSave, onClickCancel, open }: AdDialogueProps) {
  const [alt, setAlt] = useState(ad?.image.alt ?? "")
  const [href, setHref] = useState(ad?.image.href ?? "")
  const [aid, setAid] = useState(ad?.id ?? "")

  const disabled = useMemo<boolean>(() => {
    return anyEmpty([alt, href, aid])
  }, [alt, href, aid])

  const { loading, value: ads, error } = useAsync(async () => {
    const response: GetAdsResponse = await dataProvider("GET_LIST", "ads", {
      pagination: { page: 1, perPage: 25 },
      sort: { order: "ASC" },
    })
    return response.data.filter((ad) => !isEmpty(ad.screenshot_url))
  }, [open])

  const options: Option[] = isEmpty(ads)
    ? []
    : ads!.map((ad) => {
        return {
          name: ad.title,
          value: ad.id as string,
        }
      })

  const onClick = useCallback(() => {
    const ad = find(ads, (ad) => ad.id === aid)
    if (isPresent(ad)) {
      const id = ad!.id as string
      const src = ad!.screenshot_url!
      onClickSave({
        id,
        image: {
          alt,
          href,
          src,
        },
      })
    } else {
      alert("Oops! Ad ID missing")
    }
  }, [alt, href, aid])

  return h(Dialog, { open, fullWidth: true, maxWidth: "md" }, [
    h(DialogContent, [
      loading
        ? h(CircularProgress, {
            size: 20,
            disableShrink: true,
          })
        : h(Select, {
            label: translate("ad-input-dialogue-src-label"),
            options,
            value: aid,
            onChange: (value) => setAid(value),
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
