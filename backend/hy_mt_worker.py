"""
HY-MT worker for Genkit — no HTTP port.
Reads JSON lines from stdin, writes JSON lines to stdout.
Signals readiness on stderr with HY_MT_READY.
"""

import json
import sys

from hy_mt_service import load_model, translate_text

load_model()
sys.stderr.write("HY_MT_READY\n")
sys.stderr.flush()

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        req = json.loads(line)
        translation = translate_text(
            req.get("text", ""),
            req.get("source_lang", "en"),
            req.get("target_lang", "es"),
        )
        print(json.dumps({"translation": translation}), flush=True)
    except Exception as exc:
        print(json.dumps({"error": str(exc)}), flush=True)
