import { h } from "@cycle/react"
import {
  DateField,
  Edit,
  ReferenceField,
  SimpleForm,
  TextInput,
  UrlField,
} from "react-admin"

export const LinkEdit = (props: {}) =>
  h(Edit, { ...props }, [
    h(SimpleForm, { redirect: false, submitOnEnter: true }, [
      h(
        ReferenceField,
        {
          label: "Edition",
          source: "edition.id",
          reference: "editions",
          link: "show",
        },
        [h(DateField, { source: "publish_at", label: "Published" }, [])]
      ),
      h(UrlField, { source: "redirect", target: "_blank" }, []),
      h(TextInput, {
        source: "topic",
        fullWidth: true,
      }),
      h(TextInput, {
        source: "subtopic",
        fullWidth: true,
      }),
    ]),
  ])
