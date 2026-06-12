#!/bin/sh

cleanup() {
    echo "Caught shutdown signal! Tearing down PTY link..."
    if [ -n "$SOCAT_PID" ]; then
        kill "$SOCAT_PID" 2>/dev/null
    fi
    exit 0
}

trap cleanup INT TERM

echo 'Waiting for IPC socket from sidecar...'
while [ ! -e /ipc/tty.sock ]; do 
  sleep 1
done

echo 'Socket found! Linking to virtual /dev/ttyUSB0...'
# Run in background to allow signal trapping
socat -d -d PTY,link=/dev/ttyUSB0,raw,echo=0 UNIX-CONNECT:/ipc/tty.sock &
SOCAT_PID=$!

wait "$SOCAT_PID"