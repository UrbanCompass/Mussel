#!/bin/bash
# This script is used to run the mussel server.
# It expects the MusselServer binary to be in the same directory as this script.
# Its intended to be use by Xcode run script phases.

MUSSEL_PID=$(pgrep MusselServer)
MUSSEL_DIR=$(dirname $0)

if [ $MUSSEL_PID ]; then
    echo "Mussel server already running, killing it process: $MUSSEL_PID"
    kill $MUSSEL_PID
fi

echo "Launching Mussel server in background"
$MUSSEL_DIR/MusselServer > stdout 2>&1 &
echo "Mussel server launched!"
