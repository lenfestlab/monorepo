import { Edition } from "components/admin/shared"
import { TypeStyle } from "typestyle"
import { AnalyticsProps } from "../MarkdownField"

export interface Context {
  edition: Edition
  isWelcome: boolean
}

export interface SectionProps {
  analytics: AnalyticsProps
  context: Context
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
  ad?: AdOpt
}

export { Input as AdInput } from "./ad"
