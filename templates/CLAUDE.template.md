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

<!-- 
  PLACEHOLDER VALUES BY PLATFORM (used by setup.sh):

  For web:
  - LAYOUT_FILE_INSTRUCTION: "3. Read `web/app/layout.tsx` — confirms Sidebar + `<main>` wrapper are already provided; pages must NOT duplicate them"
  - UI_LIBRARY_CONSTRAINT: "No Ant Design, MUI, or custom components. Use shadcn Tabs for segmented controls, shadcn Input for date inputs — never native HTML elements."
  - EXTRA_CONSTRAINTS: "- **Sidebar is provided by layout.tsx** — do NOT add `<Sidebar />` to individual pages. Pages output content fragment only.\n- **Font must be {{FONT_FAMILY}}** (except logo: {{LOGO_FONT}}).\n- **Follow SKILL.md specs exactly** — colors, spacing, font sizes, table styles. Don't improvise.\n- Use `npx shadcn@latest add <component>` to install missing shadcn components before using them."
  - DEV_SERVER_COMMAND: "`cd web && npm run dev -- -p 3090`"

  For mobile:
  - LAYOUT_FILE_INSTRUCTION: "(no layout.tsx for mobile — pages are standalone)"
  - UI_LIBRARY_CONSTRAINT: "Use heroui-native components exclusively. Import from `@/components/ui/*`."
  - EXTRA_CONSTRAINTS: "- **Font must be {{FONT_FAMILY}}**.\n- **Follow SKILL.md specs exactly** — colors, spacing, font sizes. Don't improvise."
  - DEV_SERVER_COMMAND: "`cd mobile && npx expo start --web --port 8081`"
-->
