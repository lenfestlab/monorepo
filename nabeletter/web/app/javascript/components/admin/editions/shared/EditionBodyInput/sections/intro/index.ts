import { SectionConfig } from "../section"

export interface Config extends SectionConfig {
  markdown?: string
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { node } from "./node"
