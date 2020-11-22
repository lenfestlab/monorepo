import { translate } from "i18n"
import { Node } from "mj"
import { Config, node as imagesNode } from "../images"
import { SectionNodeProps } from "../section"

export interface Props extends SectionNodeProps {
  config: Config
}

export const node = (props: Props): Node | null => {
  const titlePlaceholder = translate("history-input-title-placeholder")
  return imagesNode({ ...props, titlePlaceholder })
}
