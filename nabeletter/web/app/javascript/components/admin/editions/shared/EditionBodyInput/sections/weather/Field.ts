import { h } from "@cycle/react"
import { img, span, table, tbody, td, tr } from "@cycle/react-dom"
import { important, percent, px } from "csx"
import { format, fromUnixTime } from "date-fns"
import { useAsync } from "react-use"
import { media } from "typestyle"
import { CachedImage } from "../CachedImage"

import { Link } from "analytics"
import { LayoutTable } from "components/table"
import { allEmpty, either } from "fp"
import { translate } from "i18n"
import { colors, compileStyles, queries } from "styles"
import { Config } from "."
import { MarkdownField } from "../MarkdownField"
import { SectionField, SectionFieldProps } from "../section/SectionField"
import { getIconURLs } from "./node"

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

export interface Props extends SectionFieldProps {
  config: Config
}

export const Field = ({ config, typestyle, id, analytics, isAmp }: Props) => {
  const title = either(
    config.title,
    translate("weather-input-title-placeholder")
  )
  const { markdown, pre, post } = config
  if (process.env.NODE_ENV === "development" && allEmpty([pre, markdown, post]))
    return null

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
          imageURL: getIconURLs(icon)[60],
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
  const { styles, classNames } = compileStyles(typestyle!, {
    vendorAttribution: {
      width: percent(100),
      fontFamily: "Roboto",
      fontSize: px(14),
      fontWeight: 500,
      fontStyle: "italic",
      color: colors.darkGray,
      textAlign: "right",
      padding: px(12),
    },
    vendorAttributionLink: {
      color: colors.darkGray,
      textDecoration: "none",
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
      ...(!isAmp &&
        media(queries.mobile, {
          width: important(px(40)),
        })),
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
      ...(!isAmp &&
        media(queries.mobile, {
          display: "block",
          paddingLeft: px(0),
        })),
    },
  })

  const colSpan = 7
  const tableProps = {
    cellPadding: 0,
    cellSpacing: 1,
  }
  return h(
    SectionField,
    { title, pre, post, typestyle, id, analytics, isAmp },
    [
      h(LayoutTable, { ...tableProps }, [
        tbody([
          tr(
            data.value?.map(({ dayOfWeek, imageURL, temp }) => {
              const src = imageURL
              return td([
                table({ ...tableProps }, [
                  tbody([
                    tr([
                      td(
                        {
                          style: styles.dayOfWeek,
                          className: classNames.dayOfWeek,
                        },
                        [dayOfWeek]
                      ),
                    ]),
                    tr([
                      td([
                        h(CachedImage, {
                          src,
                          alt: dayOfWeek,
                          style: styles.img,
                          className: classNames.img,
                          isAmp,
                        }),
                      ]),
                    ]),
                    tr([
                      td({ style: styles.temps, className: classNames.temps }, [
                        span({
                          style: styles.tempHigh,
                          className: classNames.tempHigh,
                          dangerouslySetInnerHTML: {
                            __html: `${temp.high}&#176`,
                          },
                        }),
                        span({
                          style: styles.tempLow,
                          className: classNames.tempLow,
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
          tr([
            td(
              {
                colSpan,
                style: styles.vendorAttribution,
                className: classNames.vendorAttribution,
              },
              [
                h(
                  Link,
                  {
                    url: vendorURL,
                    title: "Powered by Dark Sky",
                    analytics,
                    style: styles.vendorAttributionLink,
                    className: classNames.vendorAttributionLink,
                  },
                  [translate("weather-field-vendor-attribution")]
                ),
              ]
            ),
          ]),
          tr([
            td({ colSpan }, [
              h(MarkdownField, { markdown, typestyle, analytics, isAmp }),
            ]),
          ]),
        ]),
      ]),
    ]
  )
}
