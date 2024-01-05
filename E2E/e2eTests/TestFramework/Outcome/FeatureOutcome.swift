import Foundation

class FeatureOutcome {
    let feature: Feature
    var scenarios: [ScenarioOutcome] = []
    var pass = true
    
    init(_ feature: Feature) {
        self.feature = feature
    }
}
