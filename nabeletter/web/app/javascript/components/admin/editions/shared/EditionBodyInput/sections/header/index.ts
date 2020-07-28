export interface Config {
  subtitle?: string
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
export { node } from "./node"
