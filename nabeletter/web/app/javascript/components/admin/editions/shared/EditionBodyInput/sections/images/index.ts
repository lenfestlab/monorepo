export type URL = string

export interface Image {
  url: URL
  caption?: string
}

export interface Config {
  title: string
  images?: Image[]
  markdown?: string
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
