import { h } from "@cycle/react"
import { img, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { FunctionComponent } from "react"
import { media, TypeStyle } from "typestyle"

import { allEmpty, either, isEmpty } from "fp"
import { queries } from "styles"
import { Config, Image } from "."
import { AnalyticsProps, MarkdownField } from "../MarkdownField"
import { SectionField } from "../section/SectionField"

export interface Props {
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: AnalyticsProps
  titlePlaceholder: string
}
export const Field: FunctionComponent<Props> = ({
  config,
  id,
  typestyle,
  analytics,
  titlePlaceholder,
}) => {
  const title = either(config.title, titlePlaceholder)
  const { pre, post, markdown } = config
  const images: Image[] = either(config.images, [])
  if (allEmpty([pre, post, markdown, images])) return null

  const classNames = typestyle?.stylesheet({
    item: {
      verticalAlign: "top",
      width: percent(50),
      ...media(queries.mobile, {
        width: important(percent(100)),
      }),
    },
    image: {
      objectFit: "cover",
      height: px(160),
      width: percent(100),
      ...media(queries.mobile, {
        width: important(percent(100)),
      }),
    },
    markdown: {
      paddingTop: px(22),
      fontSize: px(14),
      fontWeight: "normal",
      textAlign: "center",
      ...media(queries.mobile, {
        fontSize: important(px(18)),
        fontWeight: 300,
      }),
    },
  })

  return h(SectionField, { title, pre, post, typestyle, id, analytics }, [
    table([
      tbody([
        tr([
          ...images.map((image: Image) => {
            const { url: src, caption } = image
            // prettier-ignore
            return td({ className: classNames?.item }, [
              table([
                tbody([
                  tr([
                    img({ src: image.url, className: classNames?.image })
                  ]),
                  tr([
                    td({}, caption)
                  ])
                ])
              ])
            ])
          }),
        ]),
        tr([
          td({ colSpan: 3, className: classNames?.markdown }, [
            h(MarkdownField, { markdown, typestyle, analytics }),
          ]),
        ]),
      ]),
    ]),
  ])
}
