import { link, rewriteDomLinks } from "analytics"
import { important, px } from "csx"
import { format, parseISO } from "date-fns"
import { allEmpty, compact, either, first, last } from "fp"
import { translate } from "i18n"
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
  }
  const classNames = typestyle.stylesheet(styles)

  return cardWrapper(
    { title, pre, post, analytics, typestyle },
    compact([
      ...events.map((event) => {
        const title = event.summary

        const description = rewriteDomLinks(event.description, analytics)

        const startsAt = format(parseISO(event.dstart), "EEE, d LLL y' at 'p")

        const location = event.location.includes("zoom")
          ? link({
              analytics,
              url: event.location,
              className: classNames.zoomLink,
              title: translate("meetings-field-zoom-link"),
            })
          : first(event.location?.split(","))

        const endpoint = process.env.ICS_ENDPOINT!
        const url = stringifyUrl({
          url: endpoint,
          query: {
            ...event,
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
                link({
                  analytics,
                  url,
                  className: classNames.link,
                  title: translate("meetings-field-set-reminder"),
                })
              ),
            ])
          ),
        ])
      }),
    ])
  )
}
