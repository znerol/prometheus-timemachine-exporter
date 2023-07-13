import Foundation

protocol TMDestination {
  func latestSnapshotDate() -> Date
  func earliestSnapshotDate() -> Date
  func totalCapacity() -> UInt64
  func availableCapacity() -> UInt64

  func aliasVolumeName() -> String
  func destinationID() -> String
  func isNetworkDestination() -> Bool
}
