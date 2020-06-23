import { SectionConfig } from "../section"

export interface Event {
  uid: string
  summary: string
  description: string
  location: string
  url: string
  start: string
  end: string
  attach: string[]
}

export interface Config extends SectionConfig {
  webcal: string
  publicURL?: string
  selections: Event[]
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
