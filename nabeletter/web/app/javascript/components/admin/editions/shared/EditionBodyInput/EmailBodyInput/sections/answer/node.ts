import { either } from "fp"
import { translate } from "i18n"
import { Node } from "mjml-json"
import { Config } from "."
import { articlesNode } from "../news"
import { SectionNodeProps } from "../section"

export interface Props extends SectionNodeProps {
  config: Config
}

export const node = (props: Props): Node | null => {
  const config = props.config
  const title = either(
    config.title,
    translate(`answer-input-title-placeholder`)
  )
  return articlesNode({ ...props, title })
}
