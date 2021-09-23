import { Edition, Newsletter } from "components/admin/shared"
import { TypeStyle } from "typestyle"
import { AnalyticsProps } from "../MarkdownField"

export interface SectionInputContext {
  newsletter?: Newsletter
}

export interface SectionNodeContext {
  edition: Edition
  isWelcome: boolean
}

export interface SectionNodeProps {
  analytics: AnalyticsProps
  context: SectionNodeContext
  typestyle: TypeStyle
}

export { cardWrapper } from "./cardWrapper"
export { cardSection } from "./cardSection"

import { AdOpt } from "./ad"
export { AdOpt }

export interface SectionConfig {
  title: string
  pre?: string
  post?: string
  post_es?: string
  ad?: AdOpt
}

export { Input as AdInput } from "./ad"
