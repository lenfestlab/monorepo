#!/bin/bash

PLIST_PATH="${SRCROOT}/firebase/project/${PRODUCT_BUNDLE_IDENTIFIER}/GoogleService-Info.plist"
echo ${PLIST_PATH}
cp -f ${PLIST_PATH} "${SRCROOT}/App/Resources"
