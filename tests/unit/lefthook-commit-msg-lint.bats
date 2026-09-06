#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
}

@test "valid subject passes" {
    echo "Add new feature" > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_success
}

@test "conventional commit prefix passes" {
    echo "feat: add new feature" > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_success
}

@test "fix prefix with scope passes" {
    echo "fix(auth): resolve token expiry" > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_success
}

@test "empty message fails" {
    echo "" > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_failure
    assert_output --partial "Empty commit message"
}

@test "lowercase subject without prefix fails" {
    echo "add new feature" > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_failure
    assert_output --partial "capital letter"
}

@test "trailing period fails" {
    echo "Add new feature." > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_failure
    assert_output --partial "period"
}

@test "subject over 72 chars fails" {
    printf '%0.s.' {1..73} > "$TMP/msg"
    # Overwrite with a real long subject
    python3 -c "print('A' * 73)" > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_failure
    assert_output --partial "72 characters"
}

@test "non-blank second line fails" {
    printf 'Add feature\nsome detail\n' > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_failure
    assert_output --partial "blank"
}

@test "merge commit is skipped" {
    echo "Merge branch 'feature' into main" > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_success
}

@test "fixup commit is skipped" {
    echo "fixup! Add feature" > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_success
}

@test "body line over 80 chars passes" {
    printf 'Add feature\n\n%s\n' "$(python3 -c "print('x' * 81)")" > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_success
}

@test "valid message with body passes" {
    printf 'Add feature\n\nThis adds a new feature.\n' > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_success
}

@test "breaking change prefix passes" {
    echo "feat!: breaking change" > "$TMP/msg"
    run lefthook-commit-msg-lint "$TMP/msg"
    assert_success
}
