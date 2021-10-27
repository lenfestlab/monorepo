import { h } from "@cycle/react"
import { a, button, div, form, img, input, p, span } from "@cycle/react-dom"
import { normalize, setupPage } from "csstips"
import { url } from "csx"
import get from "lodash/get"
import { phone as validatePhone } from "phone"
import { FormEvent, useCallback, useState } from "react"
import { renderToStaticMarkup } from "react-dom/server"
import { useEffectOnce } from "react-use"
import RestrictedInput from "restricted-input"
import { classes, cssRaw, cssRule } from "typestyle"

import { Channel, Lang, Newsletter } from "components/admin/shared"
import newletter_icon from "images/newsletter.png"
import sms_icon from "images/sms_icon.png"
import { classNames } from "./style";

const container: HTMLElement = document.getElementById("root")!
const newsletter: Newsletter = JSON.parse(container.dataset.newsletter || JSON.stringify({}))

normalize()
setupPage("#root")
cssRule("html, body", {
  height: "100%",
  width: "100%",
  padding: 0,
  margin: 0,
})
cssRule("html", {
  background: `${url(newsletter.signup_background_image_url)} no-repeat center center fixed`,
  "-webkit-background-size": "cover",
  MozBackgroundSize: "cover",
  OBackgroundSize: "cover",
  backgroundSize: "cover",
})
cssRaw(`
@import url('https://fonts.googleapis.com/css?family=Roboto|Roboto+Slab&display=swap');
`)

interface GetResponse {
  data: Newsletter
  total: number
}

const { search } = window.location
const params = new URLSearchParams(search)
const newsletter_id = params.get("newsletter_id")
const channel = params.get("channel") ?? Channel.email
const lang = params.get("lang") ?? Lang.en

const link = ({ href, content, className }: { href?: string, content?: string, className?: string}) =>
  renderToStaticMarkup(
    h("a", { href, target: "_blank", className }, [content])
  )

