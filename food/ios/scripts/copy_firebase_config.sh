#!/bin/bash

PLIST_PATH="${SRCROOT}/firebase/project/${ENV_NAME}/GoogleService-Info.plist"
echo ${PLIST_PATH}
cp -f ${PLIST_PATH} "${SRCROOT}/App/Resources"
