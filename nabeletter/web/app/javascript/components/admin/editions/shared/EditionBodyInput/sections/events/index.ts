export interface Event {
  uid: string
  summary: string
  description: string
  location: string
  url: string
  start: string
  end: string
}

export interface Config {
  title: string
  webcal: string
  publicURL?: string
  selections: Event[]
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
