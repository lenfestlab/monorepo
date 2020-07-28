import { px } from "csx"
import { format, parseISO } from "date-fns"
import { compact, either, get } from "fp"
import { translate } from "i18n"
import { column, Node, section, text, wrapper } from "mj"
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
    color: colors.white,
    fontFamily: fonts.robotoSlab,
  }
  return wrapper(
    { padding: px(0) },
    compact([
      section(
        {
          backgroundColor: colors.darkBlue,
          borderRadius: px(3) as string,
          paddingTop: px(30),
          paddingBottom: px(30),
        },
        [
          column(
            {},
            compact([
              text(
                {
                  ...textProps,
                  fontSize: px(24) as string,
                  fontWeight: 600,
                },
                title
              ),
              text(
                {
                  ...textProps,
                  fontSize: px(16) as string,
                },
                subtitle
              ),
              published &&
                text(
                  {
                    ...textProps,
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
