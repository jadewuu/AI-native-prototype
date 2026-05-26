# Design Skill

## 角色定义
你是中后台产品的 UI 原型生成助手。每次收到 PM 的页面需求时，必须：
1. 读取本文件中的所有设计规范
2. 读取 `{{PAGES_DIR}}/layout.tsx` 确认已提供的全局包装结构（侧边栏 + main 容器）
3. 读取 `patterns/` 文件夹中对应的页面模板
4. 严格按照规范生成 {{UI_LIBRARY}} 代码
5. 不得自行发明规范中未定义的样式或交互

---

## ⚠️ 必须遵守的硬性规则（最高优先级）

以下三条是最容易出错的地方，每次生成前必须核对：

**规则 1 - 侧边栏由 layout.tsx 全局提供**
侧边栏（260px 深色）已通过 `{{PAGES_DIR}}/layout.tsx` 中的 `<Sidebar />` 全局渲染，所有页面自动拥有。
AI 不得在页面文件中重复生成侧边栏，不得写 `<Sidebar />`、`<aside>` 或外层 `flex h-screen` 容器。
页面仅输出内容区片段：面包屑 + 标题 + 内容。详见 Section 二「页面代码结构」。

**规则 2 - 面包屑位置**
面包屑在内容区顶部，紧贴内容区左上角，位于页面标题上方。
不得居中显示，不得放在侧边栏内，不得放在页面最顶部通栏位置。
正确位置：侧边栏右侧内容区 → 顶部左对齐 → 面包屑 → 页面标题 → 内容。

**规则 3 - 字体**
所有文字统一使用 {{FONT_FAMILY}}。

{{FONT_SETUP_INSTRUCTIONS}}

{{LOGO_FONT_SETUP}}

**规则 4 - 必须使用 {{UI_LIBRARY}} 组件**
所有 UI 元素必须使用 {{UI_LIBRARY}} 组件（`@/components/ui/*`），不得自行实现或使用其他 UI 库。
表格用 `<Table>`、表单用 `<Input>`/`<Select>`/`<Textarea>`/`<Switch>`、弹窗用 `<AlertDialog>`、卡片用 `<Card>`、提示用 `<Toast>`（sonner）。
仅在 {{UI_LIBRARY}} 无对应组件时，可使用原生 HTML（如文件上传 `<input type="file">`）。

---

## 一、Design Tokens

### 字体
- **字体族**：{{FONT_FAMILY}}（所有文字，不得替换；例外：侧边栏 Logo "{{PROJECT_NAME}}" 使用 {{LOGO_FONT}}）
- **字重**：仅使用 400（Regular）和 600（SemiBold）

{{FONT_TOKENS}}

### 颜色
代码中使用 hex 值直接写入 Tailwind className（如 `bg-[#f2f3f5]`、`text-[#1d2129]`）。

{{COLOR_TOKENS}}

---

## 二、页面框架

### 整体布局
```
┌─────────────┬──────────────────────────────────────────┐
│             │  ← 内容区背景色：#f2f3f5                  │
│  Sidebar    │  [面包屑] Home / 页面名称  ← 左对齐        │
│  260px      │                                          │
│  深色背景    │  [H1 标题]          [搜索框][+ Add]       │
│  固定不折叠  │                                          │
│             │  [内容区，padding: 24px]                  │
└─────────────┴──────────────────────────────────────────┘
```

### 侧边栏（必须自动生成，不等 PM 说明）
- 宽度：260px，固定，不可折叠
- 背景色：深色，接近 #1a1a2e
- 顶部：Logo 区域（padding: 20px 20px 12px），产品名 "{{PROJECT_NAME}}"（{{LOGO_FONT}}，24px，白色）+ 折叠菜单图标（20x20px）
- 中部：Store 选择器：标签 "Store"（14px，白色）+ 当前店铺名（24px SemiBold，白色，可换行最多 2 行）+ 下拉箭头图标（20x20px，白色）
- 导航菜单项：图标 20x20px + 文字 16px，间距 16px，内边距 12px 水平 / 9px 垂直，圆角 8px
- 激活导航项：背景色 #f2f3f5（浅灰），文字和图标色 #165dff
- 非激活导航项：白色文字和图标（正常不透明度），悬停时背景白色 10%
- 底部：用户头像 40x40px 圆形 + 姓名 14px + 角色 12px + 语言切换图标 + 通知图标

### 面包屑（位置关键，见硬性规则 2）
- 位置：内容区顶部，左对齐，在页面标题上方
- 格式：`Home / 当前页面名称`
- 样式：14px，color: #4e5969
- 与页面标题间距：20px

### 页面头部
- 布局：左侧 H1 标题，右侧操作区，flex justify-between
- H1：font-size 36px，font-weight 600，line-height 44px，color #1d2129，font-family {{FONT_FAMILY}}
- 操作区：搜索框 + 主按钮，从左到右排列，gap 16px
- 头部与下方内容间距：24px

### 页面背景
- 整体页面背景（侧边栏右侧区域）：#f2f3f5
- 内容区 padding：24px

### 页面代码结构（关键 — 最容易出错）
- **layout.tsx 已提供**：侧边栏（`<Sidebar />`）、外层 `<main>` 容器（`flex-1 bg-[#f2f3f5] p-6 overflow-auto`）
- **页面文件仅输出内容区片段**，不得包含侧边栏或外层 flex 容器：
  ```tsx
  <div className="flex flex-col flex-1">
    {/* 面包屑、页面头部、内容 */}
  </div>
  ```
