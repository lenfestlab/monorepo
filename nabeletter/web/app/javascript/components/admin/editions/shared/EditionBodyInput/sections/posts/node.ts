import { rewriteURL } from "analytics"
import { px } from "csx"
import { allEmpty, either, isEmpty, map, values } from "fp"
import { translate } from "i18n"
import { column, group, image, image as imageNode, Node, text } from "mj"
import { Config, Post } from "."
import { cardSection, cardWrapper, SectionProps } from "../section"

export interface Props extends SectionProps {
  config: Config
  kind: string
}

export const node = ({
  analytics,
  config,
  typestyle,
  kind,
}: Props): Node | null => {
  const title = either(
    config.title,
    translate(`${kind}-input-title-placeholder`)
  )
  const { pre, post } = config
  const postMap = either(config.postmap, {})
  const posts = values(postMap)
  if (allEmpty([pre, post, posts])) return null

  return cardWrapper({ title, pre, post, analytics, typestyle }, [
    cardSection({}, [
      column({}, [
        ...posts.map(({ url, screenshot_url: src }: Post, idx) => {
          const href = rewriteURL(url, {
            ...analytics,
            title: url,
          })
          return image({
            alt: url,
            src,
            href,
            padding: px(10),
            width: px(400),
          })
        }),
      ]),
    ]),
  ])
}
