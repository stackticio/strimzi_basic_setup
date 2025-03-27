1) RabbitMQHighMemoryUsage

    Rule:

rabbitmq_process_resident_memory_bytes > 2e8

Checks if the node’s resident memory exceeds 200MB for 5 minutes.

Curl Test (raw metric):

curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=rabbitmq_process_resident_memory_bytes'

Look at the value field in the JSON. If it’s above 2e8 (200,000,000), the alert triggers.

Prometheus UI (raw metric):

    http://localhost:9090/graph?g0.expr=rabbitmq_process_resident_memory_bytes&g0.tab=1

    You can remove the threshold to see the current memory usage. Then add > 2e8 to see if it matches any series.

2) RabbitMQHighFileDescriptorUsage

    Rule:

(rabbitmq_process_open_fds / rabbitmq_process_max_fds) > 0.0001

Because your open_fds is 44 and max_fds is ~1,048,576, that ratio is ~0.00004. We use 0.0001 to demonstrate a “threshold” above the current ratio.

Curl Test:

curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=rabbitmq_process_open_fds / rabbitmq_process_max_fds'

UI:

    http://localhost:9090/graph?g0.expr=(rabbitmq_process_open_fds%20%2F%20rabbitmq_process_max_fds)&g0.tab=1

    You’ll see a numeric ratio. If it’s below 0.0001, no alert fires → “empty” query for the > 0.0001 comparison.

3) RabbitMQLowDiskSpace

    Rule:

(rabbitmq_disk_space_available_bytes / rabbitmq_disk_space_available_limit_bytes) < 0.1

Checks if free disk space is <10% of the configured watermark. Your sample data shows rabbitmq_disk_space_available_bytes=~8.3GB vs rabbitmq_disk_space_available_limit_bytes=50MB, so the ratio is quite large (~166). Unlikely to alert unless your free disk dips.

Curl:

curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=rabbitmq_disk_space_available_bytes / rabbitmq_disk_space_available_limit_bytes'

UI:

    http://localhost:9090/graph?g0.expr=(rabbitmq_disk_space_available_bytes%20%2F%20rabbitmq_disk_space_available_limit_bytes)&g0.tab=1

4) RabbitMQQueueBacklog

    Rule:

rabbitmq_queue_messages > 100

If total messages (ready + unacked) exceed 100 for 5 minutes, triggers a “warning backlog” alert.

Curl:

curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=rabbitmq_queue_messages'

UI:

    http://localhost:9090/graph?g0.expr=rabbitmq_queue_messages&g0.tab=1

    If it’s never above 100, no alert.

5) RabbitMQNoQueueConsumers

    Rule:

rabbitmq_queue_consumers == 0

If a queue has 0 consumers for 5m, we raise an alert.

Curl:

curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=rabbitmq_queue_consumers'

If the result is zero for a queue label, it meets the condition.

UI:

    http://localhost:9090/graph?g0.expr=rabbitmq_queue_consumers&g0.tab=1

6) RabbitMQFrequentGC

    Rule:

increase(rabbitmq_erlang_gc_runs_total[5m]) > 200

More than 200 GC runs in 5 minutes might signal memory churn.

Curl:

curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=increase(rabbitmq_erlang_gc_runs_total[5m])'

UI:

    http://localhost:9090/graph?g0.expr=increase(rabbitmq_erlang_gc_runs_total[5m])&g0.tab=1

7) RabbitMQNodeRecentlyRestarted

    Rule:

rabbitmq_erlang_uptime_seconds < 300

If uptime is under 5 minutes, triggers the alert. Good to catch unexpected restarts.

Curl:

curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=rabbitmq_erlang_uptime_seconds'

UI:

    http://localhost:9090/graph?g0.expr=rabbitmq_erlang_uptime_seconds&g0.tab=1

    If the value is <300, you’ll see a match.

8) RabbitMQFDAlarm

    Rule:

rabbitmq_alarms_file_descriptor_limit == 1

If the FD limit alarm is active, it sets this metric to 1. This alerts you that the node is throttling or refusing new connections due to FD exhaustion.

Curl:

curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=rabbitmq_alarms_file_descriptor_limit'

UI:

    http://localhost:9090/graph?g0.expr=rabbitmq_alarms_file_descriptor_limit&g0.tab=1

    If it’s 1, the alarm is active.

9) RabbitMQHighAuthFailureRate

    Rule:

increase(rabbitmq_auth_attempts_failed_total[5m])
  / ignoring(instance) increase(rabbitmq_auth_attempts_total[5m]) > 0.2

If over 20% of attempts fail in 5 minutes, triggers an alert. (Use ignoring(instance) or a suitable label if needed, so the ratio is computed properly.)

Curl:

# Check total attempts vs failed attempts in the last 5m
curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=increase(rabbitmq_auth_attempts_failed_total[5m])'
curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=increase(rabbitmq_auth_attempts_total[5m])'

Compare the numbers to see your actual rate.

UI:

    http://localhost:9090/graph?g0.expr=increase(rabbitmq_auth_attempts_failed_total[5m])&g0.tab=1
    http://localhost:9090/graph?g0.expr=increase(rabbitmq_auth_attempts_total[5m])&g0.tab=1

    Then apply the division if you want to see the ratio directly.

10) RabbitMQMemoryAlarm

    Rule:

rabbitmq_alarms_memory_used_watermark == 1

If this alarm is 1, RabbitMQ triggers memory-based flow control (stops accepting new connections/publishes).

Curl:

curl -G 'http://localhost:9090/api/v1/query' \
     --data-urlencode 'query=rabbitmq_alarms_memory_used_watermark'

UI:

http://localhost:9090/graph?g0.expr=rabbitmq_alarms_memory_used_watermark&g0.tab=1

Value 1 means the alarm is active.
