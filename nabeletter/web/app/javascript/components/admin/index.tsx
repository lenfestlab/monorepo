import * as React from "react"
import { h } from "@cycle/react"
import { Admin, Resource } from "react-admin"
import { i18nProvider } from "./i18nProvider"
import { dataProvider } from "./dataProvider"
import { authProvider } from "./authProvider"

import { NewsletterList } from "./newsletters"
import {
  EditionCreate,
  EditionEdit,
  EditionList,
  EditionShow,
} from "./editions"
import {
  SubscriptionList,
  SubscriptionCreate,
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
