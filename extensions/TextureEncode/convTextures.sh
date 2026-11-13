#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
tools_dir="${FVM_TEXTURE_TOOLS_DIR:-$script_dir/../../.macos-build/texture-tools}"
if [[ "$(uname -s)" != "Darwin" ]]; then
    tools_dir="$script_dir"
fi
read -r -a custom_options <<< "${CustomOptions:-}"

case "${ToolType:-}" in
    ASTC)
        tool_path="$tools_dir/astcenc"
        suffix=astc
        arguments=(-cl "${InputFile:?Missing InputFile}" "${OutputFile:?Missing OutputFile}.astc" "${custom_options[@]}")
        ;;
    BCN)
        tool_path="$tools_dir/bc7enc"
        suffix=dds
        arguments=(-g "${custom_options[@]}" "${InputFile:?Missing InputFile}" "${OutputFile:?Missing OutputFile}.dds")
        ;;
    *)
        echo "Unsupported or missing ToolType: ${ToolType:-}" >&2
        exit 1
        ;;
esac

if [[ ! -x "$tool_path" ]]; then
    echo "Missing signed texture encoder. Run: python3 tools/build_macos.py --native-only" >&2
    exit 1
fi
"$tool_path" "${arguments[@]}"
mv -f "$OutputFile.$suffix" "$OutputFile"
