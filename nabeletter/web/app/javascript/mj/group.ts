// attribute           | unit        | description                    | default attributes
// --------------------|-------------|--------------------------------|--------------------------------------
// width               | percent/px  | group width                    | (100 / number of non-raw elements in section)%
// vertical-align      | string      | middle/top/bottom              | top
// background-color    | string      | background color for a group   | n/a
// direction           | ltr / rtl   | set the display order of direct children | ltr
// css-class           | string      | class name, added to the root HTML element created | n/a

import { mj, Node } from "."

export interface Attributes {
  verticalAlign: "top" | "middle" | "bottom"
}

export const group = (attributes: Attributes, nodes: Node[]) => {
  return mj("mj-group", attributes, nodes)
}
