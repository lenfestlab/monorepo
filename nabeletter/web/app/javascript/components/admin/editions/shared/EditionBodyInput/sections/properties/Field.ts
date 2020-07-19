import { h } from "@cycle/react"
import { b, div, img, table, tbody, td, tr } from "@cycle/react-dom"

import { Link } from "analytics"
import { percent, px } from "csx"
import { allEmpty, either } from "fp"
import { currency, translate } from "i18n"
import { colors, compileStyles } from "styles"
import { Config } from "."
import { SectionField, SectionFieldProps } from "../section/SectionField"

export interface Props extends SectionFieldProps {
  kind: string
  config: Config
  titlePlaceholder: string
}

export const Field = ({
  config,
  typestyle,
  id,
  analytics,
  isAmp,
  titlePlaceholder,
}: Props) => {
  const { pre, post, properties } = config
  const title = either(config.title, titlePlaceholder)
  if (allEmpty([pre, post, properties])) return null

  const { styles, classNames } = compileStyles(typestyle!, {
    items: {
      fontFamily: "Roboto",
      lineHeight: 1.7,
      color: colors.black,
    },
    item: {
      textAlign: "left",
      paddingBottom: px(15),
      lineHeight: 1.7,
    },
    image: {
      width: percent(100),
      display: "block",
      paddingBottom: px(10),
    },
    primary: {
      fontSize: px(16),
      fontWeight: 500,
      paddingTop: px(10),
    },
    secondary: {
      fontSize: px(14),
      fontWeight: "normal",
    },
    link: {
      fontSize: px(16),
      fontWeight: 500,
      color: colors.darkBlue,
    },
  })

  return h(
    SectionField,
    { title, pre, post, typestyle, id, analytics, isAmp },
    [
      table({ style: styles.items, className: classNames.items }, [
        tbody([
          tr([
            td([
              ...properties.map(
                ({
                  url,
                  price,
                  image,
                  address,
                  beds,
                  baths,
                  description,
                  sold_on,
                }) => {
                  const _description = null ?? description
                  const _price = price && currency(parseFloat(price))
                  const details = []
                  if (beds) details.push(`${beds} bedroom`)
                  if (beds) details.push(`${baths} bath`)
                  const _details = details.join(", ")
                  return table([
                    tr([
                      td({ style: styles.item, className: classNames.item }, [
                        img({
                          style: styles.image,
                          className: classNames.image,
                          src: image,
                        }),
                        div(
                          {
                            style: styles.primary,
                            className: classNames.primary,
                          },
                          [b(_price)]
                        ),
                        address &&
                          div(
                            {
                              style: styles.secondary,
                              className: classNames.secondary,
                            },
                            [
                              h(Link, {
                                analytics,
                                url,
                                title: address,
                                style: styles.link,
                                className: classNames.link,
                              }),
                            ]
                          ),
                        _details &&
                          div(
                            {
                              style: styles.secondary,
                              className: classNames.secondary,
                            },
                            [_details]
                          ),
                        sold_on &&
                          div(
                            {
                              style: styles.secondary,
                              className: classNames.secondary,
                            },
                            [`Sold on ${sold_on}`]
                          ),
                        _description &&
                          div(
                            {
                              style: styles.secondary,
                              className: classNames.secondary,
                            },
                            [_description]
                          ),
                        img({
                          src:
                            "http://www.zillow.com/widgets/GetVersionedResource.htm?path=/static/logos/Zillowlogo_200x50.gif",
                          width: "200",
                          height: "50",
                          alt: "Zillow Real Estate Search",
                        }),
                      ]),
                    ]),
                  ])
                }
              ),
            ]),
          ]),
        ]),
      ]),
    ]
  )
}
