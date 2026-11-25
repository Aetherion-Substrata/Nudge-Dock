#!/usr/bin/env bash
# release-scan.sh <dir>  -  hard stop for release files.
# Unpacks every file in <dir> (exe / 7z / zip layers) and fails (exit 1) if anything inside holds a personal
# absolute path of the build machine: X:\Users\<name>\...  (also X:/Users/<name>/ and the JSON-escaped form),
# as plain text or as UTF-16 text. The name itself is never printed: logs of a public repo are public.
# Run it on the folder holding the files BEFORE publishing; the release-guard workflow runs it again after.
set -u
DIR="${1:?usage: release-scan.sh <dir with the release files>}"
SEVENZ="${SEVENZ:-7z}"
# placeholder names that are not a person's folder
ALLOW='^(public|default|default user|all users|runneradmin|runner|user|users|username|user name|name|you|me|yourname|your name|your-name|your_name|xxx+|foo|bar|example|test|admin|administrator|appveyor|vagrant|circleci|buildbot|%username%|\$\{?user(name)?\}?|<[^>]*>|\[[^]]*\]|\{[^}]*\}|\*+|\.+)$'
PAT_A='[A-Za-z]:[\\/]{1,2}Users[\\/]{1,2}[^\\/:*?"<>|[:cntrl:]]{1,40}[\\/]'
PAT_W='(?i)[A-Za-z]\x00:\x00(?:[\\/]\x00){1,2}U\x00s\x00e\x00r\x00s\x00(?:[\\/]\x00){1,2}(?:[^\\/:*?"<>|\x00-\x1f]\x00){1,40}[\\/]\x00'

# 1. unpack: the files handed in, then archives found inside, up to 4 layers deep
while IFS= read -r -d '' f; do mkdir -p "$f.unpacked"; "$SEVENZ" x -y -bd -o"$f.unpacked" "$f" >/dev/null 2>&1 || true; done \
  < <(find "$DIR" -maxdepth 1 -type f -print0)
for layer in 2 3 4; do
  n=0
  while IFS= read -r -d '' f; do [ -e "$f.unpacked" ] && continue; n=1; mkdir -p "$f.unpacked"; "$SEVENZ" x -y -bd -o"$f.unpacked" "$f" >/dev/null 2>&1 || true; done \
    < <(find "$DIR" -type f \( -iname '*.7z' -o -iname '*.zip' -o -iname '*.nupkg' -o -iname '*.asar.gz' \) -print0)
  [ "$n" = 0 ] && break
done

# 2. scan every file, both text forms
bad=0; files=0
while IFS= read -r -d '' f; do
  files=$((files + 1))
  names=$( { LC_ALL=C grep -a -o -i -E "$PAT_A" "$f" 2>/dev/null; LC_ALL=C grep -a -o -P "$PAT_W" "$f" 2>/dev/null | tr -d '\000'; } \
    | sed -E 's/^.*[Uu][Ss][Ee][Rr][Ss][\\/]+([^\\/]+)[\\/]$/\1/' | tr 'A-Z' 'a-z' | sort -u)
  [ -z "$names" ] && continue
  while IFS= read -r nm; do
    [ -z "$nm" ] && continue
    if printf '%s' "$nm" | grep -q -i -E "$ALLOW"; then continue; fi
    bad=$((bad + 1))
    if [ -n "${SCAN_SHOW_NAMES:-}" ]; then shown="$nm"; else shown="<name hidden, ${#nm} characters>"; fi
    echo "LEAK  ${f#$DIR/}  holds a path under Users/$shown"
  done <<< "$names"
done < <(find "$DIR" -type f -print0)

echo "release-scan: $files files checked, $bad personal path hit(s)"
[ "$bad" = 0 ] || { echo "release-scan: STOP - do not publish these files"; exit 1; }
echo "release-scan: clean"
