import { SectionConfig } from "../section"

export interface Config extends SectionConfig {
  prompt?: string
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
