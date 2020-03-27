import { Timber } from "@timberio/browser"
import { ITimberLog } from "@timberio/types"

const key = process.env.TIMBER_API_KEY as string
const source = process.env.TIMBER_SOURCE_ID as string
const timber = new Timber(key, source)

async function _addUserContext(log: ITimberLog): Promise<ITimberLog> {
  const id = localStorage.getItem("user_id") as string
  const email = localStorage.getItem("user_email") as string
  const context = { user: { id, email } }
  return {
    ...log,
    context,
  }
}
export const addUserContext = () => timber.use(_addUserContext)
export const removeUserContext = () => timber.remove(_addUserContext)

export const info = (message: string): Promise<string | void> => {
  console.info(message) // tslint:disable-line
  return timber.info(message).then((log) => log.message)
}
