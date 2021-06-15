import capitalize from "lodash/capitalize"
import chunk from "lodash/chunk"
import compact from "lodash/compact"
import every from "lodash/every"
import find from "lodash/find"
import first from "lodash/first"
import get from "lodash/get"
import isEmpty from "lodash/isEmpty"
import isEqual from "lodash/isEqual"
import keys from "lodash/keys"
import last from "lodash/last"
import map from "lodash/map"
import max from "lodash/max"
import omit from "lodash/omit"
import reduce from "lodash/reduce"
import some from "lodash/some"
import sortBy from "lodash/sortBy"
import startsWith from "lodash/startsWith"
import truncate from "lodash/truncate"
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

const isPresent = (value: any | string | null | undefined) => !isEmpty(value)
const anyEmpty = <T>(coll: T[]) => some(coll, isEmpty)
const anyPresent = <T>(coll: T[]) => some(coll, (item: T) => isPresent(item))
const allEmpty = <T>(coll: T[]) => every(coll, isEmpty)

export {
  allEmpty,
  anyEmpty,
  anyPresent,
  capitalize,
  chunk,
  compact,
  either,
  find,
  first,
  get,
  isEmpty,
  isEqual,
  isPresent,
  keys,
  last,
  map,
  max,
  omit,
  reduce,
  sortBy,
  truncate,
  startsWith,
  union,
  unionWith,
  uniqBy,
  values,
}
