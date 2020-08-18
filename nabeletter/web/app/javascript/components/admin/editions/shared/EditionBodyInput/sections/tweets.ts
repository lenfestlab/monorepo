import { h } from "@cycle/react"
import { FunctionComponent } from "react"

import { compact, isEmpty } from "fp"
import { Input as PostInput, Props as PostInputProps } from "./posts/Input"

const kind = "tweets"

const quickLinks = compact(
  (process.env.SECTION_TWEETS_SOURCE_URLS ?? "").split(/\s+/)
)
export const Input: FunctionComponent<PostInputProps> = (props) =>
  h(PostInput, { kind, quickLinks, ...props })

import { node as postNode, Props as PostNodeProps } from "./posts/node"
export const node = (props: PostNodeProps) => postNode({ ...props, kind })
