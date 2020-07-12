import { h } from "@cycle/react"
import { img } from "@cycle/react-dom"
import { Typography } from "@material-ui/core"
import { Skeleton } from "@material-ui/lab"
import { stringifyUrl } from "query-string"
import { useAsync } from "react-use"

import { queries } from "styles"
const { mobile } = queries

interface Image {
  id: string
  url: string
  width: number
  height: number
}

type URL = string

interface Props {
  alt: string
  src: URL
  maxWidth?: number
  placeholderHeight?: number
  isAmp: boolean
  style?: object
  className?: string
}

const imageEndpoint: string = process.env.IMAGE_ENDPOINT!

export const CachedImage = ({
  alt,
  src: originalURL,
  maxWidth = mobile.maxWidth,
  placeholderHeight = 250,
  style,
  className,
  isAmp,
}: Props) => {
  const { loading, value: image, error } = useAsync(async () => {
    const url = originalURL
    const requestURL = stringifyUrl({
      url: imageEndpoint,
      query: { url, width: String(maxWidth) },
    })
    const response = await fetch(requestURL)
    const image: Image = await response.json()
    return image
  }, [originalURL])

  if (loading) {
    return h(Skeleton, {
      variant: "rect",
      width: maxWidth,
      height: placeholderHeight,
    })
  }
  if (image) {
    const { id, url: src, width, height } = image
    if (isAmp) {
      // @ts-ignore - amp-img tag currently unsupported
      return h("amp-img", {
        class: className,
        style,
        src,
        width,
        height,
        alt,
      })
    } else {
      return img({
        className,
        style,
        src,
        width,
        alt,
      })
    }
  } else {
    return h(Typography, { color: "error" }, JSON.stringify(error))
  }
}
