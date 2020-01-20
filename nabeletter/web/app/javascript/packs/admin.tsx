import React from "react"
import ReactDOM from "react-dom"
import * as Sentry from "@sentry/browser"

import { AdminApp } from "../components/admin"

process.env.RACK_ENV == "production" &&
  Sentry.init({ dsn: process.env.SENTRY_DSN })

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <AdminApp />,
    document.body.appendChild(document.createElement("div"))
  )
})
