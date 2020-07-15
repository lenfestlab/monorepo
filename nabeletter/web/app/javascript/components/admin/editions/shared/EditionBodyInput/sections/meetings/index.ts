// TODO: restore once FNA ical resumes; in meantime, use Event module
export { Config, Event, SetConfig } from "../events/index"
export { Input } from "./Input"
export { Field } from "./Field"
export { node } from "./node"

/*
// "id": "2ukv1ql9r72hnvhr70kvdu7b5s",
// "title": "Community Mtg - 1217 E Columbia Ave",
// "description": "PROPOSAL FOR THE PARTIAL DEMOLITION OF AN EXISTING STRUCTURE (2ND STORY) AND ERECTION OF ADDITION ABOVE REMAINING 1 STORY ATTACHED STRUCTURE FOR USE AS MULTI FAMILY HOUSEHOLD LIVING (six (6) dwelling units) WITH SIX INTERIOR ACCESSORY OFF STREET PARKING SPACES .&nbsp;<br><br><a href=\"https://drive.google.com/file/d/0B6EuVE_SZ8FsRlg3UFRGVjIzNUM1N2NxdDJPeWJPZXp5Tl9R/view?usp=sharing\" id=\"ow1566\" __is_owner=\"true\">Refusal&nbsp;</a><br><a href=\"https://drive.google.com/file/d/1Zmc0icYE_qSC41iL6uqKan-0WPcbBWLX/view?usp=sharing\" id=\"ow1576\" __is_owner=\"true\">Address List</a><br><br><a href=\"https://drive.google.com/file/d/1xNBQHCNn3IWEMCvSR8atFqn_TMJwNyYd/view?usp=sharing\" id=\"ow1586\" __is_owner=\"true\">Notification Letter</a>",
// "date": {
//   "name": "Meeting Date",
//   "datetime": "2020-02-11T19:00:00-05:00"
// },
// "location": {
//   "address": "1217 E Columbia Ave, Philadelphia, PA 19125, USA",
//   "lat": 39.9709596,
//   "lng": -75.13064
// },
// "action": {
//   "url": "https://www.google.com/calendar/event?eid=MnVrdjFxbDlyNzJobnZocjcwa3ZkdTdiNXMgZmlzaHRvd24ub3JnX28wbnUwaDlpdHZxYmZjZTdjMjUzOHFpajcwQGc",
//   "name": "Set Reminder"
// },
// "meeting": "Fishtown Rec Center, 1202 E Montgomery Ave",
// "people": [{
//   "name": "Mom Investment Llc",
//   "title": "Owner"

interface Person {
  name: string
  title: string
}

export interface Meeting {
  id: string
  title: string
  description: string
  date: {
    name: string
    datetime: string
  }
  location: {
    address: string
    lat: number
    lng: number
  }
  action: {
    url: string
    name: string
  }
  meeting: string
  people: Person[]
}

import { SectionConfig } from "../section"

export interface Config extends SectionConfig {
  selections: Meeting[]
}
export type SetConfig = (config: Config) => void

export { Input } from "./Input"
export { Field } from "./Field"

*/
