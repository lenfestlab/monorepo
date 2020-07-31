import { h } from "@cycle/react"
import { span } from "@cycle/react-dom"
import { Box, Fade } from "@material-ui/core"
import { Laptop, PhoneIphone } from "@material-ui/icons"
import { ToggleButton, ToggleButtonGroup } from "@material-ui/lab"
import { Frame } from "components/frame"
import { rgb } from "csx"
import { isEmpty, max, values } from "fp"
import React, { Fragment, useEffect, useState } from "react"
import { queries } from "styles"
import type { PreviewRef, SectionField } from "../../types"

interface Props {
  htmlRef?: PreviewRef
  fields: SectionField[]
  html: string
}

export const Preview = ({ fields: unstyledFields, htmlRef, html }: Props) => {
  const desktop = queries.desktop.maxWidth + 40 // 640
  const iphone = queries.mobile.maxWidth + 20
  const widths = { desktop, mobile: iphone }
  const [width, setWidth] = useState(desktop)
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
          display: "flex",
          flexDirection: "row",
          paddingBottom: 2,
        },
        [
          h(
            ToggleButtonGroup,
            {
              style: { padding: "4px" },
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
          span({
            ref: htmlRef,
            id: "format-html",
            dangerouslySetInnerHTML: { __html: html },
          }),
        ]
      ),
    ]
  )
}
