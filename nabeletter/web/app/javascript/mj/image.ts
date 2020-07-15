// attribute                     | unit          | description                    | default value
// ------------------------------|---------------|--------------------------------|-----------------------------
// align                         | position      | image alignment                | center
// alt                           | string        | image description              | n/a
// border                        | string        | css border definition          | none
// border-radius                 | px            | border radius                  | n/a
// container-background-color    | color         | inner element background color | n/a
// css-class                     | string        | class name, added to the root HTML element created | n/a
// fluid-on-mobile               | string        | if "true", will be full width on mobile even if width is set | n/a
// height                        | px            | image height                   | auto
// href                          | url           | link to redirect to on click   | n/a
// padding                       | px            | supports up to 4 parameters    | 10px 25px
// padding-bottom                | px            | bottom offset                  | n/a
// padding-left                  | px            | left offset                    | n/a
// padding-right                 | px            | right offset                   | n/a
// padding-top                   | px            | top offset                     | n/a
// rel                           | string        | specify the rel attribute      | n/a
// sizes                         | media query & width | set width based on query | n/a
// src                           | url           | image source                   | n/a
// srcset                        | url & width   | enables to set a different image source based on the viewport | n/a
// target                        | string        | link target on click           | \_blank
// title                         | string        | tooltip & accessibility        | n/a
// usemap                        | string        | reference to image map, be careful, it isn't supported everywhere         | n/a
// width                         | px            | image width                    | 100%

import { mj, Node } from "."

export interface Attributes {
  align?: string
  alt: string
  src: string
  href?: string
  width?: string | number
  height?: string | number
  padding?: string | number // px | int
  paddingLeft?: string | number // px | int
  paddingRight?: string | number // px | int
  paddingTop?: string | number // px | int
  paddingBottom?: string | number // px | int
  sizes?: string
  srcset?: string
}

export const image = (attributes: Attributes) => {
  return mj("mj-image", attributes)
}
