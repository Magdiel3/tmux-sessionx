#!/usr/bin/env bash

GIT_BRANCH_COLOR=$'\033[38;2;137;180;250m'
GIT_BRANCH_RESET=$'\033[0m'

session_git_branch() {
	local pane_path branch remote default_ref
	while IFS= read -r pane_path; do
		[[ -z "$pane_path" ]] && continue
		branch=$(git -C "$pane_path" branch --show-current 2>/dev/null) || branch=""
		if [[ -n "$branch" ]]; then
			remote=$(git -C "$pane_path" config --get "branch.$branch.remote" 2>/dev/null) || remote=""
			[[ -z "$remote" || "$remote" == "." ]] && remote=origin
			default_ref=$(git -C "$pane_path" symbolic-ref --quiet "refs/remotes/$remote/HEAD" 2>/dev/null) || default_ref=""
			if [[ "$default_ref" == "refs/remotes/$remote/$branch" ]]; then
				branch=m
			fi
			printf '%s\n' "$branch"
			return
		fi
	done < <(tmux list-panes -s -t "=$1" -F '#{?#{==:#{window_name},main},#{pane_current_path},}' 2>/dev/null)
}

format_sessions_with_git_branch() {
	local sessions="$1"
	local session branch

	while IFS= read -r session; do
		[[ -z "$session" ]] && continue
		branch=$(session_git_branch "$session")
		if [[ -n "$branch" ]]; then
			printf '%s %s(%s)%s\n' "$session" "$GIT_BRANCH_COLOR" "$branch" "$GIT_BRANCH_RESET"
		else
			printf '%s\n' "$session"
		fi
	done <<< "$sessions"
}

strip_git_branch_info() {
	local value session
	value=$(printf '%s\n' "$1" | sed $'s/\033\\[[0-9;]*m//g')
	if [[ -d "$value" ]] || tmux has-session -t "=$value" 2>/dev/null; then
		printf '%s\n' "$value"
	elif [[ "$value" =~ ^(.*)\ \(([^[:space:]]*)\)$ ]]; then
		session="${BASH_REMATCH[1]}"
		if tmux has-session -t "=$session" 2>/dev/null; then
			printf '%s\n' "$session"
		else
			printf '%s\n' "$value"
		fi
	else
		printf '%s\n' "$value"
	fi
}
