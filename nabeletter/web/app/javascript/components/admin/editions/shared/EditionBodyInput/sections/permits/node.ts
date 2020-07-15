import { px } from "csx"
import { allEmpty, compact, either } from "fp"
import { translate } from "i18n"
import { column, image as imageNode, Node, text } from "mj"
import { Config } from "."
import { md } from "../MarkdownField"
import { cardSection, cardWrapper, SectionProps } from "../section"

export interface Props extends SectionProps {
  config: Config
}

export const node = ({ analytics, config, typestyle }: Props): Node | null => {
  const { pre, post, selections: permits } = config
  const title = either(
    config.title,
    translate("permits-input-title-placeholder")
  )
  if (allEmpty([pre, post, permits])) return null

  return cardWrapper({ title, pre, post, analytics, typestyle }, [
    ...permits.map(
      ({
        image: src,
        type,
        address,
        date,
        description: defaultDescription,
        description_custom,
        property_owner,
        contractor_name,
      }) => {
        const description = description_custom ?? defaultDescription
        const primary = {
          fontSize: px(18),
          fontWeight: 500,
          paddingTop: px(10),
        }
        const secondary = {
          fontSize: px(14),
          fontWeight: "normal",
        }
        return cardSection({}, [
          column(
            { paddingBottom: px(24) },
            compact([
              imageNode({
                src,
                alt: address,
                paddingBottom: px(12),
              }),
              text({ ...primary }, `${address} | ${type}`),
              date &&
                text({ ...secondary }, [
                  `<b>${translate("permits-field-date-issued")}</b> ${date}`,
                ]),
              description && text({ ...secondary }, description),
              property_owner &&
                text(
                  { ...secondary },
                  `<b>${translate("permits-field-owner")}</b> ${property_owner}`
                ),
              contractor_name &&
                text(
                  { ...secondary },
                  `<b>${translate(
                    "permits-field-owner"
                  )}</b> ${contractor_name}`
                ),
            ])
          ),
        ])
      }
    ),
  ])
}
