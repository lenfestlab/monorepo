import { px } from "csx"
import { Node, section, SectionAttributes } from "mj"
import { colors } from "styles"

interface Attributes extends SectionAttributes {
  isFirstSection?: boolean
  isLastSection?: boolean
}

export const cardSection = (
  { isFirstSection, isLastSection, ...attributes }: Attributes,
  children: Node[]
): Node => {
  const radius = px(3) as string
  const sharedAttributes: SectionAttributes = {
    backgroundColor: colors.white,
    ...(isFirstSection && {
      borderRadius: `${radius} ${radius} 0px 0px`,
    }),
    ...(isLastSection && {
      borderRadius: `0px 0px ${radius} ${radius}`,
    }),
  }
  return section({ ...sharedAttributes, ...attributes }, children)
}
