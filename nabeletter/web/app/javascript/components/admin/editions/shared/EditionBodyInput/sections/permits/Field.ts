import { h } from "@cycle/react"
import { b, img, table, tbody, td, tr } from "@cycle/react-dom"
import { TypeStyle } from "typestyle"

import { AnalyticsProps as AllAnalyticsProps, Link } from "analytics"
import { percent, px } from "csx"
import { allEmpty, either } from "fp"
import { translate } from "i18n"
import { colors } from "styles"
import { Config } from "."
import { SectionField } from "../section/SectionField"

interface Props {
  kind: string
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: Omit<AllAnalyticsProps, "title">
}

export const Field = ({ config, typestyle, id, kind, analytics }: Props) => {
  const { pre, post, selections: permits } = config
  const title = either(
    config.title,
    translate("permits-input-title-placeholder")
  )

  const classNames = typestyle?.stylesheet({
    permits: {
      fontFamily: "Roboto",
      lineHeight: 1.7,
      color: colors.black,
    },
    permit: {
      paddingBottom: px(15),
    },
    image: {
      width: percent(100),
    },
    primary: {
      fontSize: px(16),
      fontWeight: 500,
    },
    secondary: {
      fontSize: px(14),
      fontWeight: "normal",
    },
  })

  return allEmpty([pre, post, permits])
    ? null
    : h(SectionField, { title, pre, post, typestyle, id, analytics }, [
        table([
          tbody({ className: classNames?.permits }, [
            tr([
              td([
                ...permits.map(
                  ({
                    image,
                    type,
                    address,
                    date,
                    description,
                    property_owner,
                    contractor_name,
                  }) =>
                    table({ className: classNames?.permit }, [
                      tr([
                        td([img({ className: classNames?.image, src: image })]),
                      ]),

                      tr([
                        td({ className: classNames?.primary }, [
                          b(`${address} | ${type}`),
                        ]),
                      ]),

                      date &&
                        tr([
                          td({ className: classNames?.secondary }, [
                            b(translate("permits-field-date-issued")),
                            date,
                          ]),
                        ]),

                      description &&
                        tr([
                          td({ className: classNames?.secondary }, [
                            description,
                          ]),
                        ]),

                      property_owner &&
                        tr([
                          td({ className: classNames?.secondary }, [
                            b(translate("permits-field-owner")),
                            property_owner,
                          ]),
                        ]),

                      contractor_name &&
                        tr([
                          td({ className: classNames?.secondary }, [
                            b(translate("permits-field-contractor")),
                            contractor_name,
                          ]),
                        ]),
                    ])
                ),
              ]),
            ]),
          ]),
        ]),
      ])
}
