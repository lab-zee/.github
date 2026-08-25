#!/usr/bin/env bash

set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage: sync-org-standards.sh --write|--check

  --write  Install or update managed Lab Z Cursor rules and skills.
  --check  Fail if managed Lab Z Cursor rules or skills have drifted.

Set LABZ_STANDARDS_REF to a reviewed branch, tag, or commit SHA. Default: main.
EOF
}

die() {
  printf 'sync-org-standards: %s\n' "$*" >&2
  exit 1
}

[[ $# -eq 1 ]] || {
  usage >&2
  exit 2
}

case "$1" in
  --write|--check)
    mode="$1"
    ;;
  --help|-h)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

command -v curl >/dev/null 2>&1 || die "curl is required"
command -v cmp >/dev/null 2>&1 || die "cmp is required"
command -v install >/dev/null 2>&1 || die "install is required"

ref="${LABZ_STANDARDS_REF:-main}"
case "$ref" in
  ""|*[^A-Za-z0-9._/-]*|*..*)
    die "LABZ_STANDARDS_REF contains unsupported characters"
    ;;
esac

readonly canonical_base="https://raw.githubusercontent.com/lab-zee/.github/${ref}/templates/cursor"
readonly managed_files=(
  "rules/labz-core-engineering.mdc"
  "rules/labz-plain-language.mdc"
  "rules/labz-testing-verification.mdc"
  "skills/labz-deferred-bug-triage/SKILL.md"
  "skills/labz-pr-readiness/SKILL.md"
)

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(CDPATH= cd -- "${script_dir}/.." && pwd -P)"
cursor_root="${repo_root}/.cursor"
rules_dir="${cursor_root}/rules"
skills_dir="${cursor_root}/skills"

temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/labz-standards.XXXXXX")" ||
  die "could not create temporary directory"
cleanup() {
  rm -rf -- "$temp_dir"
}
trap cleanup EXIT
trap 'exit 130' HUP INT TERM

for relative_path in "${managed_files[@]}"; do
  download_path="${temp_dir}/${relative_path}"
  mkdir -p -- "$(dirname -- "$download_path")"
  url="${canonical_base}/${relative_path}"

  if ! curl \
    --fail \
    --show-error \
    --silent \
    --location \
    --retry 3 \
    --connect-timeout 10 \
    --max-time 60 \
    --output "$download_path" \
    "$url"; then
    die "failed to download ${url}"
  fi

  [[ -s "$download_path" ]] ||
    die "downloaded an empty managed file: ${relative_path}"
  IFS= read -r first_line <"$download_path" || true
  [[ "$first_line" == "---" ]] ||
    die "managed file is missing YAML frontmatter: ${relative_path}"
done

is_expected_rule() {
  case "$1" in
    labz-core-engineering.mdc|labz-plain-language.mdc|labz-testing-verification.mdc)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_expected_skill() {
  case "$1" in
    labz-deferred-bug-triage|labz-pr-readiness)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

mark_drift() {
  if [[ "$mode" == "--check" ]]; then
    printf '%s: %s\n' "$1" "$2" >&2
  fi
  drift=1
}

drift=0
for directory in "$cursor_root" "$rules_dir" "$skills_dir"; do
  if [[ -L "$directory" ]]; then
    mark_drift "unsafe managed directory symlink" "${directory#${repo_root}/}"
  fi
done

for relative_path in "${managed_files[@]}"; do
  expected="${temp_dir}/${relative_path}"
  destination="${cursor_root}/${relative_path}"

  if [[ -L "$destination" ]]; then
    mark_drift "unsafe managed symlink" "${destination#${repo_root}/}"
  elif [[ ! -f "$destination" ]]; then
    mark_drift "missing managed file" "${destination#${repo_root}/}"
  elif ! cmp -s -- "$expected" "$destination"; then
    mark_drift "changed managed file" "${destination#${repo_root}/}"
  fi
done

for existing in "${rules_dir}"/labz-*.mdc; do
  [[ -e "$existing" || -L "$existing" ]] || continue
  if ! is_expected_rule "$(basename -- "$existing")"; then
    mark_drift "stale managed rule" "${existing#${repo_root}/}"
  fi
done

for existing in "${skills_dir}"/labz-*; do
  [[ -e "$existing" || -L "$existing" ]] || continue
  if ! is_expected_skill "$(basename -- "$existing")"; then
    mark_drift "stale managed skill" "${existing#${repo_root}/}"
  fi
done

if [[ "$mode" == "--check" ]]; then
  [[ "$drift" -eq 0 ]] ||
    die "managed Cursor standards are out of date; run with --write"
  printf 'Managed Cursor standards are current at %s.\n' "$ref"
  exit 0
fi

for directory in "$cursor_root" "$rules_dir" "$skills_dir"; do
  [[ ! -L "$directory" ]] ||
    die "refusing to write through symlink: ${directory#${repo_root}/}"
done

mkdir -p -- "$rules_dir" "$skills_dir"

for relative_path in "${managed_files[@]}"; do
  source_path="${temp_dir}/${relative_path}"
  destination="${cursor_root}/${relative_path}"
  destination_dir="$(dirname -- "$destination")"
  [[ ! -L "$destination" ]] ||
    die "refusing to replace managed symlink: ${destination#${repo_root}/}"
  [[ ! -L "$destination_dir" ]] ||
    die "refusing to write through symlink: ${destination_dir#${repo_root}/}"
  mkdir -p -- "$destination_dir"
  install -m 0644 "$source_path" "$destination"
done

for existing in "${rules_dir}"/labz-*.mdc; do
  [[ -e "$existing" || -L "$existing" ]] || continue
  is_expected_rule "$(basename -- "$existing")" || rm -f -- "$existing"
done

for existing in "${skills_dir}"/labz-*; do
  [[ -e "$existing" || -L "$existing" ]] || continue
  is_expected_skill "$(basename -- "$existing")" || rm -rf -- "$existing"
done

printf 'Updated managed Cursor standards to %s.\n' "$ref"
