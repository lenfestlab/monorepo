// attribute           | unit        | description                    | default attributes
// --------------------|-------------|--------------------------------|--------------------------------------
// background-color    | color       | background color for a column  | n/a
// inner-background-color | color    | requires: a padding, inner background color for column | n/a
// border              | string      | css border format              | none
// border-bottom       | string      | css border format              | n/a
// border-left         | string      | css border format              | n/a
// border-right        | string      | css border format              | n/a
// border-top          | string      | css border format              | n/a
// border-radius       | percent/px  | border radius                  | n/a
// inner-border        | string      | css border format              | n/a
// inner-border-bottom       | string      | css border format ; requires a padding | n/a
// inner-border-left         | string      | css border format ; requires a padding | n/a
// inner-border-right        | string      | css border format ; requires a padding | n/a
// inner-border-top          | string      | css border format ; requires a padding | n/a
// inner-border-radius       | percent/px  | border radius ; requires a padding     | n/a
// width               | percent/px  | column width                   | (100 / number of non-raw elements in section)%
// vertical-align      | string      | middle/top/bottom              | top
// padding             | px          | supports up to 4 parameters    | n/a
// padding-top         | px          | section top offset             | n/a
// padding-bottom      | px          | section bottom offset          | n/a
// padding-left        | px          | section left offset            | n/a
// padding-right       | px          | section right offset           | n/a
// css-class           | string      | class name, added to the root HTML element created | n/a

import { mj, Node } from "."

interface Attrs {
  backgroundColor?: string
  cssClass?: string
  innerBackgroundColor?: string
  padding?: string | number
  paddingBottom?: string | number
  paddingLeft?: string | number
  paddingRight?: string | number
  paddingTop?: string | number
  verticalAlign?: "top" | "middle" | "bottom"
  width?: string
}

export const column = (attrs: Attrs, nodes: Node[]) =>
  mj("mj-column", attrs, nodes)
