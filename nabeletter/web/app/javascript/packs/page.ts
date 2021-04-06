import { h } from "@cycle/react"
import ReactDOM from "react-dom"

import { PageProfile } from "../components/page"

const json: string = document.querySelector("#root")!.getAttribute("data-page")!
const page = JSON.parse(json)

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    h(PageProfile, { page }),
    document.body.appendChild(document.getElementById("root")!)
  )
})
