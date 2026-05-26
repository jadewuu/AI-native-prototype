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
- `{{COLOR_TOKENS}}` → formatted color token table
- `{{FONT_TOKENS}}` → formatted font spec table
- `{{LOGO_FONT}}` → "Wix Madefor Text Bold" (for web) or leave as-is for mobile
- `{{UI_LIBRARY}}` → "shadcn/ui" for web, "heroui-native" for mobile
- `{{FRAMEWORK}}` → "Next.js" for web, "Expo (React Native Web)" for mobile
- `{{PAGES_DIR}}` → "web/app" for web, "mobile/app" for mobile
- `{{PREVIEW_PORT}}` → "localhost:3090" for web, "localhost:8081" for mobile
- `{{FONT_SOURCE}}` → "next/font/google" for web, appropriate source for mobile
- `{{FONT_SETUP_INSTRUCTIONS}}` → platform-specific font setup
- `{{CURRENT_DATE}}` → YYYY-MM
- `{{LOGO_FONT_SETUP}}` → logo font import block

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

**Mobile:**
```bash
cd mobile && npx expo start --web --port 8081
```

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

echo ""
echo "==> Setup script complete. Follow the prompt above to configure your project."
