# shellcheck shell=bash
# Lefthook-compatible commit message linter.
# Enforces: capitalized subject (or conventional commit prefix), no trailing period,
# subject max 72 chars, blank line after subject, body lines max 80 chars.
# Skips merge, fixup, squash, and amend commits.
# Usage: lefthook-commit-msg-lint <message-file>
# NOTE: sourced by writeShellApplication — no shebang or set needed.

msg_file="$1"
subject=$(head -1 "$msg_file")
errors=()

if [[ "$subject" =~ ^(Merge\ |fixup!\ |squash!\ |amend!\ ) ]]; then
    exit 0
fi

if [ -z "$subject" ]; then
    errors+=("Empty commit message")
fi

if [[ -n "$subject" && ! "$subject" =~ ^[a-z]+(\(.+\))?!?:\ .+ && "$subject" =~ ^[a-z] ]]; then
    errors+=("Subject must start with a capital letter")
fi

if [[ "$subject" =~ \.$ ]]; then
    errors+=("Subject must not end with a period")
fi

if [ "${#subject}" -gt 72 ]; then
    errors+=("Subject exceeds 72 characters (${#subject})")
fi

line2=$(sed -n '2p' "$msg_file")
if [ -n "$line2" ]; then
    errors+=("Second line must be blank (separate subject from body)")
fi

line_num=0
while IFS= read -r line; do
    line_num=$((line_num + 1))
    [ "$line_num" -le 2 ] && continue
    if [ "${#line}" -gt 80 ]; then
        errors+=("Line $line_num exceeds 80 characters (${#line})")
    fi
done <"$msg_file"

if [ ${#errors[@]} -gt 0 ]; then
    echo "Commit message lint errors:"
    for err in "${errors[@]}"; do
        echo "  - $err"
    done
    exit 1
fi
