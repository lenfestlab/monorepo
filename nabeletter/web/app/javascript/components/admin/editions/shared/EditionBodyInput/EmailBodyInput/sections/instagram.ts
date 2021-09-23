import { h } from "@cycle/react"
import { FunctionComponent } from "react"

import { Input as PostInput, Props as PostInputProps } from "./posts/Input"

const kind = "instagram"

export const Input: FunctionComponent<PostInputProps> = (props) =>
  h(PostInput, { kind, ...props })

import { node as postNode, Props as PostNodeProps } from "./posts/node"
export const node = (props: PostNodeProps) => postNode({ ...props, kind })
