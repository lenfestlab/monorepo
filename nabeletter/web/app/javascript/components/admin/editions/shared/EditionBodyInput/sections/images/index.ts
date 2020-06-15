export type URL = string

export interface Image {
  url: URL
  caption?: string
}

import { SectionConfig } from "../section"
export interface Config extends SectionConfig {
  images?: Image[]
  markdown?: string
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
