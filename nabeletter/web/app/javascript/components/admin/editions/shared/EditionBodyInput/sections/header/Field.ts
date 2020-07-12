import { table, tbody, td, thead, tr } from "@cycle/react-dom"
import { percent, px } from "csx"
import { important } from "csx"
import { media, TypeStyle } from "typestyle"

import { AnalyticsProps } from "analytics"
import { translate } from "i18n"
import { compileStyles } from "styles"
import { colors, queries } from "styles"
import { Config } from "."
import { SectionFieldProps } from "../section/SectionField"

interface Props extends SectionFieldProps {
  config: Config
}

export const Field = ({ typestyle, isAmp }: Props) => {
  const { styles, classNames } = compileStyles(typestyle!, {
    header: {
      width: percent(100),
      borderRadius: px(3),
      backgroundColor: colors.darkBlue,
      padding: "45px 140px 45px 140px",
      ...(!isAmp &&
        media(queries.mobile, {
          padding: important(px(10)),
        })),
    },
    headerTitle: {
      textAlign: "center",
      fontFamily: "Roboto Slab, Roboto, sans-serif",
      fontSize: px(24),
      fontWeight: 600,
      color: colors.white,
    },
  })

  const title = translate("header-title")

  return tr([
    td([
      table({ className: classNames.header, style: styles.header }, [
        tr([
          td(
            {
              className: classNames.headerTitle,
              style: styles.headerTitle,
            },
            [title]
          ),
        ]),
      ]),
    ]),
  ])
}
