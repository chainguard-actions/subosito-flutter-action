<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.22.0** was hardened automatically. 13 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Set action inputs' run: block in action.yaml directly interpolates multiple ${{ inputs.* }} expressions inside the shell command string. Most are single-quoted (e.g., '${{ inputs.flutter-version }}'), but single-quoting does not prevent injection because YAML template substitution happens before the shell sees the string — an attacker-controlled value containing a single-quote can break out of the quoting. Most critically, '${{ inputs.channel }}' is completely unquoted at the end of the command line, allowing direct shell command injection via the channel input (e.g., a value of 'stable; malicious-command' would execute arbitrary code).

Locations:

- `action.yaml:95`
- `action.yaml:96`
- `action.yaml:97`
- `action.yaml:98`
- `action.yaml:99`
- `action.yaml:100`
- `action.yaml:101`
- `action.yaml:102`
- `action.yaml:103`
- `action.yaml:104`

### script-injection (severity: high)

Rule (a): The 'Run setup script' run: block in action.yaml directly interpolates ${{ steps.flutter-action.outputs.* }} expressions inside the shell command string. The final argument '${{ steps.flutter-action.outputs.CHANNEL }}' is completely unquoted, allowing shell command injection if the output value contains shell metacharacters. The other outputs are single-quoted but still subject to YAML template injection before shell quoting takes effect.

Locations:

- `action.yaml:121`
- `action.yaml:122`
- `action.yaml:123`
- `action.yaml:124`
- `action.yaml:125`
- `action.yaml:126`

### github-env-injection (severity: high)

setup.sh writes values derived from inherited workflow-controlled environment variables to $GITHUB_OUTPUT, $GITHUB_ENV, and $GITHUB_PATH without the required sanitization step (printf '%s' ... | tr -d '\n\r'). Specifically: (1) $GITHUB_OUTPUT receives values including info_channel, info_version, info_architecture, CACHE_KEY, CACHE_PATH, PUB_CACHE_KEY, and PUB_CACHE — all derived from $RUNNER_OS, $RUNNER_ARCH, $FLUTTER_STORAGE_BASE_URL, and other inherited env vars; (2) $GITHUB_ENV receives FLUTTER_ROOT=$CACHE_PATH and PUB_CACHE=$PUB_CACHE without sanitization; (3) $GITHUB_PATH receives $CACHE_PATH/bin and $PUB_CACHE/bin paths without sanitization. A calling workflow can set these env vars to values containing newlines, enabling injection of arbitrary environment variables or PATH entries.

Locations:

- `setup.sh:196`
- `setup.sh:213`
- `setup.sh:219`

### unpinned-uses (severity: high)

Two uses: references in action.yaml pin to the mutable tag '@v5' instead of a full 40-character commit SHA. Mutable tags can be moved by the upstream repository owner (or an attacker who compromises it), enabling a supply-chain attack. Affected references: 'actions/cache@v5' (Cache Flutter step) and 'actions/cache@v5' (Cache pub dependencies step).

Locations:

- `action.yaml:107`
- `action.yaml:113`

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

**Fixes applied:** script-injection, unpinned-uses, github-env-injection, static-inline-injection

**Notes:**

Fixed all findings in action.yaml and setup.sh:

1. script-injection / static-inline-injection (action.yaml): Moved all ${{ inputs.* }} expressions in 'Set action inputs' step and all ${{ steps.flutter-action.outputs.* }} expressions in 'Run setup script' step into env: blocks. Shell script now references safe environment variable names with proper double-quoting. The previously unquoted ${{ inputs.channel }} and ${{ steps.flutter-action.outputs.CHANNEL }} are now safely passed as "$INPUT_CHANNEL" and "$FLUTTER_ACTION_CHANNEL" respectively.

2. unpinned-uses (action.yaml): Pinned both actions/cache@v5 references to full commit SHA actions/cache@caa296126883cff596d87d8935842f9db880ef25 # v5.

3. github-env-injection (setup.sh): Added sanitize_value() helper using printf '%s' | tr -d '\n\r'. Applied to all values written to $GITHUB_OUTPUT (7 values), $GITHUB_ENV (FLUTTER_ROOT and PUB_CACHE), and $GITHUB_PATH (3 path entries) to prevent newline injection attacks.

