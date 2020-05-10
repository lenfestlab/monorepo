import { h } from "@cycle/react"
import { a } from "@cycle/react-dom"
import {
  AnalyticsProps as AllAnalyticsProps,
  rewriteURL,
  safeTitle,
} from "analytics"
import { FunctionComponent, ReactElement, SFC } from "react"

type AnalyticsProps = Omit<AllAnalyticsProps, "title">

interface StandardProps {
  key?: string
  className?: string
}

type Props = StandardProps & {
  analytics: AnalyticsProps
  url: string
  title: string
}

export const Link: FunctionComponent<Props> = ({
  children,
  className,
  analytics,
  url,
  title,
}) => {
  const href = rewriteURL(url, {
    title: safeTitle(title),
    ...analytics,
  })
  const target = "_blank" // NOTE: always open new window
  return a({ href, target, className }, [children])
}
