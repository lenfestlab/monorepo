import find from "lodash/find"
import get from "lodash/get"
import isEmpty from "lodash/isEmpty"
import isEqual from "lodash/isEqual"
import map from "lodash/map"
import max from "lodash/max"
import omit from "lodash/omit"
import startsWith from "lodash/startsWith"
import union from "lodash/union"
import values from "lodash/values"

const either = (value: any | string | null | undefined, fallback: any): any => {
  if (value === null || value === undefined || isEmpty(value)) {
    return fallback
  } else {
    return value
  }
}

export {
  either,
  find,
  get,
  isEmpty,
  isEqual,
  map,
  max,
  omit,
  startsWith,
  union,
  values,
}
