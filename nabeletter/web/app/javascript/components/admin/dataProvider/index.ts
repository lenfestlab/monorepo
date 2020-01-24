import jsonapiClient from "ra-jsonapi-client"
import join from "lodash/join"
import map from "lodash/map"

const apiHost = "" // same as asset server

// TODO: transforms JSON:API errors into notification message
// http://bit.ly/2S7QEDs
const messageCreator = ({ errors }) => join(map(errors, "detail"), ", ")

/// serializer configuration: https://git.io/JvGJK
const keyForAttribute = "underscore_case"
const settings = {
  deserializerOpts: {
    subscriptions: { keyForAttribute },
    editions: { keyForAttribute },
  },
  serializerOpts: {
    subscriptions: { keyForAttribute },
    editions: { keyForAttribute },
  },
}

export const dataProvider = jsonapiClient(apiHost, settings)
