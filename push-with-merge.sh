#!/usr/bin/env bash
# Push to the private repo's branch, merging if the remote moved.
#
# WHY THIS EXISTS. On 2026-08-26 the engine run measured the whole thing --
# Setup.sh killed at 113 GB after 637 s -- wrote its report, committed it,
# recorded it in the changelog, and then LOST ALL OF IT to a rejected push,
# because a session had pushed to the same branch while the job was running.
# The numbers survived only because they were also in the job log. Ten minutes
# of measurement was thrown away by the last command of the job.
#
# A push is the delivery. A job that measured something and could not deliver
# it has not done its work, so this retries through a merge rather than
# giving up on the first rejection.
#
# Team/CHANGELOG.md is declared `merge=union` in the private repo's
# .gitattributes, so two sessions appending entries at the same place keeps
# BOTH -- which is that project's rule, now enforced by git rather than by
# whoever is watching.
#
# Usage:  ./push-with-merge.sh <branch>
set +e

BRANCH="$1"
if [ -z "$BRANCH" ]; then
  echo "usage: push-with-merge.sh <branch>"
  exit 2
fi

for attempt in 1 2 3 4; do
  git push origin "HEAD:${BRANCH}"
  if [ $? -eq 0 ]; then
    echo "pushed on attempt ${attempt}"
    exit 0
  fi

  echo "push rejected on attempt ${attempt} -- the remote moved. Merging."
  git fetch origin "$BRANCH"
  if [ $? -ne 0 ]; then
    echo "fetch failed. Not a merge problem; stopping so it is not mistaken"
    echo "for one."
    exit 1
  fi

  git merge --no-edit "origin/${BRANCH}"
  if [ $? -ne 0 ]; then
    echo "MERGE CONFLICT that union could not settle. Stopping rather than"
    echo "resolving something a person should look at. Conflicted paths:"
    git diff --name-only --diff-filter=U
    exit 1
  fi

  sleep $(( attempt * 3 ))
done

echo "still rejected after 4 attempts. The measurement is in this job's log;"
echo "it did NOT reach the repository."
exit 1
