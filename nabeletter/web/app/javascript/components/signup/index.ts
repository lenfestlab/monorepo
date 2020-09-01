import { h } from "@cycle/react"
import { a, button, div, form, img, input, span } from "@cycle/react-dom"
import { BrowserClient } from "@sentry/browser"
import { dataProvider } from "components/admin/providers"
import { horizontal, normalize, setupPage } from "csstips"
import { content, fillParent, vertical } from "csstips"
import { percent, px, rgba, url } from "csx"
import get from "lodash/get"
import { ChangeEvent, FormEvent, useCallback, useState } from "react"
import { create } from "rxjs-spy"
import { colors, fonts, queries } from "styles"
import { classes, cssRaw, cssRule, media, stylesheet } from "typestyle"
import { URL } from "url"
import backgroundImage from "./background.jpg"

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
cssRule("html", {
  background: `${url(backgroundImage)} no-repeat center center fixed`,
  "-webkit-background-size": "cover",
  MozBackgroundSize: "cover",
  OBackgroundSize: "cover",
  backgroundSize: "cover",
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
    alignItems: "center",
    justifyContent: "center",
  },
  container: {
    ...content,
    ...vertical,
    justifyContent: "center",
    backgroundColor: rgba(255, 255, 255, 0.9).toString(),
    borderRadius: px(8),
    width: px(700),
    ...media(queries.desktop, {
      width: px(328),
    }),
    padding: px(pad),
    paddingTop: px(pad * 2),
    paddingBottom: px(pad * 2),
  },
  logo: {
    paddingBottom: px(pad),
  },
  pitch: {
    fontFamily: fonts.robotoSlab,
    fontSize: px(20),
    fontWeight: 500,
    paddingBottom: px(pad),
  },
  description: {
    ...textStyle,
    lineHeight: 1.33,
    paddingBottom: px(pad),
  },
  more: {
    paddingTop: px(pad),
    ...textStyle,
  },
  link: {
    color: colors.darkBlue,
  },

  form: {
    ...vertical,
    justifyContent: "center",
  },
  email: {
    ...content,
    height: px(40),
    borderRadius: px(8),
    borderWidth: px(1),
    borderStyle: "solid",
    boxSizing: "border-box",
    paddingLeft: px(10),
    width: px(400),
    marginRight: px(20),
    $nest: {
      "&::placeholder": {
        fontFamily: fonts.roboto,
        fontSize: px(14),
      },
      "&:focus": {
        outline: "none",
      },
    },
  },
  emailMobile: {
    ...media(queries.desktop, {
      marginRight: px(0),
      width: percent(100),
    }),
  },
  error: {
    ...content,
    color: "red",
    height: px(40),
    paddingTop: px(10),
    paddingLeft: px(10),
  },
  submit: {
    ...content,
    color: colors.white,
    fontSize: px(16),
    height: px(40),
    borderRadius: px(8),
    border: px(0),
    backgroundColor: colors.darkBlue,
    marginTop: px(10),
    marginBottom: px(10),
    width: px(180),
    $nest: {
      "&:disabled": {
        opacity: 0.5,
      },
    },
  },
  submitMobile: {
    ...media(queries.desktop, {
      width: percent(100),
    }),
  },
  ready: {
    ...content,
    ...horizontal,
    alignItems: "center",
    ...media(queries.desktop, {
      ...vertical,
    }),
  },
  success: {
    ...content,
    ...textStyle,
    textAlign: "center",
    alignSelf: "center",
    color: colors.darkBlue,
  },
})

const moreURL = process.env.ONBOARDING_SIGNUP_MORE_URL! as string

export const App = (_: {}) => {
  const [email, setEmail] = useState("")
  const onChange = (event: ChangeEvent) => {
    const target = event.target as HTMLInputElement
    const value = target.value
    const emailAdress = /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i
    setValid(emailAdress.test(value))
    setEmail(target.value)
  }

  const [valid, setValid] = useState(false)
  const [loading, setLoading] = useState(false)
  const [success, setSucces] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const onSubmit = useCallback(
    (event: FormEvent) => {
      event.preventDefault()
      setError(null)
      setLoading(true)
      const { search } = window.location
      const params = new URLSearchParams(search)
      const newsletter_id = params.get("newsletter_id")
      const email_address = email
      const data = { email_address, newsletter_id }
      fetch(`/signups`, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
      })
        .then(async (response: Response) => {
          if (response.ok) {
            setSucces(true)
          } else {
            const json = await response.json()
            const error = get(json, "error")
            setError(error)
          }
        })
        .catch((error: Error) => {
          setError(error.message)
        })
        .finally(() => {
          setLoading(false)
        })
    },
    [email]
  )

  const disabled = !valid || loading

  return div({ className: classNames.background }, [
    div({ className: classNames.container }, [
      img({ src: logo, alt: "The Hook", className: classNames.logo }),
      div(
        { className: classNames.pitch },
        `Fishtown: Do you want all of your neighborhood news in one place?`
      ),
      div(
        { className: classNames.description },
        `The Hook is a weekly newsletter just about Fishtown. Each week, you’ll receive local news, events, real estate listings, and more.`
      ),
      form({ id: "signup-form", className: classNames.form, onSubmit }, [
        success && div({ className: classNames.success }, "Thanks!"),
        !success &&
          div({ className: classNames.ready }, [
            input({
              placeholder: "Enter your email",
              onChange,
              value: email,
              className: classes(classNames.emailMobile, classNames.email),
            }),
            button(
              {
                className: classes(classNames.submit, classNames.submitMobile),
                disabled,
              },
              "Subscribe"
            ),
          ]),
        error && div({ className: classNames.error }, error),
      ]),
      div({ className: classNames.more }, [
        span(`View more about our project `),
        a(
          { href: moreURL, target: "_blank", className: classNames.link },
          "here"
        ),
      ]),
    ]),
  ])
}
