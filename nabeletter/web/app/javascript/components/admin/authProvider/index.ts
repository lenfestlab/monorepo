import { AuthProvider } from "ra-core"
import { addUserContext, removeUserContext, info } from "./logger"

export const authProvider: AuthProvider = {
  login: ({ username, password }) => {
    const user = {
      email: username,
      password,
    }
    const request = new Request("tokens", {
      method: "POST",
      body: JSON.stringify({ user }),
      headers: new Headers({
        Accept: "application/json",
        "Content-Type": "application/json",
      }),
    })
    return fetch(request)
      .then((response) => {
        if (response.status < 200 || response.status >= 300) {
          throw new Error(response.statusText)
        }
        const headers = response.headers
        const authorization: string = headers.get("Authorization")
        const [kind, token] = authorization.split(" ")
        return response.json().then(function mergeToken(data) {
          return { ...data, token }
        })
      })
      .then(({ token, id, email }) => {
        localStorage.setItem("token", token)
        localStorage.setItem("user_id", id)
        localStorage.setItem("user_email", email)
        addUserContext()
        return info("login")
      })
  },
  logout: async () => {
    await info("logout")
    removeUserContext()
    localStorage.clear()
  },
  checkError: () => Promise.resolve(),
  checkAuth: () => {
    addUserContext()
    return localStorage.getItem("token") ? Promise.resolve() : Promise.reject()
  },
  getPermissions: () => Promise.reject("Unknown method"),
}
