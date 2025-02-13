#!/bin/bash

# vars
ZSCALER_BIN_DIR="/opt/zscaler/bin"
ZSCALER_EXECUTABLES=("zstunnel" "zstray" "ZSTray.Deb" "zsaservice" "zsupdater")

# kill it with fire
kill_processes() {
    for executable in "${ZSCALER_EXECUTABLES[@]}"; do
        # Find and kill the process if it's running
        process_id=$(pgrep -f "$executable")
        if [ -n "$process_id" ]; then
            echo "Killing process $executable with PID $process_id"
            sudo kill -9 "$process_id"
        else
            echo "$executable is not running."
        fi
    done
}

# disable it (with fire)
disable_executables() {
    for executable in "${ZSCALER_EXECUTABLES[@]}"; do
        executable_path="$ZSCALER_BIN_DIR/$executable"
        if [ -f "$executable_path" ]; then
            # Rename the executable to prevent it from running
            echo "Disabling $executable by renaming it"
            sudo mv "$executable_path" "$executable_path.disabled"
        else
            echo "$executable does not exist in $ZSCALER_BIN_DIR."
        fi
    done
}

# restore it (so they don't catch on)
restore_executables() {
    for executable in "${ZSCALER_EXECUTABLES[@]}"; do
        executable_path="$ZSCALER_BIN_DIR/$executable.disabled"
        if [ -f "$executable_path" ]; then
            # Rename the executable back to its original name
            echo "Restoring $executable by renaming it back"
            sudo mv "$executable_path" "$ZSCALER_BIN_DIR/$executable"
        else
            echo "$executable is not disabled, cannot restore."
        fi
    done
}

# double check
check_status() {
    for executable in "${ZSCALER_EXECUTABLES[@]}"; do
        if [ -f "$ZSCALER_BIN_DIR/$executable.disabled" ]; then
            echo "$executable has been disabled."
        else
            echo "$executable is still active and enabled."
        fi
    done
}

# simple arg menu
if [ "$1" == "disable" ]; then
    # Stop running processes
    kill_processes
    disable_executables
    check_status
    echo "Zscaler has been temporarily disabled. To re-enable, run with 'restore'."

elif [ "$1" == "restore" ]; then
    restore_executables
    check_status
    echo "Zscaler has been restored to its original state."

else
    echo "Usage: $0 [disable|restore]"
    echo "  disable  - Disable Zscaler functionality"
    echo "  restore  - Restore Zscaler functionality"
fi
