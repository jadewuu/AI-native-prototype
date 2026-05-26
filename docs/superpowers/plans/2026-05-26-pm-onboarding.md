# PM Zero-Friction Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** PM runs `git clone && bash setup.sh` in Claude Code → interactive setup → dev server running → can describe pages and AI generates valid code.

**Architecture:** `setup.sh` checks Node.js and outputs a setup prompt. Claude Code reads the prompt, guides PM through Q&A, acquires Design Tokens, generates CLAUDE.md + SKILL.md + .mcp.json from templates, scaffolds platform directory (web or mobile), and starts dev server.

**Tech Stack:** Bash (setup.sh), Next.js + shadcn/ui (web), Expo + heroui-native (mobile), Figma REST API (theme extraction)

**Spec:** `docs/superpowers/specs/2026-05-26-pm-onboarding-design.md`

---

### Task 1: Create `setup.sh`

**Files:**
- Create: `setup.sh`

- [ ] **Step 1: Write setup.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

# ── setup.sh ──
# Design System Starter — entry point for PM onboarding.
# Usage: bash setup.sh
# Prerequisites: Node.js >= 22

echo "==> Design System Starter Setup"
echo ""

# ── 1. Check Node.js ──
if ! command -v node &> /dev/null; then
  echo "❌ Node.js is not installed."
  echo "   Please install Node.js >= 22: https://nodejs.org/"
  exit 1
fi

NODE_MAJOR=$(node -v | sed 's/v//' | cut -d'.' -f1)
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo "❌ Node.js >= 22 required. Current: $(node -v)"
  echo "   Please upgrade: https://nodejs.org/"
  exit 1
fi

echo "✔ Node.js $(node -v) detected"
echo ""

# ── 2. Copy config template if not exists ──
if [ ! -f "project.config.sh" ]; then
  cp templates/project.config.sh project.config.sh
  echo "✔ Created project.config.sh (you can edit it beforehand next time)"
  echo ""
fi

# ── 3. Output setup prompt ──
echo "── Setup Prompt ──"
echo ""
cat << 'PROMPT'
## Setup Task

You are setting up a design-system-driven prototype project for a PM. Follow these steps in order.

### Step 1: Read Configuration

Read `project.config.sh`. The file contains these variables:

```bash
PROJECT_NAME=""
PLATFORM=""
THEME=""
FIGMA_URL=""
FIGMA_TOKEN=""
PRIMARY_COLOR=""
FONT_FAMILY=""
```

For each variable that is empty/default, you will ask the PM in the next step.

### Step 2: Interactive Q&A

Ask questions ONE AT A TIME. Wait for the answer before asking the next.

**Q1 — Project Name** (if PROJECT_NAME is empty):
用中文询问："请输入项目名称（例如：我的后台系统）："
Save the answer to PROJECT_NAME.

**Q2 — Platform** (if PLATFORM is empty):
用中文询问：
"选择平台类型：
1️⃣ Web — Next.js + shadcn/ui，浏览器预览（localhost:3090）
2️⃣ Mobile — Expo + heroui-native，浏览器预览（localhost:8081）
请输入 1 或 2："
- "1" → PLATFORM="web"
- "2" → PLATFORM="mobile"

**Q3 — Theme Source** (if THEME is empty):
用中文询问：
"选择主题来源：
1️⃣ 默认主题 — 蓝色系（#165dff）+ Nunito Sans 字体，无需额外配置
2️⃣ 从 Figma 提取 — 粘贴 Figma 文件链接，自动提取 Design Tokens
3️⃣ 自定义 — 手动输入主色和字体
请输入 1、2 或 3："
- "1" → THEME="default"
- "2" → THEME="figma"
- "3" → THEME="custom"

**Q3a — Figma details** (only if THEME="figma"):
询问 Figma 文件 URL 和 Personal Access Token（引导 PM 去 Figma → Settings → Personal Access Tokens 生成）。
Save to FIGMA_URL and FIGMA_TOKEN.

**Q3b — Custom tokens** (only if THEME="custom"):
询问主色（hex，如 #165dff）和字体（如 Nunito Sans）。
Save to PRIMARY_COLOR and FONT_FAMILY.

### Step 3: Acquire Design Tokens

