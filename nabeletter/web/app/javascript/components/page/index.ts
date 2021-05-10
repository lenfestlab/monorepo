import { h } from "@cycle/react"
import { a, b, div, h1, h2, h3, img, li, ol, span } from "@cycle/react-dom"
import { parseISO } from "date-fns"
import ReactMarkdown from "react-markdown"

import { Page, PageSection } from "components/admin/shared"
import { EST, format, FORMAT_LONG_ENG } from "i18n"
import facebook from "images/facebook-icon.svg"
import { classNames } from "./styles"

export const PageProfile = ({ page }: { page: Page }) => {
  const {
    id: page_id,
    header_image_url,
    title,
    pre,
    post,
    sections,
    newsletter_logo_url,
    newsletter_name,
    newsletter_social_url_facebook,
    last_updated_at,
  } = page
  const updated_at = format(
    parseISO(last_updated_at),
    "LLLL d',' y 'at' h':'mm aaaa",
    EST
  )
  return div({ className: classNames.background }, [
    div({ className: classNames.container }, [
      div({ className: classNames.header }, [
        div({ className: classNames.headerBottomAligmentWrapper }, [
          img({
            src: newsletter_logo_url,
            className: classNames.logo,
          }),
          span({ className: classNames.updated }, `Updated on ${updated_at}`),
        ]),
      ]),
      header_image_url &&
        img({
          className: classNames.headerImage,
          src: header_image_url,
        }),
      div({ className: classNames.content }, [
        // title && h1(title),
        h(ReactMarkdown, {
          source: pre,
          escapeHtml: false,
          linkTarget: "_blank",
        }),
        ol({ className: classNames.tableOfContents }, [
          ...sections.map(({ id, title, hidden }: PageSection) => {
            return !hidden && li([a({ href: `#section-${id}` }, title)])
          }),
        ]),
        ...sections.map(({ id, title, body, hidden }: PageSection) => {
          return (
            !hidden &&
            div({ id: `section-${id}`, className: classNames.card }, [
              h3({ className: classNames.cardHeader }, title),
              h(ReactMarkdown, {
                source: body,
                escapeHtml: false,
                linkTarget: "_blank",
              }),
            ])
          )
        }),
        h(ReactMarkdown, {
          source: post,
          escapeHtml: false,
          linkTarget: "_blank",
        }),
      ]),
      div({ className: classNames.footer }, [
        div(
          { className: classNames.footerAttribution },
          `This page is created by the Lenfest Local Lab @ The Inquirer.`
        ),
        div(
          { className: classNames.footerSocialPitch },
          `Connect with ${newsletter_name} on Facebook`
        ),
        a(
          {
            href: newsletter_social_url_facebook,
            target: "_blank",
          },
          [img({ src: facebook, alt: "Facebook" })]
        ),
      ]),
    ]),
  ])
}
