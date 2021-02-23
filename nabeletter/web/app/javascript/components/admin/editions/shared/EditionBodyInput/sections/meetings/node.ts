import { link, rewriteDomLinks } from "analytics"
import { important, px } from "csx"
import { parseISO } from "date-fns"
import { allEmpty, compact, either, first, last } from "fp"
import { EST, format, FORMAT_GCAL, FORMAT_LONG, translate, UTC } from "i18n"
import { column, image, Node, text } from "mj"
import { stringifyUrl } from "query-string"
import { colors, StyleMap } from "styles"
import { Config } from "."
import { cardSection, cardWrapper, SectionNodeProps } from "../section"

export interface Props extends SectionNodeProps {
  config: Config
}

export const node = ({ analytics, config, typestyle }: Props): Node | null => {
  const title = either(
    config.title,
    translate(`meetings-input-title-placeholder`)
  )
  const { pre, post } = config
  const events = config.selections
  const publicURL = config.publicURL
  if (allEmpty([events, pre, post])) return null

  const styles: StyleMap = {
    description: {
      $nest: {
        "& a": {
          color: colors.darkBlue,
        },
      },
    },
    link: {
      color: important(colors.black),
    },
    zoomLink: {
      color: important(colors.black),
      textDecoration: important("none"),
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
    { title, pre, post, analytics, typestyle },
    compact([
      ...events.map((event) => {
        const title = event.summary
        const description = rewriteDomLinks(event.description, analytics)
        const startsAt = format(parseISO(event.dstart), FORMAT_LONG, EST)
        const location = event.location.includes("zoom")
          ? link({
              analytics,
              url: event.location,
              className: classNames.zoomLink,
              title: translate("meetings-field-zoom-link"),
            })
          : first(event.location?.split(","))
        const url = stringifyUrl({
          url: process.env.ICS_ENDPOINT!,
          query: {
            ...event,
          },
        })
        const { dstart, dend } = event
        let dates = format(parseISO(dstart), FORMAT_GCAL, UTC)
        if (dend) {
          const ends = format(parseISO(dend), FORMAT_GCAL, UTC)
          dates = `${dates}/${ends}`
        }
        const addUrl = stringifyUrl({
          url: "https://calendar.google.com/calendar/r/eventedit",
          query: {
            action: "TEMPLATE",
            text: title,
            details: event.description, // NOTE: w/o analytics URLs
            location,
            dates,
          },
        })

        return cardSection({}, [
          column(
            {
              paddingBottom: px(24),
            },
            compact([
              text({ fontWeight: 500, fontSize: px(18) }, title),
              text({ fontWeight: 500 }, startsAt),
              text({ cssClass: classNames.description }, description),
              text({}, "<br/>"),
              text({ fontWeight: 500 }, location ?? ""),
              text(
                {},
                `\u{1F5D3} ` +
                  link({
                    analytics,
                    url: addUrl,
                    className: classNames.link,
                    title: translate("meetings-field-set-reminder"),
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
                  "https://calendar.google.com/calendar/embed?src=c_uqq4uallutcud0pv1fmepbl9ng%40group.calendar.google.com&ctz=America%2FNew_York",
                title: translate("meetings-field-more"),
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
                    title: translate("meetings-field-add"),
                  })
              ),
            ]),
          ]
        ),
    ])
  )
}