**If THEME="default":**
Use these built-in tokens:
- Primary: #165dff
- Success: #00b42a / Success-light: #4cd263
- Danger: #f53f3f / Danger-mid: #f76560 / Danger-light: #f98981
- Warning: #f99057
- Text-primary: #1d2129 / Text-secondary: #4e5969 / Text-tertiary: #86909c / Text-disabled: #c9cdd4 / Text-white: #ffffff
- Background-page: #f2f3f5 / Background-surface: #ffffff
- Border-default: #e5e6eb / Border-emphasis: #c9cdd4
- Shadow-card: 6px 0px 20px 0px rgba(34,87,188,0.10)
- Font: Nunito Sans (weights 400, 600)
- Logo font: Wix Madefor Text Bold (weight 700)

**If THEME="figma":**
1. Parse FIGMA_URL to extract file_key
2. Call Figma REST API:
   - `GET https://api.figma.com/v1/files/${file_key}/styles` with header `X-Figma-Token: ${FIGMA_TOKEN}`
   - `GET https://api.figma.com/v1/files/${file_key}` with same token
3. Extract color styles → map to primary/success/danger/text/background/border roles
4. Extract text styles → map to font family/weights/sizes
5. Fill any unmapped tokens with default values from default theme above

**If THEME="custom":**
Use PRIMARY_COLOR value as primary. Auto-derive:
- Success: auto-pick a green that works with primary
- Danger: auto-pick a red
- Text/Border/Background: use defaults from default theme
Use FONT_FAMILY as the font.

### Step 4: Generate Files from Templates

Read each template, replace `{{PLACEHOLDER}}` with the actual value, write to root.

**4a: Generate SKILL.md from templates/SKILL.template.md**

Replacements:
- `{{PROJECT_NAME}}` → PROJECT_NAME value
- `{{PRIMARY_COLOR}}` → hex from tokens
- `{{FONT_FAMILY}}` → font family from tokens
- `{{COLOR_TOKENS}}` → formatted color token table:

```markdown
| 角色 | 色值 | 用途 |
|---|---|---|
| **主色** | `<primary>` | 按钮、链接、激活态 |
| **成功** | `<success>` | 成功 Toast、趋势下降 |
| **危险** | `<danger>` | 删除按钮、错误提示 |
| **文字-主** | `<text-primary>` | 标题、正文、表格内容 |
| **文字-次** | `<text-secondary>` | 辅助说明、图标、面包屑 |
| **文字-三** | `<text-tertiary>` | placeholder、坐标轴 |
| **文字-禁用** | `<text-disabled>` | 禁用态文字 |
| **背景-页** | `<bg-page>` | 页面背景、表头背景 |
| **背景-面** | `<bg-surface>` | 卡片、输入框 |
| **边框-默认** | `<border-default>` | 输入框边框、表格分隔线 |
| **边框-强调** | `<border-emphasis>` | 搜索框边框 |
| **阴影-卡片** | `<shadow-card>` | 数据指标卡片专用 |
```

- `{{FONT_TOKENS}}` → formatted font spec table:

```markdown
| 用途 | Size | Weight | Line Height |
|---|---|---|---|
| 页面标题 H1 / 大数值 | 36px | 600 | 44px |
| 区块标题 H2 | 20px | 600 | 28px |
| 卡片标题 / 强调 | 16px | 600 | 24px |
| 正文 / 输入框 / 导航菜单 | 16px | 400 | 24px |
| 表格列标题 / 表格内容 | 16px | 400 | 24px |
| 表格列标题（强调） | 16px | 600 | 24px |
| 辅助说明 / 时间戳 | 12px | 400 | 20px |
```

- `{{LOGO_FONT}}` → "Wix Madefor Text Bold" (for web) or leave as-is for mobile
- `{{UI_LIBRARY}}` → "shadcn/ui" for web, "heroui-native" for mobile
- `{{FRAMEWORK}}` → "Next.js" for web, "Expo (React Native Web)" for mobile
- `{{PAGES_DIR}}` → "web/app" for web, "mobile/app" for mobile
- `{{PREVIEW_PORT}}` → "localhost:3090" for web, "localhost:8081" for mobile

**4b: Generate CLAUDE.md from templates/CLAUDE.template.md**

Same replacements as above.

**4c: Generate .mcp.json**

For web:
```json
{
  "mcpServers": {
    "shadcn": {
      "type": "local",
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
```

For mobile:
```json
{
  "mcpServers": {
    "heroui-native": {
      "type": "local",
      "command": "npx",
      "args": ["heroui-native", "mcp"]
    }
  }
}
```

### Step 5: Scaffold Platform Directory

