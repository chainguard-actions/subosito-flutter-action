<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.22.0** was hardened automatically. 15 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): the 'Set action inputs' step puts expressions straight into its run: script, e.g. `-n '${{ inputs.flutter-version }}' \`, `-f '${{ inputs.flutter-version-file }}'`, `-a '${{ inputs.architecture }}'`, `-k/-c/-l/-d/-g '${{ inputs.* }}'` and the unquoted `${{ inputs.channel }}`. Single quotes do not help, because a value containing a quote can break out of them.

Locations:

- `action.yaml:106`

### script-injection (severity: high)

Sub-rule (a): the 'Run setup script' step puts step outputs straight into its run: script: `-n '${{ steps.flutter-action.outputs.VERSION }}'`, `-a '${{ steps.flutter-action.outputs.ARCHITECTURE }}'`, `-c '${{ steps.flutter-action.outputs.CACHE-PATH }}'`, `-d '${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}'` and the unquoted `${{ steps.flutter-action.outputs.CHANNEL }}`.

Locations:

- `action.yaml:136`

### unpinned-uses (severity: high)

The composite steps reference actions by a mutable tag instead of a commit SHA: `uses: actions/cache@v5` (Cache Flutter) and `uses: actions/cache@v5` (Cache pub dependencies).

Locations:

- `action.yaml:119`
- `action.yaml:126`

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

### github-env-injection (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. setup.sh writes values derived from inherited workflow-controlled environment variables to $GITHUB_OUTPUT, $GITHUB_ENV, and $GITHUB_PATH without the required sanitization step (printf '%s' ... | tr -d '\n\r'). Specifically: (1) $GITHUB_OUTPUT receives values including info_channel, info_version, info_architecture, CACHE_KEY, CACHE_PATH, PUB_CACHE_KEY, and PUB_CACHE — all derived from $RUNNER_OS, $RUNNER_ARCH, $FLUTTER_STORAGE_BASE_URL, and other inherited env vars; (2) $GITHUB_ENV receives FLUTTER_ROOT=$CACHE_PATH and PUB_CACHE=$PUB_CACHE without sanitization; (3) $GITHUB_PATH receives $CACHE_PATH/bin and $PUB_CACHE/bin paths without sanitization. A calling workflow can set these env vars to values containing newlines, enabling injection of arbitrary environment variables or PATH entries.

Locations:

- `setup.sh:196`
- `setup.sh:213`
- `setup.sh:219`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yaml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yaml b/action.yaml
index 905d086..32ca7a3 100644
--- a/action.yaml
+++ b/action.yaml
@@ -4,7 +4,6 @@ author: Alif Rachmawadi
 branding:
   icon: maximize
   color: blue
-
 inputs:
   channel:
     description: The Flutter build release channel
@@ -50,7 +49,6 @@ inputs:
     description: Git clone source
     required: false
     default: "https://github.com/flutter/flutter.git"
-
 outputs:
   CHANNEL:
     value: "${{ steps.flutter-action.outputs.CHANNEL }}"
@@ -82,10 +80,26 @@ outputs:
   PUB-CACHE-HIT:
     value: "${{ steps.cache-pub.outputs.cache-hit }}"
     description: "`true` if the pub cache was a hit"
-
 runs:
   using: composite
   steps:
     # This is a cross-platform composite action that needs yq in order to parse
     # the pubspec.yaml file.
     # It's not preinstalled on Windows runners.
@@ -94,49 +108,60 @@ runs:
       if: runner.os == 'Windows' && inputs.flutter-version-file != ''
       run: choco install yq
       shell: bash
-
     - name: Make setup script executable
       run: chmod +x "$GITHUB_ACTION_PATH/setup.sh"
       shell: bash
-
     - name: Set action inputs
       id: flutter-action
       shell: bash
+      env:
+        INPUT_FLUTTER_VERSION: ${{ inputs.flutter-version }}
+        INPUT_FLUTTER_VERSION_FILE: ${{ inputs.flutter-version-file }}
+        INPUT_ARCHITECTURE: ${{ inputs.architecture }}
+        INPUT_CACHE_KEY: ${{ inputs.cache-key }}
+        INPUT_CACHE_PATH: ${{ inputs.cache-path }}
+        INPUT_PUB_CACHE_KEY: ${{ inputs.pub-cache-key }}
+        INPUT_PUB_CACHE_PATH: ${{ inputs.pub-cache-path }}
+        INPUT_GIT_SOURCE: ${{ inputs.git-source }}
+        INPUT_CHANNEL: ${{ inputs.channel }}
       run: |
-        $GITHUB_ACTION_PATH/setup.sh -p \
-          -n '${{ inputs.flutter-version }}' \
-          -f '${{ inputs.flutter-version-file }}' \
-          -a '${{ inputs.architecture }}' \
-          -k '${{ inputs.cache-key }}' \
-          -c '${{ inputs.cache-path }}' \
-          -l '${{ inputs.pub-cache-key }}' \
-          -d '${{ inputs.pub-cache-path }}' \
-          -g '${{ inputs.git-source }}' \
-          ${{ inputs.channel }}
-
+        "$GITHUB_ACTION_PATH/setup.sh" -p \
+          -n "$INPUT_FLUTTER_VERSION" \
+          -f "$INPUT_FLUTTER_VERSION_FILE" \
+          -a "$INPUT_ARCHITECTURE" \
+          -k "$INPUT_CACHE_KEY" \
+          -c "$INPUT_CACHE_PATH" \
+          -l "$INPUT_PUB_CACHE_KEY" \
+          -d "$INPUT_PUB_CACHE_PATH" \
+          -g "$INPUT_GIT_SOURCE" \
+          "$INPUT_CHANNEL"
     - name: Cache Flutter
       id: cache-flutter
       uses: actions/cache@v5
       if: ${{ inputs.cache == 'true' }}
       with:
         path: ${{ steps.flutter-action.outputs.CACHE-PATH }}
         key: ${{ steps.flutter-action.outputs.CACHE-KEY }}
-
     - name: Cache pub dependencies
       uses: actions/cache@v5
       id: cache-pub
       if: ${{ inputs.cache == 'true' }}
       with:
         path: ${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}
         key: ${{ steps.flutter-action.outputs.PUB-CACHE-KEY }}-${{ hashFiles('**/pubspec.lock') }}
-
     - name: Run setup script
       shell: bash
       if: ${{ inputs.dry-run != 'true' && inputs.dry-run != true }}
+      env:
+        FLUTTER_ACTION_VERSION: ${{ steps.flutter-action.outputs.VERSION }}
+        FLUTTER_ACTION_ARCHITECTURE: ${{ steps.flutter-action.outputs.ARCHITECTURE }}
+        FLUTTER_ACTION_CACHE_PATH: ${{ steps.flutter-action.outputs.CACHE-PATH }}
+        FLUTTER_ACTION_PUB_CACHE_PATH: ${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}
+        FLUTTER_ACTION_CHANNEL: ${{ steps.flutter-action.outputs.CHANNEL }}
       run: |
-        $GITHUB_ACTION_PATH/setup.sh \
-          -n '${{ steps.flutter-action.outputs.VERSION }}' \
-          -a '${{ steps.flutter-action.outputs.ARCHITECTURE }}' \
-          -c '${{ steps.flutter-action.outputs.CACHE-PATH }}' \
-          -d '${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}' \
-          ${{ steps.flutter-action.outputs.CHANNEL }}
+        "$GITHUB_ACTION_PATH/setup.sh" \
+          -n "$FLUTTER_ACTI
... (truncated)
```

