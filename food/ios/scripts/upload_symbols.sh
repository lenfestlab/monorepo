#!/bin/bash
# https://docs.sentry.io/clients/cocoa/dsym/#upload-symbols-with-sentry-cli

if which sentry-cli >/dev/null; then
export SENTRY_ORG=lenfest-institute
export SENTRY_PROJECT=food
export SENTRY_AUTH_TOKEN=$SENTRY_AUTH_TOKEN
ERROR=$(sentry-cli upload-dif "$DWARF_DSYM_FOLDER_PATH" 2>&1 >/dev/null)
if [ ! $? -eq 0 ]; then
echo "warning: sentry-cli - $ERROR"
fi
else
echo "warning: sentry-cli not installed, download from https://github.com/getsentry/sentry-cli/releases"
fi
