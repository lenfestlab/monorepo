export interface Article {
  url: string
  title: string
  description: string
  published_time: string
  site_name: string
  image: string
}

export interface Config {
  title: string
  url: string
  articles: Article[]
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
