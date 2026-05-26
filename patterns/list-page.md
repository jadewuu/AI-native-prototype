# Pattern：列表页（List Page）

## 适用场景
资源管理类页面，例如：产品管理、订单管理、用户列表等。

## 页面结构

```
┌─────────────────────────────────────────────────────┐
│ Home / [页面名称]                    ← 面包屑        │
├─────────────────────────────────────────────────────┤
│ [页面标题 H1]        [搜索框] [+ 新建按钮]           │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │ 列1      │ 列2    │ 列3    │ ...  │ Action   │  │  ← 表头（bg-page 背景）
│  ├──────────────────────────────────────────────┤  │
│  │ 内容     │ 内容   │ 内容   │ ...  │ 操作区   │  │  ← 数据行
│  │ 内容     │ 内容   │ 内容   │ ...  │ 操作区   │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  [分页组件]（如有）                                  │
└─────────────────────────────────────────────────────┘
```

## 生成规则

### 页面代码结构
- **layout.tsx 已提供** Sidebar + main 容器，页面文件不得重复定义
- 页面仅输出内容片段：`<div className="flex flex-col flex-1">` → 面包屑 → 头部 → 表格

### 头部区域
```tsx
<div className="flex items-center justify-between mb-6">
  <h1 className="text-[36px] font-semibold leading-[44px] text-[#1d2129]">[页面标题]</h1>
  <div className="flex items-center gap-4">
    <Input
      placeholder="Enter keyword to search"
      className="w-[220px] h-10 rounded-lg border-[#c9cdd4]"
      prefix={<SearchIcon />}
    />
    <Button className="bg-[#165dff] text-white h-9 rounded-lg">
      <PlusIcon className="mr-2 h-[14px] w-[14px]" />
      Add
    </Button>
  </div>
</div>
```

### 表格规则
- 使用 shadcn `<Table>` 组件
- 表头加 `className="bg-[#f2f3f5]"`
- 行高通过 `<TableRow className="h-16">` 控制（64px）
- 无外边框：`<Table className="border-0">`

### Action 列模板
```tsx
<TableCell className="text-right">
  <div className="flex items-center justify-end gap-4">
    {/* 主操作：文字链接 */}
    <Button variant="link" className="text-[#165dff] p-0 h-auto text-base">
      Manage
    </Button>
    {/* 次要操作：图标按钮 */}
    <Button variant="ghost" size="icon" className="h-6 w-6 text-[#4e5969]">
      <SettingsIcon className="h-6 w-6" />
    </Button>
    <Button variant="ghost" size="icon" className="h-6 w-6 text-[#4e5969]">
      <CopyIcon className="h-6 w-6" />
    </Button>
    {/* 危险操作：红色图标 */}
    <Button variant="ghost" size="icon" className="h-6 w-6 text-[#f53f3f]">
      <TrashIcon className="h-6 w-6" />
    </Button>
  </div>
</TableCell>
```

### 删除确认 Dialog
```tsx
<AlertDialog>
  <AlertDialogContent>
    <AlertDialogHeader>
      <AlertDialogTitle>Confirm Delete</AlertDialogTitle>
      <AlertDialogDescription>
        Are you sure you want to delete "{resourceName}"?
        This action cannot be undone.
      </AlertDialogDescription>
    </AlertDialogHeader>
    <AlertDialogFooter>
      <AlertDialogCancel>Cancel</AlertDialogCancel>
      <AlertDialogAction className="bg-[#f53f3f] hover:bg-[#f76560]">
        Delete
      </AlertDialogAction>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>
```

### 空状态
```tsx
{data.length === 0 && (
  <div className="flex flex-col items-center justify-center py-16 text-[#86909c]">
    <InboxIcon className="h-12 w-12 mb-3 opacity-40" />
    <p className="text-sm">No data yet</p>
    <Button variant="link" className="text-[#165dff] mt-1">
      + Add your first item
    </Button>
  </div>
)}
```

## 参考页面
具体参考 `references/product-list-page.tsx` 完整示例。
