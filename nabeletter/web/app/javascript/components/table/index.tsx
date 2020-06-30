import { percent } from "csx"
import React, { Fragment, FunctionComponent } from "react"
const HTMLComment = require("react-html-comment")

interface TableProps {
  border?: number
  cellPadding?: number
  cellSpacing?: number
  className?: string
  style?: object
  maxWidth?: number
}

export const LayoutTable: FunctionComponent<TableProps> = ({
  maxWidth,
  children,
  ...props
}) => {
  const style = {
    ...props.style,
    maxWidth,
  }
  const tableProps = {
    align: "center",
    border: 0,
    cellPadding: 0,
    cellSpacing: 0,
    width: percent(100),
    ...props,
    style,
  }
  const preText = `
    [if (gte mso 9)|(IE)]>
    <table align="center" border="0" cellspacing="0" cellpadding="0" width="${maxWidth}">
    <tr>
    <td align="center" valign="top" width="${maxWidth}">
    <![endif]
  `
  const postText = `
    [if (gte mso 9)|(IE)]>
    </td>
    </tr>
    </table>
    <![endif]
  `
  return (
    <Fragment>
      {maxWidth && <HTMLComment text={preText} />}
      <table {...tableProps}>{children}</table>
      {maxWidth && <HTMLComment text={postText} />}
    </Fragment>
  )
}
