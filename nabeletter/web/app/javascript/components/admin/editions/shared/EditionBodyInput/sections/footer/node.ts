import { link, pixelURL } from "analytics"
import { rewriteURL } from "analytics"
import { px } from "csx"
import { get } from "fp"
import { translate } from "i18n"
import {
  column as columnNode,
  image,
  mj,
  Node,
  section as sectionNode,
  text as textNode,
  TextAttributes,
} from "mj"
import { colors } from "styles"
import { SectionProps } from "../section"

const feedbackEmail = process.env.FEEDBACK_EMAIL as string

interface SocialLink {
  title: string
  url: string
  src: string
}
const socialLinks: SocialLink[] = [
  {
    title: "facebook",
    url: process.env.SOCIAL_FACEBOOK as string,
    src:
      "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1585124217/social/facebook-icon_yfgb3v.png",
  },
]

const linebreak = "<br/>"

export interface Props extends SectionProps {}

export const node = ({
  analytics: _analytics,
  context: { edition },
}: Props): Node => {
  const { white } = colors
  const analytics = {
    ..._analytics,
    section: "footer",
    sectionRank: -1,
  }
  const newsletter_id = get(edition, ["newsletter", "id"])
  const newsletter_name = get(edition, "newsletter_name")
  const edition_id = get(edition, "id")

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
      padding: px(24),
    },
    [
      columnNode({}, [
        textNode(
          {
            ...footerTextAttributes,
            paddingBottom: px(24),
          },
          [
            translate("footer-feedback-prompt"),
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
            paddingBottom: px(24),
          },
          [
            translate("footer-signup-copy").replace(
              "LINK",
              link({
                analytics,
                title: "Sign up",
                url: `https://${process.env.RAILS_HOST}/signup?newsletter_id=${newsletter_id}`,
                style: {
                  ...styles.link,
                  fontWeight: "bold",
                },
              })
            ),
          ]
        ),

        textNode({ ...footerTextAttributes }, [
          translate("footer-connect").replace(
            "NEWSLETTER_NAME",
            newsletter_name
          ),
        ]),
        mj(
          "mj-social",
          {
            align: "center",
            containerBackgroundColor: colors.darkBlue,
            color: colors.black,
            iconSize: px(30) as string,
            mode: "horizontal",
            paddingTop: px(0),
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
          [`&copy;`, translate("footer-copyright")]
        ),

        textNode(
          {
            ...footerTextAttributes,
            paddingBottom: px(24),
          },
          [translate("footer-attribution")]
        ),

        textNode(
          {
            ...footerTextAttributes,
          },
          [
            link({
              analytics,
              title: translate("footer-unsubscribe"),
              url: "VAR-UNSUBSCRIBE-URL",
              style: styles.link,
            }),
          ]
        ),
        // image({
        //   src: pixelURL(edition_id),
        //   alt: "pixel",
        //   width: px(1),
        //   height: px(1),
        // }),
      ]),
    ]
  )
}
