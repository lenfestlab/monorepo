import { h } from "@cycle/react"
import * as React from "react"
import { Admin, Resource } from "react-admin"

import { create } from "rxjs-spy"
const spy = create({ defaultLogger: console, sourceMaps: true })
spy.log() // no filter, logs everything

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

export const AdminApp = () =>
  h(Admin, { dataProvider, i18nProvider, authProvider }, [
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
