import { head, html, meta, span, style } from "@cycle/react-dom"
import { FunctionComponent } from "react"

import type { PreviewRef } from "../../types"

interface Props {
  forwardRef?: PreviewRef
  css?: string
  visible?: boolean
}

export const HtmlEmail: FunctionComponent<Props> = ({
  forwardRef: ref,
  css,
  children,
  visible = false,
}) =>
  span({ ref, id: "format-html", style: { display: visible || "none" } }, [
    html([
      head([
        meta({
          httpEquiv: "Content-Type",
          content: "text/html",
          charSet: "utf-8",
        }),
        meta({
          name: "viewport",
          content: "minimum-scale=1, initial-scale=1, width=device-width",
        }),
        style({
          type: "text/css",
          dangerouslySetInnerHTML: { __html: css },
        }),
      ]),
      children,
    ]),
  ])
