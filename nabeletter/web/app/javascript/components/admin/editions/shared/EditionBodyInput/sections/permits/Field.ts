import { h } from "@cycle/react"
import { b, img, table, tbody, td, tfoot, thead, tr } from "@cycle/react-dom"
import { Fragment } from "react"
import { TypeStyle } from "typestyle"

import { AnalyticsProps as AllAnalyticsProps, Link } from "analytics"
import { percent, px } from "csx"
import { allEmpty } from "fp"
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
  const { title, pre, post, selections: permits } = config

  const classNames = typestyle?.stylesheet({
    permit: {
      fontFamily: "Roboto",
      lineHeight: 1.7,
      color: colors.black,
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

  return allEmpty([title, pre, post, permits])
    ? null
    : h(SectionField, { title, pre, post, typestyle, id, analytics }, [
        table([
          tbody({ className: classNames?.permit }, [
            permits.map((permit) =>
              h(Fragment, [
                tr([
                  td([
                    img({ className: classNames?.image, src: permit.image }),
                  ]),
                ]),

                tr([
                  td({ className: classNames?.primary }, [
                    b(`${permit.address} | ${permit.type}`),
                  ]),
                ]),

                tr([td({ className: classNames?.secondary }, permit.date)]),

                tr([
                  td({ className: classNames?.secondary }, permit.description),
                ]),

                tr([
                  td({ className: classNames?.secondary }, [
                    b(`Property Owner: `),
                    permit.property_owner,
                  ]),
                ]),

                tr([
                  td({ className: classNames?.secondary }, [
                    b(`Contractor: `),
                    permit.contractor_name,
                  ]),
                ]),
              ])
            ),
          ]),
        ]),
      ])
}
