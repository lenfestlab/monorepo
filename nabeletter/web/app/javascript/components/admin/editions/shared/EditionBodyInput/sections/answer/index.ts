export interface Article {
  url: string
  title: string
  description: string
  published_time: string
  site_name: string
  image: string
}

import { SectionConfig } from "../section"
export interface Config extends SectionConfig {
  url: string
  articles: Article[]
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
export { node } from "./node"
