import { Identifier, Record } from "ra-core"
export { Identifier, Record }

export interface Newsletter extends Record {
  name: string
  lat: string
  lng: string
  source_urls?: string // space-delimited list of site urls
  sender_address?: string
  sender_name?: string
  social_url_facebook?: string
  logo_url?: string
  timezone?: string
}

export interface Edition extends Record {
  newsletter: Newsletter
  publish_at: string
  subject: string
  // TODO: embed JSONAPI edition.newsletter
  newsletter_name: string
  newsletter_lat: string
  newsletter_lng: string
  newsletter_source_urls: string
  newsletter_analytics_name: string
  newsletter_logo_url: string
  newsletter_timezone: string
}

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
