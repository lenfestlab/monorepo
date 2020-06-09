import { h } from "@cycle/react"
import { Skeleton } from "@material-ui/lab"
import { RefObject, useEffect, useState } from "react"
import { Item, TransferList } from "../TransferList"

import { compact } from "fp"
import { translate } from "i18n"
import { useAsync } from "react-use"
import { Config, Permit, SetConfig } from "."
import { SectionInput } from "../section/SectionInput"

const mapToItems = (permits: Permit[]): Item[] =>
  permits.map((permit) => {
    const id = permit.address
    const title = `${permit.type} - ${permit.address}`
    return { id, title }
  })

const mapToPermits = (items: Item[], permits: Permit[]): Permit[] =>
  compact(
    items.map((item: Item) =>
      permits.find((permit) => permit.address === item.id)
    )
  )

interface Props {
  config: Config
  setConfig: SetConfig
  inputRef: RefObject<HTMLDivElement>
  id: string
}
interface State {
  permits: Permit[]
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

  const url = "/permits"
  const { loading, value, error } = useAsync(async () => {
    const response = await fetch(url)
    const permits: Permit[] = await response.json()
    setPermits(permits)
    setLeft(mapToItems(permits))
    return permits
  }, [url])

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
