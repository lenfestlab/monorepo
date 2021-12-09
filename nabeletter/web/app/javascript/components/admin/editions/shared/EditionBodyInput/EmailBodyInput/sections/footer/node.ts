import { link } from "analytics"
import { rewriteURL } from "analytics"
import { percent, px } from "csx"
import { get } from "fp"
import { translate } from "i18n"
import {
  column as columnNode,
  group,
  image,
  mj,
  Node,
  section as sectionNode,
  text as textNode,
  TextAttributes,
  wrapper,
} from "mjml-json"
import { colors } from "styles"
import { SectionNodeProps } from "../section"

const feedbackEmail = process.env.FEEDBACK_EMAIL as string

interface SocialLink {
  title: string
  url: string
  src: string
}
const linebreak = "<br/>"

export interface Props extends SectionNodeProps {}

export const node = ({
  analytics: _analytics,
  context: { edition, isWelcome },
}: Props): Node => {
  const { white } = colors
  const analytics = {
    ..._analytics,
    section: "footer",
    sectionRank: -1,
  }
  const newsletter_id = get(edition, ["newsletter", "id"])
  const newsletter_name = get(edition, "newsletter_name")
  const newsletter_social_url_facebook = get(
    edition,
    "newsletter_social_url_facebook"
  )
  const edition_id = get(edition, "id")

  const socialLinks: SocialLink[] = [
    {
      title: "facebook",
      url: newsletter_social_url_facebook,
      src:
        "https://res.cloudinary.com/dh5yeyrsc/image/upload/v1585124217/social/facebook-icon_yfgb3v.png",
    },
  ]

  const footerTextAttributes: TextAttributes = {
    align: "center",
    color: white,
    fontSize: px(15) as string,
    fontWeight: 400,
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

  const data: {src: string, content: string}[] =  [
    {
      src: "https://res.cloudinary.com/ho6rcccn6/image/upload/v1639069657/20211209-footer-email_sdcwr7.png",
      content: translate("footer-feedback-cta").replace("HERE",
                link({
                  analytics,
                  title: "here",
                  url: `mailto:${feedbackEmail}`,
                  style: {
                    ...styles.link,
                    fontWeight: "bold",
                  },
                })
              ),
    },{
      src: "https://res.cloudinary.com/ho6rcccn6/image/upload/v1639408579/20211209-footer-signup_mipbtx.png",
      content: translate("footer-signup-copy").replace(
          "SIGN_UP",
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
    },{
      src: "https://res.cloudinary.com/ho6rcccn6/image/upload/v1639069657/20211209-footer-news_sxmofw.png",
      content: translate("footer-past-editions").replace(
        "HERE",
        link({
          analytics,
          title: "here",
          url: `https://${process.env.RAILS_HOST}/editions?newsletter_id=${newsletter_id}`,
          style: {
            ...styles.link,
            fontWeight: "bold",
          },
        })
      )
    },
  ]

  const iconRow = ({ src, content }: { src?: string, content: string }): Node => {
      return sectionNode({
        // @ts-ignore
        textAlign: "left",
        paddingBottom: px(24)
      }, [

        group({ verticalAlign: "middle" }, [

          columnNode({
              verticalAlign: "middle",
              paddingRight: px(10),
              // @ts-ignore
              width: px(25),
          }, [
            image({
              src,
              // @ts-ignore
              align: "left",
            }),
          ]),

          columnNode({
              verticalAlign: "middle",
              // @ts-ignore
              width: percent(89),
          }, [
            textNode(
              {
                ...footerTextAttributes,
                align: "left",
              }, [content]
            )

          ])

        ]),

      ])
  }

  return wrapper({
    backgroundColor: colors.darkBlue,
    padding: px(24),
  }, [

    ...data.map(({ src, content }) => {
      return iconRow({ src, content })
    }),

    sectionNode({}, [
      columnNode({}, [
        mj("mj-spacer", { height: px(40) })
      ])
    ]),

    iconRow({
      src: "https://res.cloudinary.com/ho6rcccn6/image/upload/v1639069657/20211209-footer-copyright_t0pe3n.png",
      content: translate("footer-copyright")
    }),

    sectionNode({ }, [
      columnNode({ }, [

        textNode(
          {
            ...footerTextAttributes,
            paddingBottom: px(24),
            align: "left"
          },
          [
            translate("footer-attribution").replace(
              "Lenfest Lab",
              link({
                analytics,
                title: "Lenfest Lab",
                url: "https://medium.com/the-lenfest-local-lab",
                style: styles.link,
              })
              ).replace(
              "The Philadelphia Inquirer",
              link({
                analytics,
                title: "The Philadelphia Inquirer",
                url: "https://www.inquirer.com",
                style: styles.link,
              })
              ).replace(
              "The Lenfest Institute for Journalism",
              link({
                analytics,
                title: "The Lenfest Institute for Journalism",
                url: "https://www.lenfestinstitute.org",
                style: styles.link,
              })
            )
          ]
        ),

        textNode(
          {
            ...footerTextAttributes,
            align: "left",
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


      ])
    ]),

  ])
}
