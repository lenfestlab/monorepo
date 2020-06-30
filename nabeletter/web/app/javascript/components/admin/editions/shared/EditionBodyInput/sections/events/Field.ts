import { h } from "@cycle/react"
import { a, img, table, tbody, td, tfoot, thead, tr } from "@cycle/react-dom"
import { format, parseISO } from "date-fns"
import { Fragment, FunctionComponent } from "react"
import { classes, media, TypeStyle } from "typestyle"

import { AnalyticsProps as AllAnalyticsProps, Link } from "analytics"
import { LayoutTable } from "components/table"
import { percent, px } from "csx"
import { allEmpty, either, isEmpty, last, map, reduce, values } from "fp"
import { translate } from "i18n"
import { colors, compileStyles, queries, StyleMap } from "styles"
import { Config, Event } from "."
import { CachedImage } from "../CachedImage"
import { SectionField } from "../section/SectionField"

interface Props {
  kind: string
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: Omit<AllAnalyticsProps, "title">
}

export const Field: FunctionComponent<Props> = ({
  config,
  typestyle,
  id,
  kind,
  analytics,
}) => {
  const title = either(
    config.title,
    translate(`${kind}-input-title-placeholder`)
  )
  const { pre, post } = config
  const events = config.selections
  const publicURL = config.publicURL
  if (allEmpty([events, pre, post])) return null

  const { styles, classNames } = compileStyles(typestyle!, {
    eventContainer: {
      padding: "2px 0px 0px 0px",
      margin: px(0),
    },
    image: {
      width: percent(100),
      display: "block", // https://bit.ly/2VUo8rP
    },
    event: {
      width: percent(100),
      textAlign: "left",
      backgroundColor: colors.darkBlue,
      color: colors.white,
      fontSize: px(18),
      fontWeight: "normal",
      padding: "12px 24px 12px 24px",
    },
    title: {
      fontWeight: 900,
    },
    description: {
      $nest: {
        "& a": {
          color: colors.white,
        },
      },
    },
    more: {
      fontSize: px(20),
      fontWeight: 500,
      fontStyle: "italic",
      color: colors.darkBlue,
      textDecoration: "none",
      paddingTop: px(24),
      paddingBottom: px(24),
    },
  })

  const moreTitle = translate("events-field-more")
  const maxWidth = queries.mobile.maxWidth - 2 * 24

  return h(SectionField, { title, pre, post, typestyle, id, analytics }, [
    h(LayoutTable, [
      tbody([
        events.map((event) => {
          let description = event.description
          const parser = new DOMParser()
          const doc = parser.parseFromString(description, "text/html")
          const links = doc.querySelectorAll("a")
          const link = last(links)
          const src = link?.href
          // remove img link from description
          link?.parentNode?.removeChild(link)
          description = doc.documentElement.innerHTML
          const startsAt = format(parseISO(event.dstart), "EEE, d LLL y' at 'p")

          return h(
            LayoutTable,
            {
              style: styles.eventContainer,
              className: classNames.eventContainer,
            },
            [
              tr([
                td([
                  src &&
                    h(CachedImage, {
                      src,
                      alt: event.summary,
                      style: styles.image,
                      className: classNames.image,
                      maxWidth,
                    }),
                  h(
                    LayoutTable,
                    { style: styles.event, className: classNames.event },
                    [
                      tr([
                        td(
                          {
                            style: styles.title,
                            className: classNames.title,
                          },
                          [event.summary]
                        ),
                      ]),
                      tr([
                        td(
                          {
                            style: styles.title,
                            className: classNames.title,
                          },
                          [startsAt]
                        ),
                      ]),
                      description &&
                        tr([
                          td({
                            dangerouslySetInnerHTML: {
                              __html: `&nbsp;`,
                            },
                          }),
                        ]),
                      description &&
                        tr([
                          td({
                            style: styles.description,
                            className: classNames.description,
                            dangerouslySetInnerHTML: {
                              __html: description,
                            },
                          }),
                        ]),
                    ]
                  ),
                ]),
              ]),
            ]
          )
        }),
        publicURL &&
          tr({ height: 40, style: { textAlign: "left" } }, [
            td([
              h(Link, {
                analytics,
                style: styles.more,
                className: classNames?.more,
                url: publicURL,
                title: moreTitle,
              }),
            ]),
          ]),
      ]),
    ]),
  ])
}
