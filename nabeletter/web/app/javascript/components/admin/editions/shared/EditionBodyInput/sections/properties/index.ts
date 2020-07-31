import { SectionConfig } from "../section"

export interface Property {
  url: string
  image: string
  address: string
  beds: string
  baths: string
  description: string
  price?: string // for sale
  sold_on?: string
}

export interface EditableProperty extends Property {
  description_custom?: string | null
}

export interface Config extends SectionConfig {
  url: string
  properties: EditableProperty[]
}
export type SetConfig = (config: Config) => void

export { Input as BaseInput } from "./Input"

export { Input as SaleInput } from "./sale/Input"
export { Field as SaleField } from "./sale/Field"
export { node as saleNode } from "./sale/node"

export { Input as SoldInput } from "./sold/Input"
export { Field as SoldField } from "./sold/Field"
export { node as soldNode } from "./sold/node"
