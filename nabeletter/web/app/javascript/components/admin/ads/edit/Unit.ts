import { h } from "@cycle/react"
import { body as _body, div, head, img, link } from "@cycle/react-dom"
import { percent, px } from "csx"
import { colors, fonts, Style, StyleMap } from "styles"

interface Props {
  title: string
  body: string
  logo_image_url?: string
  main_image_url?: string
}

const copyStyle: Style = {
  width: percent(100),
  fontSize: px(16),
  color: colors.black,
}

const width = 600
const paddingPx = 10
const padding = px(paddingPx)

const styles: StyleMap = {
  ad: {
    width: px(600),
    minHeight: px(300),
    // display: "none",
    opacity: 0.001,
  },
  container: {
    width: "auto",
    backgroundColor: colors.veryLightGray,
    borderRadius: px(8),
    fontFamily: fonts.roboto,
    padding,
  },
  header: {
    display: "flex",
    flexDirection: "row",
    flexWrap: "nowrap",
    alignItems: "flex-start",
    paddingBottom: padding,
  },
  logo: {
    paddingRight: padding,
  },
  copy: {
    display: "flex",
    flexDirection: "column",
    flexWrap: "nowrap",
    alignItems: "flex-start",
    width: "auto",
    paddingTop: padding, // top aligned slightly below logo
  },
  title: {
    ...copyStyle,
    fontWeight: "bolder",
  },
  body: {
    ...copyStyle,
  },
  bottom: {
    display: "flex",
    flexDirection: "column",
    flexWrap: "nowrap",
    alignItems: "flex-end",
  },
  main_image: {
    width: px(width - paddingPx * 2),
  },
  notice: {
    paddingTop: padding,
    fontSize: px(12),
    fontWeight: 500,
    color: colors.darkGray,
  },
}

export const Unit = ({ title, body, logo_image_url, main_image_url }: Props) =>
  div({ id: "ad", style: styles.ad }, [
    head([
      link({
        rel: "stylesheet",
        type: "text/css",
        href:
          "https://fonts.googleapis.com/css?family=Roboto|Roboto+Slab&display=swap",
      }),
    ]),
    div({ id: "container", style: styles.container }, [
      div({ id: "header", style: styles.header }, [
        logo_image_url &&
          img({ id: "logo", style: styles.logo, src: logo_image_url }),
        div({ id: "copy", style: styles.copy }, [
          div({ id: "title", style: styles.title }, title),
          div({ id: "body", style: styles.body }, body),
        ]),
      ]),
      div({ id: "bottom", style: styles.bottom }, [
        main_image_url &&
          img({
            id: "main_image",
            style: styles.main_image,
            src: main_image_url,
          }),
        div({ id: "notice", style: styles.notice }, "Advertisement"),
      ]),
    ]),
  ])
