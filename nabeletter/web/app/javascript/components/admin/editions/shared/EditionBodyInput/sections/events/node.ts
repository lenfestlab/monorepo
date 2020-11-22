import { link, rewriteDomLinks } from "analytics"
import { important, px } from "csx"
import { format, parseISO } from "date-fns"
import { allEmpty, compact, either, last } from "fp"
import { translate } from "i18n"
import { column, image, Node, text } from "mj"
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
  const title = either(
    config.title,
    translate(`events-input-title-placeholder`).replace("NABE_NAME", NABE_NAME)
  )
  const { pre, post, ad } = config
  const events = config.selections
  const publicURL = config.publicURL
  if (allEmpty([events, pre, post, ad])) return null

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
    { title, pre, post, ad, analytics, typestyle },
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
        // analyze links
        description = rewriteDomLinks(doc.documentElement.innerHTML, analytics)
        const startsAt = format(parseISO(event.dstart), "EEEE, LLLL d @ h aaaa")
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
            ])
          ),
        ])
      }),
      publicURL &&
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
