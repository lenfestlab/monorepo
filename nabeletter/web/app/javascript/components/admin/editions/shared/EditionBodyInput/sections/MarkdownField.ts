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
import { colors, queries } from "styles"
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
  typestyle: TypeStyle
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
        media(queries.desktop, {
          fontWeight: important(300),
        })),
      $nest: {
        "& p": {
          paddingBottom: px(20),
        },
      },
    },
  }
  const classNames = typestyle.stylesheet(styles)

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

import { renderToStaticMarkup } from "react-dom/server"

interface MdProps {
  analytics: AnalyticsProps
  markdown?: string
  typestyle: TypeStyle
}
export const md = ({ markdown, analytics, typestyle }: MdProps): string => {
  const transformLinkUri: TransformLinkUri = (url, children, title) => {
    const analyticsProps: AllAnalyticsProps = {
      ...analytics,
      title: safeTitle(title),
    }
    const rewritten = rewriteURL(url, analyticsProps)
    return rewritten
  }

  const styles: StyleMap = {
    markdown: {
      lineHeight: 1.5,
      $nest: {
        "& a": {
          color: important(colors.darkBlue),
        },
        "& h1,h2,h3,h4,h5,h6": {
          paddingBottom: px(20),
        },
        "& h2,h3,h4,h5,h6": {
          fontSize: px(18),
        },
      },
    },
  }
  const classNames = typestyle.stylesheet(styles)

  const style = styles.markdown
  const className = classNames.markdown

  return renderToStaticMarkup(
    span({ className }, [
      h(ReactMarkdown, {
        source: markdown,
        escapeHtml: false,
        linkTarget: "_blank",
        transformLinkUri,
      }),
    ])
  )
}
