import React, { Fragment } from "react"
import { h } from "@cycle/react"
import { Admin, Resource } from "react-admin"

import jsonServerProvider from "ra-data-json-server"
const apiHost = "" // same as asset server
const dataProvider = jsonServerProvider(apiHost)

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

export const AdminApp = () =>
  h(Admin, { dataProvider: dataProvider }, [
    h(Resource, {
      name: "newsletters",
      list: NewsletterList,
    }),
    h(Resource, {
      name: "editions",
      list: EditionList,
      create: EditionCreate,
      show: EditionShow,
      edit: EditionEdit,
    }),
    h(Resource, {
      name: "subscriptions",
      list: SubscriptionList,
      create: SubscriptionCreate,
      show: SubscriptionShow,
    }),
  ])
