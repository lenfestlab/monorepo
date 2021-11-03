import { stringifyUrl } from "query-string"
export { Link, link } from "./Link"
import { Channel, Lang } from "components/admin/shared"

import { either } from "fp"

export const safeTitle = (title: string | undefined | null) => either(title, "")

export const shortenerPrefix = `${document.location.host}/s/`

type Category = "interaction"
type Action = "click"
type Label = "content" | "ad"

type UUID = string

const uid = "VAR-RECIPIENT-UID"

export interface AnalyticsProps {
  category?: Category
  action?: Action
  label?: Label
  neighborhood: string
  edition: UUID
  section?: string
  sectionRank?: number
  title?: string
  aid?: UUID
  channel: Channel
  lang: Lang
}

export const rewriteURL = (redirect: string, props: AnalyticsProps): string => {
  const {
    category = "interaction",
    action = "click",
    label = "content",
    neighborhood,
    edition,
    section,
    sectionRank,
    title,
    aid,
    channel,
    lang,
  } = props
  const url = `https://${process.env.RAILS_HOST}/analytics`
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
      cd9: aid,
      cd10: channel,
      cd11: lang
    },
  })
}

export const pixelURL = (
  channel: Channel,
  lang: Lang,
  newsletter_analytics_name: string,
  edition: string | number,
  ours?: boolean
): string => {
  const v = "1"
  const t = "event"
  const ec = "email"
  const ea = "open"
  const tid = process.env.GA_TID as string
  const cd1 = newsletter_analytics_name
  const cd2 = String(edition)
  const cd10 = channel
  const cd11 = lang
  const url = ours
    ? `https://${process.env.RAILS_HOST}/pixel`
    : `https://www.google-analytics.com/collect`
  return stringifyUrl({
    url,
    query: {
      v,
      t,
      ec,
      ea,
      tid,
      uid,
      cd1,
      cd2,
      cd10,
      cd11,
    },
  })
}

export const rewriteDomLinks = (
  html: string,
  analytics: Omit<AnalyticsProps, "title">
): string => {
  const parser = new DOMParser()
  const doc = parser.parseFromString(html, "text/html")
  doc.querySelectorAll("a").forEach((link) => {
    const href = rewriteURL(link.href, {
      ...analytics,
      title: link.innerHTML,
    })
    link.target = "_blank"
    link.href = href
  })
  return doc.documentElement.innerHTML
}
