import { link } from "analytics"
import { px } from "csx"
import { format, parseISO } from "date-fns"
import { allEmpty, capitalize, compact, either, map } from "fp"
import { translate } from "i18n"
import { column, image, Node, text } from "mj"
import { colors } from "styles"
import { Article, Config } from "."
import { cardSection, cardWrapper, SectionProps } from "../section"

export interface Props extends SectionProps {
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
  const { articles, pre, post, ad } = config
  if (allEmpty([pre, post, ad, articles])) return null

  return cardWrapper(
    { title, pre, post, ad, analytics, typestyle },
    compact([
      ...map(articles, (article: Article) => {
        const {
          url,
          title,
          description,
          site_name: _site_name,
          image: src,
          published_time,
        } = article

        // "http://www.inquirer.com" => "Inquirer.com"
        const site_name = capitalize(_site_name.split(".").slice(-2).join("."))

        const published =
          published_time && format(parseISO(published_time), "MMMM d, y")

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
                    className: typestyle.style({
                      fontSize: px(16),
                      fontWeight: 500,
                      color: colors.darkBlue,
                      textDecoration: "underline",
                    }),
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
