import polyglotI18nProvider from "ra-i18n-polyglot"
import englishMessages from "ra-language-english"

const messages: any = { en: englishMessages }

export const i18nProvider = polyglotI18nProvider(
  (locale) => messages[locale],
  "en",
  {
    allowMissing: true,
    onMissingKey: (key: string, options: object, locale: string) => key,
  }
)
