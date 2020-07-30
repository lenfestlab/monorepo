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
  context,
  typestyle,
}: Props): Node | null => {
  const title = translate("header-title")
  const subtitle = either(
    config.subtitle,
    translate("header-input-subtitle-placeholder")
  )
  const { edition } = context
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
        },
        [
          column(
            {},
            compact([
              image({
                alt: title,
                width: px(166),
                height: px(58),
                src:
                  "https://res.cloudinary.com/hb8lfmjh0/image/upload/v1596141169/366063a485d790eacd7ec9646b2b58fa.png",
              }),
              text(
                {
                  ...textProps,
                  paddingTop: px(8),
                },
                subtitle
              ),
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
