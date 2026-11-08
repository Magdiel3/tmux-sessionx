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
	case "$2" in
	/repo) printf '%s\n' 'feature/test(branch)' ;;
	*) return 1 ;;
	esac
}

TEST_SESSION="work"
PANE_PATHS=("/not-a-repo" "/repo")
expected=$'work \033[38;2;137;180;250m(feature/test(branch))\033[0m'
[[ "$(format_sessions_with_git_branch "$TEST_SESSION")" == "$expected" ]]
[[ "$(strip_git_branch_info "$expected")" == "work" ]]
[[ "$(strip_git_branch_info 'existing (session)')" == 'existing (session)' ]]
[[ "$(strip_git_branch_info 'new (session)')" == 'new (session)' ]]

PANE_PATHS=("/not-a-repo")
[[ "$(format_sessions_with_git_branch "$TEST_SESSION")" == "work" ]]
