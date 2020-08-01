import { stringifyUrl } from "query-string"
export { Link, link } from "./Link"

import { either } from "fp"

export const safeTitle = (title: string | undefined | null) => either(title, "")

type Category = "interaction"
type Action = "click"
type Label = "content" | "ad"
type Neighborhood = "fishtown"

type UUID = string

export interface AnalyticsProps {
  category?: Category
  action?: Action
  label?: Label
  neighborhood?: Neighborhood
  edition: UUID
  section: string
  sectionRank: number
  title: string
}

export const rewriteURL = (
  redirect: string,
  props: AnalyticsProps,
  pixel?: boolean
): string => {
  const {
    category = "interaction",
    action = "click",
    label = "content",
    neighborhood = "fishtown",
    edition,
    section,
    sectionRank,
    title,
  } = props
  const uid = "VAR-RECIPIENT-UID"
  const path = pixel ? "pixel" : "analytics"
  const url = `https://${process.env.RAILS_HOST}/${path}`
  return stringifyUrl({
    url,
    query: {
      redirect,
      uid,
      ec: category,
      ea: action,
      el: label,
      cd1: neighborhood,
      cd2: edition,
      // cd3: "WIP"
      cd4: section,
      cd5: String(sectionRank),
      cd6: redirect,
      cd7: title,
    },
  })
}

export const pixelURL = (edition: string | number): string => {
  const category = "email"
  const action = "open"
  const neighborhood = "fishtown"
  const uid = "VAR-RECIPIENT-UID"
  const url = stringifyUrl({
    url: `https://${process.env.RAILS_HOST}/pixel`,
    query: {
      ec: category,
      ea: action,
      cd1: neighborhood,
      cd2: String(edition),
    },
  })
  const pixel = `${url}&uid=${uid}`
  return pixel
}
