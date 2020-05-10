import { h } from "@cycle/react"
import { head, html, meta, style } from "@cycle/react-dom"
import { Box } from "@material-ui/core"
import { Laptop, PhoneIphone } from "@material-ui/icons"
import { ToggleButton, ToggleButtonGroup } from "@material-ui/lab"
import { Frame } from "components/frame"
import { rgb } from "csx"
import React, { useEffect, useState } from "react"
import { createTypeStyle } from "typestyle"

import { max, values } from "fp"
import type { PreviewRef, SectionField } from "../../types"
import { Body } from "./Body"

interface Props {
  previewRef?: PreviewRef
  fields: SectionField[]
}
export const Preview = ({ fields: unstyledFields, previewRef: ref }: Props) => {
  const typestyle = createTypeStyle()
  // clone each field to merge in typestyle prop
  const fields: SectionField[] = unstyledFields.map(
    (child: React.ReactElement<any>) => {
      return React.cloneElement(child, {
        ...child.props,
        typestyle,
      })
    }
  )
  // update accumulated css from rendered components
  const [css, setCss] = useState("")
  useEffect(() => {
    const newCss = typestyle.getStyles()
    if (!(css === newCss)) {
      setCss(newCss)
    }
  })

  const desktop = 640
  const iphone = 320 // iPhone 5
  const widths = { desktop, mobile: iphone }
  const [width, setWidth] = useState(widths.desktop)
  const onChange = (event: React.MouseEvent<HTMLElement>, newWidth: number) =>
    setWidth(newWidth ?? widths.desktop)

  const height = "100%"
  const formFieldGray = rgb(242, 242, 242)

  return h(
    Box,
    {
      id: "preview-manager",
      width: max(values(widths)),
      height,
      display: "flex",
      flexDirection: "column",
      flexWrap: "nowrap",
      alignItems: "flex-start",
      alignContent: "flex-start",
    },
    [
      h(
        Box,
        {
          id: "preview-controls",
          alignSelf: "center",
          paddingBottom: 2,
        },
        [
          h(
            ToggleButtonGroup,
            {
              id: "preview-device-toggle",
              value: width,
              onChange,
              size: "small",
              exclusive: true,
              "aria-label": "device",
            },
            [
              h(
                ToggleButton,
                { value: widths.desktop, "aria-label": "desktop" },
                [h(Laptop)]
              ),
              h(
                ToggleButton,
                { value: widths.mobile, "aria-label": "mobile" },
                [h(PhoneIphone)]
              ),
            ]
          ),
        ]
      ),
      h(
        Frame,
        {
          id: "preview-frame",
          width,
          height,
          style: { border: "0", backgroundColor: formFieldGray },
        },
        [
          html({ ref, key: "html" }, [
            head({ key: "head" }, [
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
            h(Body, { fields, typestyle }),
          ]),
        ]
      ),
    ]
  )
}
