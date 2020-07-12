import { h } from "@cycle/react"
import { span } from "@cycle/react-dom"

import { allEmpty, either } from "fp"
import { translate } from "i18n"
import { compileStyles } from "styles"
import { Config } from "."
import { MarkdownField } from "../MarkdownField"
import { SectionField, SectionFieldProps } from "../section/SectionField"

export interface Props extends SectionFieldProps {
  config: Config
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
