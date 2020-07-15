// attribute           | unit        | description                    | default value
// --------------------|-------------|--------------------------------|---------------
// background-color    | color       | section color                  | n/a
// background-position   | percent / 'left','top',... (2 values max) | css background position (see outlook limitations in mj-section doc)        | top center
// background-position-x | percent / keyword   | css background position x      | none
// background-position-y | percent / keyword   | css background position y      | none
// background-repeat     | string      | css background repeat          | repeat
// background-size       | px/percent/'cover'/'contain'     | css background size    | auto
// background-url      | url         | background url                 | n/a
// border              | string      | css border format              | none
// border-bottom       | string      | css border format              | n/a
// border-left         | string      | css border format              | n/a
// border-radius       | px          | border radius                  | n/a
// border-right        | string      | css border format              | n/a
// border-top          | string      | css border format              | n/a
// css-class           | string      | class name, added to the root HTML element created | n/a
// full-width          | string      | make the wrapper full-width    | n/a
// padding             | px          | supports up to 4 parameters    | 20px 0
// padding-bottom      | px          | section bottom offset          | n/a
// padding-left        | px          | section left offset            | n/a
// padding-right       | px          | section right offset           | n/a
// padding-top         | px          | section top offset             | n/a
// text-align          | string      | css text-align                 | center

import { mj, Node } from "."

export interface Attributes {
  padding?: string
  paddingLeft?: string | number // px | int
  paddingRight?: string | number // px | int
  paddingTop?: string | number // px | int
  paddingBottom?: string | number // px | int
}

export const wrapper = (attributes: Attributes, nodes: Node[]) => {
  return mj("mj-wrapper", attributes, nodes)
}
