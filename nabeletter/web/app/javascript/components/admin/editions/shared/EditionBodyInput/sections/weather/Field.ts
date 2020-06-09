import { h } from "@cycle/react"
import { img, span, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { format, fromUnixTime } from "date-fns"
import { useAsync } from "react-use"
import { media, TypeStyle } from "typestyle"

import { Link } from "analytics"
import { either, isEmpty } from "fp"
import { translate } from "i18n"
import { colors, queries } from "styles"
import { Config } from "."
import { AnalyticsProps, MarkdownField } from "../MarkdownField"
import { SectionField } from "../SectionField"
import { getIconURL } from "./util"

interface ApiDatum {
  icon: string
  time: number
  temperatureHigh: number
  temperatureLow: number
}
interface ApiResponseJSON {
  daily: {
    data: ApiDatum[]
  }
}

interface Day {
  dayOfWeek: string
  imageURL: string
  temp: {
    low: number
    high: number
  }
}

export interface Props {
  config: Config
  typestyle?: TypeStyle
  id: string
  analytics: AnalyticsProps
}
export const Field = ({ config, typestyle, id, analytics }: Props) => {
  const title = either(
    config.title,
    translate("weather-input-title-placeholder")
  )
  const markdown = either(config.markdown, "")

  const vendorURL = "https://darksky.net/poweredby"
  const endpoint = process.env.WEATHER_ENDPOINT
  const lat = process.env.WEATHER_LAT
  const lng = process.env.WEATHER_LNG
  const url = `${endpoint}?lat=${lat}&lng=${lng}`
  const data = useAsync(async () => {
    const response = await fetch(url)
    const json: ApiResponseJSON = await response.json()
    const { round } = Math
    const days: Day[] = json.daily.data
      .slice(0, 7)
      .map(({ time, icon, temperatureHigh, temperatureLow }: ApiDatum) => {
        const day: Day = {
          dayOfWeek: format(fromUnixTime(time), "eee"),
          imageURL: getIconURL(icon),
          temp: {
            high: round(temperatureHigh),
            low: round(temperatureLow),
          },
        }
        return day
      })
    return days
  }, [url])

  const paddingBottom = px(12)
  const classNames = typestyle?.stylesheet({
    vendorAttribution: {
      width: percent(100),
      fontFamily: "Roboto",
      fontSize: px(14),
      fontWeight: 500,
      fontStyle: "italic",
      color: colors.darkGray,
      textAlign: "right",
      padding: px(12),
      $nest: {
        "& a": {
          color: "inherit",
          textDecoration: "inherit",
        },
      },
    },
    dayOfWeek: {
      textTransform: "capitalize",
      textAlign: "center",
      fontWeight: 500,
      color: colors.black,
      fontSize: px(18),
      paddingTop: px(16),
      paddingBottom,
    },
    img: {
      paddingBottom,
      width: px(60),
      ...media(queries.mobile, {
        width: important(px(40)),
      }),
    },
    temps: {
      textAlign: "center",
      paddingBottom,
      fontWeight: "normal",
    },
    tempHigh: {
      display: "inline",
    },
    tempLow: {
      color: colors.darkGray,
      display: "inline",
      paddingLeft: px(5),
      ...media(queries.mobile, {
        display: "block",
        paddingLeft: px(0),
      }),
    },
  })

  const colSpan = 7
  const tableProps = {
    cellPadding: 0,
    cellSpacing: 1,
  }
  if (isEmpty(markdown)) return null
  return h(SectionField, { title, typestyle, id }, [
    table({ className: "weather", ...tableProps }, [
      tbody([
        tr(
          data.value?.map(({ dayOfWeek, imageURL, temp }) => {
            const src = imageURL
            return td([
              table({ ...tableProps }, [
                tbody([
                  tr([td({ className: classNames?.dayOfWeek }, [dayOfWeek])]),
                  tr([td([img({ src, className: classNames?.img })])]),
                  tr([
                    td({ className: classNames?.temps }, [
                      span({
                        className: classNames?.tempHigh,
                        dangerouslySetInnerHTML: {
                          __html: `${temp.high}&#176`,
                        },
                      }),
                      span({
                        className: classNames?.tempLow,
                        dangerouslySetInnerHTML: {
                          __html: `${temp.low}&#176;`,
                        },
                      }),
                    ]),
                  ]),
                ]),
              ]),
            ])
          })
        ),
        // prettier-ignore
        tr([td({ colSpan }, [
          h(MarkdownField, { markdown, typestyle, analytics })
        ])]),
        tr([
          td(
            {
              colSpan,
              className: classNames?.vendorAttribution,
            },
            [
              h(
                Link,
                { url: vendorURL, title: "Powered by Dark Sky", analytics },
                [translate("weather-field-vendor-attribution")]
              ),
            ]
          ),
        ]),
      ]),
    ]),
  ])
}
