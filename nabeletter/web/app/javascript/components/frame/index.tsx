// https://stackoverflow.com/a/34744946
import React, { Component } from "react"
import { createPortal } from "react-dom"

interface Props {
  id?: string
  height?: string | number
  width?: string | number
  style: object
}
interface State {}
export class Frame extends Component<Props, State> {
  setContentRef: (node: HTMLIFrameElement) => void
  contentRef: HTMLElement | undefined = undefined
  constructor(props: Props) {
    super(props)
    this.setContentRef = (node: HTMLIFrameElement | null) =>
      (this.contentRef = node?.contentWindow?.document.body)
  }

  render() {
    const { children, ...props } = this.props // eslint-disable-line
    return (
      <iframe {...props} ref={this.setContentRef}>
        {this.contentRef &&
          createPortal(React.Children.only(children), this.contentRef)}
      </iframe>
    )
  }
}
