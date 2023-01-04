# Apple Time Machine Exporter for Prometheus

This is a simple server that determines the age of the latest time machine
backup and exports that via HTTP for Prometheus consumption.

## Getting Started

To run it:

```bash
./timemachine_exporter [flags]
```

Help on flags:

```bash
./timemachine_exporter --help
```

For more information check the [source code documentation][gdocs]. All of the
core developers are accessible via the Prometheus Developers [mailinglist][].

[gdocs]: http://godoc.org/github.com/znerol/prometheus-timemachine-exporter

## Usage

### Building

```bash
make all
```

### Exported Metrics

Here's an example of the metrics exported.

```
swift build -c release --arch arm64 --arch x86_64
# HELP timemachine_destination_avail_bytes Filesystem size in bytes on current destination
# TYPE timemachine_destination_avail_bytes gauge
timemachine_destination_avail_bytes 1571991666688
# HELP timemachine_destination_latest_age_seconds Seconds since the last successful Apple Time Machine Backup to current destination
# TYPE timemachine_destination_latest_age_seconds gauge
timemachine_destination_latest_age_seconds 657.5939079523087
# HELP timemachine_destination_info Apple Time Machine Backup current destination info
# TYPE timemachine_destination_info gauge
timemachine_destination_info 0
timemachine_destination_info{volume="TimeMachine", network="true", id="8CC5AF2D-7A6D-4168-A48D-B3D1C28B03D1"} 1
# HELP timemachine_destination_earliest_age_seconds Seconds since the earliest successful Apple Time Machine Backup to current destination
# TYPE timemachine_destination_earliest_age_seconds gauge
timemachine_destination_earliest_age_seconds 42320198.59390795
# HELP timemachine_destination_size_bytes Filesystem space available to Apple Time Machine Backups in bytes on current destination
# TYPE timemachine_destination_size_bytes gauge
timemachine_destination_size_bytes 9500087140352
```

## License

Apache License 2.0, see [LICENSE](https://github.com/znerol/prometheus-timemachine-exporter/blob/develop/LICENSE).

