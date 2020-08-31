import { rewriteURL } from "analytics"
import { px } from "csx"
import { allEmpty, either } from "fp"
import { translate } from "i18n"
import { button, column, Node, text } from "mj"
import { colors } from "styles"
import { Config } from "."
import { md } from "../MarkdownField"
import { cardSection, cardWrapper, SectionProps } from "../section"

export interface Props extends SectionProps {
  config: Config
}

export const node = ({ analytics, config, typestyle }: Props): Node | null => {
  const title = either(config.title, translate("ask-input-title-placeholder"))
  const { prompt = "", pre, post } = config
  if (allEmpty([prompt, pre, post])) return null

  const markdown = prompt
  const emailAddress = process.env.FEEDBACK_EMAIL as string
  const emailSubject = translate("ask-field-email-subject")
  const mailto = `mailto:${emailAddress}?subject=${emailSubject}`
  const cta = translate("ask-field-email-cta")

  return cardWrapper({ title, pre, post, analytics, typestyle }, [
    cardSection({}, [
      column({}, [
        text(
          { fontSize: px(18), fontWeight: 500 },
          md({ markdown, analytics, typestyle })
        ),
        button(
          {
            backgroundColor: colors.darkBlue,
            borderRadius: px(3),
            color: colors.white,
            fontSize: px(18),
            fontWeight: "bold",
            href: rewriteURL(mailto, { ...analytics, title: cta }),
            textDecoration: "none",
            padding: "10px 20px 10px 20px",
          },
          cta
        ),
      ]),
    ]),
  ])
}
