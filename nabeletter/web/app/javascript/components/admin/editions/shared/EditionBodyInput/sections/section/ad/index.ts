export interface CachedAd {
  id: string
  image: {
    src: string
    href: string
    alt: string
  }
}

export type AdOpt = CachedAd | undefined

export { Input } from "./Input"
