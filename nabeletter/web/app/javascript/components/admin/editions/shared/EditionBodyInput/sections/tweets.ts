import { h } from "@cycle/react"
import { FunctionComponent } from "react"

import { compact, isEmpty } from "fp"
import { Field as PostField, Props as PostFieldProps } from "./posts/Field"
import { Input as PostInput, Props as PostInputProps } from "./posts/Input"

const kind = "tweets"

export const Field: FunctionComponent<PostFieldProps> = (props) =>
  h(PostField, { kind, ...props })

const quickLinks = compact(
  (process.env.SECTION_TWEETS_SOURCE_URLS ?? "").split(/\s+/)
)
export const Input: FunctionComponent<PostInputProps> = (props) =>
  h(PostInput, { kind, quickLinks, ...props })
