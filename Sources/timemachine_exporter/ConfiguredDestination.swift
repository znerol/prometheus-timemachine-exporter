import CoreFoundation
import Foundation
import Logging

struct ConfiguredDestination: TMDestination {
  private let values: [String: Any]
  private let logger = Logger(label: "io.prometheus.TimeMachineExporter.ConfiguredDestination")

  public init(withDictionaryRepresentation values: [String: Any]) {
    self.values = values
  }

  func latestSnapshotDate() -> Date {
    if let dates = values["SnapshotDates"] as? [Date],
      let dateValue = dates.last
    {
      return dateValue
    }

    return Date.distantPast
  }

  func earliestSnapshotDate() -> Date {
    if let dates = values["SnapshotDates"] as? [Date],
      let dateValue = dates.first
    {
      return dateValue
    }

    return Date.distantPast
  }

  func totalCapacity() -> UInt64 {
    if let bytesAvailable = values["BytesAvailable"] as? UInt64,
      let bytesUsed = values["BytesUsed"] as? UInt64
    {
      return bytesUsed + bytesAvailable
    }

    return 0
  }

  func availableCapacity() -> UInt64 {
    if let bytesAvailable = values["BytesAvailable"] as? UInt64 {
      return bytesAvailable
    }

    return 0
  }

  func aliasVolumeName() -> String {
    return aliasResourceValues()?.volumeLocalizedName ?? ""
  }

  func destinationID() -> String {
    if let destinationID = values["DestinationID"] as? String {
      return destinationID
    }

    return ""
  }

  func isNetworkDestination() -> Bool {
    return !(aliasResourceValues()?.volumeIsLocal ?? true)
  }

  private func aliasResourceValues() -> URLResourceValues? {
    if let aliasData = values["BackupAlias"] as? Data,
      let bookmarkDataUnmanaged = CFURLCreateBookmarkDataFromAliasRecord(
        kCFAllocatorDefault, aliasData as CFData)
    {
      var isStale = false
      var options: URL.BookmarkResolutionOptions = [
        .withoutUI,
        .withoutMounting,
      ]
      if #available(macOS 11.2, *) {
        options.insert(.withoutImplicitStartAccessing)
      }

      do {
        let url = try URL(
          resolvingBookmarkData: bookmarkDataUnmanaged.takeRetainedValue() as Data,
          options: options, bookmarkDataIsStale: &isStale)
        return try url.resourceValues(forKeys: [.volumeLocalizedNameKey, .volumeIsLocalKey])
      } catch {
        logger.error("Failed to resolve alias: \(error).")
      }
    }

    return nil
  }
}
