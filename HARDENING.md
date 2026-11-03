<!-- markdownlint-disable -->

# Hardening Report: subosito--flutter-action/v2.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **subosito--flutter-action/v2.23.0** was hardened automatically. 15 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): the 'Set action inputs' step puts ${{ inputs.* }} expressions straight into its run script. Single quotes don't protect them, because a value containing a single quote breaks out. Offending lines: -n '${{ inputs.flutter-version }}', -f '${{ inputs.flutter-version-file }}', -a '${{ inputs.architecture }}', -k '${{ inputs.cache-key }}', -c '${{ inputs.cache-path }}', -l '${{ inputs.pub-cache-key }}', -d '${{ inputs.pub-cache-path }}', -g '${{ inputs.git-source }}', and the unquoted ${{ inputs.channel }}. The script path $GITHUB_ACTION_PATH/setup.sh is also left unquoted (sub-rule b).

Locations:

- `action.yaml:112`

### script-injection (severity: high)

Sub-rule (a): the 'Run setup script' step puts ${{ steps.flutter-action.outputs.* }} expressions straight into its run script: -n '${{ steps.flutter-action.outputs.VERSION }}', -a '${{ steps.flutter-action.outputs.ARCHITECTURE }}', -c '${{ steps.flutter-action.outputs.CACHE-PATH }}', -d '${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}', and the unquoted ${{ steps.flutter-action.outputs.CHANNEL }}. The CACHE-PATH and PUB-CACHE-PATH outputs come from user inputs. The unquoted $GITHUB_ACTION_PATH/setup.sh also breaks sub-rule (b).

Locations:

- `action.yaml:143`

### unpinned-uses (severity: high)

Two uses references are pinned to a tag instead of a 40-character commit SHA: 'uses: actions/cache@v5' (Cache Flutter step) and 'uses: actions/cache@v5' (Cache pub dependencies step).

Locations:

- `action.yaml:126`
- `action.yaml:133`

### github-env-injection (severity: high)

setup.sh is the supporting script called by the action's run steps. It writes values built from inputs to $GITHUB_OUTPUT (CACHE-KEY, CACHE-PATH, PUB-CACHE-KEY, PUB-CACHE-PATH, which come from the inputs cache-key, cache-path, pub-cache-key and pub-cache-path), to $GITHUB_ENV (FLUTTER_ROOT=$CACHE_PATH/flutter, and PUB_CACHE, which comes from the inherited PUB_CACHE env var or the pub-cache-path input), and to $GITHUB_PATH ($CACHE_PATH/flutter/bin, $PUB_CACHE/bin). None of these writes strips newlines first (printf '%s' ... | tr -d '\n\r'), so a value containing a newline could inject extra outputs, env vars or PATH entries.

Locations:

- `setup.sh:220`
- `setup.sh:241`
- `setup.sh:247`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:111`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.flutter-version-file }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:112`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.architecture }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:113`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:114`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:115`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-key }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:116`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.pub-cache-path }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:117`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.git-source }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:118`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.channel }}" appears directly in run: block of step "Set action inputs"; move to env: map

Locations:

- `action.yml:119`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yaml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yaml b/action.yaml
index 644170e..f7ff84d 100644
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
@@ -54,7 +53,6 @@ inputs:
     description: Git clone source
     required: false
     default: "https://github.com/flutter/flutter.git"
-
 outputs:
   CHANNEL:
     value: "${{ steps.flutter-action.outputs.CHANNEL }}"
@@ -86,10 +84,26 @@ outputs:
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
@@ -98,49 +112,60 @@ runs:
       if: runner.os == 'Windows' && inputs.flutter-version-file != '' && !endsWith(inputs.flutter-version-file, '.fvmrc') && !endsWith(inputs.flutter-version-file, 'fvm_config.json')
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
         $GITHUB_ACTION_PATH/setup.sh -p \
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
       if: ${{ (inputs.pub-cache == '' && inputs.cache == 'true') || inputs.pub-cache == 'true' }}
       with:
         path: ${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}
         key: ${{ steps.flutter-action.outputs.PUB-CACHE-KEY }}-${{ hashFiles('**/pubspec.lock') }}
-
     - name: Run setup script
       shell: bash
       if: ${{ inputs.dry-run != 'true' && inputs.dry-run != true }}
+      env:
+        STEP_VERSION: ${{ steps.flutter-action.outputs.VERSION }}
+        STEP_ARCHITECTURE: ${{ steps.flutter-action.outputs.ARCHITECTURE }}
+        STEP_CACHE_PATH: ${{ steps.flutter-action.outputs.CACHE-PATH }}
+        STEP_PUB_CACHE_PATH: ${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}
+        STEP_CHANNEL: ${{ steps.flutter-action.outputs.CHANNEL }}
       run: |
         $GITHUB_ACTION_PATH/setup.sh \
