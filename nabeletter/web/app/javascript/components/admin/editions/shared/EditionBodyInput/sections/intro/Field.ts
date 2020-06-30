import { h } from "@cycle/react"
import { span } from "@cycle/react-dom"
import { TypeStyle } from "typestyle"

import { allEmpty, either } from "fp"
import { translate } from "i18n"
import { compileStyles } from "styles"
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
  const title = either(config.title, translate("intro-input-title-placeholder"))
  const { markdown, pre, post } = config
  if (allEmpty([markdown, pre, post])) return null

  const { styles, classNames } = compileStyles(typestyle!, {
    main: {
      textAlign: "left",
    },
  })
  const className = classNames.main
  const style = styles.main

  return h(
    SectionField,
    { title, pre, post, typestyle, id, analytics, isAmp },
    [
      span({ className, style }, [
        h(MarkdownField, { markdown, typestyle, analytics, className, isAmp }),
      ]),
    ]
  )
}
