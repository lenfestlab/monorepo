import { h } from "@cycle/react"
import { a, b, div, h1, h2, img, li, ol, span } from "@cycle/react-dom"
import { horizontal, normalize, setupPage } from "csstips"
import { content, fillParent, vertical } from "csstips"
import { important, percent, px, rgba, url } from "csx"
import ReactMarkdown from "react-markdown"
import { colors, fonts, queries } from "styles"
import { classes, cssRaw, cssRule, media, stylesheet } from "typestyle"

import { Page, PageSection } from "components/admin/shared"

normalize()
setupPage("#root")
cssRule("html, body", {
  height: "100%",
  width: "100%",
  padding: 0,
  margin: 0,
})
cssRule("#root", {
  height: "100%",
  width: "100%",
  padding: 0,
  margin: 0,
})
cssRaw(`
@import url('https://fonts.googleapis.com/css?family=Roboto|Roboto+Slab&display=swap');
`)

const pad = 24
const textStyle = {
  fontFamily: fonts.roboto,
  fontSize: px(18),
}
const classNames = stylesheet({
  background: {
    ...vertical,
    ...fillParent,
    padding: px(pad),
    ...media(queries.desktop, {
      padding: px(0),
    }),
    alignItems: "center",
    justifyContent: "left",
    ...textStyle,
  },
  container: {
    ...content,
    ...vertical,
    backgroundColor: rgba(255, 255, 255, 0.9).toString(),
    maxWidth: px(800),
    ...media(queries.desktop, {
      maxWidth: px(328),
    }),
    padding: px(pad),
    $nest: {
      "& h1, h2": {
        fontSize: px(20),
        fontFamily: fonts.robotoSlab,
      },
    },
    "& a": {
      color: important(colors.darkBlue),
    },
    "& iframe": {
      width: important("100%"),
    },
  },
  toc: {
    listStyleType: "none",
    padding: 0,
    $nest: {
      "& li": {
        paddingBottom: px(14),
      },
    },
  },
  card: {
    padding: px(50),
    paddingTop: px(24),
    ...media(queries.desktop, {
      padding: px(14),
      paddingTop: px(0),
    }),
    marginBottom: px(24),
    fontSize: px(16),
    //
    borderRadius: px(3),
    boxShadow: "0 2px 4px 0 rgba(0, 0, 0, 0.5)",
  },
})

export const PageProfile = ({ page }: { page: Page }) => {
  const { id: page_id, title: page_title, pre, post, sections } = page
  return div({ className: classNames.background }, [
    div({ className: classNames.container }, [
      h1(page_title),
      h(ReactMarkdown, {
        source: pre,
        escapeHtml: false,
        linkTarget: "_blank",
      }),
      ol({ className: classNames.toc }, [
        ...sections.map((section: PageSection) => {
          return li([a({ href: `#section-${section.id}` }, section.title)])
        }),
      ]),
      ...sections.map((section: PageSection) => {
        return div(
          { id: `section-${section.id}`, className: classNames.card },
          [
            h2(section.title),
            h(ReactMarkdown, {
              source: section.body,
              escapeHtml: false,
              linkTarget: "_blank",
            }),
          ]
        )
      }),
      h(ReactMarkdown, {
        source: post,
        escapeHtml: false,
        linkTarget: "_blank",
      }),
    ]),
  ])
}
