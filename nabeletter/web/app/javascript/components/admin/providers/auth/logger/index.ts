// NOTE: stops React from logging `validateDOMNesting` errors to console
function filterConsoleErrors() {
  // tslint:disable
  const _error = console.error
  const _warn = console.warn
  console.error = (args: any) => {
    const argsString = `${args}`
    if (args && argsString.includes("Warning")) {
      _warn.call(console, ...args)
    } else {
      _error.call(console, ...args)
    }
  }
}
// filterConsoleErrors()
