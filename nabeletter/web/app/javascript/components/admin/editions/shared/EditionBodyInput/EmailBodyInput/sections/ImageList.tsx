// https://material-ui.com/components/grid-list/#single-line-grid-list
import GridList from "@material-ui/core/GridList"
import GridListTile from "@material-ui/core/GridListTile"
import GridListTileBar from "@material-ui/core/GridListTileBar"
import IconButton from "@material-ui/core/IconButton"
import { createStyles, makeStyles, Theme } from "@material-ui/core/styles"
import { Delete } from "@material-ui/icons"
import React from "react"

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      display: "flex",
      flexWrap: "wrap",
      justifyContent: "space-around",
      overflow: "hidden",
      backgroundColor: theme.palette.background.paper,
    },
    gridList: {
      flexWrap: "nowrap",
      // Promote the list into his own layer on Chrome. This cost memory but helps keeping high FPS.
      transform: "translateZ(0)",
    },
    title: {
      color: theme.palette.primary.light,
    },
    titleBar: {
      background:
        "linear-gradient(to top, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.3) 70%, rgba(0,0,0,0) 100%)",
    },
  })
)

export interface Tile {
  url: string
  caption?: string
  onClickDelete?: (el: any) => void
}

interface Props {
  cellHeight?: number | "auto"
  tiles: Tile[]
}

export function ImageList(props: Props) {
  const classes = useStyles()
  const { tiles, cellHeight } = props

  return (
    <div className={classes.root}>
      <GridList cellHeight={cellHeight} className={classes.gridList} cols={1.5}>
        {tiles.map((tile) => (
          <GridListTile key={tile.url}>
            <img src={tile.url} />
            <GridListTileBar
              title={tile.caption}
              classes={{
                root: classes.titleBar,
                title: classes.title,
              }}
              actionIcon={
                <IconButton id={tile.url} onClick={tile.onClickDelete}>
                  <Delete className={classes.title} />
                </IconButton>
              }
            />
          </GridListTile>
        ))}
      </GridList>
    </div>
  )
}
