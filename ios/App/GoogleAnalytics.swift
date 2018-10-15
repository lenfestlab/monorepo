import Foundation
import GoogleReporter

struct GoogleAnalytics {

  private var env: Env
  private var ga: GoogleReporter

  init(_ env: Env) {
    self.env = env
    self.ga = GoogleReporter.shared

    let tid = env.get(.googleAnalyticsTrackingId)
    ga.configure(withTrackerId: tid)
    ga.anonymizeIP = false // https://git.io/fxuUt
    ga.quietMode = ["prod", "stag"].contains(env.get(.name))
    ga.customDimensionArguments = [
      "Installation ID": env.installlationId
    ]
  }

}
