import { format as _format } from "date-fns"
import { utcToZonedTime } from "date-fns-tz"
import { get } from "fp"

export const currency = (amount: number) => {
  const formatter = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  })
  return formatter.format(amount).replace(/\D00(?=\D*$)/, "") // https://bit.ly/3fPs70s
}

export const UTC = "Etc/UTC"
export const EST = "America/New_York"
export const FORMAT_GCAL = "yyyyMMdd'T'HHmmss'Z'"
export const FORMAT_LONG = "EEEE, LLLL d @ p"
export const FORMAT_LONG_ENG = "EEEE, LLLL d 'at' p"
export const FORMAT_SHORT = "L/d/yy h':'mmaa"
export const format = (date: Date, format: string, timezone: string) =>
  _format(utcToZonedTime(date, timezone), format)

export const translate = (key: string): string => {
  const messages = {
    // header
    "header-input-subtitle-placeholder":
      "What you need to start your week in NABE_NAME",
    // properties
    "properties-input-url-placeholder": "https://www.zillow.com/homedetails...",
    "properties-input-url-add": "Add",
    "properties_sale-input-header": "Properties for sale",
    "properties_sale-input-title-placeholder": "Properties for sale",
    "properties_sold-input-header": "Properties sold",
    "properties_sold-input-title-placeholder": "Properties sold",
    // preview
    "preview-title": `Inbox preview`,
    "preview-input-placeholder":
      "Optional. If omitted, clients default to first ~90 characters of content.",
    // header
    "header-title": "NABE_NAME Neighborhood Newsletter",
    // sections
    "section-pre": "Pre",
    "section-post": "Post",
    "section-post-es": "Post (translated)",
    // intro
    "intro-input-header": "Intro",
    "intro-input-title-placeholder": "Today's neighborhood headlines",
    "intro-input-markdown-placeholder": markdownPlaceholder(),
    "intro-field-markdown-placeholder": "TK",
    // weather
    "weather-input-header": "Weather",
    "weather-input-title-placeholder": "Weather Outlook",
    "weather-input-markdown-placeholder": markdownPlaceholder(),
    "weather-field-vendor-attribution": "* Weather Data Powered by Dark Sky",
    // events
    "events-input-header": "Events",
    "events-input-title-placeholder": "NABE_NAME events",
    "events-input-url-placeholder":
      "https://calendar.google.com/calendar/ical/.../basic.ics",
    "events-input-download": "Load",
    "events-add-to-gcal": "Add to calendar >>",
    "events-field-more": "View more events >>",
    "events-field-add":
      "Add our shared neighborhood events calendar to your Google Calendar.",
    "events-input-public-helper":
      "Settings and sharing > Integrate calendar > Public URL to this calendar",
    "events-input-webcal-helper":
      "Settings and sharing > Integrate calendar > Public address in iCal format",
    // news
    "news-input-header": "News",
    "news-input-title-placeholder": "Neighborhood news",
    "news-input-url-placeholder": "https://www.inquirer.com/...html",
    "news-input-url-add": "Add",
    // stats
    "stats-input-header": "Statistics",
    "stats-input-title-placeholder": "NABE_NAME Statistics",
    "stats-input-url-placeholder": "https://.../image.png",
    "stats-input-caption-placeholder": "Image caption",
    "stats-input-md-placeholder": "TK",
    "stats-button-add": "Add",
    // safety
    "safety-input-header": "Safety watch",
    "safety-input-title-placeholder": "Safety watch",
    "safety-input-url-placeholder": "https://.../image.png",
    "safety-input-caption-placeholder": "Image caption",
    "safety-input-md-placeholder": "TK",
    "safety-button-add": "Add",
    // history
    "history-input-header": "History",
    "history-input-title-placeholder": "History",
    "history-input-url-placeholder": "https://.../image.png",
    "history-input-caption-placeholder": "Image caption",
    "history-input-md-placeholder": "TK",
    "history-button-add": "Add",
    // tweets
    "tweets-input-header": "Tweets",
    "tweets-input-title-placeholder": "Tweets from Local Officials",
    "tweets-input-url-placeholder":
      "https://twitter.com/lenfestlab/status/1191710124752158720",
    "tweets-input-url-add": "Add",
    // instagram
    "instagram-input-header": "Instagram",
    "instagram-input-title-placeholder": "Instagram Photos from Local Business",
    "instagram-input-url-placeholder":
      "https://www.instagram.com/p/Bw2CLlzl6bP/",
    "instagram-input-url-add": "Add",
    // facebook
    "facebook-input-header": "Facebook",
    "facebook-input-title-placeholder": "Local Business Facebook Posts",
    "facebook-input-url-placeholder":
      "https://www.facebook.com/greensgrowfarms/posts/10158900860584769",
    "facebook-input-url-add": "Add",
    // permits
    "permits-input-header": "New construction & demolition",
    "permits-input-title-placeholder": "New construction and demolition",
    "permits-field-date-issued": "Date issued: ",
    "permits-field-owner": "Property owner: ",
    "permits-field-contractor": "Contractor: ",
    // ask
    "ask-input-header": "Ask the editor",
    "ask-input-title-placeholder": "Ask the editor",
    "ask-input-prompt-placeholder":
      "What else do you want to know about your neighborhood?",
    "ask-field-question-placeholder": "Type your question here...",
    "ask-field-email-cta": "Email the editor",
    "ask-field-email-subject": "Asking the editor:",
    // answer
    "answer-input-header": "Answer from the editor",
    "answer-input-title-placeholder": "Answer from the editor",
    "answer-input-url-placeholder": "https://www.inquirer.com/...html",
    "answer-input-url-add": "Add",
    // meetings
    "meetings-input-header": "Meetings",
    "meetings-input-title-placeholder": "Neighbors Association Meetings",
    "meetings-field-zoom-link": "Zoom link",
    // "meetings-field-set-reminder": "Set reminder",
    "meetings-field-set-reminder": "Add to calendar >>",
    "meetings-field-more": "View more meetings >>",
    "meetings-field-add": `Add our shared community meetings calendar to your Google Calendar.`,
    // footer
    "footer-feedback-cta": "Send your feedback HERE.",
    "footer-signup-copy": `SIGN_UP to receive the newsletter each week.`,
    "footer-past-editions": `View past editions of The Hook HERE.`,
    "footer-copyright": "Copyright © 2022 The Lenfest Local Lab @ The Inquirer",
    "footer-unsubscribe": "Unsubscribe",
    "footer-attribution":
      "This newsletter is brought to you by the Lenfest Lab, a product and UX team at The Philadelphia Inquirer and founded by The Lenfest Institute for Journalism in 2018.",
    "ad-input-set": "Set advertisement",
    "ad-input-edit": "Edit advertisement",
    "ad-input-title-label": "Title",
    "ad-input-title-placeholder": "Goose Island",
    "ad-input-body-label": "Body",
    "ad-input-body-placeholder": "Lorem...",
    "ad-input-dialogue-href-label": "Link destination URL",
    "ad-input-dialogue-href-placeholder":
      "https://www.gooseisland.com/brewhouse-philly/",
    "ad-input-dialogue-alt-label": "Image alt text",
    "ad-input-dialogue-alt-placeholder": "Goose Island",
    "ad-input-dialogue-src-label": "Ad",
    "ad-input-logo-image-label": "Logo image",
    "ad-input-logo-image-placeholder": "https://.../image.png",
    "ad-input-main-image-label": "Main image",
    "ad-input-main-image-placeholder": "https://.../image.png",
    // pages
    "page-input-image-label": "Header image URL",
    "page-input-image-placeholder": "https://...",
    "page-input-title-label": "Title (required for embedding)",
    "page-input-title-placeholder": "COVID-19 Resources",
    "page-input-pre-label": "Pre/intro text (markdown)",
    "page-input-pre-placeholder": "# ...",
    "page-input-post-label": "Post/outro text (markdown)",
    "page-input-post-placeholder": "# ...",
    // page sections
    "page-section-input-title-label": "Title",
    "page-section-input-title-placeholder": "...",
    "page-section-input-body-label": "Body text (markdown)",
    "page-section-input-body-placeholder": "# ...",

    // Text messaging
    "sms-input-label": "SMS message body",
    "sms-input-placeholder": "SMS message body"
  }
  return get(messages, key)
}

function markdownPlaceholder() {
  return `[Inline-style link](https://www.google.com)
Emphasis, aka italics, with *asterisks* or _underscores_.
Strong emphasis, aka bold, with **asterisks** or __underscores__.
Combined emphasis with **asterisks and _underscores_**.
Strikethrough uses two tildes. ~~Scratch this.~~
`
}
