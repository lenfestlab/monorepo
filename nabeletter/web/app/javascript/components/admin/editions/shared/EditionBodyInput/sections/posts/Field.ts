import { h } from "@cycle/react"
import { a, img, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { media, TypeStyle } from "typestyle"

import { AnalyticsProps as AllAnalyticsProps, Link } from "analytics"
import { either, map, values } from "fp"
import { translate } from "i18n"
import { queries } from "styles"
import type { Config, Post } from "."
import { SectionField } from "../SectionField"

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
  return h(SectionField, { title, typestyle, id }, [
    map(posts, ({ url, screenshot_url: src }: Post, idx) => {
      const key = String(idx)
      const title = url // NOTE: natural name for social media post?
      // return a(
      //   { key, href: url, target: "_blank", className: classNames?.link },
      //   [img({ src, className: classNames?.image })]
      // )

      return h(
        Link,
        { key, url, className: classNames?.link, analytics, title },
        [img({ src, className: classNames?.image })]
      )
    }),
  ])
}
