export interface Config {
  text?: string
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { node } from "./node"
