# Pattern：表单页（Form Page）

## 适用场景
创建或编辑资源的表单页面，例如：新建产品、编辑用户、配置设置等。

## 页面结构

```
┌─────────────────────────────────────────────────────┐
│ Home / [上级页面] / [表单标题]         ← 面包屑      │
├─────────────────────────────────────────────────────┤
│ [返回按钮]  [表单标题 H1]                            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  分组标题：基本信息                            │  │
│  │  ┌───────────────┐  ┌──────────────────────┐ │  │
│  │  │ 字段标签       │  │ 输入框               │ │  │
│  │  │ 字段标签       │  │ 下拉选择             │ │  │
│  │  │ 字段标签       │  │ 文本域               │ │  │
│  │  └───────────────┘  └──────────────────────┘ │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │  分组标题：价格信息                            │  │
│  │  ┌───────────────┐  ┌──────────────────────┐ │  │
│  │  │ 字段标签       │  │ 数字输入             │ │  │
│  │  │ 字段标签       │  │ 开关                 │ │  │
│  │  └───────────────┘  └──────────────────────┘ │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  [Cancel]  [Save]                                   │
└─────────────────────────────────────────────────────┘
```

## 生成规则

### 页面代码结构
- **layout.tsx 已提供** Sidebar + main 容器，页面文件不得重复定义
- 页面仅输出内容片段：`<div className="flex flex-col flex-1">` → 面包屑 → 头部 → 表单卡片

### 页面头部
```tsx
<div className="flex items-center gap-3 mb-6">
  <Button variant="ghost" size="icon" className="h-8 w-8 text-[#4e5969]">
    <ArrowLeftIcon className="h-4 w-4" />
  </Button>
  <h1 className="text-[36px] font-semibold leading-[44px] text-[#1d2129]">[表单标题]</h1>
</div>
```

### 表单卡片（分组）
```tsx
<Card className="mb-6 border-[#e5e6eb] rounded-lg">
  <CardHeader className="pb-3">
    <CardTitle className="text-lg font-semibold text-[#1d2129]">
      [分组标题]
    </CardTitle>
  </CardHeader>
  <CardContent>
    <div className="grid grid-cols-2 gap-x-8 gap-y-5">
      {/* 文本输入 */}
      <div>
        <label className="block text-sm font-semibold text-[#1d2129] mb-2">
          [字段名] <span className="text-[#f53f3f]">*</span>
        </label>
        <Input
          placeholder="[placeholder]"
          className="bg-white border-[#e5e6eb] text-[#1d2129]"
        />
      </div>

      {/* 下拉选择 */}
      <div>
        <label className="block text-sm font-semibold text-[#1d2129] mb-2">
          [字段名]
        </label>
        <Select>
          <SelectTrigger className="bg-white border-[#e5e6eb]">
            <SelectValue placeholder="[选择]" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="option1">Option 1</SelectItem>
            <SelectItem value="option2">Option 2</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* 文本域 */}
      <div className="col-span-2">
        <label className="block text-sm font-semibold text-[#1d2129] mb-2">
          [字段名]
        </label>
        <Textarea
          placeholder="[placeholder]"
          className="bg-white border-[#e5e6eb] text-[#1d2129] min-h-[120px]"
        />
      </div>

      {/* 开关 */}
      <div className="flex items-center gap-3">
        <Switch />
        <label className="text-sm text-[#1d2129]">[开关标签]</label>
      </div>

      {/* 日期选择 — 使用 shadcn Input type="date" */}
      <div>
        <label className="block text-sm font-semibold text-[#1d2129] mb-2">
          [字段名]
        </label>
        <Input
          type="date"
          className="bg-white border-[#e5e6eb] text-[#1d2129] w-full"
        />
      </div>
    </div>
  </CardContent>
</Card>
```

### 底部操作按钮
```tsx
<div className="flex items-center justify-end gap-3 pt-4 border-t border-[#e5e6eb]">
  <Button variant="outline" className="border-[#e5e6eb] text-[#4e5969]">
    Cancel
  </Button>
  <Button className="bg-[#165dff] hover:bg-[#165dff]/90 text-white">
    Save
  </Button>
</div>
```

## 注意事项
- 必填字段用红色星号标注（`color: #f53f3f`）
- 字段默认 2 列布局（`grid-cols-2`），文本域等宽字段用 `col-span-2`
- 表单分组按逻辑切分，每组对应一个 Card
- 提交前做前端校验，校验失败在对应字段下方显示红色提示
- 提交成功后 Toast 提示 + 跳转回列表页
- 编辑模式下字段预填已有数据
- 取消时弹出未保存确认（如有修改）
