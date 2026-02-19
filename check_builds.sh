#!/bin/bash
# Quick Build Status Checker
# Run anytime with: ./check_builds.sh

cd "/Users/stillbulldog35/Documents/hass agent/jusPrin"

echo "🔍 Checking jusPrin builds..."
echo ""

# Latest build on updates branch
echo "━━━ Latest Build on 'updates' Branch ━━━"
gh run list --branch updates --limit 1 --json status,conclusion,databaseId,createdAt,event \
  --jq '.[] | "Status: \(.status)\nResult: \(.conclusion // "running")\nRun ID: \(.databaseId)\nAge: \((.createdAt | fromdateiso8601 | (now - .) / 60 | floor)) minutes ago\n"'

echo ""
echo "━━━ All Recent Builds ━━━"
gh run list --branch updates --limit 5

echo ""
echo "━━━ Failed Builds ━━━"
failed=$(gh run list --branch updates --status failure --limit 3 2>/dev/null)
if [ -n "$failed" ]; then
  echo "$failed"
  echo ""
  echo "💡 To see errors: gh run view <run-id> --log-failed"
else
  echo "✅ No recent failures"
fi

echo ""
echo "━━━ Quick Actions ━━━"
echo "View latest: gh run view \$(gh run list --branch updates --limit 1 --json databaseId -q '.[0].databaseId')"
echo "Watch live:  gh run watch"
echo "Get errors:  gh run view <id> --log-failed"
