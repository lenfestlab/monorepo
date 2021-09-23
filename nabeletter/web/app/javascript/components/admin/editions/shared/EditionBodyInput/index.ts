import { h } from "@cycle/react"
import { Tab, Tabs } from "@material-ui/core"
import { Email, Phone } from "@material-ui/icons"
import { Fragment, useState } from "react"

import { Edition } from "components/admin/shared"
import { EmailBodyInput } from "./EmailBodyInput"
import { SmsBodyInput } from "./SmsBodyInput"

interface Props {
  record?: Edition
}

export const EditionBodyInput = ({ record }: Props) => {
  const initialTab: number = Number(localStorage.getItem("tab") ?? 0)
  const [tab, setTab] = useState(initialTab)
  const changeTab = (idx: number) => {
    setTab(idx)
    localStorage.setItem("tab", idx.toString())
  }
  return h(Fragment, [
    h(Tabs, { value: tab, variant: "fullWidth" }, [
      h(Tab, { icon: h(Email), onClick: () => changeTab(0) }),
      h(Tab, { icon: h(Phone), onClick: () => changeTab(1) }),
    ]),
    h(Fragment, [
      tab === 0 && h(EmailBodyInput, { record }),
      h(SmsBodyInput, { record, visibility: tab === 1 ? "visible" : "hidden" }),
    ]),
  ])
}
