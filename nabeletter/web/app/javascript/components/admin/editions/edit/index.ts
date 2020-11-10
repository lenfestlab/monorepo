import { h } from "@cycle/react"
import { div } from "@cycle/react-dom"
import { makeStyles } from "@material-ui/core/styles"
import { formatISO, parseISO } from "date-fns"
import { ChangeEvent, useEffect, useState } from "react"
import { Edit, SimpleForm } from "react-admin"
import { from, Observable, Subject, Subscription } from "rxjs"
import { tag } from "rxjs-spy/operators"
import { catchError, debounceTime, share, switchMap, tap } from "rxjs/operators"

import {
  EditionBodyInput,
  EditionKindInput,
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
        debounceTime(1000),
        switchMap((data: any) => {
          const request: Promise<any> = dataProvider("UPDATE", "editions", {
            id,
            data,
          })
          return from(
            request.then((value: any) => {
              if (data.publish_at) window.location.reload()
            })
          )
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
    kind: {
      display: "flex-inline",
      marginLeft: theme.spacing(2),
      marginTop: theme.spacing(-4.5),
    },
    publish: {
      display: "flex-inline",
      minWidth: px(250),
      marginLeft: theme.spacing(2),
    },
    subject: {
      display: "flex-inline",
      marginLeft: theme.spacing(2),
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

  const onChangeKind = (value: string) => {
    data$.next({ kind: value })
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
        div({ className: classes.topInputs, id: `top-inputs` }, [
          h(EditionKindInput, {
            id: "edition-kind",
            className: classes.kind,
            onChange: onChangeKind,
          }),
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
        h(EditionBodyInput),
      ]),
    ]
  )
}
