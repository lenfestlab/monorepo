import { link } from "analytics"
import { px } from "csx"
import { format, parseISO } from "date-fns"
import { allEmpty, capitalize, compact, either, map } from "fp"
import { translate } from "i18n"
import { column, image, Node, text } from "mj"
import { colors } from "styles"
import { Config, EditableArticle } from "."
import { cardSection, cardWrapper, SectionNodeProps } from "../section"

export interface Props extends SectionNodeProps {
  config: Config
}

export interface ArticlesCardProps extends Props {
  title: string
}

export const articlesNode = ({
  analytics,
  config,
  typestyle,
  title,
}: ArticlesCardProps): Node | null => {
  const { articles, pre, post, post_es, ad } = config
  if (allEmpty([pre, post, post_es, ad, articles])) return null

  return cardWrapper(
    { title, pre, post, post_es, ad, analytics, typestyle },
    compact([
      ...map(articles, (article) => {
        const {
          url,
          title,
          description,
          site_name: _site_name,
          site_name_custom,
          image: src,
          published_time,
        } = article

        const site_name =
          site_name_custom ??
          (_site_name &&
            (_site_name.includes(".com")
              ? // "http://www.inquirer.com" => "Inquirer.com"
                capitalize(_site_name.split(".").slice(-2).join("."))
              : _site_name))

        const published =
          published_time && format(parseISO(published_time), "MMMM d, y")

        const style = {
          fontSize: px(16),
          fontWeight: 500,
          color: colors.darkBlue,
          textDecoration: "underline",
        }
        const className = typestyle.style(style)

        return cardSection({}, [
          column(
            { paddingBottom: px(12) },
            compact([
              src &&
                image({
                  src,
                  alt: title,
                }),
              title &&
                text(
                  {
                    paddingTop: px(10),
                    paddingBottom: px(6),
                  },
                  link({
                    analytics,
                    title,
                    url,
                    style,
                    className,
                  })
                ),
              published &&
                text(
                  {
                    fontSize: px(14),
                    fontWeight: "normal",
                    fontStyle: "italic",
                  },
                  published.toUpperCase()
                ),
              description &&
                text(
                  {
                    fontSize: px(14),
                    fontWeight: 300,
                  },
                  description
                ),
              site_name &&
                text(
                  {
                    fontSize: px(14),
                    fontWeight: "normal",
                  },
                  site_name
                ),
            ])
          ),
        ])
      }),
    ])
  )
}

export const node = (props: Props): Node | null => {
  const config = props.config
  const title = either(config.title, translate(`news-input-title-placeholder`))
  return articlesNode({ ...props, title })
}
