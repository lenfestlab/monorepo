import { px } from "csx"
import { translate } from "i18n"
import { column, Node, section, text } from "mj"
import { colors, fonts } from "styles"

export const node = (props: {}): Node => {
  const title = translate("header-title")
  return section(
    {
      backgroundColor: colors.darkBlue,
      borderRadius: px(3) as string,
      paddingTop: px(30),
      paddingBottom: px(30),
    },
    [
      column({}, [
        text(
          {
            align: "center",
            color: colors.white,
            fontFamily: fonts.robotoSlab,
            fontSize: px(24) as string,
            fontWeight: 600,
          },
          title
        ),
      ]),
    ]
  )
}
