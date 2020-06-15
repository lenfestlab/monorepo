import { h } from "@cycle/react"
import { a, div, img, span, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { format, parseISO } from "date-fns"
import { classes, media, TypeStyle } from "typestyle"

import { AnalyticsProps as AllAnalyticsProps, Link } from "analytics"
import { allEmpty, chunk, either, isEmpty } from "fp"
import { translate } from "i18n"
import { colors, queries } from "styles"
import type { Article, Config } from "."
import { SectionField } from "../section/SectionField"

export interface Props {
  kind: string
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: Omit<AllAnalyticsProps, "title">
}
export const Field = ({ config, typestyle, id, kind, analytics }: Props) => {
  const title = either(
    config.title,
    translate(`${kind}-input-title-placeholder`)
  )
  const { articles, pre, post } = config
  if (allEmpty([pre, post, articles])) return null

  const width: number = articles.length > 1 ? 50 : 100
  const classNames = typestyle?.stylesheet({
    article: {
      paddingBottom: px(20),
      width: percent(width),
      ...media(queries.mobile, {
        width: important(percent(100)),
      }),
    },
    image: {
      objectFit: "cover",
      width: percent(100),
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
      fontWeight: 500,
      fontSize: px(16),
      ...media(queries.mobile, {
        fontSize: important(px(18)),
      }),
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
      ...media(queries.mobile, {
        fontSize: important(px(16)),
        lineHeight: important(1.5),
      }),
    },
    site: {
      fontWeight: 500,
      color: colors.darkBlue,
      textDecoration: "underline",
    },
  })
  return h(SectionField, { title, typestyle, id, pre, post, analytics }, [
    table({ border: 0, cellPadding: 0, cellSpacing: 0 }, [
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
                published_time && format(parseISO(published_time), "MMMM L, y")
              return td(
                {
                  className: classNames?.article,
                },
                [
                  h(
                    Link,
                    {
                      url,
                      analytics,
                      title,
                      className: classNames?.link,
                    },
                    [
                      src && img({ className: classNames?.image, src }),
                      title && div({ className: classNames?.title }, title),
                      published &&
                        div({ className: classNames?.published }, published),
                      description &&
                        div(
                          { className: classNames?.description },
                          description
                        ),
                      site_name &&
                        div({ className: classNames?.site }, site_name),
                    ]
                  ),
                ]
              )
            }),
          ])
        }),
      ]),
    ]),
  ])
}
