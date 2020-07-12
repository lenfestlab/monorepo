import { h } from "@cycle/react"
import { a, img, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { media } from "typestyle"

import { AnalyticsProps as AllAnalyticsProps, Link } from "analytics"
import { allEmpty, either, isEmpty, map, values } from "fp"
import { translate } from "i18n"
import { compileStyles, queries } from "styles"
import type { Config, Post } from "."
import { SectionField, SectionFieldProps } from "../section/SectionField"

export interface Props extends SectionFieldProps {
  kind: string
  config: Config
}

export const Field = ({
  config,
  typestyle,
  id,
  kind,
  analytics,
  isAmp,
}: Props) => {
  const title = either(
    config.title,
    translate(`${kind}-input-title-placeholder`)
  )
  const { pre, post } = config
  const postMap = either(config.postmap, {})
  const posts = values(postMap)
  if (allEmpty([pre, post, posts])) return null

  const { styles, classNames } = compileStyles(typestyle!, {
    image: {
      display: "block",
      width: percent(100),
    },
    link: {
      display: "block",
      paddingTop: px(20),
      ...(!isAmp &&
        media(queries.mobile, {
          paddingTop: important(px(10)),
          paddingLeft: important(px(0)),
        })),
    },
  })

  return h(
    SectionField,
    { title, pre, post, typestyle, id, analytics, isAmp },
    [
      map(posts, ({ url, screenshot_url: src }: Post, idx) => {
        const key = String(idx)
        const title = url
        return h(
          Link,
          {
            key,
            url,
            style: styles.link,
            className: classNames.link,
            analytics,
            title,
          },
          [img({ src, style: styles.image, className: classNames.image })]
        )
      }),
    ]
  )
}
