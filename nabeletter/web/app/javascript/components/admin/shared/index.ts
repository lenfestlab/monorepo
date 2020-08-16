import { Identifier, Record } from "ra-core"
export { Identifier, Record }

export type Newsletter = Record
export type Edition = Record

export interface Ad extends Record {
  title: string
  body: string
  screenshot_url?: string
  newsletter: Newsletter
  created_at: string
  updated_at: string
}

export { NewsletterReferenceInput } from "./NewsletterReferenceInput"
export { NewsletterReferenceField } from "./NewsletterReferenceField"
