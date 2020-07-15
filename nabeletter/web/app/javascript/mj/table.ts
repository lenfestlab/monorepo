// attribute                   | unit                        | description                    | default value
// ----------------------------|-----------------------------|------------------------------- |--------------
// align                       | left/right/center           | self horizontal alignment      | left
// border                      | border                      | table external border          | none
// cellpadding                 | pixels                      | space between cells            | n/a
// cellspacing                 | pixels                      | space between cell and border  | n/a
// color                       | color                       | text header & footer color     | #000000
// container-background-color  | color                       | inner element background color | n/a
// css-class                   | string                      | class name, added to the root HTML element created | n/a
// font-family                 | string                      | font name                      | Ubuntu, Helvetica, Arial, sans-serif
// font-size                   | px                          | font size                      | 13px
// font-style                  | string                      | font style                     | n/a
// line-height                 | percent/px                  | space between lines            | 22px
// padding                     | percent/px                  | supports up to 4 parameters    | 10px 25px
// padding-bottom              | percent/px                  | bottom offset                  | n/a
// padding-left                | percent/px                  | left offset                    | n/a
// padding-right               | percent/px                  | right offset                   | n/a
// padding-top                 | percent/px                  | top offset                     | n/a
// table-layout                | auto/fixed/initial/inherit  | sets the table layout.         | auto
// width                       | percent/px                  | table width                    | 100%

import { mj, Node } from "."

export interface Attributes {}

export const node = (attributes: Attributes, nodes: Node[]) => {
  return mj("mj-table", attributes, nodes)
}
