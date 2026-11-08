#!/usr/bin/env bash

set -e
source "$(dirname "$0")/../scripts/git-branch.sh"

git() {
	case "$3" in
	config) [[ -n "$REMOTE" ]] && printf '%s\n' "$REMOTE" ;;
	symbolic-ref)
		[[ -n "$DEFAULT_REF" && "$5" == "refs/remotes/$EXPECTED_REMOTE/HEAD" ]] &&
			printf '%s\n' "$DEFAULT_REF"
		;;
	esac
}

REMOTE=origin
EXPECTED_REMOTE=origin
for branch in main master jp6; do
	DEFAULT_REF="refs/remotes/origin/$branch"
	[[ "$(abbreviate_git_branch /repo "$branch")" == m ]]
done

DEFAULT_REF=refs/remotes/origin/main
[[ "$(abbreviate_git_branch /repo feature/test)" == feature/test ]]
DEFAULT_REF=
[[ "$(abbreviate_git_branch /repo jp6)" == jp6 ]]
REMOTE=upstream
EXPECTED_REMOTE=upstream
DEFAULT_REF=refs/remotes/upstream/jp6
[[ "$(abbreviate_git_branch /repo jp6)" == m ]]
REMOTE=.
EXPECTED_REMOTE=origin
DEFAULT_REF=refs/remotes/origin/jp6
[[ "$(abbreviate_git_branch /repo jp6)" == m ]]
