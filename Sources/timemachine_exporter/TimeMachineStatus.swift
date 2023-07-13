import Foundation

struct TimeMachineStatus {
    public func currentDestination() -> TMDestination? {
        let defaults = UserDefaults(suiteName: "com.apple.TimeMachine");

        if let lastDestinationID = defaults?.string(forKey: "LastDestinationID"),
           let destinations = defaults?.array(forKey: "Destinations") as? [[String: Any]] {
            if let currentDestination = destinations.first(where: { destination in
                return destination["DestinationID"] as? String == lastDestinationID
            }) {
                return ConfiguredDestination(withDictionaryRepresentation: currentDestination)
            }
        }
        return nil
    }
}
