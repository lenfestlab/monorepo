import { h } from "@cycle/react"
import { a, div, i, img, span, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { format, parseISO } from "date-fns"
import { media, TypeStyle } from "typestyle"

import { AnalyticsProps as AllAnalyticsProps, Link } from "analytics"
import { LayoutTable } from "components/table"
import { allEmpty, chunk, either, isEmpty } from "fp"
import { translate } from "i18n"
import { colors, compileStyles, queries } from "styles"
import type { Config } from "."
import { SectionField, SectionFieldProps } from "../section/SectionField"

export interface Props extends SectionFieldProps {
  kind: string
  config: Config
}

export const Field = ({
  config,
  typestyle,
  id,
  kind,
  analytics,
  isAmp,
}: Props) => {
  const title = either(
    config.title,
    translate(`${kind}-input-title-placeholder`)
  )
  const { articles, pre, post } = config
  if (allEmpty([pre, post, articles])) return null

  const width: number = articles.length > 1 ? 50 : 100
  const { styles, classNames } = compileStyles(typestyle!, {
    article: {
      paddingBottom: px(20),
      width: percent(width),
      ...(!isAmp &&
        media(queries.mobile, {
          width: important(percent(100)),
        })),
    },
    image: {
      objectFit: "cover",
      width: percent(100),
      display: "block",
    },
    link: {
      color: colors.black,
      textDecoration: "none",
      textAlign: "left",
      $nest: {
        "& div": {
          paddingTop: px(5),
        },
      },
    },
    title: {
      paddingTop: px(5),
      fontWeight: 500,
      fontSize: px(16),
      ...(!isAmp &&
        media(queries.mobile, {
          fontSize: important(px(18)),
        })),
    },
    published: {
      fontWeight: "normal",
      fontStyle: "itallic",
    },
    description: {
      fontSize: px(14),
      fontWeight: 300,
      lineHeight: "normal",
      color: colors.black,
      ...(!isAmp &&
        media(queries.mobile, {
          fontSize: important(px(16)),
          lineHeight: important(1.5),
        })),
    },
    site: {
      fontWeight: 500,
      color: colors.darkBlue,
      textDecoration: "underline",
    },
  })

  return h(
    SectionField,
    { title, typestyle, id, pre, post, analytics, isAmp },
    [
      h(LayoutTable, [
        tbody([
          ...chunk(articles).map((articlePair) => {
            return tr([
              ...articlePair.map((article) => {
                const {
                  url,
                  title,
                  description,
                  site_name,
                  image: src,
                  published_time,
                } = article

                const published =
                  published_time &&
                  format(parseISO(published_time), "MMMM d, y")

                return td(
                  {
                    style: styles.article,
                    className: classNames.article,
                  },
                  [
                    h(
                      Link,
                      {
                        url,
                        analytics,
                        title,
                        style: styles.link,
                        className: classNames.link,
                      },
                      [
                        // TODO: cached image
                        src &&
                          img({
                            src,
                            style: styles.image,
                            className: classNames.image,
                          }),
                        title &&
                          div(
                            {
                              style: styles.title,
                              className: classNames.title,
                            },
                            title
                          ),
                        published &&
                          div(
                            {
                              style: styles.published,
                              className: classNames.published,
                            },
                            [i(published)]
                          ),
                        description &&
                          div(
                            {
                              style: styles.description,
                              className: classNames.description,
                            },
                            description
                          ),
                        site_name &&
                          div(
                            {
                              style: styles.site,
                              className: classNames.site,
                            },
                            site_name
                          ),
                      ]
                    ),
                  ]
                )
              }),
            ])
          }),
        ]),
      ]),
    ]
  )
}
