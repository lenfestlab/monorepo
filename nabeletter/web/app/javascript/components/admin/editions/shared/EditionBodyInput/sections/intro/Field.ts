import { h } from "@cycle/react"
import { TypeStyle } from "typestyle"

import { allEmpty, either } from "fp"
import { translate } from "i18n"
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
  const title = either(config.title, translate("intro-input-title-placeholder"))
  const { markdown, pre, post } = config
  if (allEmpty([markdown, pre, post])) return null
  return h(SectionField, { title, pre, post, typestyle, id, analytics }, [
    h(MarkdownField, { markdown, typestyle, analytics }),
  ])
}
