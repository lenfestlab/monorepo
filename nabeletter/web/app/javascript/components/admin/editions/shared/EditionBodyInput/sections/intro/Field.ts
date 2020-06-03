import { h } from "@cycle/react"
import { TypeStyle } from "typestyle"

import { either, isEmpty } from "fp"
import { translate } from "i18n"
import { Config } from "."
import { AnalyticsProps, MarkdownField } from "../MarkdownField"
import { SectionField } from "../SectionField"

export interface Props {
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: AnalyticsProps
}
export const Field = ({ config, id, typestyle, analytics }: Props) => {
  const title = either(config.title, translate("intro-input-title-placeholder"))
  const markdown = config.markdown
  if (isEmpty(markdown)) return null
  return h(SectionField, { title, typestyle, id }, [
    h(MarkdownField, { markdown, typestyle, analytics }),
  ])
}
