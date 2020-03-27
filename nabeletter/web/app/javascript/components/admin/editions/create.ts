import { h } from "@cycle/react"
import { Create, SimpleForm } from "react-admin"

import { NewsletterReferenceInput } from "components/admin/shared"
import { EditionPublishAtInput, EditionSubjectInput } from "./shared"

interface Props {}

export const EditionCreate = (props: Props) =>
  h(Create, { ...props }, [
    h(SimpleForm, { redirect: "show" }, [
      h(NewsletterReferenceInput),
      h(EditionSubjectInput),
      h(EditionPublishAtInput),
    ]),
  ])
