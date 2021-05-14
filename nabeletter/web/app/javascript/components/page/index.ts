import { h } from "@cycle/react"
import { a, b, div, h1, h2, h3, img, li, ol, span } from "@cycle/react-dom"
import { parseISO } from "date-fns"
import { ReactNode } from "react"
import ReactMarkdown from "react-markdown"
import { useAsync } from "react-use"

import { Page, PageSection } from "components/admin/shared"
import { EST, format, FORMAT_LONG_ENG } from "i18n"
import facebook from "images/facebook-icon.svg"
import { AnalyticsProps, analyticsURL, track } from "./analytics"
import { classNames } from "./styles"

export type TransformLinkUri = (
  uri: string,
  children?: ReactNode,
  title?: string
) => string

export const PageProfile = ({ page }: { page: Page }) => {
  const {
    id: _page_id,
    header_image_url,
    title,
    pre,
    post,
    sections,
    newsletter_logo_url,
    newsletter_name,
    newsletter_social_url_facebook,
    newsletter_analytics_name,
    last_updated_at,
  } = page

  const sharedAnalyticsProps = {
    label: title,
    page_id: String(_page_id),
    nabe_name: newsletter_analytics_name,
  }

  const { loading, value, error } = useAsync(async () => {
    return await track({
      ...sharedAnalyticsProps,
      action: "view",
    })
  }, [])

  const makeTransformLinkUri = (section_id?: string): TransformLinkUri => {
    const transformLinkUri: TransformLinkUri = (url, children, _) => {
      let child
      // @ts-ignore
      if (children) child = children[0]
      const label: string | undefined = child?.value
      const analyticsProps: AnalyticsProps = {
        ...sharedAnalyticsProps,
        action: "click",
        label,
        section_id,
      }
      const rewritten = analyticsURL(analyticsProps, url)
      return rewritten
    }
    return transformLinkUri
  }

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
          transformLinkUri: makeTransformLinkUri(),
        }),
        ol({ className: classNames.tableOfContents }, [
          ...sections.map(({ id, title, hidden }: PageSection) => {
            const href = `#section-${id}`
            return (
              !hidden &&
              li([
                a(
                  {
                    href,
                    onClick: async () => {
                      await track({
                        ...sharedAnalyticsProps,
                        action: "click",
                        label: title,
                        anchor: `${window.location.href.split("#")[0]}${href}`,
                      })
                    },
                  },
                  title
                ),
              ])
            )
          }),
        ]),
        ...sections.map(({ id, title, body, hidden }: PageSection) => {
          const section_id = String(id)
          return (
            !hidden &&
            div({ id: `section-${id}`, className: classNames.card }, [
              h3({ className: classNames.cardHeader }, title),
              h(ReactMarkdown, {
                source: body,
                escapeHtml: false,
                linkTarget: "_blank",
                transformLinkUri: makeTransformLinkUri(section_id),
              }),
            ])
          )
        }),
        h(ReactMarkdown, {
          source: post,
          escapeHtml: false,
          linkTarget: "_blank",
          transformLinkUri: makeTransformLinkUri(),
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
            href: analyticsURL(
              {
                ...sharedAnalyticsProps,
                action: "click",
              },
              newsletter_social_url_facebook
            ),
            target: "_blank",
          },
          [img({ src: facebook, alt: "Facebook" })]
        ),
      ]),
    ]),
  ])
}
