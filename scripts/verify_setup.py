#!/usr/bin/env python3
"""Clone 本仓库并 bootstrap 后，用于快速自检环境与常用依赖。"""

from __future__ import annotations

import sys


def main() -> int:
    print("Python:", sys.version.split()[0])

    required = (
        "joblib",
        "scipy",
        "rliable",
        "jsonargparse",
        "docstring_parser",
    )
    for name in required:
        __import__(name)
        print(f"  ok: {name}")

    import torch

    print(f"  ok: torch {torch.__version__}")
    print(f"  cuda available: {torch.cuda.is_available()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
