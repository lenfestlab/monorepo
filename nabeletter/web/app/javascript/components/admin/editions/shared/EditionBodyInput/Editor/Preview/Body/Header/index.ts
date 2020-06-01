import { table, tbody, td, thead, tr } from "@cycle/react-dom"
import { percent, px } from "csx"
import { important } from "csx"
import { classes, media, TypeStyle } from "typestyle"

import { translate } from "i18n"
import { colors, queries } from "styles"

interface Props {
  typestyle: TypeStyle
}
export const Header = ({ typestyle }: Props) => {
  const { inner, header, headerTitle } = typestyle.stylesheet({
    inner: {},
    header: {
      width: percent(100),
      borderRadius: px(3),
      backgroundColor: colors.darkBlue,
      padding: "45px 140px 45px 140px",
      ...media(queries.mobile, {
        padding: important(px(10)),
      }),
    },
    headerTitle: {
      textAlign: "center",
      fontFamily: "Roboto Slab",
      fontSize: px(24),
      fontWeight: 600,
      color: colors.white,
    },
  })

  const title = translate("header-title")
  return thead([
    tr([
      td([
        table({ className: classes(inner, header) }, [
          tbody([
            tr([
              td([
                table({ className: classes(inner, headerTitle) }, [
                  tbody([tr([td(title)])]),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]),
    ]),
  ])
}
