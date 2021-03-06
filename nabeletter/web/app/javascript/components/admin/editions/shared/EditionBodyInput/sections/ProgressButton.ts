import { h } from "@cycle/react"
import { Box, Button, CircularProgress } from "@material-ui/core"
import { px } from "csx"
import { FunctionComponent, ReactNode, RefObject } from "react"
import { stylesheet } from "typestyle"

type Ref = RefObject<HTMLButtonElement>

interface Props {
  disabled: boolean
  pending: boolean
  children?: ReactNode
  forwardRef?: Ref
  onClick?: (event: React.MouseEvent) => void
}

export const ProgressButton: FunctionComponent<Props> = (props) => {
  const { children, disabled, pending, forwardRef: ref, onClick } = props

  const classNames = stylesheet({
    root: {
      position: "relative",
    },
    progress: {
      position: "absolute",
      left: px(20),
      zIndex: 2,
    },
  })

  return h(
    Box,
    {
      display: "flex",
      flexDirection: "row",
      flexWrap: "nowrap",
      alignItems: "center",
      className: classNames.root,
    },
    [
      h(
        Button,
        {
          color: "primary",
          disabled,
          ref,
          onClick,
          variant: "contained",
        },
        [children]
      ),
      pending &&
        h(CircularProgress, { size: 24, className: classNames.progress }),
    ]
  )
}
