import { h } from "@cycle/react"
import { SaveButton, Toolbar as _Toolbar } from "react-admin"

import { EditionTestDeliveryButton } from "../shared"

// NOTE: omit react-admin's default Delete button
export const Toolbar = (props: object) =>
  h(_Toolbar, { ...props }, [h(SaveButton), h(EditionTestDeliveryButton)])
