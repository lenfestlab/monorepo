import { h } from "@cycle/react"
import { div } from "@cycle/react-dom"
import { Box, CircularProgress, Grid } from "@material-ui/core"
import { makeStyles } from "@material-ui/core/styles"

import { viewHeight } from "csx"
import type { PreviewRef, SectionField, SectionInput } from "../types"
import { AnalyticsProps, Preview } from "./Preview"
export { AnalyticsProps }

const useStyles = makeStyles((theme) => ({
  panel: {
    maxHeight: viewHeight(70),
    overflowY: "scroll",
  },
}))

interface Props {
  htmlRef?: PreviewRef
  ampRef?: PreviewRef
  inputs: SectionInput[]
  fields: SectionField[]
  analytics: AnalyticsProps
  syncing: boolean
}

export const Editor = ({
  inputs,
  fields,
  htmlRef,
  ampRef,
  analytics,
  syncing,
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
              id: "preview",
              htmlRef,
              ampRef,
              fields,
              analytics,
            }),
          ]
        ),
      ]
    ),
  ])
}
