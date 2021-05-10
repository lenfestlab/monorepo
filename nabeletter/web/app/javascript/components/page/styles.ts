import {
  horizontal,
  horizontallyCenterChildren,
  normalize,
  setupPage,
} from "csstips"
import { content, fillParent, vertical } from "csstips"
import { important, percent, px, rgba } from "csx"
import { colors, fonts, queries } from "styles"
import { cssRaw, cssRule, media, stylesheet } from "typestyle"

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

const headerStyle = {
  fontFamily: fonts.robotoSlab,
}

export const classNames = stylesheet({
  background: {
    ...vertical,
    ...fillParent,
    alignItems: "center",
    justifyContent: "left",
  },

  container: {
    ...content,
    ...vertical,
    width: percent(100),
    maxWidth: px(1024),
    ...media(queries.desktop, {
      maxWidth: px(328),
    }),
    // text styles
    fontFamily: fonts.roboto,
    fontSize: px(18),
    $nest: {
      "& h1": {
        fontSize: px(60),
        ...headerStyle,
      },
      "& h2": {
        fontSize: px(48),
        ...headerStyle,
      },
      "& h3": {
        fontSize: px(20),
        ...headerStyle,
      },
      "& h4": {
        fontSize: px(18),
        ...headerStyle,
      },
      "& h5": {
        fontSize: px(16),
        ...headerStyle,
      },
      "& h6": {
        fontSize: px(14),
        ...headerStyle,
      },
    },
    "& a": {
      color: important(colors.darkBlue),
    },
    "& iframe": {
      width: important("100%"),
    },
  },

  header: {
    ...horizontal,
    minHeight: px(100),
    backgroundColor: colors.lightBlue,
    padding: "21px 38px 21px 44px",
  },
  headerBottomAligmentWrapper: {
    ...fillParent,
    ...horizontal,
    justifyContent: "space-between",
    flexWrap: "wrap",
  },
  logo: {
    width: px(146),
    height: px(50),
  },
  updated: {
    alignSelf: "flex-end",
    fontSize: px(14),
    fontStyle: "italic",
    paddingTop: px(10),
  },

  headerImage: {
    width: percent(100),
  },

  content: {
    ...fillParent,
    ...vertical,
    padding: "20px 112px 0px 112px",
    ...media(queries.desktop, {
      padding: "0px 12px 0px 12px",
    }),
  },

  tableOfContents: {
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
    borderRadius: px(3),
    boxShadow: "0 2px 4px 0 rgba(0, 0, 0, 0.5)",
    fontSize: px(16),
    fontWeight: 300,
    lineHeight: 1.5,
  },
  cardHeader: {
    fontFamily: fonts.robotoSlab,
    textTransform: "uppercase",
  },

  footer: {
    ...vertical,
    marginTop: px(60),
    alignItems: "center",
    textAlign: "center",
    backgroundColor: colors.darkBlue,
    color: colors.white,
    fontSize: px(18),
    padding: px(pad),
  },
  footerAttribution: {
    paddingBottom: px(12),
  },
  footerSocialPitch: {
    paddingBottom: px(10),
  },
})
