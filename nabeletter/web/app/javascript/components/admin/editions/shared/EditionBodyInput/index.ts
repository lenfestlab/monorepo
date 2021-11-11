import { h } from "@cycle/react"
import { Tab, Tabs } from "@material-ui/core"
import { Email, Phone } from "@material-ui/icons"
import { Fragment, useState } from "react"

import { Edition, Lang } from "components/admin/shared"
import { EmailBodyInput } from "./EmailBodyInput"
import { SmsBodyInput } from "./SmsBodyInput"

interface Props {
  record?: Edition
}

export const EditionBodyInput = ({ record }: Props) => {
  // TODO: dynamic lang selection
  // const initialLang: Lang =
  //   (localStorage.getItem("lang") === Lang.en
  //     ? Lang.en
  //     : Lang.es)
  //   ?? Lang.en
  // const [lang, setLang] = useState<Lang>(initialLang)
  // const changeLang = (lang: Lang) => {
  //   setLang(lang)
  //   localStorage.setItem("lang", lang)
  // }
  const initialTab: number = Number(localStorage.getItem("tab") ?? 0)
  const [tab, setTab] = useState(initialTab)
  const changeTab = (idx: number) => {
    setTab(idx)
    localStorage.setItem("tab", idx.toString())
  }
  return h(Fragment, [
    // h(Tabs, { value: (lang === Lang.en ? 0 : 1) }, [
    //   h(Tab, { label: "English", onClick: () => changeLang(Lang.en) }),
    //   h(Tab, { label: "Español", onClick: () => changeLang(Lang.es) }),
    // ]),
    h(Tabs, { value: tab, variant: "fullWidth" }, [
      h(Tab, { label: "English", icon: h(Email), onClick: () => changeTab(0) }),
      h(Tab, { label: "Español", icon: h(Phone), onClick: () => changeTab(1) }),
    ]),
    h(Fragment, [
      h(EmailBodyInput, {
        record,
        lang: Lang.en,
        visibility: tab === 0 ? "visible" : "hidden",
      }),
      h(SmsBodyInput, {
        record,
        lang: Lang.es,
        visibility: tab === 1 ? "visible" : "hidden",
      }),
    ]),
  ])
}
