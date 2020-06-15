export type URL = string

export interface Post {
  title?: string
  url: URL
  screenshot_url: URL
  image_id: string
}

export type PostMap = Record<URL, Post>

import { SectionConfig } from "../section"
export interface Config extends SectionConfig {
  postmap: PostMap
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
