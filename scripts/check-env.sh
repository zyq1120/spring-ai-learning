#!/usr/bin/env bash
# 第 1 周环境自检：逐项打印版本，缺失的会明确标出。
# 用法：bash scripts/check-env.sh
set -u

check() {
  local name="$1"; shift
  if command -v "$1" >/dev/null 2>&1; then
    printf '[OK]   %-8s %s\n' "$name" "$($* 2>&1 | head -1)"
  else
    printf '[缺失] %-8s 未安装或不在 PATH 中\n' "$name"
  fi
}

check "JDK"    java -version
check "Maven"  mvn -version
check "Git"    git --version
check "Docker" docker --version

echo
if [ -n "${AI_API_KEY:-}" ]; then
  echo "[OK]   AI_API_KEY 已在环境变量中设置（长度 ${#AI_API_KEY}，不显示内容）"
else
  echo "[未设置] AI_API_KEY 尚未设置：请参考 .env.example 配置后再启动项目"
fi
echo "AI_BASE_URL=${AI_BASE_URL:-（未设置，默认 https://api.openai.com）}"
echo "AI_MODEL=${AI_MODEL:-（未设置，默认 gpt-4o-mini）}"