**If PLATFORM="web":**
```bash
npx create-next-app@latest web --typescript --tailwind --eslint --app --src-dir=false --import-alias="@/*" --use-npm
cd web
npx shadcn@latest init -d
npx shadcn@latest add button input table alert-dialog card select tabs textarea switch
```

**If PLATFORM="mobile":**
```bash
npx create-expo@latest mobile --template blank-typescript
cd mobile
npx expo install react-native-web react-dom @expo/metro-runtime
npx heroui-native@latest init
```

### Step 6: Start Dev Server

**Web:**
```bash
cd web && npm run dev -- -p 3090
```
Output: "Dev server running at http://localhost:3090"

**Mobile:**
```bash
cd mobile && npx expo start --web --port 8081
```
Output: "Dev server running at http://localhost:8081"

### Step 7: Done

用中文告知 PM：
"🎉 设置完成！项目「{PROJECT_NAME}」已就绪。

现在你可以直接在对话中描述页面需求，例如：
- 「帮我生成一个产品管理列表页，字段有名称、分类、价格、状态」
- 「生成一个数据仪表板，包含营收、订单、用户、转化率四个指标」

我会按照设计规范自动生成代码。预览地址：{PREVIEW_PORT}"

---

**Important rules:**
- Ask one question at a time, wait for the answer
- Use Chinese for all PM-facing communication
- If any step fails, explain the error in Chinese and suggest a fix
- Do NOT ask PM to run terminal commands — you run them yourself via Bash
PROMPT
```

- [ ] **Step 2: Make setup.sh executable**

```bash
chmod +x setup.sh
```

---

### Task 2: Create `templates/project.config.sh`

**Files:**
- Create: `templates/project.config.sh`

- [ ] **Step 1: Write templates/project.config.sh**

```bash
# project.config.sh
# Fill in your project details below.
# Leave empty to be asked interactively during setup.

# Project name (e.g., "My App")
PROJECT_NAME=""

# Platform: "web" or "mobile"
PLATFORM=""

# Theme source: "default", "figma", or "custom"
THEME=""

# Figma — only needed if THEME="figma"
FIGMA_URL=""
FIGMA_TOKEN=""

# Custom theme — only needed if THEME="custom"
PRIMARY_COLOR=""
FONT_FAMILY=""
```

---

### Task 3: Create `templates/SKILL.template.md`

**Files:**
- Create: `templates/SKILL.template.md`
- Reference: current `SKILL.md` (BRANDED — contains "Smartalk.AI", specific hex colors, font specs)

- [ ] **Step 1: Read current SKILL.md to confirm exact content before writing template**

```bash
cat SKILL.md | head -30
```

- [ ] **Step 2: Write de-branded SKILL.template.md**

Create `templates/SKILL.template.md` based on the current `SKILL.md` content but with the following **specific replacements**:

**Section: 硬性规则 3 (Font)**

Replace the hardcoded Nunito Sans font import block and Wix Madefor Text import block with:

```md
**规则 3 - 字体**
所有文字统一使用 {{FONT_FAMILY}}。

{{FONT_SETUP_INSTRUCTIONS}}

{{LOGO_FONT_SETUP}}
```

**Section: 硬性规则 3 exception about Logo**

Replace "Smartalk.AI" with `{{PROJECT_NAME}}` Logo.

**Section: Design Tokens → 字体**

Replace the entire font table with `{{FONT_TOKENS}}` placeholder.

**Section: Design Tokens → 颜色**

Replace the entire color table with `{{COLOR_TOKENS}}` placeholder.

**Section: 页面框架 → 侧边栏**

Replace "Smartalk.AI" with `{{PROJECT_NAME}}`.

**Section: 页面框架 → 侧边栏**

Replace "Wix Madefor Text Bold" references with `{{LOGO_FONT}}`.

**Section: 页面代码结构**

Replace `app/layout.tsx` references — keep as-is (Next.js convention, applies to web only).

**Section: 页面框架 → 侧边栏 (logo area)**

Replace "Smartalk.AI" with `{{PROJECT_NAME}}`.

**Section: 页面模板索引 (version)**

Replace the v2.3 version line with:

```
{{UI_LIBRARY}} · {{CURRENT_DATE}}
```

**Replace every occurrence in the file:**

| Find | Replace with |
|---|---|
| `Smartalk.AI` | `{{PROJECT_NAME}}` |
| `Wix Madefor Text Bold` | `{{LOGO_FONT}}` |
| `Nunito Sans` | `{{FONT_FAMILY}}` (in most places) |
| `next-app/app/` | `{{PAGES_DIR}}/` |
| `localhost:3090` | `{{PREVIEW_PORT}}` |
| `shadcn/ui` | `{{UI_LIBRARY}}` |
| `next/font/google` | `{{FONT_SOURCE}}` |

**Keep everything else identical** — component specs (button variants, table styles, search box, filters, metric cards, charts), interaction rules (toast, delete dialog, empty state), forbidden patterns, and page template index.

---

### Task 4: Create `templates/CLAUDE.template.md`

**Files:**
- Create: `templates/CLAUDE.template.md`
- Reference: current `CLAUDE.md`

- [ ] **Step 1: Read current CLAUDE.md to confirm content**

```bash
cat CLAUDE.md
```

- [ ] **Step 2: Write CLAUDE.template.md**

```markdown
# CLAUDE.md

