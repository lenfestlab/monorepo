import { h } from "@cycle/react"
import { a, img, table, tbody, td, tfoot, thead, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { TypeStyle } from "typestyle"

import { Link } from "analytics"
import { allEmpty, either } from "fp"
import { translate } from "i18n"
import { colors } from "styles"
import { Config } from "."
import { AnalyticsProps, MarkdownField } from "../MarkdownField"
import { SectionField } from "../section/SectionField"

export interface Props {
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: AnalyticsProps
}

export const Field = ({ config, id, typestyle, analytics }: Props) => {
  const title = either(config.title, translate("ask-input-title-placeholder"))
  const { prompt = "", pre, post } = config

  const classNames = typestyle?.stylesheet({
    prompt: {
      textAlign: "center",
    },
    linkContainer: {
      textAlign: "center",
    },
    link: {
      backgroundColor: colors.darkBlue,
      color: important(colors.white), // important! else overwritten in gmail
      fontWeight: "bold",
      fontSize: px(18),
      textDecoration: "none",
      padding: "10px 20px 10px 20px",
      marginTop: px(20),
      display: "inline-block",
    },
  })

  const emailAddress = process.env.FEEDBACK_EMAIL as string
  const emailSubject = translate("ask-field-email-subject")
  const mailto = `mailto:${emailAddress}?subject=${emailSubject}`

  if (allEmpty([prompt, pre, post])) return null
  return h(SectionField, { title, pre, post, typestyle, id, analytics }, [
    table([
      tbody([
        tr({ className: classNames?.prompt }, [
          td([
            h(MarkdownField, {
              markdown: prompt,
              typestyle,
              analytics,
            }),
          ]),
        ]),
        tr({ className: classNames?.linkContainer }, [
          td([
            h(
              Link,
              { url: mailto, className: classNames?.link, analytics },
              translate("ask-field-email-cta")
            ),
          ]),
        ]),
      ]),
    ]),
  ])
}
