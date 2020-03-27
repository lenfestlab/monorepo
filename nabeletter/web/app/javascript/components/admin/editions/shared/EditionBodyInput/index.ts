import { h } from "@cycle/react"
import { dataProvider } from "components/admin/providers"
import React, { createRef, Fragment, RefObject } from "react"
import { BehaviorSubject, from, Subscription } from "rxjs"
import { debounceTime, share, skip, switchMap } from "rxjs/operators"

import { Record } from "components/admin/shared"
import { get, isEmpty } from "fp"
import { tag } from "rxjs-spy/operators"
import {
  Field as SummaryField,
  Input as SummaryInput,
} from "./sections/summary"

type Kind = "summary"
function getSectionComponents(kind: Kind) {
  switch (kind) {
    case "summary":
      return { field: SummaryField, input: SummaryInput }
  }
}

type Config = object
type SetConfig = (config: Config) => void

interface SectionConfig {
  kind: Kind
  config: Config
}
interface BodyConfig {
  sections: SectionConfig[]
}

type SectionInput = React.ReactElement
type SectionField = any

type PreviewRef = RefObject<HTMLDivElement>

interface Props {
  record?: Record
}
interface State {
  sections: SectionConfig[]
}
export class EditionBodyInput extends React.Component<Props, State> {
  subscription: Subscription | null = null
  configs$ = new BehaviorSubject<SectionConfig[]>([])
  previewRef: PreviewRef = createRef<HTMLDivElement>()
  constructor(props: Props) {
    super(props)
    this.state = { sections: [] }
  }
  componentDidMount() {
    // set record loaded from server
    const { record } = this.props
    let bodyConfig: BodyConfig = get(record, "body_data")
    if (isEmpty(bodyConfig)) {
      bodyConfig = {
        sections: [{ kind: "summary", config: { markdown: "" } }],
      }
    }
    const sections: SectionConfig[] = get(bodyConfig, "sections", [])
    this.setState({
      sections,
    })
    // sync all changes back to server
    this.subscription = this.configs$
      .pipe(
        skip(1),
        debounceTime(1000),
        tag("configs$"),
        switchMap((sections) => {
          const node = this.previewRef.current
          const body_html = node?.innerHTML
          const body_data = { sections }
          const id = this.props.record?.id
          const data = { body_data, body_html }
          const request = dataProvider("UPDATE", "editions", { id, data })
          return from(request)
        }),
        share()
      )
      .subscribe()
  }
  componentWillUnmount() {
    this.subscription?.unsubscribe()
  }
  shouldComponentUpdate() {
    return true
  }
  render() {
    const inputs: SectionInput[] = []
    const fields: SectionField[] = []
    const { sections } = this.state
    sections.forEach((sectionConfig: SectionConfig, idx: number) => {
      const kind = get(sectionConfig, "kind")
      const config: any = get(sectionConfig, "config")
      // section input
      const setConfig: SetConfig = (config) => {
        const sections = this.state.sections
        sections[idx] = { kind, config }
        this.configs$.next(sections)
        this.setState({
          sections,
        })
      }
      const { input, field } = getSectionComponents(kind)
      inputs.push(h(input, { config, setConfig }))
      fields.push(h(field, { config }))
    })
    const previewRef = this.previewRef
    return h(Editor, { inputs, fields, previewRef })
  }
}

import { div } from "@cycle/react-dom"
import Grid from "@material-ui/core/Grid"
import Paper from "@material-ui/core/Paper"
import { makeStyles } from "@material-ui/core/styles"

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
  paper: {
    padding: theme.spacing(2),
    color: theme.palette.text.secondary,
  },
}))

interface EditorProps {
  previewRef: PreviewRef
  inputs: SectionInput[]
  fields: SectionField[]
}
function Editor(props: EditorProps) {
  const classes = useStyles()
  const { inputs, fields, previewRef } = props
  return div({ className: classes.root }, [
    h(Grid, { container: true, spacing: 3 }, [
      h(Grid, { item: true, xs: 6 }, [
        h(Paper, { className: classes.paper, elevation: 0 }, inputs),
      ]),
      h(Grid, { item: true, xs: 6 }, [
        h(Paper, { className: classes.paper }, [
          div({ ref: previewRef }, fields),
        ]),
      ]),
    ]),
  ])
}
