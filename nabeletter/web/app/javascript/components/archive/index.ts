import { h } from "@cycle/react"
import { a, b, div, img, li, span, ul } from "@cycle/react-dom"
import { dataProvider } from "components/admin/providers"
import { normalize, setupPage } from "csstips"
import { px } from "csx"
import { format, formatISO, parseISO } from "date-fns"
import { renderToStaticMarkup } from "react-dom/server"
import { useAsync } from "react-use"
import { create } from "rxjs-spy"
import { colors, fonts, queries } from "styles"
import { classes, cssRaw, cssRule, media, stylesheet } from "typestyle"

import facebook from "images/facebook-icon.svg"
import logo from "images/hook.svg"

const spy = create({ defaultLogger: console, sourceMaps: true })
if (process.env.DEBUG_RX) {
  spy.log() // no filter, logs everything
}

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
const half = 24 / 2
const responsiveWidth = {
  width: px(700),
  ...media(queries.desktop, {
    width: px(328),
  }),
}
const classNames = stylesheet({
  container: {
    minHeight: "100vh",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-end",
    fontFamily: fonts.roboto,
    fontSize: px(18),
  },
  footer: {
    flexBasis: "content",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    backgroundColor: colors.darkBlue,
  },
  footerInner: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    textAlign: "center",
    ...responsiveWidth,
    padding: px(half),
    fontSize: px(16),
    color: colors.white,
  },
  attribution: {
    paddingBottom: px(12),
  },
  social: {},
  socialPitch: {
    paddingBottom: px(10),
  },
  main: {
    flexGrow: 4,
    backgroundColor: colors.lightGray,
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    alignItems: "center",
  },
  mainInner: {
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    ...responsiveWidth,
    alignItems: "stretch",
  },
  innerBare: {
    paddingLeft: px(half),
    paddingRight: px(half),
    paddingBottom: px(half),
  },
  logo: {
    paddingTop: px(pad),
    paddingBottom: px(pad),
  },
  pitch: {
    paddingBottom: px(pad),
  },
  cta: {
    paddingBottom: px(pad),
    alignSelf: "flex-start",
  },
  editions: {
    backgroundColor: colors.white,
    borderRadius: px(3),
    padding: px(pad),
    marginBottom: px(pad),
  },
  editionsHeader: {
    fontSize: px(20),
    fontWeight: 500,
    paddingBottom: px(pad),
  },
  edition: {
    paddingBottom: px(pad),
  },
  editionTitle: {
    fontWeight: 500,
  },
})

const linkString = ({
  href,
  text,
  color,
}: {
  href: string
  text: string
  color?: string
}) =>
  renderToStaticMarkup(
    h(
      "a",
      {
        href,
        target: "_blank",
        style: {
          color: color ?? colors.white,
        },
      },
      [text]
    )
  )

import { Edition } from "components/admin/shared"
interface GetResponse {
  data: Edition[]
  total: number
}

export const App = (_: {}) => {
  const { search } = window.location
  const params = new URLSearchParams(search)
  const newsletter_id = params.get("newsletter_id")

  const lab = linkString({
    href: "https://medium.com/the-lenfest-local-lab",
    text: "Lenfest Local Lab",
  })
  const institute = linkString({
    href: "https://www.lenfestinstitute.org",
    text: "The Lenfest Institute for Journalism",
  })
  const inquirer = linkString({
    href: "https://www.inquirer.com",
    text: "The Philadelphia Inquirer",
  })
  const signup = linkString({
    href: `/signup?newsletter_id=${newsletter_id}`,
    text: "Sign up",
    color: colors.darkBlue,
  })

  const { loading, value, error } = useAsync(async () => {
    const response: GetResponse = await dataProvider("GET_LIST", "editions", {
      filter: { state: "delivered", newsletter_id },
      pagination: { page: 1, perPage: 100 },
      sort: { field: "publish_at", order: "DESC" },
    })
    return response.data
  }, [open])
  const editions = value ?? []

  return div({ id: "container", className: classNames.container }, [
    div({ id: "main", className: classNames.main }, [
      div({ id: "inner", className: classNames.mainInner }, [
        img({ src: logo, alt: "The Hook", className: classNames.logo }),
        div({ className: classNames.innerBare }, [
          div(
            { className: classes(classNames.innerBare, classNames.pitch) },
            `The Hook is a weekly newsletter just about Fishtown. Each week, you’ll be sent curated headlines about your neighborhood, local events, real estate listings, reminders for community meetings, and more. `
          ),
          div({ className: classes(classNames.innerBare, classNames.cta) }, [
            span({
              dangerouslySetInnerHTML: {
                __html: `${signup} for The Hook`,
              },
            }),
          ]),
        ]),
        div({ id: "editions", className: classNames.editions }, [
          div({ className: classNames.editionsHeader }, "Past editions"),
          ...editions.map(({ id, subject, publish_at }) => {
            const published = format(parseISO(publish_at), "MMMM d, y")
            return div({ className: classNames.edition }, [
              div({ className: classNames.editionTitle }, [
                `The Hook: ${published}`,
              ]),
              a(
                {
                  href: `/editions/${id}`,
                  style: { color: colors.darkBlue },
                },
                subject
              ),
            ])
          }),
        ]),
      ]),
    ]),
    div({ id: "footer", className: classNames.footer }, [
      div({ className: classNames.footerInner }, [
        div({
          id: "attribution",
          className: classNames.attribution,
          dangerouslySetInnerHTML: {
            __html: `This newsletter is brought to you by the ${lab}, a project of ${institute}, and ${inquirer}.`,
          },
        }),
        div({ id: "social", className: classNames.social }, [
          div(
            { id: "social-pitch", className: classNames.socialPitch },
            `Connect with The Hook on Facebook`
          ),
          a(
            {
              href: "https://www.facebook.com/The-Hook-100662555076140",
              target: "_blank",
            },
            [img({ src: facebook, alt: "Facebook" })]
          ),
        ]),
      ]),
    ]),
  ])
}
