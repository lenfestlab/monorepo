import { px } from "csx"
import { compact, either, isEmpty } from "fp"
import { column, Node, text } from "mjml-json"
import { StyleMap } from "styles"
import { Config } from "."
import { cardSection, cardWrapper, SectionNodeProps } from "../section"

export interface Props extends SectionNodeProps {
  config: Config
}

export const node = ({ analytics, config, typestyle }: Props): Node | null => {
  const previewText = config.text
  if (isEmpty(text)) return null

  const styles: StyleMap = {
    hide: {
      display: "none",
      maxHeight: px(0),
      overflow: "hidden",
    },
  }
  const classNames = typestyle.stylesheet(styles)

  // NOTE: https://bit.ly/3dzW6rj
  return cardSection({}, [
    column(
      {},
      compact([
        previewText && text({ cssClass: classNames.hide }, previewText),
        previewText && text({}, `&nbsp;&zwnj;`.repeat(90)),
      ])
    ),
  ])
}
