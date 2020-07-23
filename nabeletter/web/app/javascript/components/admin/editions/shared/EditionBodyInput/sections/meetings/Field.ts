import { h } from "@cycle/react"
import { a, b, br, div, img, tbody, td, tr } from "@cycle/react-dom"
import { format, parseISO } from "date-fns"
import { stringifyUrl } from "query-string"
import { Fragment, FunctionComponent } from "react"
import { classes, media, TypeStyle } from "typestyle"

import {
  AnalyticsProps as AllAnalyticsProps,
  Link,
  rewriteURL,
} from "analytics"
import { LayoutTable } from "components/table"
import { percent, px } from "csx"
import { allEmpty, either, first, isEmpty, last, map, reduce, values } from "fp"
import { translate } from "i18n"
import { colors, compileStyles, queries, StyleMap } from "styles"
import { Config, Event } from "."
import { SectionField, SectionFieldProps } from "../section/SectionField"

interface Props extends SectionFieldProps {
  kind: string
  config: Config
}

export const Field: FunctionComponent<Props> = ({
  config,
  typestyle,
  id,
  kind,
  analytics,
  isAmp,
}) => {
  const title = either(
    config.title,
    translate(`${kind}-input-title-placeholder`)
  )
  const { pre, post } = config
  const events = config.selections
  if (allEmpty([events, pre, post])) return null

  const { styles, classNames } = compileStyles(typestyle!, {
    eventContainer: {
      textAlign: "left",
      paddingBottom: px(20),
      lineHeight: px(24),
      fontFamily: "Roboto, sans-serif",
      fontSize: px(16),
      fontWeight: "normal",
    },
    event: {
      paddingBottom: px(10),
    },
    title: {
      fontWeight: "bold",
    },
    description: {},
    reminderLink: {
      color: colors.black,
    },
  })

  return h(
    SectionField,
    { title, pre, post, typestyle, id, analytics, isAmp },
    [
      h(LayoutTable, [
        tbody([
          events.map((event) => {
            const title = event.summary

            let description = event.description
            const parser = new DOMParser()
            const doc = parser.parseFromString(description, "text/html")
            const links = doc.querySelectorAll("a")
            // replace all links w/ analytics links
            doc.querySelectorAll("a").forEach((link) => {
              const href = rewriteURL(link.href, {
                ...analytics,
                title: link.innerHTML,
              })
              link.target = "_blank"
              link.href = href
            })
            description = doc.documentElement.innerHTML

            const startsAt = format(
              parseISO(event.dstart),
              "EEE, d LLL y' at 'p"
            )

            const location = event.location.includes("zoom")
              ? translate("meetings-field-zoom-link")
              : first(event.location?.split(","))

            const endpoint = process.env.ICS_ENDPOINT!
            const url = stringifyUrl({
              url: endpoint,
              query: {
                ...event,
              },
            })

            return h(
              LayoutTable,
              {
                style: styles.eventContainer,
                className: classNames.eventContainer,
              },
              [
                tr([
                  td({ style: styles.event, className: classNames.event }, [
                    div(
                      {
                        style: styles.title,
                        className: classNames.title,
                      },
                      [title]
                    ),
                    div(
                      {
                        style: styles.title,
                        className: classNames.title,
                      },
                      [startsAt]
                    ),
                    div({
                      style: styles.description,
                      className: classNames.description,
                      dangerouslySetInnerHTML: {
                        __html: description,
                      },
                    }),
                  ]),
                ]),
                tr([
                  td([
                    b(location),
                    br(),
                    h(Link, {
                      analytics,
                      url,
                      style: styles.reminderLink,
                      className: classNames.reminderLink,
                      title: translate("meetings-field-set-reminder"),
                    }),
                  ]),
                ]),
              ]
            )
          }),
        ]),
      ]),
    ]
  )
}
