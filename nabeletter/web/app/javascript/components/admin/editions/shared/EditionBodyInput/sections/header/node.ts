import { pixelURL } from "analytics"
import { px } from "csx"
import { format, parseISO } from "date-fns"
import { compact, either, get } from "fp"
import { translate } from "i18n"
import { column, image, Node, section, text, wrapper } from "mj"
import { colors, fonts } from "styles"
import { Config } from "."
import { SectionProps } from "../section"

export interface Props extends SectionProps {
  config: Config
}

export const node = ({
  analytics,
  config,
  context: { edition, isWelcome },
  typestyle,
}: Props): Node | null => {
  const title = translate("header-title")
  const subtitle = either(
    config.subtitle,
    translate("header-input-subtitle-placeholder")
  )
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
                src: `https://res.cloudinary.com/hb8lfmjh0/image/upload/v1596322723/8b5c7b89f30a3afe90c7cfa30889c909.png`,
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
            ])
          ),
        ]
      ),
    ])
  )
}