This is a {{FRAMEWORK}} project using {{UI_LIBRARY}} for {{PROJECT_NAME}}.

## Behavioral Guidelines

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

### 5. {{PROJECT_NAME}} Design System

This is a {{UI_LIBRARY}} project. When generating UI pages:

#### Mandatory reading before generating ANY page:
1. Read `SKILL.md` — design tokens, layout rules, component specs, forbidden patterns
2. Read `patterns/<page-type>.md` — page template and code snippets for the requested page type
{{LAYOUT_FILE_INSTRUCTION}}

#### Hard constraints:
- **All UI components must be {{UI_LIBRARY}}** (`@/components/ui/*`). {{UI_LIBRARY_CONSTRAINT}}
- **Delete must have confirmation dialog** — never delete directly.
- **Filters must propagate to data** — state changes must flow through to all displayed metrics/charts/tables.
{{EXTRA_CONSTRAINTS}}

#### Code output location:
- Generate pages into `{{PAGES_DIR}}/<page-name>/page.tsx`
- Dev server: `{{DEV_SERVER_COMMAND}}`
- Verify with: `curl -s -o /dev/null -w "%{http_code}" {{PREVIEW_PORT}}/<page-name>`
```

- [ ] **Step 3: Define per-platform placeholder values**

When generating CLAUDE.md from this template during setup, use:

**For web:**
- `{{LAYOUT_FILE_INSTRUCTION}}` = `3. Read \`web/app/layout.tsx\` — confirms Sidebar + \`<main>\` wrapper are already provided; pages must NOT duplicate them`
- `{{UI_LIBRARY_CONSTRAINT}}` = `No Ant Design, MUI, or custom components. Use shadcn Tabs for segmented controls, shadcn Input for date inputs — never native HTML elements.`
- `{{EXTRA_CONSTRAINTS}}` = `- **Sidebar is provided by layout.tsx** — do NOT add \`<Sidebar />\` to individual pages. Pages output content fragment only.\n- **Font must be {{FONT_FAMILY}}** (except logo: {{LOGO_FONT}}).\n- **Follow SKILL.md specs exactly** — colors, spacing, font sizes, table styles. Don't improvise.\n- Use \`npx shadcn@latest add <component>\` to install missing shadcn components before using them.`
- `{{DEV_SERVER_COMMAND}}` = `\`cd web && npm run dev -- -p 3090\``

**For mobile:**
- `{{LAYOUT_FILE_INSTRUCTION}}` = `(no layout.tsx for mobile — pages are standalone)`
- `{{UI_LIBRARY_CONSTRAINT}}` = `Use heroui-native components exclusively. Import from \`@/components/ui/*\`.`
- `{{EXTRA_CONSTRAINTS}}` = `- **Font must be {{FONT_FAMILY}}**.\n- **Follow SKILL.md specs exactly** — colors, spacing, font sizes. Don't improvise.`
- `{{DEV_SERVER_COMMAND}}` = `\`cd mobile && npx expo start --web --port 8081\``

---

### Task 5: Update `.gitignore`

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Add generated files to .gitignore**

Append to `.gitignore`:
```
# Generated by setup.sh
CLAUDE.md
SKILL.md
.mcp.json
web/
mobile/
project.config.sh
```

---

### Task 6: Rewrite `README.md` (PM-facing, Chinese)

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Write PM-facing README in Chinese**

