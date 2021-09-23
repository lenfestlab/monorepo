import { h } from "@cycle/react"
import { span } from "@cycle/react-dom"
import Autolinker from "autolinker"
import { Frame } from "components/frame"
import { queries } from "styles"

const autolinker = new Autolinker({
  stripPrefix: false,
})

interface Props {
  text: string
}

export const Preview = ({ text }: Props) => {
  console.debug("Preview")
  const newLinedText = text.replace(/\n/g, "<br/>")
  const linkedText = autolinker.link(newLinedText)
  const __html = messageMarkup(linkedText)
  return h(
    Frame,
    {
      id: "preview-frame",
      width: queries.mobile.maxWidth,
      height: "100%",
      style: { border: "0" },
    },
    [
      span({
        id: "sms-simulated-style-text",
        style: { height: "100%" },
        dangerouslySetInnerHTML: { __html },
      }),
    ]
  )
}

function messageMarkup(message: string) {
  // css source: https://stackoverflow.com/a/45944762
  const css = `
  body {
    font-family: helvetica;
    display: flex ;
    flex-direction: column;
    align-items: center;
  }

  .chat {
    height: 100%;
    width: 300px;
    border: solid 1px #EEE;
    display: flex;
    flex-direction: column;
    padding: 10px;
  }

  .messages {
    margin-top: 30px;
    display: flex;
    flex-direction: column;
  }

  .message {
    border-radius: 20px;
    padding: 8px 15px;
    margin-top: 5px;
    margin-bottom: 5px;
    display: inline-block;
  }

  .yours {
    align-items: flex-start;
  }

  .yours .message {
    margin-right: 25%;
    background-color: #EEE;
    position: relative;
  }

  .yours .message.last:before {
    content: "";
    position: absolute;
    z-index: 0;
    bottom: 0;
    left: -7px;
    height: 20px;
    width: 20px;
    background: #EEE;
    border-bottom-right-radius: 15px;
  }
  .yours .message.last:after {
    content: "";
    position: absolute;
    z-index: 1;
    bottom: 0;
    left: -10px;
    width: 10px;
    height: 20px;
    background: white;
    border-bottom-right-radius: 10px;
  }

  .mine {
    align-items: flex-end;
  }

  .mine .message {
    color: white;
    margin-left: 25%;
    background: rgb(0, 120, 254);
    position: relative;
  }

  .mine .message.last:before {
    content: "";
    position: absolute;
    z-index: 0;
    bottom: 0;
    right: -8px;
    height: 20px;
    width: 20px;
    background: rgb(0, 120, 254);
    border-bottom-left-radius: 15px;
  }

  .mine .message.last:after {
    content: "";
    position: absolute;
    z-index: 1;
    bottom: 0;
    right: -10px;
    width: 10px;
    height: 20px;
    background: white;
    border-bottom-left-radius: 10px;
  }
  `

  return `
  <html>
  <head>
  <style type="text/css">
    ${css}
  </style>
  </head>
  <body>
    <div class="chat">
      <div class="yours messages">
        <div class="message last">
          ${message}
        </div>
      </div>
    </div>
  </body>
  </html>
  `
}
