import { h } from "@cycle/react"
import { addHours, startOfTomorrow } from "date-fns"
import { DateTimeInput, required } from "react-admin"

interface Props {}

export const EditionPublishAtInput = (props: Props) =>
  h(DateTimeInput, {
    ...props,
    label: "Publish/send at",
    source: "publish_at",
    validate: [required("Publish date required.")],
    initialValue: addHours(startOfTomorrow(), 6),
  })