```markdown
# Design System Starter

基于 AI 的页面原型生成工具——用自然语言描述需求，自动生成符合设计规范的页面代码。

## 快速开始

在 Claude Code 中执行以下命令：

```bash
git clone <仓库地址> && cd design-system-starter && bash setup.sh
```

setup.sh 会自动检查环境并引导你完成配置：
1. 输入项目名称
2. 选择平台（Web / Mobile）
3. 选择主题（默认 / Figma 提取 / 自定义）

配置完成后，直接在对话中描述页面即可生成代码。

## 页面模板

| 模板 | 用途 | 示例 prompt |
|---|---|---|
| 列表页 | 管理列表、数据表格 | 「帮我生成一个产品管理列表页，字段有名称、分类、价格、状态、创建时间」 |
| 仪表板 | 数据概览、运营报表 | 「生成一个数据仪表板，包含营收、订单、用户数、转化率四个指标卡片和趋势图表」 |
| 表单页 | 新建/编辑资源 | 「生成一个新建产品的表单页，包含名称、分类下拉、价格、描述、上架开关」 |
| 详情页 | 资源详情查看 | 「生成一个产品详情页，包含基本信息卡片、订单记录 Tab、操作日志 Tab」 |

## 调整页面

生成页面后，可以用自然语言直接调整：

- 「把表格的价格列改成右对齐」
- 「搜索框支持按名称和分类搜索」
- 「删除按钮加一个确认弹窗」
- 「加一个分类筛选下拉框」

## 项目结构

```
design-system-starter/
├── setup.sh              # 唯一入口
├── project.config.sh     # 你的项目配置
├── SKILL.md              # 设计规范（自动生成）
├── CLAUDE.md             # AI 行为指令（自动生成）
├── patterns/             # 页面模板
├── prompts/              # PM 需求模板
└── web/ 或 mobile/       # 代码生成目录
```
```

---

### Task 7: De-brand reference examples

**Files:**
- Modify: `references/ai-assistant-page.tsx` → rename to `references/list-page-example.tsx`
- Keep: `references/product-list-page.tsx` (already generic enough)

- [ ] **Step 1: Delete the branded example**

```bash
rm references/ai-assistant-page.tsx
```

- [ ] **Step 2: Verify product-list-page.tsx is acceptably generic**

```bash
grep -i "smartalk\|assistant\|specific brand" references/product-list-page.tsx
# Should return no matches
```

The product-list-page.tsx uses generic terms (Product, Electronics, Clothing, Food) and is already suitable as a reference. No changes needed.

- [ ] **Step 3: Update pattern files that reference ai-assistant-page**

```bash
grep -rn "ai-assistant" patterns/
```

Replace any references to `references/ai-assistant-page.tsx` with `references/product-list-page.tsx`.

---

### Task 8: Update `registry/components.md` and `patterns/` references

**Files:**
- Modify: `registry/components.md`
- Potentially modify: `patterns/list-page.md` (last line reference)

- [ ] **Step 1: Update registry/components.md**

Replace the hardcoded path:

```
| Sidebar | `next-app/components/layout/sidebar.tsx` | ...
```

with:

```
| Sidebar | `{{PAGES_DIR}}/../components/layout/sidebar.tsx` | ...
```

And add a note: "Path prefix depends on platform (web/ or mobile/). Update after setup."

- [ ] **Step 2: Update patterns/list-page.md reference**

The last line of `patterns/list-page.md` says:
```
具体参考 `references/product-list-page.tsx` 完整示例。
```

This is fine (product-list-page.tsx is the remaining reference). No change needed.

- [ ] **Step 3: Check all patterns for stale paths**

```bash
grep -rn "next-app\|ai-assistant\|smartalk" patterns/ prompts/ registry/
# Should return no matches
```

If any matches found, replace with platform-agnostic equivalents.

---

### Task 9: Remove old root-level generated files

**Files:**
- Delete: `SKILL.md`
- Delete: `CLAUDE.md`

- [ ] **Step 1: Delete SKILL.md from root**

```bash
rm SKILL.md
```

- [ ] **Step 2: Delete CLAUDE.md from root**

```bash
rm CLAUDE.md
```

---

### Task 10: Verify

**Files:** None (verification only)

- [ ] **Step 1: Verify file structure**

```bash
ls -la
# Should show: setup.sh, project.config.sh, README.md, .gitignore, templates/, patterns/, prompts/, registry/, references/
# Should NOT show: SKILL.md, CLAUDE.md, web/, mobile/
```

- [ ] **Step 2: Verify setup.sh runs without error**

```bash
bash setup.sh
# Should output environment check and setup prompt, no errors
```

- [ ] **Step 3: Verify templates have correct placeholders**

```bash
grep -n "{{" templates/SKILL.template.md templates/CLAUDE.template.md
# Should list all placeholder variables
```

---
