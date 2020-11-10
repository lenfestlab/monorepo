import { h } from "@cycle/react"
import { addHours, startOfTomorrow } from "date-fns"
import { DateTimeInput, required } from "react-admin"

export const EditionPublishAtInput = (props: {}) =>
  h(DateTimeInput, {
    ...props,
    label: "Publish/send at",
    source: "publish_at",
    validate: [required("Publish date required.")],
    initialValue: addHours(startOfTomorrow(), 6),
  })
