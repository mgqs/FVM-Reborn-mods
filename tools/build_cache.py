"""Content-based incremental build steps inside the existing build directory."""

from __future__ import annotations

from collections.abc import Callable, Iterable
import hashlib
import json
import os
from pathlib import Path
import tempfile


def file_hash(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def build_if_changed(output: Path, inputs: Iterable[Path], settings: dict,
                     action: Callable[[], None], *, stamp: Path | None = None) -> bool:
    """Reuse only when inputs, settings AND output contents match a successful run.

    Missing/corrupt stamps, interrupted builds and externally replaced outputs
    all rebuild. A failed action never records a successful cache entry.
    """
    stamp = stamp or output.with_name(output.name + ".build.json")
    fingerprint = {
        "version": 1,
        "inputs": {str(path): file_hash(path) for path in sorted(set(inputs))},
        "settings": settings,
    }
    try:
        previous = json.loads(stamp.read_text(encoding="utf-8"))
        if (previous["fingerprint"] == fingerprint and output.is_file()
                and previous["output"] == file_hash(output)
                and previous["mode"] == output.stat().st_mode):
            return False
    except (OSError, ValueError, KeyError, TypeError):
        pass

    output.parent.mkdir(parents=True, exist_ok=True)
    action()
    record = {"fingerprint": fingerprint, "output": file_hash(output), "mode": output.stat().st_mode}
    # Commit the stamp only after the build has completed successfully.
    stamp.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=stamp.parent,
                                         prefix=stamp.name + ".", delete=False) as stream:
            temporary = Path(stream.name)
            json.dump(record, stream, ensure_ascii=False, sort_keys=True)
            stream.write("\n")
        os.replace(temporary, stamp)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    return True
