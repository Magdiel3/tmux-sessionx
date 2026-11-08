#!/usr/bin/env bash

set -e
source "$(dirname "$0")/../scripts/git-branch.sh"

tmux() {
	case "$1" in
	list-panes)
		[[ "$4" == "=$TEST_SESSION" ]] || return 1
		[[ "$6" == '#{?#{==:#{window_name},main},#{pane_current_path},}' ]] || return 1
		printf '%s\n' "${PANE_PATHS[@]}"
		;;
	has-session)
		[[ "$3" == '=existing (session)' || "$3" == '=work' ]]
		;;
	esac
}

git() {
	[[ "$2" == /repo ]] || return 1
	case "$3" in
	branch) printf '%s\n' "$BRANCH" ;;
	config) [[ -n "$REMOTE" ]] && printf '%s\n' "$REMOTE" ;;
	symbolic-ref)
		[[ -n "$DEFAULT_REF" && "$5" == "refs/remotes/$EXPECTED_REMOTE/HEAD" ]] &&
			printf '%s\n' "$DEFAULT_REF"
		;;
	esac
}

TEST_SESSION="work"
PANE_PATHS=("/not-a-repo" "/repo")
BRANCH='feature/test(branch)'
REMOTE=origin
EXPECTED_REMOTE=origin
DEFAULT_REF=refs/remotes/origin/main
expected=$'work \033[38;2;137;180;250m(feature/test(branch))\033[0m'
[[ "$(format_sessions_with_git_branch "$TEST_SESSION")" == "$expected" ]]
[[ "$(strip_git_branch_info "$expected")" == "work" ]]
[[ "$(strip_git_branch_info 'existing (session)')" == 'existing (session)' ]]
[[ "$(strip_git_branch_info 'new (session)')" == 'new (session)' ]]

for BRANCH in main master jp6; do
	DEFAULT_REF="refs/remotes/origin/$BRANCH"
	[[ "$(session_git_branch "$TEST_SESSION")" == m ]]
done

BRANCH=jp6
DEFAULT_REF=
[[ "$(session_git_branch "$TEST_SESSION")" == jp6 ]]
REMOTE=upstream
EXPECTED_REMOTE=upstream
DEFAULT_REF=refs/remotes/upstream/jp6
[[ "$(session_git_branch "$TEST_SESSION")" == m ]]
REMOTE=.
EXPECTED_REMOTE=origin
DEFAULT_REF=refs/remotes/origin/jp6
[[ "$(session_git_branch "$TEST_SESSION")" == m ]]

PANE_PATHS=("/not-a-repo")
[[ "$(format_sessions_with_git_branch "$TEST_SESSION")" == "work" ]]
