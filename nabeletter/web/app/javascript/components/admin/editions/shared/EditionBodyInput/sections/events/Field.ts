import { h } from "@cycle/react"
import { a, img, table, tbody, td, tfoot, thead, tr } from "@cycle/react-dom"
import { format, parseISO } from "date-fns"
import getUrls from "get-urls"
import { FunctionComponent } from "react"
import { classes, media, TypeStyle } from "typestyle"

import { AnalyticsProps as AllAnalyticsProps, Link } from "analytics"
import { important, percent, px } from "csx"
import { allEmpty, either, isEmpty, last, map, reduce, values } from "fp"
import { translate } from "i18n"
import { colors, queries } from "styles"
import { Config, Event } from "."
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
  const events = config.selections
  const publicURL = config.publicURL
  const { pre, post } = config

  const classNames = typestyle?.stylesheet({
    eventContainer: {
      padding: "2px 0px 0px 0px",
      margin: px(0),
    },
    image: {
      width: percent(100),
      // hide image download button on gmail - https://bit.ly/3eWuLkg
      $nest: {
        "& div": {
          display: "none",
        },
      },
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
  const tableProps = {
    width: "100%",
    border: 0,
    cellSpacing: 0,
    cellPadding: 0,
  }
  if (allEmpty([events, pre, post])) return null
  return h(SectionField, { title, pre, post, typestyle, id, analytics }, [
    table(tableProps, [
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
          const start = format(parseISO(event.start), "EEE, d LLL y' at 'p")
          return table(
            {
              ...tableProps,
              className: classNames?.eventContainer,
            },
            [
              thead({}, [img({ className: classNames?.image, src })]),
              tbody([
                table(
                  {
                    ...tableProps,
                    className: classNames?.event,
                  },
                  [
                    tbody([
                      tr([
                        td({ className: classNames?.title }, [event.summary]),
                      ]),
                      tr([td({ className: classNames?.title }, [start])]),
                      tr([
                        td({
                          dangerouslySetInnerHTML: {
                            __html: `&nbsp;`,
                          },
                        }),
                      ]),
                      tr([
                        td({
                          className: classNames?.description,
                          dangerouslySetInnerHTML: {
                            __html: description,
                          },
                        }),
                      ]),
                    ]),
                  ]
                ),
              ]),
            ]
          )
        }),
      ]),
      publicURL &&
        tfoot([
          tr({ height: 40 }, [
            td([
              h(Link, {
                analytics,
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
