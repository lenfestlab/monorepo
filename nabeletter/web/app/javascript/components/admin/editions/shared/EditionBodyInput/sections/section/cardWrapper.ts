import { rewriteURL } from "analytics"
import { px } from "csx"
import { compact } from "fp"
import { column, image, Node, text, wrapper } from "mj"
import { colors, fonts } from "styles"
import { AdOpt, SectionNodeProps } from "."
import { md } from "../MarkdownField"
import { cardSection } from "../section/cardSection"

export interface CardWrapperProps extends Omit<SectionNodeProps, "context"> {
  title: string
  pre?: string
  post?: string
  ad?: AdOpt
}

export const cardWrapper = (
  { title, pre, post, ad, analytics, typestyle }: CardWrapperProps,
  children: Node[]
): Node => {
  return wrapper(
    {
      paddingTop: px(12),
      paddingBottom: px(12),
      paddingLeft: px(24),
      paddingRight: px(24),
      backgroundColor: colors.veryLightGray,
    },
    compact([
      cardSection(
        {
          paddingTop: px(24),
          isFirstSection: true,
        },
        [
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
        ]
      ),

      pre &&
        cardSection({}, [
          column({}, [
            text({ paddingBottom: px(10) }, [
              md({ markdown: pre, analytics, typestyle }),
            ]),
          ]),
        ]),

      ...children,

      post &&
        cardSection({}, [
          column({}, [
            text({ paddingTop: px(10) }, [
              md({ markdown: post, analytics, typestyle }),
            ]),
          ]),
        ]),

      ad &&
        cardSection(
          {
            paddingTop: px(20),
          },
          [
            column({}, [
              image({
                alt: ad.image.alt,
                src: ad.image.src,
                href: rewriteURL(ad.image.href, {
                  ...analytics,
                  label: "ad",
                  title: ad.image.alt,
                  aid: ad.id,
                }),
              }),
            ]),
          ]
        ),

      cardSection({ isLastSection: true }, [column({}, [text({}, `&nbsp;`)])]),
    ])
  )
}
