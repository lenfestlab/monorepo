import { h } from "@cycle/react"
import { body, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { media, TypeStyle } from "typestyle"

import { colors, queries } from "styles"
import type { SectionField } from "../../../types"
import { AnalyticsProps, Footer } from "./Footer"
import { Header } from "./Header"

export { AnalyticsProps }

interface Props {
  fields: SectionField[]
  typestyle: TypeStyle
  analytics: AnalyticsProps
}
export function Body({ fields, typestyle, analytics }: Props) {
  const { cssRaw, cssRule, stylesheet } = typestyle
  cssRule("*", {
    margin: 0,
    padding: 0,
  })
  cssRule("html, body", {
    height: percent(100),
    fontFamily: "Roboto",
    color: "#000",
  })
  cssRule("table", {
    marginLeft: "auto",
    marginRight: "auto",
  })
  cssRaw(
    `@import url('https://fonts.googleapis.com/css?family=Roboto|Roboto+Slab&display=swap');`
  )

  const classNames = stylesheet({
    pseudoBody: {
      marginLeft: "auto",
      marginRight: "auto",
      borderSpacing: "0px",
      backgroundColor: colors.lightGray,
    },
  })

  return body({ key: "body" }, [
    table({ className: classNames.pseudoBody }, [
      h(Header, { typestyle }),
      tbody(fields),
      h(Footer, { typestyle, analytics }),
    ]),
  ])
}
