import { tbody, td, tr } from "@cycle/react-dom"
import { important, px } from "csx"
import { FunctionComponent } from "react"
import { media, TypeStyle } from "typestyle"

import { colors, queries } from "styles"

export interface SectionFieldProps {
  id: string
  title: string
  typestyle?: TypeStyle
}
export const SectionField: FunctionComponent<SectionFieldProps> = ({
  id,
  title,
  typestyle,
  children,
}) => {
  const classNames = typestyle?.stylesheet({
    sectionTitle: {
      fontFamily: "Roboto Slab",
      fontSize: px(20),
      fontWeight: 500,
      textAlign: "center",
      color: colors.black,
      paddingBottom: px(20),
      ...media(queries.mobile, {
        padding: important(px(10)),
      }),
    },
    sectionContent: {
      textAlign: "center",
      fontFamily: "Roboto",
    },
  })

  return tbody({ id }, [
    tr([td({ className: classNames?.sectionTitle }, title)]),
    tr([td({ className: classNames?.sectionContent }, [children])]),
  ])
}
