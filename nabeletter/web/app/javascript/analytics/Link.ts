import { h } from "@cycle/react"
import {
  AnalyticsProps as AllAnalyticsProps,
  rewriteURL,
  safeTitle,
} from "analytics"
import { FunctionComponent } from "react"

export type AnalyticsProps = Omit<AllAnalyticsProps, "title">

type Props = {
  analytics: AnalyticsProps
  url: string
  title?: string
  className?: string
  style?: object
}

export const Link: FunctionComponent<Props> = ({
  children,
  analytics,
  url,
  title,
  style,
  className,
}) => {
  const href = rewriteURL(url, {
    title: safeTitle(title),
    ...analytics,
  })
  const target = "_blank" // NOTE: always open new window
  const content = children ?? title
  return h("a", { href, target, className, style }, [content])
}

import { renderToStaticMarkup } from "react-dom/server"

type Children = string | string[]

interface LinkProps {
  analytics: AnalyticsProps
  url: string
  title?: string
  className?: string
  style?: object
}

export const link = (
  { analytics, className, title, url: _url, style }: LinkProps,
  children?: Children
) => {
  const host = process.env.RAILS_HOST as string
  let tracked_url: string
  if (_url.includes(host)) {
    const url = new URL(_url)
    // NOTE: pending analysis requiring uid/eid
    // url.searchParams.set("uid", "VAR-RECIPIENT-UID")
    // url.searchParams.set("eid", analytics.edition)
    tracked_url = url.href
  } else {
    tracked_url = _url
  }
  const href = rewriteURL(tracked_url, {
    title: safeTitle(title),
    ...analytics,
  })
  const target = "_blank" // NOTE: always open new window
  const content = children ?? title
  return renderToStaticMarkup(
    h("a", { href, target, className, style }, [content])
  )
}