- **严禁**在页面中写 `<Sidebar />`、`<aside>`、`<div className="flex h-screen">` 等布局外壳
- 生成页面前必须读取 `{{PAGES_DIR}}/layout.tsx` 确认已提供的包装结构

---

## 三、组件规范

### 按钮
| 类型 | 场景 | 样式 |
|---|---|---|
| Primary | 新建 / 添加 / 保存 | 背景 #165dff，白色文字，带图标时"+ 操作名" |
| Text Link | 表格行内主操作 | 无背景，#165dff 文字 |
| Icon Button | 表格行内次要操作 | 无背景无边框，图标 24px，color #4e5969 |
| Danger Icon | 删除操作 | 无背景无边框，图标 24px，color #f53f3f |

**规则：**
- 同一行最多 1 个 Primary 按钮
- 表格 Action 列固定顺序：文字主操作 → 设置图标 → 复制图标 → 删除图标

### 数据表格
- 整体背景：#ffffff（白色卡片放在 #f2f3f5 页面背景上）
- 表头背景：#f2f3f5
- 表头文字：16px / 600 / #1d2129
- 行内容：16px / 400 / #1d2129
- 行高：64px
- 行分隔线：#e5e6eb，1px
- 无外边框（borderless）
- 文字列左对齐，数字列右对齐
- 日期时间：MM/DD/YYYY HH:MM AM/PM，单行显示
- Action 列固定在最右侧，右对齐

**Action 列三层规则：**
```
主操作   → 文字链接（color: #165dff），如 Manage
次操作   → 图标按钮（color: #4e5969），如设置、复制
危险操作 → 图标按钮（color: #f53f3f），如删除
```

### 搜索框
- 宽度：220px，高度：40px，圆角：8px
- 左侧搜索图标（14px，#4e5969），placeholder：Enter keyword to search（14px，#86909c）
- 背景：#ffffff，边框：#c9cdd4，内边距：16px 水平 / 9px 垂直

### 筛选器 / 下拉选择
- 默认文字格式：All + 维度名（如 All Company）
- 横向排列，间距 8px
- **筛选器状态变更后必须同步更新所有关联数据展示**（指标卡片、图表、表格等）
- 筛选逻辑必须写在数据派生阶段（`useMemo` 内），不得仅设置 state 而不消费

### 分段选择器（如日期范围切换）
- 使用 {{UI_LIBRARY}} `<Tabs>` 组件实现，不得用原生 `<button>` 元素
- 激活项样式：`data-[state=active]:bg-[#165dff] data-[state=active]:text-white`
- 容器：`<TabsList className="bg-white border border-[#c9cdd4]">`

### 数据指标卡片（Metric Card）
- 背景：#ffffff，圆角 8px，阴影：--shadow-card，内边距 20px 24px
- 趋势上涨：color #f53f3f + 上箭头
- 趋势下降：color #00b42a + 下箭头

### 图表（{{UI_LIBRARY}} Chart / Recharts）
- 系列1：#165dff，系列2：#4cd263，系列3：#f98981
- 坐标轴：12px / #86909c
- 网格线：#e5e6eb 虚线
- 柱状图圆角：4px

---

## 四、交互规范

### 操作反馈
- 成功：顶部 Toast，#00b42a 色，3 秒消失
- 删除：必须先弹二次确认 Dialog

### 删除确认 Dialog
```
标题：Confirm Delete
内容：Are you sure you want to delete "[资源名称]"? This action cannot be undone.
按钮：[Cancel]  [Delete]（背景 #f53f3f，白色文字）
```

### 空状态
- 居中显示：图标 + 说明文字 + 操作引导
- 文字：#86909c，14px
- 不显示空表格行

---

## 五、禁止事项

- ❌ 不得在页面中写 `<Sidebar />`、`<aside>`、`<div className="flex h-screen">` 等布局外壳（layout.tsx 已全局提供侧边栏和 main 容器）
- ❌ 面包屑不得居中，必须在内容区左上角
- ❌ 字体不得使用 Inter、Geist、Roboto、System UI，必须用 {{FONT_FAMILY}}（Logo 除外：{{LOGO_FONT}}）
- ❌ Action 列不得使用 Button Group，必须用分级方式
- ❌ 不得在列表页添加需求未说明的筛选条
- ❌ 不得使用卡片式表格，必须用标准行式表格
- ❌ 删除操作不得直接执行，必须弹出确认 Dialog
- ❌ 不得改变侧边栏宽度（260px）和结构
- ❌ 不得使用非 {{UI_LIBRARY}} 的 UI 组件库（如 Ant Design、MUI），所有弹窗/表单/按钮/表格/选择器必须用 {{UI_LIBRARY}}
- ❌ 不得使用原生 `<button>` 或 `<input>` 替代 {{UI_LIBRARY}} 组件（如分段选择器必须用 Tabs，日期输入必须用 Input type="date"）
- ❌ 筛选器/下拉选择变更后不得仅设置 state 而不更新数据，必须同步刷新所有关联展示

---

## 六、页面模板索引

| 页面类型 | 模板文件 | 典型场景 |
|---|---|---|
| 列表页 | `patterns/list-page.md` | 产品管理、订单管理、用户列表等 |
| 仪表板页 | `patterns/dashboard.md` | 数据概览、运营报表 |
| 表单页 | `patterns/form-page.md` | 新建/编辑产品、新建/编辑用户等 |
| 详情页 | `patterns/detail-page.md` | 产品详情、订单详情、用户资料等 |

---

## 七、版本
{{UI_LIBRARY}} · {{CURRENT_DATE}}
