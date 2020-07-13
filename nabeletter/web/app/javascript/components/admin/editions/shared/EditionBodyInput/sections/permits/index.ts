export interface OpenDataPhillyPermit {
  permitnumber: string
  address: string
  typeofwork: string
  permitdescription: string
  permitissuedate: string
  approvedscopeofwork: string
  opa_owner: string // "office of property assessment"
  contractorname: string
}
export interface OpenDataPhillyResponse {
  rows: OpenDataPhillyPermit[]
}

export interface Permit {
  id: string
  type: string //  "Demolition Permit"
  address: string // "2343 E Firth St",
  image: string // "https://maps.googleapis.com/maps/api/streetview?key=AIzaSyA0zzOuoJnfsAJ1YIfPJ7RrtXeiYbdW-ZQ&size=505x240&location=2343 E Firth St, Philadelphia, PA 19125, USA",
  date: string
  description: string // "Ez interior demolition- for the interior demolition on non-bearing partition wall and ceilings as per attached standard. Deviations from these standards require submission of construction and site plans.",
  property_owner: string // "Adam J Osti & Anna J",
  contractor_name: string // "City Plumbing Llc",
}

export interface EditablePermit extends Permit {
  description_custom?: string | null
}

import { SectionConfig } from "../section"

export interface Config extends SectionConfig {
  selections: EditablePermit[]
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"
