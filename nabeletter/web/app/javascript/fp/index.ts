import chunk from "lodash/chunk"
import compact from "lodash/compact"
import every from "lodash/every"
import find from "lodash/find"
import get from "lodash/get"
import isEmpty from "lodash/isEmpty"
import isEqual from "lodash/isEqual"
import keys from "lodash/keys"
import map from "lodash/map"
import max from "lodash/max"
import omit from "lodash/omit"
import reduce from "lodash/reduce"
import some from "lodash/some"
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

const anyEmpty = <T>(coll: T[]) => some(coll, isEmpty)
const anyPresent = <T>(coll: T[]) => some(coll, (item: T) => !isEmpty(item))
const allEmpty = <T>(coll: T[]) => every(coll, isEmpty)

export {
  allEmpty,
  anyEmpty,
  anyPresent,
  chunk,
  compact,
  either,
  find,
  get,
  isEmpty,
  isEqual,
  keys,
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
