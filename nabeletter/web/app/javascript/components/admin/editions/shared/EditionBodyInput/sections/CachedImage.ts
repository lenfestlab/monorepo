import { h } from "@cycle/react"
import { img } from "@cycle/react-dom"
import { Typography } from "@material-ui/core"
import { Skeleton } from "@material-ui/lab"
import { stringifyUrl } from "query-string"
import { useAsync } from "react-use"

interface Image {
  id: string
  url: string
  width: number
  height: number
}

type URL = string

interface Props {
  src: URL
  className?: string
  width?: number
  placeholderHeight?: number
  isAmp?: boolean
}

const imageEndpoint: string = process.env.IMAGE_ENDPOINT!

export const CachedImage = ({
  src: originalURL,
  className,
  width = 600,
  placeholderHeight = 250,
  isAmp = false,
}: Props) => {
  const { loading, value: image, error } = useAsync(async () => {
    const url = originalURL
    const requestURL = stringifyUrl({
      url: imageEndpoint,
      query: { url, width: String(width) },
    })
    const response = await fetch(requestURL, { cache: "force-cache" })
    const image: Image = await response.json()
    return image
  }, [originalURL])

  if (loading) {
    return h(Skeleton, {
      variant: "rect",
      width,
      height: placeholderHeight,
    })
  }
  if (image) {
    const { id, url: src, width, height } = image
    return img({ className, src, width, height })
  } else {
    return h(Typography, { color: "error" }, JSON.stringify(error))
  }
}
