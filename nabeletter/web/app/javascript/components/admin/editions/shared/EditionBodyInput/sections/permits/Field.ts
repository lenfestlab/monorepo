import { h } from "@cycle/react"
import { b, div, img, table, tbody, td, tr } from "@cycle/react-dom"

import { percent, px } from "csx"
import { allEmpty, either } from "fp"
import { translate } from "i18n"
import { colors, compileStyles } from "styles"
import { Config } from "."
import { SectionField, SectionFieldProps } from "../section/SectionField"

interface Props extends SectionFieldProps {
  kind: string
  config: Config
}

export const Field = ({ config, typestyle, id, analytics, isAmp }: Props) => {
  const { pre, post, selections: permits } = config
  const title = either(
    config.title,
    translate("permits-input-title-placeholder")
  )
  if (allEmpty([pre, post, permits])) return null

  const { styles, classNames } = compileStyles(typestyle!, {
    permits: {
      fontFamily: "Roboto",
      lineHeight: 1.7,
      color: colors.black,
    },
    permit: {
      textAlign: "left",
      paddingBottom: px(15),
    },
    image: {
      width: percent(100),
      display: "block",
      paddingBottom: px(10),
    },
    primary: {
      fontSize: px(16),
      fontWeight: 500,
      paddingTop: px(10),
    },
    secondary: {
      fontSize: px(14),
      fontWeight: "normal",
    },
  })

  return h(
    SectionField,
    { title, pre, post, typestyle, id, analytics, isAmp },
    [
      table({ style: styles.permits, className: classNames.permits }, [
        tbody([
          tr([
            td([
              ...permits.map(
                ({
                  image,
                  type,
                  address,
                  date,
                  description: defaultDescription,
                  description_custom,
                  property_owner,
                  contractor_name,
                }) => {
                  const description = description_custom ?? defaultDescription
                  return table([
                    tr([
                      td(
                        { style: styles.permit, className: classNames.permit },
                        [
                          img({
                            style: styles.image,
                            className: classNames.image,
                            src: image,
                          }),
                          div(
                            {
                              style: styles.primary,
                              className: classNames.primary,
                            },
                            [b(`${address} | ${type}`)]
                          ),
                          date &&
                            div(
                              {
                                style: styles.secondary,
                                className: classNames.secondary,
                              },
                              [b(translate("permits-field-date-issued")), date]
                            ),
                          description &&
                            div(
                              {
                                style: styles.secondary,
                                className: classNames.secondary,
                              },
                              [description]
                            ),
                          property_owner &&
                            div(
                              {
                                style: styles.secondary,
                                className: classNames.secondary,
                              },
                              [
                                b(translate("permits-field-owner")),
                                property_owner,
                              ]
                            ),
                          contractor_name &&
                            div(
                              {
                                style: styles.secondary,
                                className: classNames.secondary,
                              },
                              [
                                b(translate("permits-field-contractor")),
                                contractor_name,
                              ]
                            ),
                        ]
                      ),
                    ]),
                  ])
                }
              ),
            ]),
          ]),
        ]),
      ]),
    ]
  )
}
