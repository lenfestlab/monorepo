import { h } from "@cycle/react"
import { div, img, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { Fragment, FunctionComponent } from "react"
import { media, TypeStyle } from "typestyle"

import { LayoutTable } from "components/table"
import { allEmpty, chunk, either, isEmpty } from "fp"
import { compileStyles, queries } from "styles"
import { Config, Image } from "."
import { AnalyticsProps, MarkdownField } from "../MarkdownField"
import { SectionField } from "../section/SectionField"

export interface Props {
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: AnalyticsProps
  titlePlaceholder: string
  isAmp?: boolean
}

export const Field: FunctionComponent<Props> = ({
  config,
  id,
  typestyle,
  analytics,
  titlePlaceholder,
  isAmp,
}) => {
  const title = either(config.title, titlePlaceholder)
  const { pre, post, markdown } = config
  const images: Image[] = either(config.images, [])
  if (allEmpty([pre, post, markdown, images])) return null

  const item = {
    verticalAlign: "top",
    paddingBottom: px(24),
    width: percent(100), // TODO: 50%
    ...(!isAmp &&
      media(queries.mobile, {
        width: important(percent(100)),
      })),
  }
  const { styles, classNames } = compileStyles(typestyle!, {
    item,
    caption: {
      ...item,
      textAlign: "center",
      paddingTop: px(10),
      fontFamily: "Roboto, sans-serif",
      fontSize: px(16),
      fontWeight: 500,
    },
    image: {
      width: percent(100),
      ...(!isAmp &&
        media(queries.mobile, {
          width: important(percent(100)),
        })),
    },
    markdown: {
      paddingTop: px(22),
      fontSize: px(14),
      fontWeight: "normal",
      textAlign: "center",
      ...(!isAmp &&
        media(queries.mobile, {
          fontSize: important(px(18)),
          fontWeight: 300,
        })),
    },
  })

  return h(
    SectionField,
    { title, pre, post, typestyle, id, analytics, isAmp },
    [
      h(LayoutTable, [
        tbody([
          tr([
            td([
              h(LayoutTable, [
                ...images.map((image: Image) => {
                  return tr([
                    td([
                      img({
                        src: image.url,
                        style: styles.image,
                        className: classNames.image,
                      }),
                      div(
                        {
                          style: styles.caption,
                          className: classNames.caption,
                        },
                        image.caption
                      ),
                    ]),
                  ])
                }),
              ]),
            ]),
          ]),
          tr([
            td(
              {
                colSpan: 3,
                style: styles.markdown,
                className: classNames.markdown,
              },
              [h(MarkdownField, { markdown, typestyle, analytics })]
            ),
          ]),
        ]),
      ]),
    ]
  )
}
