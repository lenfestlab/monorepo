import { link, pixelURL } from "analytics"
import { important, px } from "csx"
import { format, fromUnixTime, parseISO } from "date-fns"
import { allEmpty, either, get } from "fp"
import { translate } from "i18n"
import { column, group, image, Node, text } from "mj"
import { colors, StyleMap } from "styles"
import { Config, Forecast } from "."
import { md } from "../MarkdownField"
import { cardSection, cardWrapper, SectionProps } from "../section"

type ImageWidth = string
type ImageURL = string
export type ImageMap = Record<ImageWidth, ImageURL>
const iconMap: Record<string, ImageMap> = {
  cloudy: {
    60: "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/cloudy-icon_scaz8x.png",
    30: "https://res.cloudinary.com/hb8lfmjh0/image/upload/v1595620644/aa7668f73f1a5585cd1f153288e159ab.png",
  },
  lightning: {
    60: "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/lightning-icon_p5mfco.png",
    30: "https://res.cloudinary.com/hb8lfmjh0/image/upload/v1595621782/3fdf2b42eedca77b9fef7d0cb7e97a1d.png",
  },
  snow: {
    60: "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782166/weather/snow-icon_wyugso.png",
    30: "https://res.cloudinary.com/hb8lfmjh0/image/upload/v1595621953/35f5303c7f3eb598b6d54d03369011f6.png",
  },
  rain: {
    60: "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/rain-icon_p3zrmg.png",
    30: "https://res.cloudinary.com/hb8lfmjh0/image/upload/v1595620607/b55fb89881cce52ca6e6b100fcab8b86.png",
  },
  fog: {
    60: "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782166/weather/fog-icon_x3crqn.png",
    30: "https://res.cloudinary.com/hb8lfmjh0/image/upload/v1595622015/19f4faec86839d26f61f9e1989ba2f45.png",
  },
  "clear-day": {
    60: "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/sun-icon_utlwwb.png",
    30: "https://res.cloudinary.com/hb8lfmjh0/image/upload/v1595622066/72ab1e1c6bb625b5704a960cfbcea750.png",
  },
  "partly-cloudy-day": {
    60: "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782166/weather/half-cloudy-icon_eltwzz.png",
    30: "https://res.cloudinary.com/hb8lfmjh0/image/upload/v1595622105/4f7a112a9b0d49e23578f72d5d91c022.png",
  },
}

export const getIconURLs = (key: string): ImageMap => {
  return get(iconMap, key, {})
}

export interface Day {
  dayOfWeek: string
  imageURL: string
  imageMap: ImageMap
  temp: {
    low: number
    high: number
  }
}

export interface Props extends SectionProps {
  config: Config
}

export const node = ({
  analytics,
  config,
  typestyle,
  context: { edition },
}: Props): Node | null => {
  const title = either(
    config.title,
    translate("weather-input-title-placeholder")
  )
  const { markdown, pre, post } = config
  if (allEmpty([pre, markdown, post])) return null

  const forecast: Forecast = either(config.forecast, [])
  const days: Day[] = forecast.map(({ time, icon, high, low }) => {
    const imageMap = getIconURLs(icon)
    const day: Day = {
      dayOfWeek: format(fromUnixTime(time), "eee"),
      imageMap,
      imageURL: imageMap[30],
      temp: {
        high: Math.round(high),
        low: Math.round(low),
      },
    }
    return day
  })

  let date: null | string = null
  const publishAt = get(edition, "publish_at")
  if (publishAt) {
    date = format(parseISO(publishAt), "y-MM-dd")
  }
  const lat: string | null = get(edition, "newsletter_lat")
  const lng: string | null = get(edition, "newsletter_lng")
  const url =
    date && lat && lng
      ? `https://darksky.net/details/${lat},${lng}/${date}/us12/en`
      : "https://darksky.net"

  const edition_id = get(edition, "id")

  const styles: StyleMap = {
    day: {
      whiteSpace: "nowrap",
    },
    vendorAttributionLink: {
      color: important(colors.darkGray),
      textDecoration: important("none"),
    },
  }
  const classNames = typestyle.stylesheet(styles)

  return cardWrapper(
    {
      title,
      pre,
      post,
      analytics,
      typestyle,
    },
    [
      cardSection({}, [
        group({ verticalAlign: "top" }, [
          ...days.map(({ dayOfWeek, imageURL: src, imageMap, temp }: Day) => {
            const columnChildAttrs = {
              align: "center",
              padding: px(0),
            }
            return column({ verticalAlign: "top" }, [
              text(
                {
                  ...columnChildAttrs,
                  align: "center",
                  fontSize: px(18),
                  fontWeight: 500,
                  padding: px(0),
                  cssClass: classNames.day,
                },
                dayOfWeek
              ),
              image({
                ...columnChildAttrs,
                paddingTop: px(12),
                paddingBottom: px(12),
                src,
                // NOTE: mjml srcset/sizes support unclear
                width: px(30) as string,
                // srcset: `${imageMap[60]} 60w, ${imageMap[30]} 30w`, // "elva-fairy-480w.jpg 480w, elva-fairy-800w.jpg 800w",
                // sizes: `(max-width: ${queries.desktop.maxWidth}px) 30px, 60px`, // sizes="(max-width: 600px) 480px, 800px"
                // width: px(60) as string,
                // height: px(60) as string,
                padding: px(0),
                alt: dayOfWeek,
              }),
              text({ ...columnChildAttrs }, `${temp.high}&deg;`),
              text(
                {
                  ...columnChildAttrs,
                  color: colors.darkGray,
                  paddingTop: px(4),
                },
                `${temp.low}&deg;`
              ),
            ])
          }),
        ]),
      ]),

      cardSection({}, [
        column({ paddingTop: px(10) }, [
          text(
            {
              fontSize: px(14),
              fontStyle: "italic",
              align: "right",
            },
            [
              link(
                {
                  url,
                  title: "Powered by Dark Sky",
                  analytics,
                  style: styles.vendorAttributionLink,
                  className: classNames.vendorAttributionLink,
                },
                translate("weather-field-vendor-attribution")
              ),
            ]
          ),
        ]),
      ]),

      cardSection({}, [
        column({ paddingTop: px(10) }, [
          image({
            src: pixelURL(edition_id),
            alt: "pixel-ga",
            width: px(1),
            height: px(1),
          }),
        ]),
      ]),

      cardSection({}, [
        column({}, [text({}, md({ markdown, analytics, typestyle }))]),
      ]),
    ]
  )
}
