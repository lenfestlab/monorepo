import { Node, section, SectionAttributes } from "mj"
import { colors } from "styles"

export const cardSection = (
  attributes: SectionAttributes,
  children: Node[]
): Node => section({ backgroundColor: colors.white, ...attributes }, children)
