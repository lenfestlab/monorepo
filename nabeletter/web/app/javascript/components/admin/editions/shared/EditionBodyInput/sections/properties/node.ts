import { link } from "analytics"
import { px } from "csx"
import { allEmpty, compact, either, isEmpty } from "fp"
import { currency } from "i18n"
import { column, image as imageNode, Node, text } from "mj"
import { colors, StyleMap } from "styles"
import { Config } from "."
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
  const { pre, post, ad, properties } = config
  const title = either(config.title, titlePlaceholder)
  if (allEmpty([pre, post, ad, properties])) return null

  const styles: StyleMap = {
    link: {
      fontSize: px(16),
      fontWeight: 500,
      color: colors.darkBlue,
    },
  }
  const classNames = typestyle.stylesheet(styles)

  return cardWrapper({ title, pre, post, ad, analytics, typestyle }, [
    ...properties.map(
      ({
        url,
        price,
        image,
        image_custom,
        address,
        beds,
        baths,
        description,
        description_custom,
        sold_on,
      }) => {
        const _description = description_custom ?? description
        const src = image_custom ?? image
        const _price = price && currency(parseFloat(price))
        const details = []
        if (beds) details.push(`${beds} bedroom`)
        if (beds) details.push(`${baths} bath`)
        const _details = details.join(", ")
        const secondaryAttrs = {
          fontSize: px(14),
          lineHeight: 1.7,
        }
        return cardSection({}, [
          column(
            { paddingBottom: px(10) },
            compact([
              imageNode({
                src,
                alt: address,
                paddingBottom: px(10),
              }),
              _price && text({ fontWeight: 500, paddingTop: px(10) }, _price),
              address &&
                text(
                  { ...secondaryAttrs },
                  link({
                    analytics,
                    url,
                    title: address,
                    className: classNames.link,
                  })
                ),
              _details && text({ ...secondaryAttrs }, _details),
              sold_on && text({ ...secondaryAttrs }, `Sold on ${sold_on}`),
              _description && text({ ...secondaryAttrs }, _description),
            ])
          ),
        ])
      }
    ),
    ...compact([
      !isEmpty(properties) &&
        cardSection({}, [
          column({ paddingBottom: px(24) }, [
            imageNode({
              src:
                "http://www.zillow.com/widgets/GetVersionedResource.htm?path=/static/logos/Zillowlogo_200x50.gif",
              width: px(200),
              height: px(50),
              alt: "Zillow Real Estate Search",
            }),
          ]),
        ]),
    ]),
  ])
}
