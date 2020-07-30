import { link, rewriteURL } from "analytics"
import { px } from "csx"
import { format, parseISO } from "date-fns"
import { allEmpty, compact, either, last } from "fp"
import { translate } from "i18n"
import { column, image, Node, text } from "mj"
import { colors } from "styles"
import { Config } from "."
import { cardSection, cardWrapper, SectionProps } from "../section"

export interface Props extends SectionProps {
  config: Config
}

export const node = ({ analytics, config, typestyle }: Props): Node | null => {
  const title = either(
    config.title,
    translate(`events-input-title-placeholder`)
  )
  const { pre, post } = config
  const events = config.selections
  const publicURL = config.publicURL
  if (allEmpty([events, pre, post])) return null

  const styles = {
    description: {
      $nest: {
        "& a": {
          color: colors.white,
        },
      },
    },
    more: {
      fontSize: px(18),
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
        let description = event.description
        const parser = new DOMParser()
        const doc = parser.parseFromString(description, "text/html")
        const links = doc.querySelectorAll("a")
        const link = last(links)
        const src = link?.href
        // remove img link from description
        link?.parentNode?.removeChild(link)
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
        const startsAt = format(parseISO(event.dstart), "EEEE, LLLL d @ h aaaa")
        const childAttributes = {
          color: colors.white,
          fontWeight: 300,
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
                { ...childAttributes, paddingTop: px(12), fontWeight: 500 },
                event.summary
              ),
              text({ ...childAttributes, paddingBottom: px(12) }, startsAt),
              description &&
                text(
                  {
                    ...childAttributes,
                    paddingBottom: px(12),
                    cssClass: classNames.description,
                  },
                  description
                ),
            ])
          ),
        ])
      }),
      publicURL &&
        cardSection(
          {
            paddingTop: px(24),
            paddingBottom: px(24),
          },
          [
            column({}, [
              text(
                {},
                link({
                  analytics,
                  className: classNames.more,
                  url: publicURL,
                  title: translate("events-field-more"),
                })
              ),
            ]),
          ]
        ),
    ])
  )
}