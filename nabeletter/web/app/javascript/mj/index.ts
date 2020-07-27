// NOTE: https://mjml.io/documentation/#using-mjml-in-json
/*
{
    tagName: 'mjml',
    attributes: {},
    children: [{
        tagName: 'mj-body',
        attributes: {},
        children: [{
            tagName: 'mj-section',
            attributes: {},
            children: [{
                tagName: 'mj-column',
                attributes: {},
                children: [{
                    tagName: 'mj-image',
                    attributes: {
                        'width': '100px',
                        'src': '/assets/img/logo-small.png'
                    }
                },
                {
                    tagName: 'mj-divider',
                    attributes: {
                        'border-color' : '#F46E43'
                    }
                },
                {
                    tagName: 'mj-text',
                    attributes: {
                        'font-size': '20px',
                        'color': '#F45E43',
                        'font-family': 'Helvetica'
                    },
                    content: 'Hello World'
                }]
            }]
        }]
    }]
})
*/
import { compact, isEmpty, map, mapKeys, paramCase } from "fp"
import { Style } from "styles"

type TagName = string
type Content = string
type Attributes = {}

export interface Node {
  tagName: TagName
  attributes: Attributes
  children?: Node[]
  content?: Content
}

export function mj(
  tagName: TagName,
  attrs: Attributes,
  children?: Node[] | string
): Node {
  const attributes = mapKeys(attrs, (value, key) => paramCase(key))
  if (isEmpty(children)) return { tagName, attributes }
  if (typeof children === "string")
    return { tagName, attributes, content: children }
  return { tagName, attributes, children }
}

export { body } from "./body"
export { mjml } from "./mjml"
export { section, Attributes as SectionAttributes } from "./section"
export { column } from "./column"
export { text, Attributes as TextAttributes } from "./text"
export { image, Attributes as ImageAttributes } from "./image"
export { wrapper, Attributes as WrapperAttributes } from "./wrapper"
export { Attributes as TableAttributes, node as table } from "./table"
export { node as raw } from "./raw"
export { group } from "./group"
export { button } from "./button"

export const formatErrorHTML = (data: any): string =>
  `<pre style="color: red">${JSON.stringify(data, null, 2)}</pre>`

export interface MjApiResult {
  html: string
  errors: JSON
}
