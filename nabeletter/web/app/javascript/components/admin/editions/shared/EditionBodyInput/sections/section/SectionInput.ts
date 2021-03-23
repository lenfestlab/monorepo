import { h } from "@cycle/react"
import {
  Button,
  Card,
  CardContent,
  Grid,
  TextField,
  Typography,
} from "@material-ui/core"
import { compact } from "fp"
import { translate } from "i18n"
import React, {
  FunctionComponent,
  RefObject,
  useCallback,
  useState,
} from "react"
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
  setPost_es: (text: string) => void
  setAd?: (ad: AdOpt) => void
}

export interface TranslateResponseJSON {
  es: string
}

const showdown = require("showdown")
const converter = new showdown.Converter()

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
  post_es,
  setPost_es,
  headerText,
  children,
  ad,
  setAd,
}) => {
  const [loading, setLoading] = useState(false)
  const onClickTranslate = useCallback(async () => {
    setLoading(true)
    const url = process.env.TRANSLATE_ENDPOINT! as string
    const en = converter.makeHtml(post)
    const response = await fetch(url, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ en }),
    })
    const { es: es_html }: TranslateResponseJSON = await response.json()
    const es = converter.makeMarkdown(es_html)
    setPost_es(es)
    setLoading(false)
  }, [post])
  const translateSupported = !/news|properties/g.test(id)

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
          translateSupported &&
            h(
              Button,
              {
                color: "primary",
                variant: "text",
                disabled: loading,
                onClick: onClickTranslate,
              },
              "Translate"
            ),
          translateSupported &&
            h(MarkdownInput, {
              markdown: post_es,
              placeholder: translate("section-post-es"),
              onChange: (event: React.ChangeEvent<HTMLInputElement>) => {
                setPost_es(event.target.value as string)
              },
            }),
          setAd && h(AdInput, { ad, setAd }),
        ])
      ),
    ]),
  ])
}
