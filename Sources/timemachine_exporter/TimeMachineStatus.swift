import Foundation

@objc protocol TMDestination {
    func latestSnapshotDate() -> Date
    func earliestSnapshotDate() -> Date
    func totalCapacity() -> UInt64
    func availableCapacity() -> UInt64

    func aliasVolumeName() -> String
    func destinationID() -> String
    func isNetworkDestination() -> Bool
}

@objc protocol AppleTMSettings {
    static func sharedSettings() -> AppleTMSettings
    func readDestinations()
    func currentDestination() -> TMDestination?
}


struct TimeMachineStatus {
    private let tmMenu: Bundle
    private let tmSettings: AppleTMSettings

    init() {
        tmMenu = Bundle(path: "/System/Library/CoreServices/Menu Extras/TimeMachine.menu")!
        tmMenu.load()
        let tmSettingsClass: AnyClass = tmMenu.classNamed("AppleTMSettings")!
        tmSettings = tmSettingsClass.sharedSettings()
    }

    public func currentDestination() -> TMDestination? {
        tmSettings.readDestinations()
        return tmSettings.currentDestination()
    }
}
