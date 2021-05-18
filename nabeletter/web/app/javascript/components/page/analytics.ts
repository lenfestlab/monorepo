import { stringifyUrl } from "query-string"
import { uuid } from "uuidv4"

let anon_id = localStorage.getItem("analytics.anon_id")
if (!anon_id) {
  anon_id = uuid()
  localStorage.setItem("analytics.anon_id", anon_id)
}

export interface AnalyticsProps {
  action: string
  label?: string
  page_id: string
  nabe_name: string
  section_id?: string
  anchor?: string
  uid?: string | null
  eid?: string | null
}

export const analyticsURL = (props: AnalyticsProps, redirect?: string) => {
  const {
    action,
    label,
    page_id,
    nabe_name,
    section_id,
    anchor,
    uid,
    eid,
  } = props
  const v = "1"
  const t = "event"
  const ec = "page"
  const ea = action
  const tid = process.env.GA_TID as string
  const el = label
  const cd1 = nabe_name
  const cd2 = eid
  const cd3 = page_id
  const cd4 = section_id
  const aid = anon_id
  const url = `https://${process.env.RAILS_HOST}/analytics`
  return stringifyUrl({
    url,
    query: {
      redirect,
      aid,
      uid,
      v,
      t,
      ec,
      ea,
      el,
      tid,
      cd1,
      cd2,
      cd3,
      cd4,
      cd6: redirect ?? anchor,
      cd7: label,
    },
  })
}

export const track = async (props: AnalyticsProps): Promise<Response> => {
  const url = analyticsURL({
    ...props,
  })
  return await fetch(url)
}
