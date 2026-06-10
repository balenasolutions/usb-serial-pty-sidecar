#!/bin/sh
SOCKET_PATH="/ipc/tty.sock"

# Cleanup function executed on SIGTERM / SIGINT
cleanup() {
    echo "Caught shutdown signal! Cleaning up socket file..."
    rm -f "$SOCKET_PATH"
    if [ -n "$SOCAT_PID" ]; then
        kill "$SOCAT_PID" 2>/dev/null
    fi
    exit 0
}

# Register the trap
trap cleanup INT TERM

echo 'Waiting for USB device...'
while [ ! -d /sys/class/tty/ttyUSB0 ] && [ ! -d /sys/class/tty/ttyACM0 ]; do 
  sleep 1
done

DEV_NAME=$(ls /sys/class/tty/ | grep -E 'ttyUSB0|ttyACM0' | head -n 1)
echo "Found $DEV_NAME! Reading major/minor numbers..."
MAJ_MIN=$(cat /sys/class/tty/$DEV_NAME/dev | tr ':' ' ')

mknod /dev/$DEV_NAME c $MAJ_MIN

# Clear any stale remnants before launching
rm -f "$SOCKET_PATH"

echo 'Bridging device to UNIX socket...'
# Run in background so the shell script retains PID 1 to catch traps
socat -d -d /dev/$DEV_NAME,raw,echo=0 UNIX-LISTEN:"$SOCKET_PATH",fork &
SOCAT_PID=$!

# Block and wait for socat or a signal
wait "$SOCAT_PID"