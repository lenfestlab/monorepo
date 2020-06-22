import { h } from "@cycle/react"
import { table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { FunctionComponent } from "react"
import { classes, media, TypeStyle } from "typestyle"

import { colors, queries } from "styles"
import { SectionConfig } from "."
import { AnalyticsProps, MarkdownField } from "../MarkdownField"

export interface SectionFieldProps extends SectionConfig {
  id: string
  typestyle?: TypeStyle
  analytics: AnalyticsProps
}

export const SectionField: FunctionComponent<SectionFieldProps> = ({
  id,
  title,
  pre,
  post,
  typestyle,
  children,
  analytics,
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
    sectionPreOrPost: {
      textAlign: "center",
      fontFamily: "Roboto",
      $nest: {
        "& h2,h3,h4,h5,h6": {
          fontSize: px(18),
          paddingBottom: px(20),
          ...media(queries.mobile, {
            padding: important(px(10)),
          }),
        },
        "& img": {
          maxWidth: px(400),
        },
      },
      fontSize: important(px(16)),
      color: important(colors.black),
    },
    sectionPre: {
      paddingBottom: px(20),
    },
    sectionPost: {
      paddingTop: px(20),
    },
  })

  return tr({ width: "100%" }, [
    td([
      table({ width: "100%" }, [
        tbody({ width: "100%" }, [
          tr({ width: "100%" }, [
            td({ width: "100%" }, [
              table({ className: classNames?.section }, [
                tbody({ id }, [
                  tr([td({ className: classNames?.sectionTitle }, title)]),
                  pre &&
                    tr([
                      td(
                        {
                          className: classes(
                            classNames?.sectionPreOrPost,
                            classNames?.sectionPre
                          ),
                        },
                        [h(MarkdownField, { markdown: pre, analytics })]
                      ),
                    ]),
                  tr([
                    td({ className: classNames?.sectionContent }, [children]),
                  ]),
                  post &&
                    tr([
                      td(
                        {
                          className: classes(
                            classNames?.sectionPreOrPost,
                            classNames?.sectionPost
                          ),
                        },
                        [h(MarkdownField, { markdown: post, analytics })]
                      ),
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
