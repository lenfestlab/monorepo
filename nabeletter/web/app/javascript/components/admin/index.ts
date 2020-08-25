import { h } from "@cycle/react"
import React, { useEffect } from "react"
import {
  Admin,
  AppBar as _AppBar,
  Layout as _Layout,
  Resource,
  setSidebarVisibility,
} from "react-admin"
import { useDispatch } from "react-redux"

import { create } from "rxjs-spy"
const spy = create({ defaultLogger: console, sourceMaps: true })
if (process.env.DEBUG_RX) {
  spy.log() // no filter, logs everything
}

import {
  Create as AdCreate,
  Edit as AdEdit,
  List as AdList,
  Show as AdShow,
} from "./ads"
import {
  EditionCreate,
  EditionEdit,
  EditionList,
  EditionShow,
} from "./editions"
import { NewsletterList } from "./newsletters"
import { authProvider, dataProvider, i18nProvider } from "./providers"
import {
  SubscriptionCreate,
  SubscriptionList,
  SubscriptionShow,
} from "./subscriptions"
import { UserList } from "./users"

// NOTE: override layout to collapse nav by default
const layout = (props: any) => {
  const dispatch = useDispatch()
  useEffect(() => {
    dispatch(setSidebarVisibility(false))
  }, [setSidebarVisibility])
  return h(_Layout, { ...props })
}

export const AdminApp = () =>
  h(Admin, { layout, dataProvider, i18nProvider, authProvider }, [
    h(Resource, {
      name: "units",
      options: { label: "Ads" },
      list: AdList,
      create: AdCreate,
      show: AdShow,
      edit: AdEdit,
    }),
    h(Resource, {
      name: "editions",
      list: EditionList,
      create: EditionCreate,
      show: EditionShow,
      edit: EditionEdit,
    }),
    h(Resource, {
      name: "newsletters",
      list: NewsletterList,
    }),
    h(Resource, {
      name: "subscriptions",
      list: SubscriptionList,
      create: SubscriptionCreate,
      show: SubscriptionShow,
    }),
    h(Resource, {
      name: "users",
      list: UserList,
    }),
  ])
