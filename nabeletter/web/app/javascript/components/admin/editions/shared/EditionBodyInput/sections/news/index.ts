export interface Article {
  url: string
  title: string
  description: string
  published_time: string
  site_name: string
  image: string
}

export interface EditableArticle extends Article {
  site_name_custom?: string | null
}

import { SectionConfig } from "../section"
export interface Config extends SectionConfig {
  url: string
  articles: EditableArticle[]
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { node, articlesNode } from "./node"
