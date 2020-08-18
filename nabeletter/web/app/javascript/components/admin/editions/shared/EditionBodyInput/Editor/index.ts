import { h } from "@cycle/react"
import { div } from "@cycle/react-dom"
import { Box, CircularProgress, Grid, Typography } from "@material-ui/core"
import { makeStyles } from "@material-ui/core/styles"

import { viewHeight } from "csx"
import type { PreviewRef, SectionInput } from "../types"
import { Preview } from "./Preview"

const useStyles = makeStyles((theme) => ({
  panel: {
    maxHeight: viewHeight(70),
    overflowY: "scroll",
  },
}))

interface Props {
  htmlRef?: PreviewRef
  inputs: SectionInput[]
  syncing: boolean
  html: string
  htmlSizeError: string | null
}

export const Editor = ({
  inputs,
  syncing,
  html,
  htmlRef,
  htmlSizeError,
}: Props) => {
  const css = useStyles()
  return div({ id: "editor" }, [
    h(
      Box,
      {
        id: "progress-indicator",
        key: "progress-indicator",
        display: "flex",
        flexDirection: "row",
        justifyContent: "center",
        flexWrap: "nowrap",
        height: 20,
      },
      [
        syncing &&
          h(CircularProgress, {
            size: 20,
            disableShrink: true,
          }),
        htmlSizeError &&
          h(
            Typography,
            { variant: "subtitle1", color: "error" },
            htmlSizeError
          ),
      ]
    ),
    h(
      Box,
      {
        id: "panel-container",
        display: "flex",
        flexDirection: "row",
        justifyContent: "flex-start",
        flexWrap: "nowrap",
      },
      [
        h(
          Box,
          {
            id: "panel-inputs",
            className: css.panel,
            flex: "1 0",
            paddingLeft: 1,
            paddingTop: 1,
            paddingRight: 2,
          },
          [
            h(Grid, { container: true, direction: "column", spacing: 1 }, [
              ...inputs,
            ]),
          ]
        ),
        h(
          Box,
          {
            id: "panel-fields",
            className: css.panel,
            flex: "0 0 content",
          },
          [
            h(Preview, {
              html,
              htmlRef,
            }),
          ]
        ),
      ]
    ),
  ])
}
