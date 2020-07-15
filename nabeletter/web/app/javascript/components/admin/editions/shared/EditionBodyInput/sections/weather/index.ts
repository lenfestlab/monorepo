import { SectionConfig } from "../section"

export interface FarecastDay {
  icon: string
  time: number
  high: number
  low: number
}

export type Forecast = FarecastDay[]

export interface Config extends SectionConfig {
  markdown?: string
  forecast?: Forecast
}

export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
export { node } from "./node"
