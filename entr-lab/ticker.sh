#!/bin/sh
# A tiny long-running program that proves it is alive,
# and proves when it has been restarted: it prints its
# own process id when it starts and a heartbeat line
# every two seconds after that.
echo "ticker started: pid $$ at $(date +%T)"
while true; do
    sleep 2
    echo "  heartbeat from pid $$ at $(date +%T)"
done
