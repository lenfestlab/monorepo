import { translate } from "i18n"
import { Node } from "mj"
import { Config, node as imagesNode } from "../images"
import { SectionNodeProps } from "../section"

export interface Props extends SectionNodeProps {
  config: Config
}

export const node = (props: Props): Node | null => {
  const NABE_NAME = props.context.edition.newsletter_name
  const titlePlaceholder = translate("stats-input-title-placeholder").replace(
    "NABE_NAME",
    NABE_NAME
  )
  return imagesNode({ ...props, titlePlaceholder })
}
