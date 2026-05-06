#!/usr/bin/env bash
set -e

echo "==> 1) Create venv"
python3 -m venv .venv
source .venv/bin/activate

echo "==> 2) Install python deps"
pip install -U pip
if [ -f requirements.txt ]; then
  pip install -r requirements.txt
fi

echo "==> 3) Install Cursor extensions (if cursor cli exists)"
if command -v cursor >/dev/null 2>&1 && [ -f extensions.txt ]; then
  xargs -n 1 cursor --install-extension < extensions.txt || true
fi

echo "==> 4) Download data"
if [ -f scripts/download_data.sh ]; then
  bash scripts/download_data.sh
fi

echo "Done."