export const App = (_: {}) => {

  const {
    logo_url,
    sender_name,
    theme_foreground_color,
    name,
  } = newsletter

  const isEmail = channel === Channel.email
  const isEn = lang === Lang.en

  const altChannel = isEmail ? Channel.sms : Channel.email
  const altChannelVerbose = isEmail ? "text message" : "email"
  const altChannelEmoji = isEmail ? "📲" : "📰"
  const altLang = isEn ? Lang.es : Lang.en
  const altLangVerbose = isEn ?  "Spanish" : "English"
  const langVerbose = isEn ? "English" : "Spanish"
  const e164: string = newsletter.e164
  const phoneNumber = `${e164.slice(2, 5)}-${e164.slice(5, 8)}-${e164.slice(8, 12)}`

  const placeholder = isEmail
    ? "Enter your email"
    : "Enter your phone number"
  const type = isEmail ? "email" : "tel"
  const inputId = "input"
  const [value, setValue] = useState("")
  const [valid, setValid] = useState(false)
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const onChange: React.ChangeEventHandler<HTMLInputElement> = (event) => {
    const { value: currentValue } = event.currentTarget
    if (channel === Channel.sms) {
      const { isValid, phoneNumber } = validatePhone(currentValue, {
        country: "USA",
        strictDetection: true,
      })
      setValid(isValid)
      if (isValid && !!phoneNumber) {
        setValue(phoneNumber)
      }
    } else { // email
      setValue(currentValue)
      const emailFormat = /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i
      setValid(emailFormat.test(currentValue))
    }
  }

  const onSubmit = useCallback(
    (event: FormEvent) => {
      event.preventDefault()
      setError(null)
      setLoading(true)
      const sharedData = { newsletter_id, channel, lang }
      const data = isEmail
        ? { email: value, ...sharedData }
        : { phone: value, ...sharedData }

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
            setSuccess(true)
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
    [value]
  )

  useEffectOnce(() => {
    // eslint-disable-next-line
    const element = document.querySelector(`${inputId}`)!
    // if phone, constrain/format entry
    if (channel === Channel.sms) {
      // eslint-disable-next-line
      const input = new RestrictedInput({
        // @ts-ignore
        element,
        pattern: "({{999}}) {{999}}-{{9999}}",
      })
    }
    // @ts-ignore
    element.addEventListener("input", onChange, false)
  })

  const disabled = !valid || loading
  return div({ className: classNames.background }, [
    div({ className: classNames.spacer }),
    div({ className: classNames.main }, [
      logo_url && img({
        src: logo_url,
        alt: sender_name,
        className: classNames.logo,
      }),
      !logo_url && div({
        className: classNames.name,
        style: { color: theme_foreground_color }
      }, sender_name),
      div(
        { className: classNames.pitch },
        channel === Channel.email
        ? `Sign up for this free weekly email newsletter and get local news and information about ${name} straight to your inbox.`
        : `Sign up for this weekly texting service and get local news and information in ${langVerbose} about ${name} straight to your phone.`
      ),
      div(
        { className: classNames.description },
        channel === Channel.email
       ? `This newsletter will give you a rundown of local news, events, community meetings and more happening in your neighborhood!`
       : `This free text will highlight local news articles, events, community meeting reminders and more!`
      ),

      form({
        id: "signup-form",
        className: classNames.form,
        onSubmit }, [
        success &&
          div({
            className: classNames.success,
            style: { color: theme_foreground_color }
          }, "Thanks!"),
        !success &&
          div({ className: classNames.ready }, [
            input({
              placeholder,
              className: classes(classNames.inputMobile, classNames.input),
              style: { border: `1.5px solid ${theme_foreground_color}` },
              id: inputId,
              autoFocus: true,
              type,
            }),
            button(
              {
                className: classes(classNames.submit, classNames.submitMobile),
                disabled,
                style: { backgroundColor: theme_foreground_color }
              },
              "Sign up"
            ),
          ]),
        error && div({ className: classNames.error }, error),
      ]),

      channel === Channel.sms &&
        div({ className: classNames.viaSMS }, [
          `📲 Or text "NOTICIA" to ${phoneNumber}`
        ])
    ]),

    newsletter.id === 2 ?
    div({ className: classNames.footer }, [
      div({ className: classNames.footerRow }, [
        span({
          dangerouslySetInnerHTML: {
            __html: `
            ${altChannelEmoji} We’re also sending this information via ${altChannelVerbose} in ${altLangVerbose}. Sign up here.
            `.replace(
              "here", link({
                href: `/signup?newsletter_id=${newsletter.id}&lang=${altLang}&channel=${altChannel}`,
                content: "here",
                className: classNames.footerLink
                })
              )
            }
        })
      ]),
      div({ className: classNames.footerRow }, [
        span({
          dangerouslySetInnerHTML: {
            __html: `
        This project is from the Lenfest Local Lab
        @ The Inquirer and in collaboration with Impacto and Esperanza,
        Taller Puertorriqueño, and the Kensington Voice.
        `.replace(
          "Lenfest Local Lab", link({
            href: "https://www.lenfestinstitute.org/lenfest-local-lab/",
            content: "Lenfest Local Lab",
            className: classNames.footerLink
            })
          ).replace(
          "The Inquirer", link({
            href: "https://www.inquirer.com/",
            content: "The Inquirer",
            className: classNames.footerLink
            })
          ).replace(
            "Impacto", link({
              href: "https://www.impactomedia.com/",
              content: "Impacto",
              className: classNames.footerLink
              })
          ).replace(
            "Esperanza", link({
              href: "https://www.esperanzaartscenter.us/",
              content: "Esperanza",
              className: classNames.footerLink
              })
          ).replace(
            "Taller Puertorriqueño", link({
              href: "https://tallerpr.org/",
              content: "Taller Puertorriqueño",
              className: classNames.footerLink
              })
          ).replace(
            "Kensington Voice", link({
              href: "https://kensingtonvoice.com",
              content: "Kensington Voice",
              className: classNames.footerLink
              })
          )
        },
        })
      ]),
      div({ className: classNames.backgroundImageAttribution },
        `Curing Community by Cesar Viveros. Photo by Steve Weinik.`)
    ]) : div({className: classNames.spacer })
  ])
}
