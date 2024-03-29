import { Newsletter, Page, Record } from "components/admin/shared"
import jsonapiClient from "ra-jsonapi-client" // NOTE: fork https://git.io/JvnOF

const apiHost = "" // same as asset server

/// serializer configuration: https://git.io/JvGJK
const keyForAttribute = "underscore_case"

// relationship schemas
const newsletter = {
  // Th ID of child is given by its id field
  ref: (_parent: Record, child: Newsletter) => child.id,
}
const page = {
  ref: (_parent: Record, child: Page) => child.id,
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
    users: { keyForAttribute },
    units: { keyForAttribute },
    pages: { keyForAttribute },
    page_sections: { keyForAttribute },
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
    users: { keyForAttribute },
    units: { keyForAttribute, newsletter },
    pages: { keyForAttribute },
    page_sections: { keyForAttribute, page },
  },
}

export const dataProvider = jsonapiClient(`${apiHost}/api`, settings)
