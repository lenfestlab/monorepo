import { media, types, TypeStyle } from "typestyle"

export const fonts = {
  roboto: "Roboto, sans-serif",
  robotoSlab: "Roboto Slab, Roboto, sans-serif",
}

export const colors = {
  black: "#000",
  darkBlue: "#0066aa", // https://www.colorhexa.com/0066aa
  darkGray: "#9b9b9b", // https://www.colorhexa.com/9b9b9b
  lightGray: "#d3d3d3", // https://www.colorhexa.com/d3d3d3
  veryLightGray: "#e9e9e9",
  white: "#fff",
  lightBlue: "#bbe1fa",
}

export const queries = {
  desktop: { maxWidth: 600 },
  mobile: { maxWidth: 375 },
}

export type Style = types.NestedCSSProperties
export type StyleMap = Record<string, Style>
export type ClassMap = Record<string, string>

interface StyleSet {
  styles: StyleMap
  classNames: ClassMap
}

export const compileStyles = (
  typestyle: TypeStyle,
  styles: StyleMap
): StyleSet => {
  const { stylesheet } = typestyle
  const classNames = stylesheet(styles)
  return {
    styles,
    classNames,
  }
}
