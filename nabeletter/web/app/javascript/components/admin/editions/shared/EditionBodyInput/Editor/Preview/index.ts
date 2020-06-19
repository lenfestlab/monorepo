import { h } from "@cycle/react"
import { head, html, meta, style } from "@cycle/react-dom"
import { Box, Fade } from "@material-ui/core"
import { Laptop, PhoneIphone } from "@material-ui/icons"
import { ToggleButton, ToggleButtonGroup } from "@material-ui/lab"
import { Frame } from "components/frame"
import { rgb } from "csx"
import React, { Fragment, useEffect, useState } from "react"
import { createTypeStyle } from "typestyle"

import { max, values } from "fp"
import type { PreviewRef, SectionField } from "../../types"
import { AmpEmail } from "./AmpEmail"
import { AnalyticsProps, Body } from "./Body"
import { HtmlEmail } from "./HtmlEmail"

export { AnalyticsProps }

interface Props {
  htmlRef?: PreviewRef
  ampRef?: PreviewRef
  fields: SectionField[]
  analytics: AnalyticsProps
}

export const Preview = ({
  fields: unstyledFields,
  htmlRef,
  ampRef,
  analytics,
}: Props) => {
  // clone each field to merge in typestyle prop
  const htmlTypestyle = createTypeStyle()
  const htmlFields: SectionField[] = unstyledFields.map(
    (child: React.ReactElement<any>) => {
      return React.cloneElement(child, {
        ...child.props,
        typestyle: htmlTypestyle,
      })
    }
  )
  const ampTypestyle = createTypeStyle()
  const ampFields: SectionField[] = unstyledFields.map(
    (child: React.ReactElement<any>) => {
      return React.cloneElement(child, {
        ...child.props,
        typestyle: ampTypestyle,
      })
    }
  )

  // update accumulated css from rendered components
  const [htmlCss, setHtmlCss] = useState("")
  const [ampCss, setAmpCss] = useState("")
  useEffect(() => {
    const newHtmlCss = htmlTypestyle.getStyles()
    if (!(htmlCss === newHtmlCss)) {
      setHtmlCss(newHtmlCss)
    }
    const newAmpCss = ampTypestyle.getStyles()
    if (!(ampCss === newAmpCss)) {
      setAmpCss(newAmpCss)
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

  const formats = { amp: "amp", html: "html" }
  const [format, setFormat] = useState(formats.html)
  const onChangeFormat = (
    event: React.MouseEvent<HTMLElement>,
    newFormat: string
  ) => setFormat(newFormat ?? formats.amp)

  const ampEnabled = false // TODO
  const isAmp = format === formats.amp

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

          ampEnabled &&
            h(
              ToggleButtonGroup,
              {
                style: { padding: "4px" },
                id: "preview-format-toggle",
                value: format,
                onChange: onChangeFormat,
                size: "small",
                exclusive: true,
                "aria-label": "format",
              },
              [
                h(ToggleButton, { value: formats.amp }, "AMP"),
                h(ToggleButton, { value: formats.html }, "HTML"),
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
          h(Fragment, [
            h(
              AmpEmail,
              {
                forwardRef: ampRef,
                css: ampCss,
                visible: isAmp,
              },
              [
                h(Body, {
                  fields: ampFields,
                  typestyle: ampTypestyle,
                  analytics,
                  isAmp,
                }),
              ]
            ),

            h(
              HtmlEmail,
              {
                forwardRef: htmlRef,
                css: htmlCss,
                visible: !isAmp,
              },
              [
                h(Body, {
                  fields: htmlFields,
                  typestyle: htmlTypestyle,
                  analytics,
                }),
              ]
            ),
          ]),
        ]
      ),
    ]
  )
}
