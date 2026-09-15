#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
app_source="$project_root/WishTemple"
manifest="$app_source/Resources/PrivacyInfo.xcprivacy"

if ! command -v rg >/dev/null 2>&1; then
    echo "error: ripgrep (rg) is required to run this check" >&2
    exit 1
fi

if [ ! -f "$manifest" ]; then
    echo "error: missing WishTemple/Resources/PrivacyInfo.xcprivacy" >&2
    exit 1
fi

plutil -lint "$manifest"

check_category() {
    category=$1
    pattern=$2

    if rg --glob '*.swift' --quiet "$pattern" "$app_source"; then
        if ! rg --fixed-strings --quiet "<string>$category</string>" "$manifest"; then
            echo "error: source may use $category, but the manifest does not declare it" >&2
            rg --glob '*.swift' --line-number "$pattern" "$app_source" >&2
            exit 1
        fi
    fi
}

check_category \
    NSPrivacyAccessedAPICategoryUserDefaults \
    '(^|[^[:alnum:]_])UserDefaults([^[:alnum:]_]|$)'
check_category \
    NSPrivacyAccessedAPICategoryFileTimestamp \
    'creationDate|modificationDate|fileModificationDate|contentModificationDateKey|creationDateKey|(^|[^[:alnum:]_])(f?l?stat|fstatat|getattrlist|fgetattrlist|getattrlistat|getattrlistbulk)[[:space:]]*\('
check_category \
    NSPrivacyAccessedAPICategorySystemBootTime \
    'systemUptime|mach_absolute_time[[:space:]]*\('
check_category \
    NSPrivacyAccessedAPICategoryDiskSpace \
    'volumeAvailableCapacity(Key|ForImportantUsageKey|ForOpportunisticUsageKey)?|volumeTotalCapacityKey|systemFreeSize|systemSize|(^|[^[:alnum:]_])(f?statfs|f?statvfs)[[:space:]]*\('
check_category \
    NSPrivacyAccessedAPICategoryActiveKeyboards \
    'activeInputModes'

echo "Privacy baseline check passed."
