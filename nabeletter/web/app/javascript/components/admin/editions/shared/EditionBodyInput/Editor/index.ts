import { h } from "@cycle/react"
import { div } from "@cycle/react-dom"
import { Box, Grid } from "@material-ui/core"
import { makeStyles } from "@material-ui/core/styles"

import { viewHeight } from "csx"
import type { PreviewRef, SectionField, SectionInput } from "../types"
import { Preview } from "./Preview"

const useStyles = makeStyles((theme) => ({
  panel: {
    maxHeight: viewHeight(70),
    overflowY: "scroll",
  },
}))

interface Props {
  previewRef?: PreviewRef
  inputs: SectionInput[]
  fields: SectionField[]
}
export const Editor = (props: Props) => {
  const css = useStyles()
  const { inputs, fields, previewRef } = props
  return div({ id: "editor" }, [
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
            h(
              Grid,
              { container: true, direction: "column", spacing: 1 },
              inputs
            ),
          ]
        ),
        h(
          Box,
          {
            id: "panel-fields",
            className: css.panel,
            flex: "0 0 content",
          },
          [h(Preview, { id: "preview", previewRef, fields })]
        ),
      ]
    ),
  ])
}
