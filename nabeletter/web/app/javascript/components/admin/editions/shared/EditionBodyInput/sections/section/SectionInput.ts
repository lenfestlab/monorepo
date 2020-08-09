import { h } from "@cycle/react"
import {
  Card,
  CardContent,
  Grid,
  TextField,
  Typography,
} from "@material-ui/core"
import { compact } from "fp"
import { translate } from "i18n"
import React, { FunctionComponent, RefObject } from "react"
import { AdInput, AdOpt, SectionConfig } from "."
import { MarkdownInput } from "../MarkdownInput"

export interface SectionInputProps extends SectionConfig {
  inputRef: RefObject<HTMLDivElement>
  id: string
  headerText: string
  setTitle: (title: string) => void
  titlePlaceholder: string
  setPre: (title: string) => void
  setPost: (title: string) => void
  setAd?: (ad: AdOpt) => void
}

export const SectionInput: FunctionComponent<SectionInputProps> = ({
  id,
  inputRef,
  title,
  setTitle,
  titlePlaceholder,
  pre,
  setPre,
  post,
  setPost,
  headerText,
  children,
  ad,
  setAd,
}) => {
  return h(Grid, { item: true, ref: inputRef, id }, [
    h(Card, {}, [
      h(
        CardContent,
        {},
        compact([
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
          h(MarkdownInput, {
            markdown: pre,
            placeholder: translate("section-pre"),
            onChange: (event: React.ChangeEvent<HTMLInputElement>) => {
              setPre(event.target.value as string)
            },
          }),
          h(React.Fragment, [children]),
          h(MarkdownInput, {
            markdown: post,
            placeholder: translate("section-post"),
            onChange: (event: React.ChangeEvent<HTMLInputElement>) => {
              setPost(event.target.value as string)
            },
          }),
          setAd && h(AdInput, { ad, setAd }),
        ])
      ),
    ]),
  ])
}
