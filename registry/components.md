# Business Component Registry

记录项目中已实现的业务组件及其文件路径，便于 AI 重用已有组件而非重复生成。

## 已注册组件

| 组件名 | 文件路径 | 用途 | 注册日期 |
|---|---|---|---|
| Sidebar | `{platform}/components/layout/sidebar.tsx` | 全局侧边栏，layout.tsx 引用 | 2026-05 |

注：`{platform}` 为 `web` 或 `mobile`，由 setup.sh 按平台选择生成。

## 注册规范

新增业务组件后，在本文件表格中添加一行记录：
- **组件名**：PascalCase 组件名称
- **文件路径**：相对于项目根目录的路径
- **用途**：一句话描述组件功能和使用场景
- **注册日期**：YYYY-MM 格式
