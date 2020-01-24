import englishMessages from "ra-language-english"
import polyglotI18nProvider from "ra-i18n-polyglot"

const messages = { en: englishMessages }

export const i18nProvider = polyglotI18nProvider(
  locale => messages[locale],
  "en",
  {
    allowMissing: true,
    onMissingKey: (key, options, locale) => key,
  }
)
