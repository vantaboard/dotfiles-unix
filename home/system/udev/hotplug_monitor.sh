#!/bin/bash

# Clear the log for each run
echo "--- NEW EVENT: $(date) ---" > /tmp/autorandr.log
exec >> /tmp/autorandr.log 2>&1

ACTION=$1

# 1. DYNAMIC USER DETECTION
# Finds the first user with a graphical session via loginctl
TARGET_USER=$(loginctl list-users --no-legend | awk '{ print $2 }' | head -n 1)

# If loginctl is empty, fallback to finding the owner of the active i3 process
if [ -z "$TARGET_USER" ]; then
    TARGET_USER=$(pgrep -u root -a i3 | awk '{print $1}' | xargs ps -o user= -p | head -n 1)
fi

# Get User ID and Home directory
USER_ID=$(id -u "$TARGET_USER")
USER_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

if [ -z "$TARGET_USER" ]; then
    echo "Error: No active graphical user detected."
    exit 1
fi

# 2. DYNAMIC ENVIRONMENT DETECTION
# We grab DISPLAY and XAUTHORITY from an active process owned by the user
SESSION_PID=$(pgrep -u "$TARGET_USER" .session || pgrep -u "$TARGET_USER" i3 | head -n 1)

if [ -n "$SESSION_PID" ]; then
    export DISPLAY=$(grep -z DISPLAY "/proc/$SESSION_PID/environ" | cut -d= -f2- | tr -d '\0')
    export XAUTHORITY=$(grep -z XAUTHORITY "/proc/$SESSION_PID/environ" | cut -d= -f2- | tr -d '\0')
fi

# Fallbacks if scraping /proc failed
export DISPLAY="${DISPLAY:-:1}"
export XAUTHORITY="${XAUTHORITY:-/run/user/$USER_ID/gdm/Xauthority}"

# Find the i3 socket dynamically based on UID
export I3SOCK=$(ls /run/user/"$USER_ID"/i3/ipc-socket.* 2>/dev/null | head -n 1)

# 3. AUTORANDR PATH DETECTION
# Checks for your specific .venv first, fallbacks to system autorandr
VENV_PATH="$USER_HOME/Code/autorandr-env/.venv/bin/autorandr"
if [ -f "$VENV_PATH" ]; then
    AUTORANDR_BIN="$VENV_PATH"
else
    AUTORANDR_BIN=$(which autorandr)
fi

run_autorandr() {
    echo "Target User: $TARGET_USER (UID: $USER_ID)"
    echo "Using Display: $DISPLAY"
    echo "Using Xauth: $XAUTHORITY"
    echo "Using Bin: $AUTORANDR_BIN"

    if [ "$ACTION" == "remove" ]; then
        echo "Action: REMOVE detected. Forcing 'mobile' profile..."
        sudo -u "$TARGET_USER" DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" I3SOCK="$I3SOCK" "$AUTORANDR_BIN" --load mobile --force
    else
        echo "Action: ADD detected. Waiting 5s for monitors..."
        sleep 5
        sudo -u "$TARGET_USER" DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" I3SOCK="$I3SOCK" "$AUTORANDR_BIN" --change --force
    fi
    
    echo "--- Finished at $(date) ---"
}

# Run in background and disown
run_autorandr & disown
