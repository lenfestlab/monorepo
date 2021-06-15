import { link, rewriteDomLinks } from "analytics"
import { important, px } from "csx"
import { parseISO } from "date-fns"
import { allEmpty, compact, either, last } from "fp"
import { format, FORMAT_GCAL, FORMAT_LONG, translate, UTC } from "i18n"
import { column, image, Node, text } from "mjml-json"
import { stringifyUrl } from "query-string"
import { colors } from "styles"
import { Config } from "."
import { cardSection, cardWrapper, SectionNodeProps } from "../section"

export interface Props extends SectionNodeProps {
  config: Config
}

export const node = ({
  context: { edition },
  analytics,
  config,
  typestyle,
}: Props): Node | null => {
  const NABE_NAME = edition.newsletter_name
  const timezone = edition.newsletter_timezone
  const title = either(
    config.title,
    translate(`events-input-title-placeholder`).replace("NABE_NAME", NABE_NAME)
  )
  const { pre, post, post_es, ad } = config
  const events = config.selections
  const moreURL = process.env.SECTION_EVENTS_DEFAULT_MORE_URL! as string
  const publicURL = config.publicURL
  if (allEmpty([events, pre, post, post_es, ad])) return null

  const styles = {
    autolinks: {
      color: important(colors.white),
      $nest: {
        "& a": {
          color: important(colors.white),
        },
      },
    },
    more: {
      fontSize: px(16),
      fontWeight: 500,
      fontStyle: "italic",
      color: colors.darkBlue,
      textDecoration: "underline",
    },
  }
  const classNames = typestyle.stylesheet(styles)

  return cardWrapper(
    { title, pre, post, post_es, ad, analytics, typestyle },
    compact([
      ...events.map((event) => {
        let description = event.description
        const parser = new DOMParser()
        const doc = parser.parseFromString(description, "text/html")
        const docLinks = doc.querySelectorAll("a")
        const docLink = last(docLinks)
        const src = docLink?.href
        // remove img link from description
        docLink?.parentNode?.removeChild(docLink)
        // analyze links
        description = rewriteDomLinks(doc.documentElement.innerHTML, analytics)
        const dstart = parseISO(event.dstart)
        const startsAt = format(dstart, FORMAT_LONG, timezone)
        const dend = parseISO(event.dend)
        let dates = format(dstart, FORMAT_GCAL, UTC)
        if (dend) {
          const ends = format(dend, FORMAT_GCAL, UTC)
          dates = `${dates}/${ends}`
        }
        const addUrl = stringifyUrl({
          url: "https://calendar.google.com/calendar/r/eventedit",
          query: {
            action: "TEMPLATE",
            text: event.summary,
            details: event.description, // NOTE: w/o analytics URLs
            location: event.location,
            dates,
          },
        })

        const childAttributes = {
          color: colors.white,
          fontWeight: 300,
          paddingLeft: px(24),
          paddingRight: px(24),
        }
        return cardSection({}, [
          column(
            {
              innerBackgroundColor: colors.darkBlue,
              paddingTop: px(12),
            },
            compact([
              src && image({ src, alt: event.summary }),
              text(
                {
                  ...childAttributes,
                  paddingTop: px(12),
                  fontWeight: 500,
                  cssClass: classNames.autolinks,
                },
                event.summary
              ),
              text(
                {
                  ...childAttributes,
                  paddingBottom: px(12),
                  cssClass: classNames.autolinks,
                },
                `<span style="color: white" class="${classNames.autolinks}">${startsAt}</span>`
              ),
              description &&
                text(
                  {
                    ...childAttributes,
                    paddingBottom: px(12),
                    cssClass: classNames.autolinks,
                  },
                  description
                ),
              text(
                {
                  ...childAttributes,
                  paddingBottom: px(12),
                  cssClass: classNames.autolinks,
                },
                `\u{1F5D3} ` +
                  link({
                    analytics,
                    title: translate("events-add-to-gcal"),
                    url: addUrl,
                  })
              ),
            ])
          ),
        ])
      }),
      cardSection(
        {
          paddingTop: px(24),
        },
        [
          column({}, [
            text(
              {},
              link({
                analytics,
                className: classNames.more,
                url:
                  "https://calendar.google.com/calendar/embed?src=brent.is_gek4no71fjf7vmumoiui0sshkk%40group.calendar.google.com",
                title: translate("events-field-more"),
              })
            ),
          ]),
        ]
      ),
      publicURL &&
        cardSection(
          {
            paddingTop: px(24),
          },
          [
            column({}, [
              text(
                {},
                `\u{1F5D3} ` +
                  link({
                    analytics,
                    className: classNames.more,
                    url: publicURL,
                    title: translate("events-field-add"),
                  })
              ),
            ]),
          ]
        ),
    ])
  )
}
