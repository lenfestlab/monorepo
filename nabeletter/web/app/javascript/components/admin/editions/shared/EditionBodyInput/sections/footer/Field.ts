import { h } from "@cycle/react"
import {
  br,
  div,
  img,
  span,
  table,
  tbody,
  td,
  tfoot,
  tr,
} from "@cycle/react-dom"
import { FunctionComponent } from "react"
import { media, TypeStyle } from "typestyle"

import { Link } from "analytics"
import { AnalyticsProps as LinkAnalyticsProps } from "analytics/Link"
import { LayoutTable } from "components/table"
import { important, percent, px } from "csx"
import { translate } from "i18n"
import { colors, StyleMap } from "styles"
import { queries } from "styles"
import { CachedImage } from "../CachedImage"

export type AnalyticsProps = Omit<LinkAnalyticsProps, "section" | "sectionRank">

interface SocialLink {
  title: string
  url?: string
  src: string
}

const socialLinks: SocialLink[] = [
  {
    title: "twitter",
    url: process.env.SOCIAL_TWITTER as string,
    src:
      "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1585124214/social/twitter-icon_uevlyu.png",
  },
  {
    title: "facebook",
    url: process.env.SOCIAL_FACEBOOK as string,
    src:
      "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1585124217/social/facebook-icon_yfgb3v.png",
  },
  {
    title: "instagram",
    url: process.env.SOCIAL_INSTAGRAM as string,
    src:
      "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1585124216/social/ins-icon_ehb9j9.png",
  },
]

export interface Props {
  analytics: AnalyticsProps
  typestyle: TypeStyle
  isAmp: boolean
}

export const Field: FunctionComponent<Props> = ({
  analytics: _analytics,
  typestyle,
  isAmp,
}) => {
  const section = "footer"
  const analytics = {
    ..._analytics,
    section,
    sectionRank: -1,
  }

  const feedbackEmail = process.env.FEEDBACK_EMAIL as string
  const guideNabe = process.env.FOOTER_GUIDE_NEIGHBOR as string
  const guideRestaurant = process.env.FOOTER_GUIDE_RESTAURANT as string

  const row = {
    paddingBottom: px(24),
  }
  const link = {
    color: colors.white,
  }
  const styles: StyleMap = {
    link,
    footer: {
      marginTop: px(10),
      width: percent(100),
      textAlign: "center",
      fontSize: px(16),
      color: colors.white,
      backgroundColor: colors.darkBlue,
      padding: px(24),
      ...(!isAmp &&
        media(queries.mobile, {
          padding: important(px(10)),
        })),
    },
    feedback: {
      ...row,
      marginTop: px(24),
      fontSize: px(18),
      fontWeight: 500,
    },
    feedbackLink: {
      ...link,
      fontWeight: "bold",
    },
    guides: {
      ...row,
      fontWeight: 500,
      lineHeight: 2,
    },
    social: {
      ...row,
    },
    socialIcon: {
      paddingLeft: px(10),
      paddingRight: px(10),
    },
    misc: {
      paddingTop: px(10),
    },
    unsubscribeLink: {
      ...link,
      textTransform: "capitalize",
    },
    attribution: {},
  }
  const classNames = typestyle.stylesheet(styles)

  return tr([
    td([
      h(LayoutTable, { style: styles.footer, className: classNames.footer }, [
        tbody([
          tr([
            td({ style: styles.feedback, className: classNames.feedback }, [
              span(translate("footer-feedback-prompt")),
              br(),
              span([
                translate("footer-feedback-cta"),
                h(Link, {
                  analytics,
                  style: styles.feedbackLink,
                  className: classNames.feedbackLink,
                  url: `mailto:${feedbackEmail}`,
                  title: feedbackEmail,
                }),
              ]),
            ]),
          ]),
          guideNabe &&
            guideRestaurant &&
            tr([
              td({ style: styles.guides, className: classNames.guides }, [
                h(Link, {
                  analytics,
                  url: guideNabe,
                  title: translate("footer-guide-nabe"),
                  style: styles.link,
                  className: classNames.link,
                }),
                br(),
                h(Link, {
                  analytics,
                  url: guideRestaurant,
                  title: translate("footer-guide-restaurant"),
                  style: styles.link,
                  className: classNames.link,
                }),
              ]),
            ]),
          tr([
            td({ style: styles.social, className: classNames.social }, [
              ...socialLinks.map(({ title, url, src }: SocialLink) => {
                if (!url) return null
                return h(
                  Link,
                  {
                    analytics,
                    url,
                    title,
                    style: styles.link,
                    className: classNames.link,
                  },
                  [
                    h(CachedImage, {
                      alt: title,
                      src,
                      maxWidth: 30,
                      placeholderHeight: 30,
                      isAmp,
                      style: styles.socialIcon,
                      className: classNames.socialIcon,
                    }),
                  ]
                )
              }),
              br(),
              div({ style: styles.misc, className: classNames.misc }, [
                span({
                  dangerouslySetInnerHTML: {
                    __html: `&copy; ${translate("footer-copyright")} &nbsp;`,
                  },
                }),
                h(Link, {
                  analytics,
                  title: translate("footer-unsubscribe"),
                  url: "VAR-UNSUBSCRIBE-URL",
                  style: styles.link,
                  className: classNames.unsubscribeLink,
                }),
              ]),
            ]),
          ]),
          tr([
            td(
              {
                style: styles.attribution,
                className: classNames.attribution,
              },
              [translate("footer-attribution")]
            ),
          ]),
        ]),
      ]),
    ]),
  ])
}
