// https://material-ui.com/components/transfer-list/

import Button from "@material-ui/core/Button"
import Checkbox from "@material-ui/core/Checkbox"
import Grid from "@material-ui/core/Grid"
import List from "@material-ui/core/List"
import ListItem from "@material-ui/core/ListItem"
import ListItemIcon from "@material-ui/core/ListItemIcon"
import ListItemText from "@material-ui/core/ListItemText"
import Paper from "@material-ui/core/Paper"
import { createStyles, makeStyles, Theme } from "@material-ui/core/styles"
import React, { FunctionComponent } from "react"

import { IconButton, ListItemSecondaryAction } from "@material-ui/core"
import { Edit } from "@material-ui/icons"

import { map } from "fp"

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      margin: "auto",
    },
    paper: {
      width: 200,
      height: 230,
      overflow: "auto",
    },
    button: {
      margin: theme.spacing(0.5, 0),
    },
  })
)

function not(a: Item[], b: Item[]) {
  return a.filter((value) => b.indexOf(value) === -1)
}

function intersection(a: Item[], b: Item[]) {
  return a.filter((value) => b.indexOf(value) !== -1)
}

type ID = string

export interface Item {
  id: ID
  title: string
}

type OnClickEdit = (id: ID) => void

interface Props {
  left: Item[]
  right: Item[]
  onChange: (left: Item[], right: Item[]) => void
  onClickEdit?: OnClickEdit
}

export const TransferList: FunctionComponent<Props> = (props) => {
  const { left: _left, right, onChange, onClickEdit } = props
  const left = _left.filter((item) => !map(right, "id").includes(item.id))
  const [checked, setChecked] = React.useState<Item[]>([])

  const leftChecked = intersection(checked, left)
  const rightChecked = intersection(checked, right)

  const handleToggle = (value: Item) => () => {
    const currentIndex = checked.indexOf(value)
    const newChecked = [...checked]
    if (currentIndex === -1) {
      newChecked.push(value)
    } else {
      newChecked.splice(currentIndex, 1)
    }
    setChecked(newChecked)
  }

  const handleAllRight = () => {
    onChange([], right.concat(left))
  }

  const handleCheckedRight = () => {
    onChange(not(left, leftChecked), right.concat(leftChecked))
    setChecked(not(checked, leftChecked))
  }

  const handleCheckedLeft = () => {
    const leftIds = map(left, "id")
    const additions = rightChecked.filter((item) => !leftIds.includes(item.id))
    const newLeft = left.concat(additions)
    onChange(newLeft, not(right, rightChecked))
    setChecked(not(checked, rightChecked))
  }

  const handleAllLeft = () => {
    onChange(left.concat(right), [])
  }

  const classes = useStyles()
  const customList = (items: Item[], onClickEdit?: OnClickEdit) => (
    <Paper className={classes.paper}>
      <List dense={true} component="div" role="list">
        {items.map((value: Item, idx: number) => {
          const onClick = (_event: React.MouseEvent) => {
            onClickEdit && onClickEdit(value.id)
          }
          const labelId = `transfer-list-item-${value.id}-label`
          return (
            <ListItem
              key={idx}
              role="listitem"
              button={true}
              onClick={handleToggle(value)}
            >
              <ListItemIcon>
                <Checkbox
                  checked={checked.indexOf(value) !== -1}
                  tabIndex={-1}
                  disableRipple={true}
                  inputProps={{ "aria-labelledby": labelId }}
                />
              </ListItemIcon>
              <ListItemText id={labelId} primary={value.title} />
              {onClickEdit && (
                <ListItemSecondaryAction>
                  <IconButton edge="end" onClick={onClick}>
                    <Edit />
                  </IconButton>
                </ListItemSecondaryAction>
              )}
            </ListItem>
          )
        })}
        <ListItem />
      </List>
    </Paper>
  )

  return (
    <Grid
      container={true}
      spacing={2}
      justify="center"
      alignItems="center"
      className={classes.root}
    >
      <Grid item={true}>{customList(left)}</Grid>
      <Grid item={true}>
        <Grid container={true} direction="column" alignItems="center">
          <Button
            variant="outlined"
            size="small"
            className={classes.button}
            onClick={handleAllRight}
            disabled={left.length === 0}
            aria-label="move all right"
          >
            ≫
          </Button>
          <Button
            variant="outlined"
            size="small"
            className={classes.button}
            onClick={handleCheckedRight}
            disabled={leftChecked.length === 0}
            aria-label="move selected right"
          >
            &gt;
          </Button>
          <Button
            variant="outlined"
            size="small"
            className={classes.button}
            onClick={handleCheckedLeft}
            disabled={rightChecked.length === 0}
            aria-label="move selected left"
          >
            &lt;
          </Button>
          <Button
            variant="outlined"
            size="small"
            className={classes.button}
            onClick={handleAllLeft}
            disabled={right.length === 0}
            aria-label="move all left"
          >
            ≪
          </Button>
        </Grid>
      </Grid>
      <Grid item={true}>{customList(right, onClickEdit)}</Grid>
    </Grid>
  )
}
