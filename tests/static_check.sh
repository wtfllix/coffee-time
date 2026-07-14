#!/usr/bin/env bash

# Coffee Time 的轻量静态检查。
# 这个脚本不解析 GDScript，也不能替代 Godot 的 headless 检查；它用于在引擎不可用时
# 尽早发现缺失入口、断开的 res:// 文件引用和脚本空格缩进。

set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

required_files=(
  "project.godot"
  "scenes/main.tscn"
  "scripts/core/main.gd"
  "scripts/cafe/cafe_prototype.gd"
  "scripts/ui/prototype_toolbar.gd"
  "scripts/ui/order_panel.gd"
  "scripts/orders/drink_definition.gd"
  "scripts/orders/order_controller.gd"
  "data/drinks/coffee.tres"
  "data/drinks/tea.tres"
  "tests/test_order_controller.gd"
  "tests/test_cafe_layout.gd"
  "AGENTS.md"
  "PLAN.md"
  "PROGRESS.md"
  "STRUCTURE.md"
  "DECISIONS.md"
  "ASSETS.md"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "[FAIL] Missing required file: $file" >&2
    exit 1
  fi
done

while IFS= read -r resource_path; do
  relative_path="${resource_path#res://}"
  if [[ ! -e "$relative_path" ]]; then
    echo "[FAIL] Broken Godot file reference: $resource_path" >&2
    exit 1
  fi
done < <(rg -o 'res://[A-Za-z0-9_./-]+' project.godot scenes scripts | cut -d: -f2- | sort -u)

if rg -n '^ +\S' scripts --glob '*.gd' >/tmp/coffee_time_space_indent.txt; then
  echo "[FAIL] GDScript uses leading spaces instead of tabs:" >&2
  cat /tmp/coffee_time_space_indent.txt >&2
  exit 1
fi

echo "[PASS] Required files, Godot file references, and GDScript indentation are consistent."
echo "[NOTE] Run 'godot --headless --path . --quit' for authoritative parsing."
