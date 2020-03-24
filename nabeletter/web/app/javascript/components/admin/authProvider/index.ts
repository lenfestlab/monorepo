import { AuthProvider } from "ra-core"

const tokenKey: string = "token"

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
      .then(response => {
        if (response.status < 200 || response.status >= 300) {
          throw new Error(response.statusText)
        }
        const headers = response.headers
        const authorization: string = headers.get("Authorization")
        const [kind, token] = authorization.split(" ")
        return token
      })
      .then(token => {
        localStorage.setItem(tokenKey, token)
      })
  },
  logout: () => {
    localStorage.clear()
    return Promise.resolve()
  },
  checkError: () => Promise.resolve(),
  checkAuth: () =>
    localStorage.getItem(tokenKey) ? Promise.resolve() : Promise.reject(),
  getPermissions: () => Promise.reject("Unknown method"),
}
