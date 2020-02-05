import { DataProvider } from "ra-core"

import jsonapiClient from "ra-jsonapi-client" // NOTE: fork https://git.io/JvnOF

const apiHost = "" // same as asset server

/// serializer configuration: https://git.io/JvGJK
const keyForAttribute = "underscore_case"

// relationship schemas
const newsletter = {
  // Th ID of child is given by its id field
  ref: (parent, child) => child.id,
}

const settings = {
  arrayFormat: "comma", // http://bit.ly/2UIFGY5
  headers: {
    Accept: "application/vnd.api+json",
    "Content-Type": "application/vnd.api+json",
  },
  deserializerOpts: {
    subscriptions: { keyForAttribute },
    editions: { keyForAttribute },
    newsletters: { keyForAttribute },
  },
  serializerOpts: {
    subscriptions: {
      keyForAttribute,
      newsletter,
    },
    editions: {
      keyForAttribute,
      newsletter,
    },
    newsletters: { keyForAttribute },
  },
}

export const dataProvider: DataProvider = jsonapiClient(apiHost, settings)
