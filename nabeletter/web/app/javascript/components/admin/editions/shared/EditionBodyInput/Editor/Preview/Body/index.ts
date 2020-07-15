import { h } from "@cycle/react"
import { body, table, tbody, td, tr } from "@cycle/react-dom"
import { percent, px } from "csx"
import { TypeStyle } from "typestyle"

import { LayoutTable } from "components/table"
import { colors, compileStyles, queries } from "styles"
import type { SectionField } from "../../../types"

interface Props {
  fields: SectionField[]
  typestyle: TypeStyle
  isAmp?: boolean
}

export function Body({ fields, typestyle, isAmp = false }: Props) {
  const { cssRaw, cssRule } = typestyle
  const {
    desktop: { maxWidth },
  } = queries

  // NOTE: AMP doesn't support custom fonts
  if (!isAmp) {
    cssRaw(
      `@import url('https://fonts.googleapis.com/css?family=Roboto|Roboto+Slab&display=swap');`
    )
  }

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

  const { styles, classNames } = compileStyles(typestyle, {
    body: {
      marginLeft: "auto",
      marginRight: "auto",
      backgroundColor: colors.lightGray,
    },
  })

  return body({ key: "body" }, [
    h(LayoutTable, [
      h(
        LayoutTable,
        { maxWidth, className: classNames.body, style: styles.body },
        fields
      ),
    ]),
  ])
}
