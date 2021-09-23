import { head, html, meta, script, span, style } from "@cycle/react-dom"
import { FunctionComponent } from "react"

import type { PreviewRef } from "../../types"

interface Props {
  forwardRef?: PreviewRef
  css?: string
  visible?: boolean
}

export const AmpEmail: FunctionComponent<Props> = ({
  forwardRef: ref,
  css,
  children,
  visible = false,
}) =>
  span({ ref, id: "format-amp", style: { display: visible || "none" } }, [
    html([
      head([
        meta({ charSet: "utf-8" }),
        script({ async: true, src: "https://cdn.ampproject.org/v0.js" }),
        style({
          "amp4email-boilerplate": "true",
          dangerouslySetInnerHTML: {
            __html: `body { visibility: FIX_VISIBILITY }`,
          },
        }),
        style({
          "amp-custom": "true",
          dangerouslySetInnerHTML: { __html: css },
        }),
      ]),
      children,
    ]),
  ])
