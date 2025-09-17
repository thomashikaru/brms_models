#!/bin/bash

# Helper script to check the status of BRMS model jobs
# Usage: ./scripts/check_jobs.sh [user]

set -e

USER=${1:-$USER}

echo "Checking BRMS model jobs for user: $USER"
echo "=========================================="

# Check running jobs
echo "Running jobs:"
RUNNING_JOBS=$(squeue -u "$USER" --format="%.10i %.20j %.8u %.8T %.10M %.6D %R" --noheader)
if [ -z "$RUNNING_JOBS" ]; then
    echo "  No running jobs found"
else
    echo "$RUNNING_JOBS"
fi

echo ""

# Check recent completed jobs (last 24 hours)
echo "Recent completed jobs (last 24 hours):"
RECENT_JOBS=$(sacct -u "$USER" --starttime=$(date -d '24 hours ago' '+%Y-%m-%d') --format="JobID,JobName,State,ExitCode,Start,End,Elapsed" --noheader)
if [ -z "$RECENT_JOBS" ]; then
    echo "  No recent completed jobs found"
else
    echo "$RECENT_JOBS"
fi

echo ""

# Check for BRMS-specific log files
echo "Recent BRMS log files:"
if [ -d "outputs/logs" ]; then
    find outputs/logs -name "*.log" -mtime -1 -exec ls -la {} \; | head -10
else
    echo "  No logs directory found"
fi

echo ""

# Check for fitted models
echo "Fitted models:"
if [ -d "outputs/fitted_models" ]; then
    find outputs/fitted_models -name "*.RData" -exec ls -la {} \;
else
    echo "  No fitted models directory found"
fi