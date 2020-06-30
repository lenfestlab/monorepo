import { h } from "@cycle/react"
import { div } from "@cycle/react-dom"
import { makeStyles } from "@material-ui/core/styles"
import { formatISO, parseISO } from "date-fns"
import { ChangeEvent, useEffect } from "react"
import { Edit, SimpleForm } from "react-admin"
import { from, Observable, Subject, Subscription } from "rxjs"
import { tag } from "rxjs-spy/operators"
import {
  catchError,
  debounceTime,
  share,
  skip,
  switchMap,
} from "rxjs/operators"

import {
  EditionBodyButton,
  EditionBodyInput,
  EditionPublishAtInput,
  EditionSubjectInput,
} from "components/admin/editions/shared"
import { dataProvider } from "components/admin/providers"
import { Identifier } from "components/admin/shared"
import { px } from "csx"
import { Actions } from "./actions"
import { Title } from "./title"

const data$ = new Subject<object>()

interface Props {
  id: Identifier
  resource: string
}
export const EditionEdit = (props: Props) => {
  const { id } = props

  useEffect(() => {
    const subscription: Subscription = data$
      .pipe(
        skip(1),
        debounceTime(1000),
        switchMap((data: object) => {
          const request = dataProvider("UPDATE", "editions", { id, data })
          return from(request)
        }),
        catchError((error: Error, caught$: Observable<any>) => {
          alert(JSON.stringify(error))
          return caught$
        }),
        tag("data$"),
        share()
      )
      .subscribe()
    return () => subscription.unsubscribe()
  })

  const useStyles = makeStyles((theme) => ({
    topInputs: {
      display: "flex",
      justifyContent: "flex-start",
      alignItems: "baseline",
      alignContent: "center",
      width: "100%",
    },
    newsletter: {
      display: "flex-inline",
      marginLeft: theme.spacing(2),
    },
    publish: {
      display: "flex-inline",
      minWidth: px(250),
      marginLeft: theme.spacing(2),
    },
    subject: {
      display: "flex-inline",
      marginLeft: theme.spacing(2),
      width: "100%",
    },
  }))
  const classes = useStyles()

  const onChange = (event: ChangeEvent) => {
    const target = event.target as HTMLInputElement
    const name = target.name
    let value = target.value
    // coerce publish_at to iso8601 format for accurate tz rep
    if (name === "publish_at") {
      value = formatISO(parseISO(value))
    }
    data$.next({ [name]: value })
  }

  return h(
    Edit,
    {
      ...props,
      undoable: false,
      title: h(Title),
      actions: h(Actions),
    },
    [
      h(SimpleForm, { submitOnEnter: false, redirect: false, toolbar: null }, [
        div({ className: classes.topInputs, id: "top-inputs" }, [
          h(EditionPublishAtInput, {
            id: "edition-publish",
            className: classes.publish,
            onChange,
          }),
          h(EditionSubjectInput, {
            id: "edition-subject",
            className: classes.subject,
            onChange,
          }),
        ]),
        process.env.FF_INLINE_EDITOR
          ? h(EditionBodyInput)
          : h(EditionBodyButton),
      ]),
    ]
  )
}
