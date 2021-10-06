import { rewriteURL } from "analytics"
import { color, important, px } from "csx"
import { allEmpty, either } from "fp"
import { translate } from "i18n"
import { button, column, Node, text } from "mjml-json"
import { colors } from "styles"
import { Config } from "."
import { md } from "../MarkdownField"
import { cardSection, cardWrapper, SectionNodeProps } from "../section"

export interface Props extends SectionNodeProps {
  config: Config
}

export const node = ({ analytics, config, typestyle }: Props): Node | null => {
  const title = either(config.title, translate("intro-input-title-placeholder"))
  const { markdown, pre, post, post_es, ad } = config
  if (allEmpty([markdown, pre, post, post_es, ad])) return null

  const cta = process.env.DONATION_CTA!
  const buttonCopy = process.env.DONATION_BUTTON_COPY!
  const url = process.env.DONATION_BUTTON_URL!
  const href = rewriteURL(url, { ...analytics, title: buttonCopy })

  return cardWrapper({ title, pre, post, post_es, ad, analytics, typestyle }, [
    cardSection({}, [
      column({}, [
        text({}, md({ markdown, analytics, typestyle })),
        /* begin donation
        text({}, "<hr/>"),
        text(
          {
            fontSize: px(15),
            fontWeight: 400,
            lineHeight: px(22),
          },
          cta
        ),
        button(
          {
            align: "left",
            paddingTop: px(17),
            paddingLeft: px(0),
            backgroundColor: colors.lightBlue,
            borderRadius: px(0),
            color: colors.textBlue,
            fontSize: px(15),
            fontWeight: 700,
            lineHeight: px(18),
            textTransform: "uppercase",
            href,
          },
          buttonCopy
        ),
        */
      ]),
    ]),
  ])
}
