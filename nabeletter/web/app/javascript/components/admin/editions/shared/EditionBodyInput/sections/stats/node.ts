import { translate } from "i18n"
import { Node } from "mj"
import { Config, node as imagesNode } from "../images"
import { SectionProps } from "../section"

export interface Props extends SectionProps {
  config: Config
}

export const node = (props: Props): Node | null => {
  const titlePlaceholder = translate("stats-input-title-placeholder")
  return imagesNode({ ...props, titlePlaceholder })
}
