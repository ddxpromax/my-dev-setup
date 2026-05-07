#!/usr/bin/env bash
set -e

# 在新机器上用镜像自带 Python + PyTorch：  SKIP_VENV=1 ./bootstrap.sh
# 需要隔离环境（与本机 reproduce 完整 requirements）：./bootstrap.sh
SKIP_VENV="${SKIP_VENV:-0}"
# 指定要安装的依赖文件，例如 REQUIREMENTS_FILE=requirements.txt pip 全量
REQUIREMENTS_FILE="${REQUIREMENTS_FILE:-}"

if [[ "${SKIP_VENV}" == "1" ]]; then
	echo "==> 1) 使用系统 Python（未创建 .venv）；安装到当前 python3 环境"
	PIP_INSTALL=(python3 -m pip install)
else
	echo "==> 1) 创建虚拟环境 .venv"
	if [[ -d .venv ]] && [[ "${RECREATE_VENV}" == "1" ]]; then
		rm -rf .venv
	fi
	python3 -m venv .venv
	# shellcheck source=/dev/null
	source .venv/bin/activate
	PIP_INSTALL=(pip install)
	echo "==> 升级 pip（仅 venv 内）"
	pip install -U pip
fi

echo "==> 2) 安装 Python 依赖"
if [[ -z "${REQUIREMENTS_FILE}" ]]; then
	if [[ "${SKIP_VENV}" == "1" ]]; then
		REQUIREMENTS_FILE="requirements-extra.txt"
	else
		REQUIREMENTS_FILE="requirements.txt"
	fi
fi
if [[ -f "${REQUIREMENTS_FILE}" ]]; then
	"${PIP_INSTALL[@]}" -r "${REQUIREMENTS_FILE}"
else
	echo "    （未找到 ${REQUIREMENTS_FILE}，跳过）"
fi

echo "==> 3) 安装 Cursor 扩展（若已安装 cursor CLI）"
if command -v cursor >/dev/null 2>&1 && [[ -f extensions.txt ]]; then
	xargs -n 1 cursor --install-extension <extensions.txt || true
fi

echo "==> 4) 下载数据"
if [[ -f scripts/download_data.sh ]]; then
	bash scripts/download_data.sh
fi

echo "==> 5) 自检 Python"
if [[ -f scripts/verify_setup.py ]]; then
	if [[ "${SKIP_VENV}" == "1" ]]; then
		python3 scripts/verify_setup.py
	else
		python scripts/verify_setup.py
	fi
fi

echo "Done."