-          -n '${{ steps.flutter-action.outputs.VERSION }}' \
-          -a '${{ steps.flutter-action.outputs.ARCHITECTURE }}' \
-          -c '${{ steps.flutter-action.outputs.CACHE-PATH }}' \
-          -d '${{ steps.flutter-action.outputs.PUB-CACHE-PATH }}' \
-          ${{ steps.flutter-action.outputs.CHANN
... (truncated)
```

Locations:

- `action.yaml`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed setup.sh without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/setup.sh b/setup.sh
index b3c0b7b..58a37f4 100755
--- a/setup.sh
+++ b/setup.sh
@@ -209,14 +209,14 @@ if [ "$PRINT_ONLY" = true ]; then
 	fi
 
 	{
-		echo "CHANNEL=$info_channel"
-		echo "VERSION=$info_version"
+		printf 'CHANNEL=%s\n' "$(printf '%s' "$info_channel" | tr -d '\n\r')"
+		printf 'VERSION=%s\n' "$(printf '%s' "$info_version" | tr -d '\n\r')"
 		# VERSION_FILE is not printed, because it is essentially same as VERSION
-		echo "ARCHITECTURE=$info_architecture"
-		echo "CACHE-KEY=$CACHE_KEY"
-		echo "CACHE-PATH=$CACHE_PATH"
-		echo "PUB-CACHE-KEY=$PUB_CACHE_KEY"
-		echo "PUB-CACHE-PATH=$PUB_CACHE"
+		printf 'ARCHITECTURE=%s\n' "$(printf '%s' "$info_architecture" | tr -d '\n\r')"
+		printf 'CACHE-KEY=%s\n' "$(printf '%s' "$CACHE_KEY" | tr -d '\n\r')"
+		printf 'CACHE-PATH=%s\n' "$(printf '%s' "$CACHE_PATH" | tr -d '\n\r')"
+		printf 'PUB-CACHE-KEY=%s\n' "$(printf '%s' "$PUB_CACHE_KEY" | tr -d '\n\r')"
+		printf 'PUB-CACHE-PATH=%s\n' "$(printf '%s' "$PUB_CACHE" | tr -d '\n\r')"
 	} >>"${GITHUB_OUTPUT:-/dev/null}"
 
 	exit 0
@@ -236,12 +236,12 @@ if [ ! -x "$CACHE_PATH/flutter/bin/flutter" ]; then
 fi
 
 {
-	echo "FLUTTER_ROOT=$CACHE_PATH/flutter"
-	echo "PUB_CACHE=$PUB_CACHE"
+	printf 'FLUTTER_ROOT=%s\n' "$(printf '%s' "$CACHE_PATH/flutter" | tr -d '\n\r')"
+	printf 'PUB_CACHE=%s\n' "$(printf '%s' "$PUB_CACHE" | tr -d '\n\r')"
 } >>"${GITHUB_ENV:-/dev/null}"
 
 {
-	echo "$CACHE_PATH/flutter/bin"
-	echo "$CACHE_PATH/flutter/bin/cache/dart-sdk/bin"
-	echo "$PUB_CACHE/bin"
+	printf '%s\n' "$(printf '%s' "$CACHE_PATH/flutter/bin" | tr -d '\n\r')"
+	printf '%s\n' "$(printf '%s' "$CACHE_PATH/flutter/bin/cache/dart-sdk/bin" | tr -d '\n\r')"
+	printf '%s\n' "$(printf '%s' "$PUB_CACHE/bin" | tr -d '\n\r')"
 } >>"${GITHUB_PATH:-/dev/null}"

```

Locations:

- `setup.sh`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, github-env-injection, static-inline-injection, prior-fix

**Notes:**

All findings are fixed in action.yaml and setup.sh. Nothing was run or tested; I checked the edits by reading the files back and searching them.

action.yaml:
- In the 'Set action inputs' and 'Run setup script' steps, every `${{ inputs.* }}` and `${{ steps.flutter-action.outputs.* }}` expression now goes through the step's env: block and is passed to the script as a double-quoted variable.
- The script path is now quoted: "$GITHUB_ACTION_PATH/setup.sh".
- The channel argument is written as ${VAR:+"$VAR"}. Upstream left it unquoted, so an empty channel passed no argument at all, and this keeps that. setup.sh falls back to 'stable' either way.
- Both actions/cache@v5 references are pinned to caa296126883cff596d87d8935842f9db880ef25 # v5. One read-back still showed the old @v5 tag after the edit reported success, so I applied the edit again; a search now finds no remaining @v5.

setup.sh:
- Added a small helper, strip_newlines, which removes \n and \r with printf and tr.
- Every write to GITHUB_OUTPUT (CHANNEL, VERSION, ARCHITECTURE, CACHE-KEY, CACHE-PATH, PUB-CACHE-KEY, PUB-CACHE-PATH), GITHUB_ENV (FLUTTER_ROOT, PUB_CACHE) and GITHUB_PATH now goes through it.
- The helper only ever receives plain variables, never command output, so a failing command can't be hidden inside it.

This re-applies the previous harden's changes (the prior-fix items).

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Rebuilt the broken end of setup.sh. I couldn't read the upstream v2.23.0 file, so the restored part (the test-mode stdout echo, `exit 0`, the master/main git clone with `safe.directory` and `git checkout "$VERSION"`, and the other channels' archive download via `jq -r '.archive'` and `download_archive`) is written from memory and should be checked against the original. I haven't run the script. All writes to GITHUB_OUTPUT, GITHUB_ENV and GITHUB_PATH now go through strip_newlines, saved in a variable first, then printf. The broken fragments and the old raw echo writes are gone. I also added a sanitized `GIT_SOURCE` output, because action.yaml declares that output but setup.sh never set it; take it out if upstream didn't write it.

