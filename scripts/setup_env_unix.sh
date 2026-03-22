#!/usr/bin/env bash
set -euo pipefail

RUN_TESTS=${RUN_TESTS:-0}
START_SERVER=${START_SERVER:-0}
PYTHON_BIN=${PYTHON_BIN:-python3.11}

cd "$(dirname "$0")/../services/api"

echo "[1/7] 创建虚拟环境 .venv"
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  PYTHON_BIN=python3
fi
"$PYTHON_BIN" -m venv .venv

source .venv/bin/activate

echo "[2/7] 升级 pip"
python -m pip install --upgrade pip

echo "[3/7] 清理错误 jose 包"
python -m pip uninstall -y jose >/dev/null 2>&1 || true
python -m pip uninstall -y python-jose >/dev/null 2>&1 || true

echo "[4/7] 安装依赖"
python -m pip install -r requirements.txt
python -m pip install "python-jose[cryptography]==3.3.0"

echo "[5/7] 验证依赖"
python -m pip show python-jose >/dev/null

echo "[6/7] 可选测试"
if [[ "$RUN_TESTS" == "1" ]]; then
  PYTHONPATH=. python -m pytest -q
else
  echo "跳过测试（设置 RUN_TESTS=1 可启用）"
fi

echo "[7/7] 完成"
echo "启动：source services/api/.venv/bin/activate && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"

if [[ "$START_SERVER" == "1" ]]; then
  uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
fi
