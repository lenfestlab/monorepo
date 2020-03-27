import { h } from "@cycle/react"
import { Edit, SimpleForm } from "react-admin"

import {
  EditionBodyButton,
  EditionBodyInput,
  EditionPublishAtInput,
  EditionSubjectInput,
} from "components/admin/editions/shared"

import { Identifier, NewsletterReferenceInput } from "components/admin/shared"
import { Title } from "./title"
import { Toolbar } from "./toolbar"

interface Props {
  id: Identifier
  resource: string
}

export const EditionEdit = (props: Props) =>
  h(Edit, { ...props, undoable: false, title: h(Title) }, [
    h(SimpleForm, { redirect: "show", toolbar: h(Toolbar) }, [
      h(NewsletterReferenceInput),
      h(EditionSubjectInput),
      // TODO: restore
      // h(EditionPublishAtInput),
      process.env.FF_INLINE_EDITOR ? h(EditionBodyInput) : h(EditionBodyButton),
    ]),
  ])
