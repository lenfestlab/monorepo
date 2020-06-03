import { get } from "fp"

export const translate = (key: string): string => {
  const messages = {
    // header
    "header-title": `Fishtown Neighborhood Newsletter`,
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
    "events-input-title-placeholder": "Fishtown events",
    "events-input-url-placeholder":
      "https://calendar.google.com/calendar/ical/.../basic.ics",
    "events-input-download": "Load",
    "events-field-more": "View more events >>",
    // news
    "news-input-header": "News",
    "news-input-title-placeholder": "Neighborhood news",
    "news-input-url-placeholder": "https://www.inquirer.com/...html",
    "news-input-url-add": "Add",
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
    // footer
    "footer-feedback-prompt": "Have feedback?",
    "footer-feedback-cta": "Send your comments and questions to ",
    "footer-guide-nabe": "Fishtown New Neighbor Guide",
    "footer-guide-restaurant": "Fishtown Restaurant Guide",
    "footer-copyright": "2020 Lenfest Institute",
    "footer-unsubscribe": "unsubscribe",
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
