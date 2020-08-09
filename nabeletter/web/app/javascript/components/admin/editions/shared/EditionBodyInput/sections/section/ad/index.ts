export interface Ad {
  image: {
    src: string
    href: string
    alt: string
  }
}

export type AdOpt = Ad | undefined

export { Input } from "./Input"
