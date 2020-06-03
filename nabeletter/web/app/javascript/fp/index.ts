import chunk from "lodash/chunk"
import compact from "lodash/compact"
import find from "lodash/find"
import get from "lodash/get"
import isEmpty from "lodash/isEmpty"
import isEqual from "lodash/isEqual"
import map from "lodash/map"
import max from "lodash/max"
import omit from "lodash/omit"
import reduce from "lodash/reduce"
import startsWith from "lodash/startsWith"
import union from "lodash/union"
import unionWith from "lodash/unionWith"
import uniqBy from "lodash/uniqBy"
import values from "lodash/values"

const either = (value: any | string | null | undefined, fallback: any): any => {
  if (value === null || value === undefined || isEmpty(value)) {
    return fallback
  } else {
    return value
  }
}

export {
  chunk,
  compact,
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
  unionWith,
  uniqBy,
  values,
  reduce,
}
