import { h } from "@cycle/react"
import { span } from "@cycle/react-dom"
import { important, px } from "csx"
import { ReactNode } from "react"
import ReactMarkdown from "react-markdown"
import { classes, media, TypeStyle } from "typestyle"

import {
  AnalyticsProps as AllAnalyticsProps,
  rewriteURL,
  safeTitle,
} from "analytics"
import { queries } from "styles"
import { StyleMap } from "styles"

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
  className?: string
  isAmp?: boolean
}

export const MarkdownField = ({
  markdown,
  typestyle,
  analytics,
  className,
  isAmp,
}: Props) => {
  const source = markdown

  const styles: StyleMap = {
    markdown: {
      fontSize: px(18),
      lineHeight: "1.44",
      fontWeight: "normal",
      ...(!isAmp &&
        media(queries.mobile, {
          fontWeight: important(300),
        })),
    },
  }
  const classNames = typestyle?.stylesheet(styles)

  const transformLinkUri: TransformLinkUri = (url, children, title) => {
    const analyticsProps: AllAnalyticsProps = {
      ...analytics,
      title: safeTitle(title),
    }
    const rewritten = rewriteURL(url, analyticsProps)
    return rewritten
  }

  const style = styles.markdown
  return span({ style, className: classes(classNames?.markdown, className) }, [
    h(ReactMarkdown, {
      source,
      escapeHtml: false,
      linkTarget: "_blank",
      transformLinkUri,
    }),
  ])
}
