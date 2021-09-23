import { h } from "@cycle/react"
import { span } from "@cycle/react-dom"
import { Breadcrumbs, Divider, Grid, Link } from "@material-ui/core"
import { OpenInNew } from "@material-ui/icons"
import { FunctionComponent } from "react"

import { AnalyticsProps as AllAnalyticsProps } from "analytics"

export type AnalyticsProps = Omit<AllAnalyticsProps, "title">

interface StandardProps {
  key?: string
  className?: string
}

type Props = StandardProps & {
  urls: string[]
}

export const QuickLinks: FunctionComponent<Props> = ({
  children,
  className,
  urls,
}) => {
  return h(
    Grid,
    {
      direction: "row",
      container: true,
      alignItems: "center",
      style: { padding: "4px" },
    },
    [
      h(OpenInNew),
      span({
        dangerouslySetInnerHTML: {
          __html: `&nbsp;`,
        },
      }),
      h(Breadcrumbs, { separator: "|", style: { fontSize: "12px" } }, [
        ...urls.map((href) => {
          const title = new URL(href).hostname
          const target = "_blank" // NOTE: always open new window
          return h(Link, { href, target }, title)
        }),
      ]),
    ]
  )
}
