#!/bin/bash
# =============================================================
# generate_data.sh
# Genereaza ~/lab-linux/exercitii/sistem_mare.log (200 linii)
# Format coloane awk: $1=timestamp  $2=nivel  $3=[serviciu]  $4+=mesaj
# Utilizare: bash scripts/generate_data.sh
# =============================================================

set -euo pipefail

OUTPUT_DIR="${HOME}/lab-linux/exercitii"
OUTPUT_FILE="${OUTPUT_DIR}/sistem_mare.log"
TOTAL=200

GREEN='\033[0;32m'; RESET='\033[0m'
ok() { echo -e "${GREEN}[OK]${RESET}  $1"; }

mkdir -p "$OUTPUT_DIR"

SERVICES=("auth-service" "db-service" "api-gateway" "cache-service"
          "payment-service" "etl-pipeline" "scheduler" "report-engine")

INFO_MSGS=(
  "Request processed successfully: GET /api/users 200"
  "User session started for user_id=187"
  "Cache hit ratio last hour: 94.3%"
  "DB query executed in 12ms: SELECT FROM tranzactii"
  "ETL batch completed: 1000 records processed, 0 errors"
  "Health check passed: all services responding"
  "Scheduled task triggered: daily_report"
  "Report generation finished: raport_lunar.pdf"
  "Metrics exported to Prometheus endpoint :9090"
  "Connection pool stats: 14/20 active, 6 idle"
  "Backup completed to /var/backups/ successfully"
  "SSL certificate renewed for analytics.internal"
)
DEBUG_MSGS=(
  "Processing record ID 4823: validation passed"
  "Cache lookup: key=user_session_42 -- HIT"
  "SQL plan: seq scan on tranzactii, estimated 1000 rows"
  "Connection opened to 10.0.0.5:5432"
  "Thread pool queue depth: 3 pending tasks"
  "Token validated for user_id=203 expires_in=86400s"
  "Memory buffer flushed: 2048 bytes written to disk"
  "Request headers parsed: Content-Type=application/json"
)
WARN_MSGS=(
  "High memory usage detected: 78% (threshold: 75%)"
  "Slow query detected: 2340ms > threshold 1000ms"
  "Connection pool nearing limit: 18/20 connections"
  "Retry attempt 2/3 for payment gateway endpoint"
  "Disk usage above 75% on /var/data: 38GB/50GB"
  "Rate limit approaching for client_id=55: 92/100 req/min"
  "Cache eviction triggered: 240 entries removed (LRU)"
  "SSL certificate expires in 14 days for analytics.internal"
)
ERROR_MSGS=(
  "Database connection failed: timeout after 30s on db-replica-2"
  "Authentication failed for user admin from 10.0.2.99"
  "Payment gateway unreachable: HTTP 503 from pay.example.com"
  "ETL pipeline crashed: NullPointerException in transform phase at record 512"
  "Failed to write to disk: No space left on /var/data"
  "API rate limit exceeded for client_id=55: 150/100 req/min"
  "Unhandled exception in report-engine: IndexOutOfBoundsException"
)

# Distributie pe 20 pozitii: 8 INFO + 5 DEBUG + 4 WARN + 3 ERROR = 40/25/20/15%
DIST=(INFO INFO INFO INFO INFO INFO INFO INFO DEBUG DEBUG DEBUG DEBUG DEBUG WARN WARN WARN WARN ERROR ERROR ERROR)
D=${#DIST[@]}

HOUR=8; MIN=0; SEC=0; DAY=17; MON=02

> "$OUTPUT_FILE"   # goleste/creeaza fisierul

for (( i=1; i<=TOTAL; i++ )); do
    SEC=$(( (i * 17 + 3) % 60 ))
    MIN=$(( MIN + (i % 5) + 3 ))
    while [ "$MIN" -ge 60 ]; do MIN=$(( MIN - 60 )); HOUR=$(( HOUR + 1 )); done
    if [ "$HOUR" -ge 23 ]; then HOUR=8; MIN=0; DAY=$(( DAY + 1 )); fi
    [ "$DAY" -gt 28 ] && { DAY=1; MON=$(( MON + 1 )); }

    TS=$(printf "2026-%02d-%02dT%02d:%02d:%02d" "$MON" "$DAY" "$HOUR" "$MIN" "$SEC")
    LEVEL="${DIST[$(( (i-1) % D ))]}"
    SVC="${SERVICES[$(( (i-1) % ${#SERVICES[@]} ))]}"

    case "$LEVEL" in
        INFO)  MSG="${INFO_MSGS[$(( (i-1) % ${#INFO_MSGS[@]} ))]}" ;;
        DEBUG) MSG="${DEBUG_MSGS[$(( (i-1) % ${#DEBUG_MSGS[@]} ))]}" ;;
        WARN)  MSG="${WARN_MSGS[$(( (i-1) % ${#WARN_MSGS[@]} ))]}" ;;
        ERROR) MSG="${ERROR_MSGS[$(( (i-1) % ${#ERROR_MSGS[@]} ))]}" ;;
    esac

    printf "%s %-7s [%s] %s\n" "$TS" "$LEVEL" "$SVC" "$MSG"
done >> "$OUTPUT_FILE"

TOTAL_LINES=$(wc -l < "$OUTPUT_FILE")
IC=$(grep -c " INFO "  "$OUTPUT_FILE" || true)
DC=$(grep -c " DEBUG " "$OUTPUT_FILE" || true)
WC=$(grep -c " WARN "  "$OUTPUT_FILE" || true)
EC=$(grep -c " ERROR " "$OUTPUT_FILE" || true)

ok "Fisier generat: $OUTPUT_FILE"
ok "Total linii: $TOTAL_LINES"
echo ""
printf "   %-7s  %4d linii  (%d%%)\n"  "INFO"  "$IC" $(( IC  * 100 / TOTAL_LINES ))
printf "   %-7s  %4d linii  (%d%%)\n"  "DEBUG" "$DC" $(( DC  * 100 / TOTAL_LINES ))
printf "   %-7s  %4d linii  (%d%%)\n"  "WARN"  "$WC" $(( WC  * 100 / TOTAL_LINES ))
printf "   %-7s  %4d linii  (%d%%)  <-- > 10%% => alert H7\n" "ERROR" "$EC" $(( EC * 100 / TOTAL_LINES ))
echo ""
echo "   Verificare coloane awk (col.2=nivel, col.3=[serviciu]):"
head -3 "$OUTPUT_FILE" | awk '{printf "   %s  col2=%-7s  col3=%s\n", $1, $2, $3}'
