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
# HELP timemachine_exporter_build_info A metric with a constant '1' value labeled by version, revision, branch, goversion from which timemachine_exporter was built, and the goos and goarch for the build.
# TYPE timemachine_exporter_build_info gauge
timemachine_exporter_build_info{branch="",goarch="amd64",goos="darwin",goversion="go1.19.3",revision="unknown",version=""} 1
# HELP timemachine_latestbackup_age_seconds Seconds since the last successful Apple Time Machine Backup
# TYPE timemachine_latestbackup_age_seconds gauge
timemachine_latestbackup_age_seconds 298.016831
# HELP timemachine_latestbackup_errors_total Current total errors occured while attempting to determine Apple Time Machine Backup status
# TYPE timemachine_latestbackup_errors_total counter
timemachine_latestbackup_errors_total 0
```

### TLS and basic authentication

The Apple Time Machine Exporter supports TLS and basic authentication.

To use TLS and/or basic authentication, you need to pass a configuration file
using the `--web.config.file` parameter. The format of the file is described
[in the exporter-toolkit repository](https://github.com/prometheus/exporter-toolkit/blob/master/docs/web-configuration.md).

## License

Apache License 2.0, see [LICENSE](https://github.com/znerol/prometheus-timemachine-exporter/blob/develop/LICENSE).

