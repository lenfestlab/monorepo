import React from "react"
import ReactDOM from "react-dom"
import * as Sentry from "@sentry/browser"

import { AdminApp } from "../components/admin"

const ENV_NAME: string = process.env.RACK_ENV
const PROD: string = "production"

// https://docs.sentry.io/error-reporting/configuration/?platform=browsernpm#common-options
ENV_NAME == PROD &&
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    debug: ENV_NAME != PROD,
    environment: PROD,
  })

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <AdminApp />,
    document.body.appendChild(document.createElement("div"))
  )
})
