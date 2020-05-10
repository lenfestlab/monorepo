import { h } from "@cycle/react"
import {
  Card,
  CardContent,
  Grid,
  TextField,
  Typography,
} from "@material-ui/core"
import React, { FunctionComponent, RefObject } from "react"

export interface SectionInputProps {
  inputRef: RefObject<HTMLDivElement>
  id: string
  title: string
  setTitle: (title: string) => void
  titlePlaceholder: string
  headerText: string
}
export const SectionInput: FunctionComponent<SectionInputProps> = ({
  id,
  inputRef,
  title,
  setTitle,
  titlePlaceholder,
  headerText,
  children,
}) => {
  return h(Grid, { item: true, ref: inputRef, id }, [
    h(Card, {}, [
      h(CardContent, {}, [
        h(Typography, { variant: "h5", gutterBottom: true }, headerText),
        h(TextField, {
          value: title,
          onChange: (event: React.ChangeEvent<HTMLInputElement>) => {
            setTitle(event.target.value as string)
          },
          ...{
            placeholder: titlePlaceholder,
            fullWidth: true,
            variant: "filled",
          },
        }),
        h(React.Fragment, [children]),
      ]),
    ]),
  ])
}
