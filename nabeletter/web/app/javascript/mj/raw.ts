import { mj } from "."

export const node = (content: string | string[]) => {
  const inner = typeof content === "string" ? content : content.join(" ")
  return mj("mj-raw", {}, inner)
}
