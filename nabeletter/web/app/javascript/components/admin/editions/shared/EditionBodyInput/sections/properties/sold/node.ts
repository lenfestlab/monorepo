import { translate } from "i18n"
import { Node } from "mj"
import { node as baseNode, Props as BaseNodeProps } from "../node"

type Props = BaseNodeProps

export const node = (props: Props): Node | null => {
  const titlePlaceholder = translate("properties_sold-input-title-placeholder")
  return baseNode({ ...props, titlePlaceholder })
}
