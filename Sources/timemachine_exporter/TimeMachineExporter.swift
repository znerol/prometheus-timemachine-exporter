import ArgumentParser
import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import Metrics
import NIOCore
import Prometheus
import WebURL

@main
struct TimeMachineExporter: ParsableCommand {
    @Option(name: .long, help: "Addresses on which to expose metrics and web interface. Repeatable for multiple addresses.")
    var webListenAddress: [String] = [":9976"]

    @Option(name: .long, help: "Only log messages with the given severity or above. One of: [debug, verbose, info, warning, error]")
    var logLevel: String = "info"
}

extension TimeMachineExporter {
    mutating public func run() throws {
        let logLevel: LoggerMessageType
        switch self.logLevel {
        case "debug":
            logLevel = .debug
        case "verbose":
            logLevel = .verbose
        case "info":
            logLevel = .info
        case "warning":
            logLevel = .warning
        default:
            logLevel = .error
        }
        HeliumLogger.use(logLevel)

        let prom = PrometheusClient()
        MetricsSystem.bootstrap(PrometheusMetricsFactory(client: prom))

        let destinationInfo = prom.createGauge(
            forType: UInt.self,
            named: "timemachine_destination_info",
            helpText: "Apple Time Machine Backup current destination info"
        )
        let latestBackupAge = prom.createGauge(
            forType: Double.self,
            named: "timemachine_destination_latest_age_seconds",
            helpText: "Seconds since the last successful Apple Time Machine Backup to current destination"
        )
        let earliestBackupAge = prom.createGauge(
            forType: Double.self,
            named: "timemachine_destination_earliest_age_seconds",
            helpText: "Seconds since the earliest successful Apple Time Machine Backup to current destination"
        )
        let totalCapacity = prom.createGauge(
            forType: UInt64.self,
            named: "timemachine_destination_size_bytes",
            helpText: "Filesystem space available to Apple Time Machine Backups in bytes on current destination"
        )
        let availableCapacity = prom.createGauge(
            forType: UInt64.self,
            named: "timemachine_destination_avail_bytes",
            helpText: "Filesystem size in bytes on current destination"
        )

        let status = TimeMachineStatus()

        let router = Router()
        router.get("/") { request, response, next in
            response.send("""
                          <html>
                          <head><title>Apple Time Machine Exporter</title></head>
                          <body>
                          <h1>Apple Time Machine Exporter</h1>
                          <p><a href="metrics">Return metrics for Apple Time Machine backup</a></p>
                          </body>
                          </html>
                          """)
            next()
        }

        router.get("/metrics") { request, response, next in
            let dest = status.currentDestination()
            if (dest != nil) {
                destinationInfo.set(1, DimensionLabels([
                    ("volume", dest!.aliasVolumeName()),
                    ("id", dest!.destinationID()),
                    ("network", String(dest!.isNetworkDestination())),
                ]))

                let now = Date()
                let latestAge = now.timeIntervalSince(dest!.latestSnapshotDate())
                latestBackupAge.set(latestAge.doubleValue)
                let earliestAge = now.timeIntervalSince(dest!.earliestSnapshotDate())
                earliestBackupAge.set(earliestAge.doubleValue)

                totalCapacity.set(dest!.totalCapacity())
                availableCapacity.set(dest!.availableCapacity())
            }
            prom.collect { result in
                response.send(result)
                next()
            }
        }

        for hostAndPort in webListenAddress {
            let (address, port) = parseHostAndPort(hostAndPort)
            Log.info("Listening on \(address ?? "*"):\(port)")
            Kitura.addHTTPServer(onPort: port, onAddress: address, with: router)
        }

        Kitura.run()
    }

    private func parseHostAndPort(_ hostAndPort: String) -> (String?, Int){
        var address: String? = "::"
        var port: Int = 9976

        if ((try? SocketAddress(ipAddress: hostAndPort, port: port)) != nil) {
            address = hostAndPort
        }
        else if let url = WebURL("http://" + hostAndPort) {
            address = url.hostname
            if url.port != nil {
                port = url.port!
            }
        }
        else if let url = WebURL("http://[::]" + hostAndPort) {
            if url.port != nil {
                port = url.port!
            }
        }

        return (address, port)
    }
}
