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

export const rewriteURL = (redirect: string, props: AnalyticsProps): string => {
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
  const ga = stringifyUrl({
    url: "https://www.google-analytics.com/collect?v=1&t=event",
    query: {
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
  const url = `https://${process.env.RAILS_HOST}/analytics`
  return stringifyUrl({ url, query: { ga, redirect } })
}
