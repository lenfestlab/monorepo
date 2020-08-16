import { h } from "@cycle/react"
import { div } from "@cycle/react-dom"
import { Select as _Select } from "@material-ui/core"
import FormControl from "@material-ui/core/FormControl"
import InputLabel from "@material-ui/core/InputLabel"
import MenuItem from "@material-ui/core/MenuItem"
import { createStyles, makeStyles, Theme } from "@material-ui/core/styles"
import React from "react"

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    button: {
      display: "block",
      marginTop: theme.spacing(2),
    },
    formControl: {
      margin: theme.spacing(1),
      minWidth: 120,
    },
  })
)

export interface Option {
  name: string
  value: string
}

interface Props {
  label: string
  options: Option[]
  value?: string
  onChange: (value: string) => void
}

export const Select = ({
  label,
  options,
  onChange: _onChange,
  value,
}: Props) => {
  const classes = useStyles()
  const [open, setOpen] = React.useState(false)

  const onChange = (event: React.ChangeEvent<{ value: unknown }>) => {
    const value = event.target.value as string
    _onChange(value)
  }

  const onClose = () => setOpen(false)
  const onOpen = () => setOpen(true)

  const labelId = "select-label"
  return div([
    h(FormControl, { className: classes.formControl }, [
      h(InputLabel, { id: labelId }, label),
      h(
        _Select,
        {
          labelId,
          id: "select",
          open,
          onClose,
          onOpen,
          onChange,
          value,
        },
        options.map(({ value, name }) => h(MenuItem, { value }, name))
      ),
    ]),
  ])
}
