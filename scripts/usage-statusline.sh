#!/usr/bin/env bash
# Status line for Claude Code that also records subscription usage for forge.
#
# Claude Code hands the 5-hour and 7-day usage percentages only to the status
# line command, and only in interactive sessions (Pro and Max plans). This
# script saves them to a file so `forge run` can pause before a limit is hit
# (FORGE_USAGE_STOP_PERCENT in .forge/config.sh), then prints a status line.
#
# Use it as your status line, in ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "forge-usage-statusline" }
#
# Already have a status line? Keep yours and record usage from inside it:
#   input=$(cat); printf '%s' "$input" | forge-usage-statusline --record-only
#
# The reading is only as fresh as your last interactive activity. forge ignores
# readings older than FORGE_USAGE_MAX_AGE seconds.

command -v jq >/dev/null 2>&1 || exit 0
input="$(cat)"
out="${FORGE_USAGE_FILE:-${XDG_CACHE_HOME:-$HOME/.cache}/forge/usage.json}"

# Record only when the session actually reported rate limits.
record="$(jq -c --argjson now "$(date +%s)" '
  select(.rate_limits.five_hour != null or .rate_limits.seven_day != null)
  | { recorded_at: $now, five_hour: .rate_limits.five_hour, seven_day: .rate_limits.seven_day }' <<<"$input" 2>/dev/null)"
if [[ -n "$record" ]]; then
  mkdir -p "$(dirname "$out")" && printf '%s\n' "$record" > "$out.$$" && mv "$out.$$" "$out"
fi

[[ "${1:-}" == "--record-only" ]] && exit 0

jq -r '
  def pct: if . == null then "–" else "\(. | floor)%" end;
  "[\(.model.display_name // "?")] context \(.context_window.used_percentage | pct)"
  + (if .rate_limits then " · 5h \(.rate_limits.five_hour.used_percentage | pct) · 7d \(.rate_limits.seven_day.used_percentage | pct)" else "" end)
' <<<"$input" 2>/dev/null
exit 0
