export type URL = string

export interface Post {
  title?: string
  url: URL
  screenshot_url: URL
  image_id: string
}

export type PostMap = Record<URL, Post>

export interface Config {
  title: string
  postmap: PostMap
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