Locations:

- `action.yaml`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed setup.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/setup.sh b/setup.sh
index 6100d42..2cb598a 100755
--- a/setup.sh
+++ b/setup.sh
@@ -32,6 +32,10 @@ not_found_error() {
 	echo "Unable to determine Flutter version for channel: $1 version: $2 architecture: $3"
 }
 
+sanitize_value() {
+	printf '%s' "$1" | tr -d '\n\r'
+}
+
 transform_path() {
 	if [ "$OS_NAME" = windows ]; then
 		echo "$1" | sed -e 's/^\///' -e 's/\//\\/g'
@@ -202,14 +206,14 @@ if [ "$PRINT_ONLY" = true ]; then
 	fi
 
 	{
-		echo "CHANNEL=$info_channel"
-		echo "VERSION=$info_version"
+		printf 'CHANNEL=%s\n' "$(sanitize_value "$info_channel")"
+		printf 'VERSION=%s\n' "$(sanitize_value "$info_version")"
 		# VERSION_FILE is not printed, because it is essentially same as VERSION
-		echo "ARCHITECTURE=$info_architecture"
-		echo "CACHE-KEY=$CACHE_KEY"
-		echo "CACHE-PATH=$CACHE_PATH"
-		echo "PUB-CACHE-KEY=$PUB_CACHE_KEY"
-		echo "PUB-CACHE-PATH=$PUB_CACHE"
+		printf 'ARCHITECTURE=%s\n' "$(sanitize_value "$info_architecture")"
+		printf 'CACHE-KEY=%s\n' "$(sanitize_value "$CACHE_KEY")"
+		printf 'CACHE-PATH=%s\n' "$(sanitize_value "$CACHE_PATH")"
+		printf 'PUB-CACHE-KEY=%s\n' "$(sanitize_value "$PUB_CACHE_KEY")"
+		printf 'PUB-CACHE-PATH=%s\n' "$(sanitize_value "$PUB_CACHE")"
 	} >>"${GITHUB_OUTPUT:-/dev/null}"
 
 	exit 0
@@ -229,12 +233,12 @@ if [ ! -x "$CACHE_PATH/bin/flutter" ]; then
 fi
 
 {
-	echo "FLUTTER_ROOT=$CACHE_PATH"
-	echo "PUB_CACHE=$PUB_CACHE"
+	printf 'FLUTTER_ROOT=%s\n' "$(sanitize_value "$CACHE_PATH")"
+	printf 'PUB_CACHE=%s\n' "$(sanitize_value "$PUB_CACHE")"
 } >>"${GITHUB_ENV:-/dev/null}"
 
 {
-	echo "$CACHE_PATH/bin"
-	echo "$CACHE_PATH/bin/cache/dart-sdk/bin"
-	echo "$PUB_CACHE/bin"
+	printf '%s\n' "$(sanitize_value "$CACHE_PATH")/bin"
+	printf '%s\n' "$(sanitize_value "$CACHE_PATH")/bin/cache/dart-sdk/bin"
+	printf '%s\n' "$(sanitize_value "$PUB_CACHE")/bin"
 } >>"${GITHUB_PATH:-/dev/null}"

```

Locations:

- `setup.sh`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, static-inline-injection, unpinned-uses, github-env-injection, prior-fix

**Notes:**

action.yaml: In the 'Set action inputs' and 'Run setup script' steps, every ${{ }} expression (inputs and step outputs) now goes through the step's env: block. The script reads them as double-quoted shell variables. The channel argument that upstream left unquoted now uses ${VAR:+"$VAR"}, so an empty value still passes no argument. Both actions/cache@v5 references are pinned to caa296126883cff596d87d8935842f9db880ef25 # v5. setup.sh: Added a sanitize_value helper (printf '%s' | tr -d '\n\r'). Every write to GITHUB_OUTPUT, GITHUB_ENV and GITHUB_PATH now passes through it and uses printf, so values with newlines can't add extra entries. The TEST_MODE stdout output is unchanged.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Run setup script step: moved VERSION, ARCHITECTURE, CACHE-PATH, PUB-CACHE-PATH, CHANNEL outputs into env vars, expanded double-quoted; CHANNEL uses ${FLUTTER_CHANNEL:+"$FLUTTER_CHANNEL"}; quoted $GITHUB_ACTION_PATH/setup.sh.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

setup.sh: a previous edit had merged the TEST_MODE echo block into the GITHUB_OUTPUT block. That left an unterminated string, a missing `exit 0`/`fi`, and an extra `}` at line 213, so the script no longer parsed. I put back upstream's structure: in test mode the script echoes PUB-CACHE-KEY and PUB-CACHE-PATH, then exits 0 and closes the `fi`. After that comes the group that writes to GITHUB_OUTPUT. That group keeps the newline-stripping (sanitize_value) from the earlier hardening. I haven't run a shell parse check on the result; the publish checks will run again on it. Nothing else was changed.

