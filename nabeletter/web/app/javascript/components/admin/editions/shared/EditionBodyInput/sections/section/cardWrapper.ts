import { px } from "csx"
import { compact } from "fp"
import { column, Node, text, wrapper } from "mj"
import { colors, fonts } from "styles"
import { SectionProps } from "."
import { md } from "../MarkdownField"
import { cardSection } from "../section/cardSection"

export interface CardWrapperProps extends SectionProps {
  title: string
  pre?: string
  post?: string
}

export const cardWrapper = (
  { title, pre, post, analytics, typestyle }: CardWrapperProps,
  children: Node[]
): Node => {
  return wrapper(
    {
      paddingTop: px(12),
      paddingBottom: px(12),
      paddingLeft: px(24),
      paddingRight: px(24),
    },
    compact([
      cardSection({ paddingTop: px(25) }, [
        column({}, [
          text(
            {
              fontFamily: fonts.robotoSlab,
              fontSize: px(20),
              fontWeight: 500,
              align: "center",
              color: colors.black,
              paddingBottom: px(20),
            },
            title
          ),
        ]),
      ]),

      pre &&
        cardSection({}, [
          column({}, [
            text({ paddingBottom: px(20) }, [
              md({ markdown: pre, analytics, typestyle }),
            ]),
          ]),
        ]),

      ...children,

      post &&
        cardSection({}, [
          column({}, [
            text({ paddingTop: px(10), paddingBottom: px(20) }, [
              md({ markdown: post, analytics, typestyle }),
            ]),
          ]),
        ]),
    ])
  )
}
