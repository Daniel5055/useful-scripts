#!/usr/bin/bash

# agent_finder.sh
# Used to find any present ssh-agent sessions and use them
# Basically used so I don't have to create a new ssh-agent for each login session

# First check that active socket not assigned
if ssh-add -l > /dev/null 2>&1; then
    echo "ssh-agent present in this session"
    echo "SOCKET: $SSH_AUTH_SOCK"
    echo "PID: $SSH_AGENT_PID"
    exit 2
fi

# If ssh-agent owned by user exists, then get PID
# If multiple matches exist then return first match
# If no ssh-agent exists then AGENT_PID is an empty string
for AGENT_PID in $(pgrep -u "$USER" ssh-agent); do

    # Check if agent not found
    if [ -z "$AGENT_PID" ]; then
        echo "No ssh-agent found"
        exit 1
    else
        # Search for socket path in tmp files and assign
        export SSH_AUTH_SOCK=$(find /tmp -name "agent.$((AGENT_PID - 1))" 2> /dev/null)

        # Double check that this ssh_socket works
        if ssh-add -l > /dev/null 2>&1; then
            echo "ssh-agent found in another session"
            echo "SOCKET: $SSH_AUTH_SOCK"
            echo "PID: $AGENT_PID"
            exit 0
        fi
    fi
done

echo "No valid ssh-agent found"

exit 1
