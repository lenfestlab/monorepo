import { TypeStyle } from "typestyle"
import { AnalyticsProps } from "../MarkdownField"

export interface SectionProps {
  analytics: AnalyticsProps
  typestyle: TypeStyle
}

export { cardWrapper } from "./cardWrapper"
export { cardSection } from "./cardSection"

export interface SectionConfig {
  title: string
  pre?: string
  post?: string
}
