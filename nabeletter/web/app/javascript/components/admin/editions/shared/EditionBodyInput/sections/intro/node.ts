import { allEmpty, either } from "fp"
import { translate } from "i18n"
import { column, Node, text } from "mj"
import { Config } from "."
import { md } from "../MarkdownField"
import { cardSection, cardWrapper, SectionProps } from "../section"

export interface Props extends SectionProps {
  config: Config
}

export const node = ({ analytics, config, typestyle }: Props): Node | null => {
  const title = either(config.title, translate("intro-input-title-placeholder"))
  const { markdown, pre, post, ad } = config
  if (allEmpty([markdown, pre, post, ad])) return null

  return cardWrapper({ title, pre, post, ad, analytics, typestyle }, [
    cardSection({}, [
      column({}, [text({}, md({ markdown, analytics, typestyle }))]),
    ]),
  ])
}
