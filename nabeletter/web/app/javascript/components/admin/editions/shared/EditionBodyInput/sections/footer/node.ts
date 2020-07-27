import { footer } from "@cycle/react-dom"
import { link } from "analytics"
import { rewriteURL } from "analytics"
import { AnalyticsProps as _AnalyticsProps } from "analytics/Link"
import { px } from "csx"
import { translate } from "i18n"
import {
  column as columnNode,
  mj,
  Node,
  section as sectionNode,
  text as textNode,
  TextAttributes,
} from "mj"
import { colors } from "styles"

export type AnalyticsProps = Omit<_AnalyticsProps, "section" | "sectionRank">

const feedbackEmail = process.env.FEEDBACK_EMAIL as string
const guideNabe = process.env.FOOTER_GUIDE_NEIGHBOR as string
const guideRestaurant = process.env.FOOTER_GUIDE_RESTAURANT as string

interface SocialLink {
  title: string
  url: string
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

const linebreak = "<br/>"

export interface Props {
  analytics: AnalyticsProps
}

export const node = ({ analytics: _analytics }: Props): Node => {
  const { white } = colors
  const analytics = {
    ..._analytics,
    section: "footer",
    sectionRank: -1,
  }

  const footerTextAttributes: TextAttributes = {
    align: "center",
    color: white,
    fontSize: px(16) as string,
    lineHeight: 1.5,
  }

  const styles = {
    link: {
      color: colors.white,
    },
    socialIcon: {
      paddingLeft: px(10) as string,
      paddingRight: px(10) as string,
    },
  }

  return sectionNode(
    {
      backgroundColor: colors.darkBlue,
      borderRadius: px(3) as string,
      paddingTop: px(24),
      paddingBottom: px(24),
    },
    [
      columnNode({}, [
        textNode(
          {
            ...footerTextAttributes,
            fontSize: px(18) as string,
            paddingBottom: px(24),
          },
          [
            translate("footer-feedback-prompt"),
            linebreak,
            translate("footer-feedback-cta"),
            link({
              analytics,
              title: feedbackEmail,
              url: `mailto:${feedbackEmail}`,
              style: {
                ...styles.link,
                fontWeight: "bold",
              },
            }),
          ]
        ),
        textNode(
          {
            ...footerTextAttributes,
            fontWeight: 500,
            lineHeight: 2,
            paddingBottom: px(24),
          },
          [
            link({
              analytics,
              url: guideNabe,
              title: translate("footer-guide-nabe"),
              style: styles.link,
            }),
            linebreak,
            link({
              analytics,
              url: guideRestaurant,
              title: translate("footer-guide-restaurant"),
              style: styles.link,
            }),
          ]
        ),

        mj(
          "mj-social",
          {
            align: "center",
            containerBackgroundColor: colors.darkBlue,
            color: colors.black,
            iconSize: px(30) as string,
            mode: "horizontal",
          },
          [
            ...socialLinks.map(({ title, url, src }: SocialLink) => {
              const href = rewriteURL(url, {
                ...analytics,
                title,
              })
              return mj("mj-social-element", {
                name: `${title}-noshare`, // https://git.io/JJEie
                backgroundColor: colors.darkBlue,
                color: colors.white,
                href,
              })
            }),
          ]
        ),

        textNode(
          {
            ...footerTextAttributes,
            paddingBottom: px(24),
          },
          [
            `&copy;`,
            translate("footer-copyright"),
            `&nbsp;`,
            link({
              analytics,
              title: translate("footer-unsubscribe"),
              url: "VAR-UNSUBSCRIBE-URL",
              style: styles.link,
            }),
          ]
        ),

        textNode(
          {
            ...footerTextAttributes,
          },
          [translate("footer-attribution")]
        ),
      ]),
    ]
  )
}
