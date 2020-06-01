import { h } from "@cycle/react"
import {
  br,
  img,
  span,
  table,
  tbody,
  td,
  tfoot,
  thead,
  tr,
} from "@cycle/react-dom"
import { FunctionComponent } from "react"
import { classes, media, TypeStyle } from "typestyle"

import { Link } from "analytics"
import { AnalyticsProps as LinkAnalyticsProps } from "analytics/Link"
import { important, percent, px } from "csx"
import { translate } from "i18n"
import { colors } from "styles"
import { queries } from "styles"

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
}

export const Footer: FunctionComponent<Props> = ({
  analytics: _analytics,
  typestyle: { stylesheet },
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

  const classNames = stylesheet({
    footer: {
      width: percent(100),
      textAlign: "center",
      color: colors.white,
      backgroundColor: colors.darkBlue,
      marginTop: px(24),
      padding: px(24),
      ...media(queries.mobile, {
        padding: important(px(10)),
      }),
      $nest: {
        "& a": {
          color: colors.white,
        },
      },
    },
    row: {
      paddingBottom: px(24),
    },
    feedback: {
      fontSize: px(18),
      fontWeight: 500,
      $nest: {
        "& a": {
          fontWeight: "bold",
        },
      },
    },
    guides: {
      fontWeight: 500,
      lineHeight: 2,
    },
    socialIcon: {
      width: px(30),
      marginLeft: px(10),
      marginRight: px(10),
    },
    misc: {},
    unsubscribe: {
      textTransform: "capitalize",
    },
  })

  return tfoot([
    tr([
      td([
        table({ className: classNames.footer }, [
          tbody([
            tr([
              td({ className: classes(classNames.row, classNames.feedback) }, [
                span(translate("footer-feedback-prompt")),
                br(),
                span([
                  translate("footer-feedback-cta"),
                  h(Link, {
                    analytics,
                    url: `mailto:${feedbackEmail}`,
                    title: feedbackEmail,
                  }),
                ]),
              ]),
            ]),
            guideNabe &&
              guideRestaurant &&
              tr([
                td({ className: classes(classNames.row, classNames.guides) }, [
                  h(Link, {
                    analytics,
                    url: guideNabe,
                    title: translate("footer-guide-nabe"),
                  }),
                  br(),
                  h(Link, {
                    analytics,
                    url: guideRestaurant,
                    title: translate("footer-guide-restaurant"),
                  }),
                ]),
              ]),
            tr([
              td(
                { className: classNames.row },
                socialLinks.map(({ title, url, src }: SocialLink) => {
                  if (!url) return null
                  return h(
                    Link,
                    {
                      analytics,
                      url,
                      title,
                    },
                    [img({ src, className: classNames.socialIcon })]
                  )
                })
              ),
            ]),
            tr({ className: classes(classNames.row, classNames.misc) }, [
              span({
                dangerouslySetInnerHTML: {
                  __html: `&copy; ${translate("footer-copyright")} &nbsp;`,
                },
              }),
              h(Link, {
                className: classNames.unsubscribe,
                analytics,
                title: translate("footer-unsubscribe"),
                url: "VAR-UNSUBSCRIBE-URL",
              }),
            ]),
          ]),
        ]),
      ]),
    ]),
  ])
}
