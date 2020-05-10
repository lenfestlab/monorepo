import { h } from "@cycle/react"
import { body, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { media, TypeStyle } from "typestyle"

import { colors, queries } from "styles"
import type { SectionField } from "../../../types"
import { Header } from "./Header"

interface Props {
  fields: SectionField[]
  typestyle: TypeStyle
}
export function Body({ fields, typestyle }: Props) {
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

  const { mobile } = queries
  const { maxWidth: width } = mobile
  const classNames = stylesheet({
    pseudoBody: {
      marginLeft: "auto",
      marginRight: "auto",
      borderSpacing: "0px",
      backgroundColor: colors.lightGray,
    },
    section: {
      backgroundColor: colors.white,
      borderRadius: "3px",
      width,
      marginTop: px(24),
      marginBottom: px(0),
      marginRight: px(24),
      marginLeft: px(24),
      padding: px(24),
      ...media(mobile, {
        width: important(percent(100)),
        marginTop: important(px(12)),
        marginBottom: important(px(12)),
        marginRight: important(px(0)),
        marginLeft: important(px(0)),
        padding: important(px(10)),
      }),
    },
  })

  return body({ key: "body" }, [
    table({ className: classNames.pseudoBody }, [
      h(Header, { typestyle, mobile }),
      tbody([
        ...fields.map((field) =>
          tr([
            td([
              table([
                tbody([
                  tr([td([table({ className: classNames.section }, [field])])]),
                ]),
              ]),
            ]),
          ])
        ),
      ]),
    ]),
  ])
}
