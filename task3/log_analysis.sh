#!/bin/bash


LOG_FILE="access.log"  

echo " ========== LOG FILE ANALYSIS =========="
echo

# 1. Request Counts
echo "🔹 Request Counts"
total_requests=$(wc -l < "$LOG_FILE")
get_requests=$(grep -c '"GET ' "$LOG_FILE")
post_requests=$(grep -c '"POST ' "$LOG_FILE")
echo "Total Requests: $total_requests"
echo "GET Requests: $get_requests"
echo "POST Requests: $post_requests"
echo

# 2. Unique IPs
echo "🔹 Unique IP Addresses"
unique_ips=$(awk '{print $1}' "$LOG_FILE" | sort | uniq | wc -l)
echo "Total Unique IPs: $unique_ips"
echo "Top 5 GET requests by IP:"
awk '{print $1, $6}' "$LOG_FILE" | grep '"GET' | awk '{print $1}' | sort | uniq -c | sort -nr | head -5
echo "Top 5 POST requests by IP:"
awk '{print $1, $6}' "$LOG_FILE" | grep '"POST' | awk '{print $1}' | sort | uniq -c | sort -nr | head -5
echo

# 3. Failure Requests (4xx or 5xx)
echo "🔹 Failure Requests"
failures=$(awk '$9 ~ /^[45]/ {count++} END {print count}' "$LOG_FILE")
fail_percent=$(awk -v total=$total_requests -v fail=$failures 'BEGIN {printf "%.2f", (fail/total)*100}')
echo "Failures: $failures (${fail_percent}%)"
echo

# 4. Most Active IP
echo "🔹 Most Active IP"
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1
echo

# 5. Daily Request Averages
echo "🔹 Daily Request Averages"
days=$(awk '{print $4}' "$LOG_FILE" | cut -d: -f1 | tr -d '[' | sort | uniq | wc -l)
avg_day=$(awk -v total=$total_requests -v days=$days 'BEGIN {printf "%.2f", total/days}')
echo "Total Days: $days"
echo "Average Requests/Day: $avg_day"
echo

# 6. Failure Analysis by Day
echo "🔹 Days with Most Failures"
awk '$9 ~ /^[45]/ {print $4}' "$LOG_FILE" | cut -d: -f1 | tr -d '[' | sort | uniq -c | sort -nr | head
echo

# 7. Request by Hour
echo "🔹 Requests per Hour"
awk '{print $4}' "$LOG_FILE" | cut -d: -f2 | sort | uniq -c | awk '{printf "Hour %02d: %d requests\n", $2, $1}'
echo

# 8. Status Codes Breakdown
echo "🔹 Status Codes Breakdown"
awk '{print $9}' "$LOG_FILE" | grep '^[0-9][0-9][0-9]$' | sort | uniq -c | sort -nr
echo

# 9. Most Active IP by Method
echo "🔹 Most Active IPs by Method"
echo "GET:"
grep '"GET ' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1
echo "POST:"
grep '"POST ' "$LOG_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -1
echo

# 10. Failure Patterns by Hour
echo "🔹 Failure Patterns by Hour"
awk '$9 ~ /^[45]/ {split($4, time, ":"); print time[2]}' "$LOG_FILE" | sort | uniq -c | sort -nr | awk '{printf "Hour %02d: %d failures\n", $2, $1}'
echo

echo " Analysis Complete."