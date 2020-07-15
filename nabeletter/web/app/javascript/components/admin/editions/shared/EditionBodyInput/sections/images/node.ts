import { px } from "csx"
import { allEmpty, either } from "fp"
import { column, group, image as imageNode, Node, text } from "mj"
import { Config, Image } from "."
import { md } from "../MarkdownField"
import { cardSection, cardWrapper, SectionProps } from "../section"

export interface Props extends SectionProps {
  config: Config
  titlePlaceholder: string
}

export const node = ({
  analytics,
  config,
  typestyle,
  titlePlaceholder,
}: Props): Node | null => {
  const title = either(config.title, titlePlaceholder)
  const { pre, post, markdown } = config
  const images: Image[] = either(config.images, [])
  if (allEmpty([pre, post, markdown, images])) return null

  return cardWrapper({ title, pre, post, analytics, typestyle }, [
    cardSection({}, [
      group({ verticalAlign: "top" }, [
        ...images.map(({ url: src, caption = "" }: Image) => {
          return column({}, [
            imageNode({ src, alt: caption }),
            text(
              {
                align: "center",
                fontWeight: 500,
                paddingTop: px(10),
                paddingBottom: px(24),
              },
              caption
            ),
          ])
        }),
      ]),
    ]),
    cardSection({}, [
      column({}, [text({}, md({ markdown, analytics, typestyle }))]),
    ]),
  ])
}
