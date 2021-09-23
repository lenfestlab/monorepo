import { h } from "@cycle/react"
import { table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { FunctionComponent } from "react"
import { classes, media, TypeStyle } from "typestyle"

import { LayoutTable } from "components/table"
import { colors, compileStyles, queries } from "styles"
import { SectionConfig } from "."
import { AnalyticsProps, MarkdownField } from "../MarkdownField"

export interface SectionFieldProps extends SectionConfig {
  id: string
  typestyle: TypeStyle
  analytics: AnalyticsProps
  isAmp: boolean
  outerWidth?: number
}

export const SectionField: FunctionComponent<SectionFieldProps> = ({
  id,
  title,
  pre,
  post,
  typestyle,
  children,
  analytics,
  isAmp,
  outerWidth = 600,
}) => {
  const { desktop } = queries
  const { maxWidth: width } = desktop
  const hMargin = 24
  const { styles, classNames } = compileStyles(typestyle, {
    section: {
      backgroundColor: colors.white,
      borderRadius: "3px",
      width,
      marginTop: px(24),
      marginBottom: px(0),
      marginRight: px(hMargin),
      marginLeft: px(hMargin),
      padding: px(24),
      ...(!isAmp &&
        media(desktop, {
          width: important(percent(100)),
          marginTop: important(px(12)),
          marginBottom: important(px(12)),
          marginRight: important(px(0)),
          marginLeft: important(px(0)),
          padding: important(px(10)),
        })),
    },
    sectionTitle: {
      fontFamily: "Roboto Slab, Roboto, sans-serif",
      fontSize: px(20),
      fontWeight: 500,
      textAlign: "center",
      color: colors.black,
      paddingBottom: px(20),
      ...(!isAmp &&
        media(queries.mobile, {
          padding: important(px(10)),
        })),
    },
    sectionContent: {
      textAlign: "center",
      fontFamily: "Roboto",
    },
    sectionPreOrPost: {
      textAlign: "left",
      fontFamily: "Roboto",
      fontSize: px(16),
      color: colors.black,
      $nest: {
        "& h1,h2,h3,h4,h5,h6": {
          paddingBottom: px(20),
          ...(!isAmp &&
            media(queries.mobile, {
              padding: important(px(10)),
            })),
        },
        "& h2,h3,h4,h5,h6": {
          fontSize: px(18),
        },
        "& img": {
          maxWidth: px(400),
        },
      },
    },
    sectionPre: {
      paddingBottom: px(20),
    },
    sectionPost: {
      paddingTop: px(20),
    },
  })

  const maxWidth = outerWidth - 2 * hMargin
  return tr([
    td([
      h(
        LayoutTable,
        { maxWidth, style: styles.section, className: classNames.section },
        [
          tbody({ id }, [
            tr([
              td(
                {
                  style: styles.sectionTitle,
                  className: classNames.sectionTitle,
                },
                title
              ),
            ]),
            pre &&
              tr([
                td(
                  {
                    style: { ...styles.sectionPreOrPost, ...styles.sectionPre },
                    className: classes(
                      classNames.sectionPreOrPost,
                      classNames.sectionPre
                    ),
                  },
                  [
                    h(MarkdownField, {
                      typestyle,
                      markdown: pre,
                      analytics,
                      isAmp,
                    }),
                  ]
                ),
              ]),
            tr([
              td(
                {
                  style: styles.sectionContent,
                  className: classNames.sectionContent,
                },
                [children]
              ),
            ]),
            post &&
              tr([
                td(
                  {
                    style: {
                      ...styles.sectionPreOrPost,
                      ...styles.sectionPost,
                    },
                    className: classes(
                      classNames.sectionPreOrPost,
                      classNames.sectionPost
                    ),
                  },
                  [
                    h(MarkdownField, {
                      typestyle,
                      markdown: post,
                      analytics,
                      isAmp,
                    }),
                  ]
                ),
              ]),
          ]),
        ]
      ),
    ]),
  ])
}
