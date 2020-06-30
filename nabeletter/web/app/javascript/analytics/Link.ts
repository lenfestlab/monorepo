import { h } from "@cycle/react"
import { a } from "@cycle/react-dom"
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
