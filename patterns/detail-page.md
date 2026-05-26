# Pattern：详情页（Detail Page）

## 适用场景
查看单个资源的完整信息，例如：产品详情、订单详情、用户资料等。

## 页面结构

```
┌──────────────────────────────────────────────────────────┐
│ Home / [列表页] / [资源名称]                  ← 面包屑    │
├──────────────────────────────────────────────────────────┤
│ [返回按钮]  [资源名称 H1]           [Edit]  [Delete]      │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │  基本信息                                         │  │
│  │  ┌──────────────┬──────────────────────────────┐ │  │
│  │  │  Label       │  Value                       │ │  │
│  │  │  Label       │  Status Badge                │ │  │
│  │  │  Label       │  Value                       │ │  │
│  │  └──────────────┴──────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Tab: 关联数据 ｜ 操作日志                         │  │
│  │  ┌──────────────────────────────────────────────┐ │  │
│  │  │ ...关联的表格或时间线...                       │ │  │
│  │  └──────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

## 生成规则

### 页面代码结构
- **layout.tsx 已提供** Sidebar + main 容器，页面文件不得重复定义
- 页面仅输出内容片段：`<div className="flex flex-col flex-1">` → 面包屑 → 头部 → 信息卡片

### 页面头部
```tsx
<div className="flex items-center justify-between mb-6">
  <div className="flex items-center gap-3">
    <Button variant="ghost" size="icon" className="h-8 w-8 text-[#4e5969]">
      <ArrowLeftIcon className="h-4 w-4" />
    </Button>
    <h1 className="text-[36px] font-semibold leading-[44px] text-[#1d2129]">[资源名称]</h1>
  </div>
  <div className="flex items-center gap-2">
    <Button variant="outline" className="border-[#e5e6eb] text-[#4e5969]">
      <PencilIcon className="mr-1 h-4 w-4" />
      Edit
    </Button>
    <Button variant="ghost" size="icon" className="h-8 w-8 text-[#f53f3f]">
      <TrashIcon className="h-4 w-4" />
    </Button>
  </div>
</div>
```

### 信息卡片（描述列表）
```tsx
<Card className="mb-6 border-[#e5e6eb] rounded-lg">
  <CardHeader className="pb-3">
    <CardTitle className="text-lg font-semibold text-[#1d2129]">基本信息</CardTitle>
  </CardHeader>
  <CardContent>
    <dl className="grid grid-cols-2 gap-x-8 gap-y-5">
      {/* 文字字段 */}
      <div>
        <dt className="text-sm text-[#4e5969] mb-1">[字段标签]</dt>
        <dd className="text-sm text-[#1d2129]">[字段值]</dd>
      </div>

      {/* 状态标签 */}
      <div>
        <dt className="text-sm text-[#4e5969] mb-1">Status</dt>
        <dd>
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-[#00b42a]/10 text-[#00b42a]">
            Active
          </span>
        </dd>
      </div>

      {/* 日期时间 */}
      <div>
        <dt className="text-sm text-[#4e5969] mb-1">Created At</dt>
        <dd className="text-sm text-[#1d2129]">05/20/2026 09:30 AM</dd>
      </div>
    </dl>
  </CardContent>
</Card>
```

### 关联数据 Tab
```tsx
<Card className="border-[#e5e6eb] rounded-lg">
  <CardContent className="p-0">
    <Tabs defaultValue="related">
      <TabsList className="px-6 pt-4 bg-transparent border-b border-[#e5e6eb] rounded-none">
        <TabsTrigger
          value="related"
          className="text-sm data-[state=active]:text-[#165dff] data-[state=active]:border-b-2 data-[state=active]:border-[#165dff] rounded-none"
        >
          [Tab 1 名称]
        </TabsTrigger>
        <TabsTrigger
          value="logs"
          className="text-sm data-[state=active]:text-[#165dff] data-[state=active]:border-b-2 data-[state=active]:border-[#165dff] rounded-none"
        >
          [Tab 2 名称]
        </TabsTrigger>
      </TabsList>
      <TabsContent value="related" className="p-6">
        {/* 关联表格或列表 */}
      </TabsContent>
      <TabsContent value="logs" className="p-6">
        {/* 时间线或日志列表 */}
      </TabsContent>
    </Tabs>
  </CardContent>
</Card>
```

### 删除确认 Dialog
```tsx
<AlertDialog>
  <AlertDialogContent>
    <AlertDialogHeader>
      <AlertDialogTitle>Confirm Delete</AlertDialogTitle>
      <AlertDialogDescription>
        Are you sure you want to delete "[resourceName]"?
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

## 注意事项
- 面包屑格式：`Home / [列表页名称] / [资源名称]`（14px, #4e5969）
- 信息字段默认 2 列，字段较少时可用 1 列
- 状态标签颜色：Active/Published 用绿色（#00b42a），Inactive/Draft 用灰色（#86909c），Error/Deleted 用红色（#f53f3f）
- Tab 组件使用 shadcn `<Tabs>`，下划线高亮激活项
- Edit 按钮跳转表单页，Delete 按钮必须走确认 Dialog
- 不存在已删除资源时跳回列表页并 Toast 提示
