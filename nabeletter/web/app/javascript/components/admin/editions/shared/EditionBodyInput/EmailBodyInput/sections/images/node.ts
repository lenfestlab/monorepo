import { px } from "csx"
import { allEmpty, either } from "fp"
import { column, group, image as imageNode, Node, text } from "mjml-json"
import { Config, Image } from "."
import { md } from "../MarkdownField"
import { cardSection, cardWrapper, SectionNodeProps } from "../section"

export interface Props extends SectionNodeProps {
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
  const { pre, post, post_es, markdown } = config
  const images: Image[] = either(config.images, [])
  if (allEmpty([pre, post, post_es, markdown, images])) return null

  return cardWrapper({ title, pre, post, post_es, analytics, typestyle }, [
    cardSection({}, [
      group({ verticalAlign: "top" }, [
        ...images.map(({ url: src, caption = "" }, idx: number) => {
          return column({}, [
            imageNode({
              src,
              alt: caption,
              ...(idx === 0 && {
                paddingRight: px(12),
              }),
            }),
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
