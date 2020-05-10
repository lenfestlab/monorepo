import { get } from "fp"

const iconMap: Record<string, string> = {
  cloudy:
    "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/cloudy-icon_scaz8x.png",
  lightning:
    "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/lightning-icon_p5mfco.png",
  snow:
    "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782166/weather/snow-icon_wyugso.png",
  rain:
    "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/rain-icon_p3zrmg.png",
  fog:
    "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782166/weather/fog-icon_x3crqn.png",
  "clear-day":
    "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782167/weather/sun-icon_utlwwb.png",
  "partly-cloudy-day":
    "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1584782166/weather/half-cloudy-icon_eltwzz.png",
}

export const getIconURL = (key: string): string => {
  return get(iconMap, key, "")
}
