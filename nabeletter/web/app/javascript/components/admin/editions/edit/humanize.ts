import join from "lodash/join"
import last from "lodash/last"
import split from "lodash/split"
import trim from "lodash/trim"

function humanize(strings: string[]) {
  return join(strings, ", ")
}

interface JsonApiError {
  code: number
  detail: string
  source: { pointer: string }
  status: string
  title: string
}

// transforms JSON:API errors into notification message
const humanizeJsonApiError = ({
  code,
  detail,
  source: { pointer },
  status,
  title,
}: JsonApiError) => {
  const errorExplanation = trim(last(split(pointer, "/")))
  return `${errorExplanation} ${title}`
}
