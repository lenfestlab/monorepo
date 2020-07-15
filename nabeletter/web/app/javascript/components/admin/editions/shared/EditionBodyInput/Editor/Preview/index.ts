import { h } from "@cycle/react"
import { head, html, meta, span, style } from "@cycle/react-dom"
import { Box, Fade } from "@material-ui/core"
import { CircularProgress } from "@material-ui/core"
import { Laptop, PhoneIphone } from "@material-ui/icons"
import { ToggleButton, ToggleButtonGroup } from "@material-ui/lab"
import { Frame } from "components/frame"
import { rgb } from "csx"
import { stringifyUrl } from "query-string"
import React, { Fragment, useEffect, useState } from "react"

import { isEmpty, max, values } from "fp"
import { useAsync } from "react-use"

import { Node as MJNode } from "mj"
import { onErrorResumeNext, Subject } from "rxjs"
import { queries } from "styles"
import type { PreviewRef, SectionField } from "../../types"
import { AmpEmail } from "./AmpEmail"
import { Body } from "./Body"
import { HtmlEmail } from "./HtmlEmail"

const errorHTML = (data: any) =>
  `<pre style="color: red">${JSON.stringify(data, null, 2)}</pre>`

interface MjmlResult {
  html: string
  errors: JSON
}

interface Props {
  htmlRef?: PreviewRef
  ampRef?: PreviewRef
  fields: SectionField[]
  mjNode?: MJNode
  html$$: Subject<string>
}

export const Preview = ({
  fields: unstyledFields,
  htmlRef,
  ampRef,
  mjNode,
  html$$,
}: Props) => {
  const desktop = queries.desktop.maxWidth + 40 // 640
  const iphone = queries.mobile.maxWidth + 20
  const widths = { desktop, mobile: iphone }
  const [width, setWidth] = useState(widths.mobile)
  const onChange = (event: React.MouseEvent<HTMLElement>, newWidth: number) =>
    setWidth(newWidth ?? widths.desktop)

  const height = "100%"
  const formFieldGray = rgb(242, 242, 242)

  const result = useAsync(async () => {
    const url = process.env.MJML_ENDPOINT! as string
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "content-type": "application/json",
      },
      body: JSON.stringify({ mjml: mjNode }),
    })
    const result: MjmlResult = await response.json()
    return result
  }, [mjNode])

  const { loading, error, value } = result

  let __html = ""
  if (loading) __html = "Loading"
  if (error) __html = errorHTML(error)
  if (value) {
    const { html, errors } = value
    if (html) __html = html
    if (!isEmpty(errors)) __html = errorHTML(errors)
  }

  // sync rendered HTML
  html$$.next(__html)

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
          loading
            ? h(CircularProgress, {
                size: 20,
                disableShrink: true,
              })
            : span({
                ref: htmlRef,
                id: "format-html",
                dangerouslySetInnerHTML: { __html },
              }),
        ]
      ),
    ]
  )
}
