import { h } from "@cycle/react"
import { a, img, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { media, TypeStyle } from "typestyle"

import { AnalyticsProps as AllAnalyticsProps, Link } from "analytics"
import { allEmpty, either, isEmpty, map, values } from "fp"
import { translate } from "i18n"
import { queries } from "styles"
import type { Config, Post } from "."
import { SectionField } from "../section/SectionField"

export interface Props {
  kind: string
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: Omit<AllAnalyticsProps, "title">
}
export const Field = ({ config, typestyle, id, kind, analytics }: Props) => {
  const title = either(
    config.title,
    translate(`${kind}-input-title-placeholder`)
  )
  const { pre, post } = config
  const postMap = either(config.postmap, {})
  const posts = values(postMap)

  const width: number = posts.length > 1 ? 45 : 90
  const classNames = typestyle?.stylesheet({
    image: {
      width: percent(width),
      ...media(queries.mobile, {
        width: important(percent(100)),
      }),
    },
    link: {
      paddingTop: px(20),
      paddingLeft: px(20),
      ...media(queries.mobile, {
        paddingTop: important(px(10)),
        paddingLeft: important(px(0)),
      }),
    },
  })
  if (allEmpty([pre, post, posts])) return null
  return h(SectionField, { title, pre, post, typestyle, id, analytics }, [
    map(posts, ({ url, screenshot_url: src }: Post, idx) => {
      const key = String(idx)
      const title = url
      return h(
        Link,
        { key, url, className: classNames?.link, analytics, title },
        [img({ src, className: classNames?.image })]
      )
    }),
  ])
}
