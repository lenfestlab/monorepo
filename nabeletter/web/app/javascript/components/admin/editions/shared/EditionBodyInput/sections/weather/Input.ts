import { h } from "@cycle/react"
import { translate } from "i18n"
import React, { RefObject, useEffect, useState } from "react"
import { useAsyncFn } from "react-use"
import { Forecast } from "."
import { Config, SetConfig } from "."
import { MarkdownInput } from "../MarkdownInput"
import { ProgressButton } from "../ProgressButton"
import { SectionInput } from "../section/SectionInput"

export interface ApiDatum {
  icon: string
  time: number
  temperatureHigh: number
  temperatureLow: number
}

export interface ApiResponseJSON {
  daily: {
    data: ApiDatum[]
  }
}

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}

export const Input = ({ config, setConfig, inputRef, id }: Props) => {
  const [title, setTitle] = useState(config.title)
  const [pre, setPre] = useState(config.pre)
  const [post, setPost] = useState(config.post)
  const [ad, setAd] = useState(config.ad)
  const [markdown, setMarkdown] = useState(config.markdown)
  const [forecast, setForecast] = useState(config.forecast)

  useEffect(() => {
    setConfig({ ad, title, pre, post, markdown, forecast })
  }, [ad, title, pre, post, markdown, forecast])

  const endpoint = process.env.WEATHER_ENDPOINT
  const lat = process.env.WEATHER_LAT
  const lng = process.env.WEATHER_LNG
  const url = `${endpoint}?lat=${lat}&lng=${lng}`
  const [state, update] = useAsyncFn(async () => {
    const response = await fetch(url)
    const json: ApiResponseJSON = await response.json()
    const data: ApiDatum[] = json.daily.data.slice(0, 7)
    const newForecast: Forecast = data.map(
      ({ icon, time, temperatureHigh: high, temperatureLow: low }) => {
        return {
          icon,
          time,
          high,
          low,
        }
      }
    )
    setForecast(newForecast)
    return data
  }, [url])

  const headerText = translate("weather-input-header")
  const titlePlaceholder = translate("weather-input-title-placeholder")
  const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setMarkdown(event.target.value as string)
  }

  const disabled = state.loading
  const pending = state.loading
  const onClick = () => update()

  return h(
    SectionInput,
    {
      id,
      inputRef,
      title,
      setTitle,
      pre,
      setPre,
      post,
      setPost,
      headerText,
      titlePlaceholder,
      ad,
      setAd,
    },
    [
      h(ProgressButton, { disabled, pending, onClick }, "Update forecast"),
      h(MarkdownInput, { markdown, onChange }),
    ]
  )
}
