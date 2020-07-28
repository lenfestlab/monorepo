import { h } from "@cycle/react"
import { init } from "@sentry/browser"
import ReactDOM from "react-dom"

import { App } from "../components/signup"

const ENV_NAME = process.env.RACK_ENV
const PROD: string = "production"

// https://docs.sentry.io/error-reporting/configuration/?platform=browsernpm#common-options
if (ENV_NAME === PROD) {
  init({
    dsn: process.env.SENTRY_DSN,
    debug: ENV_NAME !== PROD,
    environment: PROD,
  })
}

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    h(App),
    document.body.appendChild(document.getElementById("root")!)
  )
})
