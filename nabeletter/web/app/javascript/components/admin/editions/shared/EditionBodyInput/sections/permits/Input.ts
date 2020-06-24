import { h } from "@cycle/react"
import { Skeleton } from "@material-ui/lab"
import { format, parseISO } from "date-fns"
import { stringifyUrl } from "query-string"
import { RefObject, useEffect, useState } from "react"
import { humanize } from "underscore.string"
import { Item, TransferList } from "../TransferList"

import { compact } from "fp"
import { translate } from "i18n"
import { useAsync } from "react-use"
import { Config, OpenDataPhillyResponse, Permit, SetConfig } from "."
import { SectionInput } from "../section/SectionInput"

const mapToItems = (permits: Permit[]): Item[] =>
  permits.map((permit) => {
    const id = permit.id
    const title = `${permit.type} - ${permit.address}`
    return { id, title }
  })

const mapToPermits = (items: Item[], permits: Permit[]): Permit[] =>
  compact(
    items.map((item: Item) => permits.find((permit) => permit.id === item.id))
  )

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}

export const Input = ({ config, setConfig, id, inputRef }: Props) => {
  const [title, setTitle] = useState(config.title)
  const [pre, setPre] = useState(config.pre)
  const [post, setPost] = useState(config.post)

  const headerText = translate("permits-input-header")
  const titlePlaceholder = translate("permits-input-title-placeholder")

  const [permits, setPermits] = useState<Permit[]>([])
  const [selections, setSelections] = useState(config.selections ?? [])

  useEffect(() => setConfig({ title, pre, post, selections }), [
    title,
    pre,
    post,
    selections,
  ])

  const [left, setLeft] = useState<Item[]>([])

  const baseURL = "https://phl.carto.com/api/v2/sql"
  const { loading, value, error } = useAsync(async () => {
    const q =
      "SELECT * FROM permits WHERE zip SIMILAR TO '(19125|19122|19123|19106)%' AND typeofwork SIMILAR TO '(NEW|DEMO)%' ORDER BY permitissuedate DESC LIMIT 50"
    const url = stringifyUrl({ url: baseURL, query: { q } })
    const response = await fetch(url, { mode: "cors" })
    const json: OpenDataPhillyResponse = await response.json()

    const permits: Permit[] = json.rows.map(
      ({
        permitnumber,
        address: rawAddress,
        typeofwork,
        permitissuedate,
        approvedscopeofwork,
        opa_owner,
        contractorname,
      }) => {
        const id = permitnumber
        const address = rawAddress
        const type = humanize(typeofwork)
        const date = format(parseISO(permitissuedate), "MMMM d, y")
        const description = approvedscopeofwork
          .split(/\./)
          .map((sentence) => humanize(sentence))
          .join(". ")
        const property_owner = opa_owner
        const contractor_name = contractorname
        const image = `https://maps.googleapis.com/maps/api/streetview?key=AIzaSyA0zzOuoJnfsAJ1YIfPJ7RrtXeiYbdW-ZQ&size=505x240&location=${address}`
        return {
          id,
          type,
          address,
          date,
          description,
          property_owner,
          contractor_name,
          image,
        }
      }
    )
    setPermits(permits)
    setLeft(mapToItems(permits))
    return permits
  }, [baseURL])

  const [right, setRight] = useState(mapToItems(selections))
  useEffect(() => {
    const selectedPermits = mapToPermits(right, permits)
    setSelections(selectedPermits)
  }, [right, permits])

  return h(
    SectionInput,
    {
      id,
      inputRef,
      title,
      setTitle,
      pre,
      setPre,
      post,
      setPost,
      headerText,
      titlePlaceholder,
    },
    [
      // NOTE: skeleton width/height approx TransferList dimensions
      loading
        ? h(Skeleton, { variant: "rect", width: 500, height: 250 })
        : h(TransferList, {
            left,
            right,
            onChange: (left: Item[], right: Item[]) => {
              setLeft(left)
              setRight(right)
            },
          }),
    ]
  )
}
