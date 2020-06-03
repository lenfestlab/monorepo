import { table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
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
  const { mobile } = queries
  const { maxWidth: width } = mobile
  const classNames = typestyle?.stylesheet({
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
    sectionTitle: {
      fontFamily: "Roboto Slab, Roboto, sans-serif",
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

  return tr([
    td([
      table([
        tbody([
          tr([
            td([
              table({ className: classNames?.section }, [
                tbody({ id }, [
                  tr([td({ className: classNames?.sectionTitle }, title)]),
                  tr([
                    td({ className: classNames?.sectionContent }, [children]),
                  ]),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]),
  ])
}
