import { horizontal, normalize, setupPage } from "csstips"
import { content, fillParent, vertical } from "csstips"
import { percent, px, rgba, url } from "csx"
import { font } from "mjml-json"
import { colors, fonts, queries } from "styles"
import { classes, cssRaw, cssRule, media, stylesheet } from "typestyle"

const pad = 24
const textStyle = {
  fontFamily: fonts.roboto,
  fontSize: px(18),
}

export const classNames = stylesheet({

  background: {
    ...vertical,
    ...fillParent,
    alignItems: "center",
    justifyContent: "space-between",
  },

  spacer: { /* no-op, used for layout only */ } ,

  footer: {
    alignSelf: "center",
    ...vertical,
    ...content,
    alignItems: "center",
    width: percent(100),
    backgroundColor: colors.black,
    color: colors.white,
    opacity: percent(80),
    paddingTop: px(pad),
    paddingBottom: px(pad),
    paddingLeft: px(12),
    paddingRight: px(12),
    fontSize: px(18),
    ...media(queries.desktop, {
      fontSize: px(12),
    }),
  },
  footerRow: {
    ...horizontal,
    alignItems: "center",
    textAlign: "center",
    paddingBottom: px(pad),
    maxWidth: px(900)
  },
  footerLink: {
    color: colors.white,
    textDecoration: "underline"
  },
  backgroundImageAttribution: {
    alignSelf: "self-end",
    fontFamily: fonts.roboto,
    fontSize: px(11)
  },

  main: {
    ...content,
    ...vertical,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: rgba(255, 255, 255, 0.95).toString(),
    width: px(825),
    ...media(queries.desktop, {
      width: px(328),
    }),
    padding: px(pad),
    paddingTop: px(pad * 2),
    paddingBottom: px(pad * 2),
    textAlign: "center"
  },

  logo: {
    width: px(166),
    alignSelf: "center",
    paddingBottom: px(pad),
  },

  name: {
    fontFamily: fonts.roboto,
    fontWeight: 700,
    fontSize: px(38),
    ...media(queries.desktop, {
      fontSize: px(22),
    }),
    textAlign: "center",
    paddingBottom: px(pad)
  },

  pitch: {
    fontFamily: fonts.roboto,
    fontSize: px(18),
    ...media(queries.desktop, {
      fontSize: px(13),
    }),
    fontWeight: 500,
    paddingBottom: px(pad),
  },

  description: {
    ...textStyle,
    fontWeight: 400,
    fontSize: px(15),
    ...media(queries.desktop, {
      fontSize: px(12),
    }),
    lineHeight: px(17),
    paddingBottom: px(pad),
  },

  viaSMS: {
    ...horizontal,
    alignItems: "center",
    paddingTop: px(pad),
    ...media(queries.desktop, {
      fontSize: px(12)
    }),
  },

  form: {
    ...vertical,
    justifyContent: "center",
  },

  ready: {
    ...content,
    ...horizontal,
    alignItems: "center",
    ...media(queries.desktop, {
      ...vertical,
    }),
  },

  input: {
    ...content,
    minHeight: px(54),
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
        fontSize: px(20),
      },
      "&:focus": {
        outline: "none",
      },
    },
  },

  inputMobile: {
    ...media(queries.desktop, {
      marginRight: px(0),
      width: percent(100),
      minHeight: px(38),
      $nest: {
        "&::placeholder": {
          fontSize: px(12),
        }
      }
    })
  },

  submit: {
    ...content,
    color: colors.white,
    fontSize: px(20),
    minHeight: px(54),
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
      minHeight: px(38),
      width: percent(100),
      fontSize: px(12),
    }),
  },

  success: {
    ...content,
    ...textStyle,
    textAlign: "center",
    alignSelf: "center",
    color: colors.darkBlue,
  },
  error: {
    ...content,
    color: "red",
    height: px(40),
    paddingTop: px(10),
    paddingLeft: px(10),
  },
})
