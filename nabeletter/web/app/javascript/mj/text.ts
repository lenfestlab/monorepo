//  attribute                    | unit          | description                                 | default value
// ------------------------------|---------------|---------------------------------------------|-------------------------------------
//  color                        | color         | text color                                  | #000000
//  font-family                  | string        | font                                        | Ubuntu, Helvetica, Arial, sans-serif
//  font-size                    | px            | text size                                   | 13px
//  font-style                   | string        | normal/italic/oblique                       | n/a
//  font-weight                  | number        | text thickness                              | n/a
//  line-height                  | px            | space between the lines                     | 1
//  letter-spacing               | px,em         | letter spacing                              | none
//  height                       | px            | The height of the element                   | n/a
//  text-decoration              | string        | underline/overline/line-through/none        | n/a
//  text-transform               | string        | uppercase/lowercase/capitalize              | n/a
//  align                        | string        | left/right/center/justify                   | left
//  container-background-color   | color         | inner element background color              | n/a
//  padding                      | px            | supports up to 4 parameters                 | 10px 25px
//  padding-top                  | px            | top offset                                  | n/a
//  padding-bottom               | px            | bottom offset                               | n/a
//  padding-left                 | px            | left offset                                 | n/a
//  padding-right                | px            | right offset                                | n/a
//  css-class                    | string        | class name, added to the root HTML element created | n/a

import { mj, Node } from "."

export interface Attributes {
  align?: string
  color?: string
  cssClass?: string
  fontFamily?: string
  fontSize?: string | number
  fontStyle?: string
  fontWeight?: number | string
  lineHeight?: string | number // px | unitless
  padding?: string | number
  paddingBottom?: string | number
  paddingTop?: string | number
  textAlign?: string
}

export const text = (attributes: Attributes, content: string | string[]) => {
  const inner = typeof content === "string" ? content : content.join(" ")
  return mj("mj-text", attributes, inner)
}
