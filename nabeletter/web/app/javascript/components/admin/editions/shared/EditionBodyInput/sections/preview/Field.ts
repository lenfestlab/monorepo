import { h } from "@cycle/react"
import { div, td, tr } from "@cycle/react-dom"
import { px } from "csx"
import { types } from "typestyle"

import { isEmpty } from "fp"
import { Config } from "."

export interface Props {
  config: Config
}

export const Field = ({ config }: Props) => {
  const text = config.text
  if (isEmpty(text)) return null

  const style: types.NestedCSSProperties = {
    display: "none",
    maxHeight: px(0),
    overflow: "hidden",
  }

  return tr({ style }, [
    td({ style }, [
      // src: https://bit.ly/3dzW6rj
      div({ style }, text),
      div({
        style,
        dangerouslySetInnerHTML: {
          __html: `&nbsp;&zwnj;`.repeat(90),
        },
      }),
    ]),
  ])
}
