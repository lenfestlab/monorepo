import { h } from "@cycle/react"
import { important, px } from "csx"
import { ReactNode } from "react"
import ReactMarkdown from "react-markdown"
import { media, TypeStyle } from "typestyle"

import {
  AnalyticsProps as AllAnalyticsProps,
  rewriteURL,
  safeTitle,
} from "analytics"
import { queries } from "styles"

type TransformLinkUri = (
  uri: string,
  children?: ReactNode,
  title?: string
) => string

export type AnalyticsProps = Omit<AllAnalyticsProps, "title">

interface Props {
  markdown?: string
  placeholder?: string
  typestyle?: TypeStyle
  analytics: AnalyticsProps
}

export const MarkdownField = ({ markdown, typestyle, analytics }: Props) => {
  const source = markdown
  const classNames = typestyle?.stylesheet({
    markdown: {
      fontSize: px(18),
      lineHeight: "1.44",
      fontWeight: "normal",
      ...media(queries.mobile, {
        fontWeight: important(300),
      }),
    },
  })

  const transformLinkUri: TransformLinkUri = (url, children, title) => {
    const analyticsProps: AllAnalyticsProps = {
      ...analytics,
      title: safeTitle(title),
    }
    const rewritten = rewriteURL(url, analyticsProps)
    return rewritten
  }

  return h(ReactMarkdown, {
    className: classNames?.markdown,
    source,
    escapeHtml: false,
    linkTarget: "_blank",
    transformLinkUri,
  })
}
