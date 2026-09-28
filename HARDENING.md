<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.19.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.19.0** was hardened automatically. 13 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Set action inputs' run: block in action.yaml directly interpolates multiple ${{ inputs.* }} expressions into shell commands. Most critically, `${{ inputs.channel }}` is completely unquoted (no surrounding quotes), allowing an attacker to inject arbitrary shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.). The other inputs (`flutter-version`, `flutter-version-file`, `architecture`, `cache-key`, `cache-path`, `pub-cache-key`, `pub-cache-path`, `git-source`) are single-quoted, but single-quoting is still vulnerable to injection if the value contains a single-quote character. All ${{ ... }} expressions must be moved to env: variables and properly double-quoted in the shell script.

Locations:

- `action.yaml:93`

### script-injection (severity: high)

Rule (a): The 'Run setup script' run: block in action.yaml directly interpolates ${{ steps.flutter-action.outputs.* }} expressions into shell commands. Critically, `${{ steps.flutter-action.outputs.CHANNEL }}` is completely unquoted, allowing shell metacharacter injection. The other step outputs (`VERSION`, `ARCHITECTURE`, `CACHE-PATH`, `PUB-CACHE-PATH`) are single-quoted, which still allows single-quote injection. All ${{ ... }} expressions must be moved to env: variables and properly double-quoted.

Locations:

- `action.yaml:113`

### unpinned-uses (severity: high)

Two `uses:` references in action.yaml pin to the mutable tag `@v4` instead of a full 40-character commit SHA. Mutable tags can be moved to point to a different (potentially malicious) commit at any time, enabling supply-chain attacks. Affected references: `actions/cache@v4` (used in both the 'Cache Flutter' and 'Cache pub dependencies' steps). Each should be pinned to a full SHA, e.g. `actions/cache@1bd1e32a3bdc45362d1e726936510720a7c6158d # v4`.

Locations:

- `action.yaml:105`
- `action.yaml:110`

### github-env-injection (severity: high)

setup.sh writes user-controlled values to $GITHUB_ENV and $GITHUB_PATH without sanitization. The variables `CACHE_PATH` and `PUB_CACHE` are derived from action inputs (`inputs.cache-path`, `inputs.pub-cache-path`) passed via command-line arguments, and are written directly with `echo "FLUTTER_ROOT=$CACHE_PATH" >> "${GITHUB_ENV}"`, `echo "PUB_CACHE=$PUB_CACHE" >> "${GITHUB_ENV}"`, and `echo "$CACHE_PATH/bin" >> "${GITHUB_PATH}"` etc. without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). A newline character in these values could inject arbitrary environment variables or PATH entries, enabling privilege escalation in subsequent steps.

Locations:

- `setup.sh:214`
- `setup.sh:220`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:100`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version-file }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:101`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.architecture }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:102`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:103`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:104`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:105`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:106`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.git-source }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:107`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.channel }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:108`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, unpinned-uses, github-env-injection

**Notes:**

Fixed in action.yaml: (1) Moved all ${{ inputs.* }} expressions in 'Set action inputs' step to an env: block (INPUT_FLUTTER_VERSION, INPUT_FLUTTER_VERSION_FILE, INPUT_ARCHITECTURE, INPUT_CACHE_KEY, INPUT_CACHE_PATH, INPUT_PUB_CACHE_KEY, INPUT_PUB_CACHE_PATH, INPUT_GIT_SOURCE, INPUT_CHANNEL) and referenced them as double-quoted shell variables. (2) Moved all ${{ steps.flutter-action.outputs.* }} expressions in 'Run setup script' step to an env: block (STEP_VERSION, STEP_ARCHITECTURE, STEP_CACHE_PATH, STEP_PUB_CACHE_PATH, STEP_CHANNEL) and referenced them as double-quoted shell variables. (3) Pinned both actions/cache@v4 references to the full SHA actions/cache@0057852bfaa89a56745cba8c7296529d2fc39830 # v4. Fixed in setup.sh: (4) Added sanitization of CACHE_PATH and PUB_CACHE using printf + tr -d '\n\r' before writing to $GITHUB_ENV and $GITHUB_PATH to prevent newline injection attacks.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the PRINT_ONLY block in setup.sh (lines ~221-228) where seven user-controlled values were written to $GITHUB_OUTPUT using plain `echo` without sanitization. Added `printf '%s' "$VAR" | tr -d '\n\r'` sanitization for each value (info_channel, info_version, info_architecture, CACHE_KEY, CACHE_PATH, PUB_CACHE_KEY, PUB_CACHE) before writing them to GITHUB_OUTPUT using `printf` instead of `echo`. This prevents newline injection attacks that could smuggle additional key=value pairs into GITHUB_OUTPUT. The fix follows the same pattern already used for $GITHUB_ENV and $GITHUB_PATH writes at the end of the script.

