export interface Permit {
  address: string // "2343 E Firth St",
  contractor_name: string // "City Plumbing Llc",
  date: string // "Permit Issued: March 12, 2020",
  description: string // "Ez interior demolition- for the interior demolition on non-bearing partition wall and ceilings as per attached standard. Deviations from these standards require submission of construction and site plans.",
  image: string // "https://maps.googleapis.com/maps/api/streetview?key=AIzaSyA0zzOuoJnfsAJ1YIfPJ7RrtXeiYbdW-ZQ&size=505x240&location=2343 E Firth St, Philadelphia, PA 19125, USA",
  property_owner: string // "Adam J Osti & Anna J",
  type: string //  "Demolition Permit"
}

import { SectionConfig } from "../section"

export interface Config extends SectionConfig {
  selections: Permit[]
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
