// Copyright 2022 Lorenz Schori.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package collectors

import (
	"math"
	"os/exec"
	"path"
	"strings"
	"time"

	"github.com/go-kit/log"
	"github.com/go-kit/log/level"
	"github.com/prometheus/client_golang/prometheus"
)

func NewLatestBackupCollector(logger log.Logger) *latestBackupCollector {
	latestBackupAge := prometheus.NewGauge(prometheus.GaugeOpts{
		Namespace: "timemachine",
		Subsystem: "latestbackup",
		Name:      "age_seconds",
		Help:      "Seconds since the last successful Apple Time Machine Backup",
	})
	collectorErrors := prometheus.NewCounter(prometheus.CounterOpts{
		Namespace: "timemachine",
		Subsystem: "latestbackup",
		Name:      "errors_total",
		Help:      "Current total errors occured while attempting to determine Apple Time Machine Backup status",
	})
	return &latestBackupCollector{
		logger,
		latestBackupAge,
		collectorErrors,
	}
}

type latestBackupCollector struct {
	logger          log.Logger
	latestBackupAge prometheus.Gauge
	collectorErrors prometheus.Counter
}

// Collect implements prometheus.Collector.
func (c *latestBackupCollector) Collect(ch chan<- prometheus.Metric) {
	ok := c.updateMetrics()

	ch <- c.collectorErrors
	if ok {
		ch <- c.latestBackupAge
	}
}

// Describe implements prometheus.Collector.
func (c *latestBackupCollector) Describe(ch chan<- *prometheus.Desc) {
	ch <- c.latestBackupAge.Desc()
}

func (c *latestBackupCollector) updateMetrics() bool {
	c.latestBackupAge.Set(math.NaN())

	cmd := exec.Command("tmutil", "latestbackup")
	out, cmdErr := cmd.Output()
	if cmdErr != nil {
		level.Warn(c.logger).Log("msg", "Failed to call tmutil latestbackup", "err", cmdErr)
		c.collectorErrors.Inc()
		return false
	}

	_, backupname := path.Split(strings.TrimSpace(string(out)))
	timestamp, parseErr := time.ParseInLocation("2006-01-02-150405", backupname, time.Local)
	if parseErr != nil {
		level.Warn(c.logger).Log("msg", "Failed to parse latestbackup timestamp", "err", cmdErr)
		c.collectorErrors.Inc()
		return false
	}

	age := time.Since(timestamp)
	c.latestBackupAge.Set(age.Seconds())

	return true
}
