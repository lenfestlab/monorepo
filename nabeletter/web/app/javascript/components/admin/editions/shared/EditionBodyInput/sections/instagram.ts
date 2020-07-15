import { h } from "@cycle/react"
import { FunctionComponent } from "react"

import { Field as PostField, Props as PostFieldProps } from "./posts/Field"
import { Input as PostInput, Props as PostInputProps } from "./posts/Input"

const kind = "instagram"

export const Input: FunctionComponent<PostInputProps> = (props) =>
  h(PostInput, { kind, ...props })

export const Field: FunctionComponent<PostFieldProps> = (props) =>
  h(PostField, { kind, ...props })

import { node as postNode, Props as PostNodeProps } from "./posts/node"
export const node = (props: PostNodeProps) => postNode({ ...props, kind })
