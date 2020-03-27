import { h } from "@cycle/react"
import { Fragment, useState } from "react"

import { Field, Input } from "."

export const Summary = () => {
  const markdown = "# Hello, world!"
  const [config, setConfig] = useState({ markdown })
  return h(Fragment, [h(Input, { config, setConfig }), h(Field, { config })])
}

export default {
  title: "EditionBodyInput / sections",
}
