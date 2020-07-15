import { mj, Node } from "."

// attribute            | unit          | description                    | default value
// ---------------------|---------------|--------------------------------|---------------
// background-color     | color formats | the general background color   | n/a
// css-class            | string        | class name, added to the root HTML element created | n/a
// width                | px            | email's width                  | 600px

interface Attrs {
  backgroundColor?: string
  width?: string
  cssClass?: string
}

export const body = (attrs: Attrs, nodes: Node[]) => mj("mj-body", attrs, nodes)
