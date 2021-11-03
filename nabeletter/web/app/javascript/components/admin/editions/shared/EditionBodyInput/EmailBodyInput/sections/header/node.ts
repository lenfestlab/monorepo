import { pixelURL } from "analytics"
import { px } from "csx"
import { format, parseISO } from "date-fns"
import { compact, either, get } from "fp"
import { translate } from "i18n"
import { column, image, Node, section, text, wrapper } from "mjml-json"
import { colors, fonts } from "styles"
import { Config } from "."
import { SectionNodeProps } from "../section"

export interface Props extends SectionNodeProps {
  config: Config
}

export const node = ({
  analytics,
  config,
  context: { edition, isWelcome },
  typestyle,
}: Props): Node | null => {
  // TODO: embed JSONAPI edition.newsletter
  const NABE_NAME = edition.newsletter_name
  const title = translate("header-title").replace("NABE_NAME", NABE_NAME)
  const subtitle = either(
    config.subtitle,
    translate("header-input-subtitle-placeholder")
  ).replace("NABE_NAME", NABE_NAME)
  const published = get(edition, "publish_at")

  const textProps = {
    align: "center",
    color: colors.black,
    fontFamily: fonts.robotoSlab,
    fontSize: px(16) as string,
  }

  return wrapper(
    { padding: px(0) },
    compact([
      section(
        {
          backgroundColor: colors.veryLightGray,
          paddingTop: px(20),
          paddingBottom: px(24),
          paddingLeft: px(24),
          paddingRight: px(24),
        },
        [
          column(
            {},
            compact([
              image({
                alt: title,
                width: px(166),
                height: px(58),
                src: edition.newsletter_logo_url,
              }),
              text(
                {
                  ...textProps,
                  paddingTop: px(8),
                },
                subtitle
              ),
              !isWelcome &&
                published &&
                text(
                  {
                    ...textProps,
                    fontWeight: 300,
                    paddingTop: px(13),
                  },
                  format(parseISO(published), "MMMM d, y")
                ),
              image({
                src: pixelURL(
                  analytics.channel,
                  analytics.lang,
                  edition.newsletter_analytics_name,
                  edition.id,
                  true
                ),
                alt: " ",
                width: px(1),
                height: px(1),
              }),
            ])
          ),
        ]
      ),
    ])
  )
}
