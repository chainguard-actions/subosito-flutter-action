<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.22.0** was hardened automatically. 16 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Set action inputs' run: block in action.yaml directly interpolates multiple ${{ inputs.* }} expressions into shell commands (rule a). Most are single-quoted (e.g., -n '${{ inputs.flutter-version }}') but single-quoting does not prevent injection when the value contains a single-quote character. Critically, ${{ inputs.channel }} is completely unquoted on the last argument line, allowing an attacker-controlled value to inject arbitrary shell commands. All ${{ ... }} expressions must be moved to env: vars and those vars must be double-quoted in the shell script.

Locations:

- `action.yaml:104`
- `action.yaml:106`
- `action.yaml:107`
- `action.yaml:108`
- `action.yaml:109`
- `action.yaml:110`
- `action.yaml:111`
- `action.yaml:112`
- `action.yaml:113`
- `action.yaml:114`

### script-injection (severity: high)

The 'Run setup script' run: block in action.yaml directly interpolates ${{ steps.flutter-action.outputs.* }} expressions into shell commands (rule a). The value ${{ steps.flutter-action.outputs.CHANNEL }} is completely unquoted on the last argument line, and the other step outputs are only single-quoted. Any ${{ ... }} expression inside a run: block is a script-injection risk regardless of context.

Locations:

- `action.yaml:133`
- `action.yaml:135`
- `action.yaml:136`
- `action.yaml:137`
- `action.yaml:138`
- `action.yaml:139`

### script-injection (severity: high)

The 'Echo outputs' run: block in .github/workflows/workflow.yaml directly interpolates ${{ runner.os }}, ${{ runner.arch }}, and ${{ steps.flutter-action.outputs.* }} expressions into shell echo commands (rule a). Any ${{ ... }} expression inside a run: block is a script-injection risk. These values should be passed via env: vars and double-quoted in the shell.

Locations:

- `.github/workflows/workflow.yaml:48`
- `.github/workflows/workflow.yaml:49`
- `.github/workflows/workflow.yaml:50`
- `.github/workflows/workflow.yaml:51`
- `.github/workflows/workflow.yaml:52`
- `.github/workflows/workflow.yaml:53`
- `.github/workflows/workflow.yaml:54`
- `.github/workflows/workflow.yaml:55`

### github-env-injection (severity: high)

setup.sh writes user-controlled values to $GITHUB_OUTPUT, $GITHUB_ENV, and $GITHUB_PATH without sanitization (no 'printf "%s" ... | tr -d "\n\r"' step). Specifically: (1) CHANNEL, VERSION, ARCHITECTURE, CACHE-KEY, CACHE-PATH, PUB-CACHE-KEY, PUB-CACHE-PATH are written to $GITHUB_OUTPUT — all derived from user-supplied inputs (channel, version, architecture, cache-key, cache-path, pub-cache-key, pub-cache-path) via the action's inputs. (2) FLUTTER_ROOT=$CACHE_PATH and PUB_CACHE=$PUB_CACHE are written to $GITHUB_ENV. (3) $CACHE_PATH/bin, $CACHE_PATH/bin/cache/dart-sdk/bin, and $PUB_CACHE/bin are written to $GITHUB_PATH. An attacker-controlled newline in any of these values can inject arbitrary environment variables or path entries.

Locations:

- `setup.sh:170`
- `setup.sh:210`
- `setup.sh:215`

### unpinned-uses (severity: high)

action.yaml references actions/cache@v5 (a mutable tag, not a pinned SHA) in two steps: 'Cache Flutter' and 'Cache pub dependencies'. These should be pinned to a full 40-character commit SHA to prevent supply-chain attacks.

Locations:

- `action.yaml:116`
- `action.yaml:123`

### unpinned-uses (severity: high)

.github/workflows/workflow.yaml references multiple actions by mutable tag or branch rather than pinned SHA: 'actions/checkout@v4' (used in lint_shellcheck, test_channel, test_cache, test_version_file, test_print_output_arm64 jobs) and 'ludeeus/action-shellcheck@master' (a branch reference, which is especially dangerous). All uses: references must be pinned to a full 40-character commit SHA.

Locations:

- `.github/workflows/workflow.yaml:20`
- `.github/workflows/workflow.yaml:22`

### missing-permissions (severity: medium)

.github/workflows/workflow.yaml has no top-level 'permissions:' key and no job-level 'permissions:' key on any of its jobs (lint_shellcheck, test_channel, test_cache, test_version_file, test_print_output_x64, test_print_output_arm64). Without explicit permissions, the workflow inherits the repository default, which may be overly broad (read/write). A minimal permissions block (e.g., 'permissions: {}' or 'contents: read') should be added.

Locations:

- `.github/workflows/workflow.yaml:1`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:107`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version-file }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:108`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.architecture }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:109`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:110`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:111`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:112`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:113`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.git-source }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:114`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.channel }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:115`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions, static-inline-injection

**Notes:**

Fixed all findings across action.yaml, setup.sh, and .github/workflows/workflow.yaml:

1. action.yaml 'Set action inputs': Moved all ${{ inputs.* }} expressions to env: vars (INPUT_FLUTTER_VERSION, INPUT_FLUTTER_VERSION_FILE, INPUT_ARCHITECTURE, INPUT_CACHE_KEY, INPUT_CACHE_PATH, INPUT_PUB_CACHE_KEY, INPUT_PUB_CACHE_PATH, INPUT_GIT_SOURCE, INPUT_CHANNEL) and double-quoted them in the shell script.

2. action.yaml 'Run setup script': Moved all ${{ steps.flutter-action.outputs.* }} expressions to env: vars (FLUTTER_VERSION, FLUTTER_ARCHITECTURE, FLUTTER_CACHE_PATH, FLUTTER_PUB_CACHE_PATH, FLUTTER_CHANNEL) and double-quoted them in the shell script.

3. action.yaml: Pinned both actions/cache@v5 to SHA caa296126883cff596d87d8935842f9db880ef25.

4. setup.sh: Added printf '%s' "$VAR" | tr -d '\n\r' sanitization for all values written to $GITHUB_OUTPUT, $GITHUB_ENV, and $GITHUB_PATH.

5. workflow.yaml 'Echo outputs': Moved all ${{ runner.* }} and ${{ steps.flutter-action.outputs.* }} expressions to env: vars and double-quoted them in the shell script.

6. workflow.yaml: Pinned all actions/checkout@v4 to SHA 11d5960a326750d5838078e36cf38b85af677262 and ludeeus/action-shellcheck@master to SHA 00b27aa7cb85167568cb48a3838b75f4265f2bca.

7. workflow.yaml: Added top-level 'permissions: contents: read' block.

