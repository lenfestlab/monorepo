import { h } from "@cycle/react"
import { a, img, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { TypeStyle } from "typestyle"

import { Link } from "analytics"
import { allEmpty, either } from "fp"
import { translate } from "i18n"
import { colors, compileStyles } from "styles"
import { Config } from "."
import { AnalyticsProps, MarkdownField } from "../MarkdownField"
import { SectionField } from "../section/SectionField"

export interface Props {
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: AnalyticsProps
  isAmp?: boolean
}

export const Field = ({ config, id, typestyle, analytics, isAmp }: Props) => {
  const title = either(config.title, translate("ask-input-title-placeholder"))
  const { prompt = "", pre, post } = config
  if (allEmpty([prompt, pre, post])) return null

  const { styles, classNames } = compileStyles(typestyle!, {
    prompt: {
      textAlign: "center",
    },
    linkContainer: {
      textAlign: "center",
    },
    link: {
      backgroundColor: colors.darkBlue,
      color: colors.white,
      fontWeight: "bold",
      fontSize: px(18),
      textDecoration: "none",
      padding: "10px 20px 10px 20px",
      marginTop: px(20),
      display: "inline-block",
      borderRadius: px(3),
    },
  })

  const emailAddress = process.env.FEEDBACK_EMAIL as string
  const emailSubject = translate("ask-field-email-subject")
  const mailto = `mailto:${emailAddress}?subject=${emailSubject}`

  return h(
    SectionField,
    { title, pre, post, typestyle, id, analytics, isAmp },
    [
      table([
        tbody([
          tr({ style: styles.prompt, className: classNames.prompt }, [
            td([
              h(MarkdownField, {
                markdown: prompt,
                typestyle,
                analytics,
              }),
            ]),
          ]),
          tr(
            {
              style: styles.linkContainer,
              className: classNames.linkContainer,
            },
            [
              td([
                h(
                  Link,
                  {
                    url: mailto,
                    style: styles.link,
                    className: classNames.link,
                    analytics,
                  },
                  translate("ask-field-email-cta")
                ),
              ]),
            ]
          ),
        ]),
      ]),
    ]
  )
}
