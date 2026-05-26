# Pattern：仪表板页（Dashboard Page）

## 适用场景
数据概览、运营数据汇总类页面，例如：Dashboard、数据报表、业绩概览等。

## 页面结构

```
┌──────────────────────────────────────────────────────────┐
│ Home / Dashboard                         ← 面包屑         │
├──────────────────────────────────────────────────────────┤
│ [标题]    [日期选择器]  [筛选1]  [筛选2]  [筛选3]         │
├─────────────┬─────────────┬─────────────┬────────────────┤
│  指标卡片1  │  指标卡片2  │  指标卡片3  │   指标卡片4    │ ← 4列等宽
├─────────────┴──────┬──────┴─────────────┴────────────────┤
│                    │                                      │
│  图表区块 A（2/3） │  图表区块 B（1/3）                   │
│                    │                                      │
├────────────────────┼──────────────────────────────────────┤
│                    │                                      │
│  图表区块 C（2/3） │  图表区块 D（1/3）                   │
│                    │                                      │
└────────────────────┴──────────────────────────────────────┘
```

## 生成规则

### 页面代码结构（关键）
- **layout.tsx 已提供** Sidebar + main 容器，页面文件不得重复定义
- 页面仅输出内容片段：`<div className="flex flex-col flex-1">` → 面包屑 → 头部 → 内容
- 生成前必须读取 `app/layout.tsx` 确认已有包装结构

### 头部筛选区
```tsx
<div className="flex items-center justify-between mb-6">
  <h1 className="text-[36px] font-semibold leading-[44px] text-[#1d2129]">Dashboard</h1>
  <div className="flex items-center gap-2">
    {/* 日期范围分段选择器 — 使用 shadcn Tabs，不得用原生 button */}
    <Tabs value={datePreset} onValueChange={v => setDatePreset(v)}>
      <TabsList className="bg-white border border-[#c9cdd4]">
        <TabsTrigger value="today" className="text-sm data-[state=active]:bg-[#165dff] data-[state=active]:text-white">Today</TabsTrigger>
        <TabsTrigger value="7d" className="text-sm data-[state=active]:bg-[#165dff] data-[state=active]:text-white">Last 7 Days</TabsTrigger>
        <TabsTrigger value="30d" className="text-sm data-[state=active]:bg-[#165dff] data-[state=active]:text-white">Last 30 Days</TabsTrigger>
        <TabsTrigger value="custom" className="text-sm data-[state=active]:bg-[#165dff] data-[state=active]:text-white">Custom</TabsTrigger>
      </TabsList>
    </Tabs>
    {/* 下拉筛选器，每个宽度约 160px */}
    <Select><SelectTrigger className="w-40"><SelectValue placeholder="All Category" /></SelectTrigger></Select>
    <Select><SelectTrigger className="w-40"><SelectValue placeholder="All Channel" /></SelectTrigger></Select>
  </div>
</div>
```

### 筛选器数据联动（必须）
- **所有筛选条件变更后必须同步更新所有关联展示**（指标卡片、图表、汇总数字）
- 筛选逻辑放在 `useMemo` 派生阶段，不得仅设置 state 而不消费
- 结构：`rawData → dateFilter → category/channel scale → scaledData → totals/trends/chartData`
- 趋势比较期需随日期范围动态变化：today → vs yesterday，7d/30d → vs previous period

### 指标卡片（Metric Card）
```tsx
<div className="grid grid-cols-4 gap-4 mb-6">
  <Card className="rounded-lg shadow-[6px_0px_20px_0px_rgba(34,87,188,0.10)]">
    <CardContent className="p-5 px-6">
      <div className="flex items-center gap-2 mb-2">
        <DollarSignIcon className="h-4 w-4 text-[#165dff]" />
        <span className="text-sm text-[#4e5969]">Revenue</span>
      </div>
      <div className="flex items-baseline gap-2">
        <span className="text-4xl font-semibold text-[#1d2129]">$12,450</span>
        {/* 趋势：上涨用红色，下降用绿色 */}
        <span className="text-sm text-[#f53f3f] flex items-center">
          <ArrowUpIcon className="h-3 w-3" /> 12.5%
        </span>
      </div>
    </CardContent>
  </Card>
  {/* 重复 4 个卡片 */}
</div>
```

### 图表布局（2/3 + 1/3）
```tsx
<div className="grid grid-cols-3 gap-4 mb-4">
  {/* 左侧图表（占 2/3） */}
  <Card className="col-span-2">
    <CardHeader>
      <CardTitle className="text-lg font-semibold">[图表标题]</CardTitle>
    </CardHeader>
    <CardContent>
      {/* shadcn Chart 组件 */}
    </CardContent>
  </Card>
  {/* 右侧图表（占 1/3） */}
  <Card className="col-span-1">
    <CardHeader>
      <CardTitle className="text-lg font-semibold">[图表标题]</CardTitle>
    </CardHeader>
    <CardContent>
      {/* shadcn Chart 组件 */}
    </CardContent>
  </Card>
</div>
```

### 图表颜色分配
```
Bar Chart 系列1：stroke/fill #165dff（主色）
Bar Chart 系列2：stroke/fill #4cd263（success-light）
Line Chart 系列1：stroke #165dff
Line Chart 系列2：stroke #00b42a
取消 / 负向数据：fill #f98981（danger-light）
```

### 图表通用配置
```tsx
// Recharts 配置参考
<CartesianGrid strokeDasharray="3 3" stroke="#e5e6eb" />
<XAxis tick={{ fontSize: 12, fill: '#86909c' }} />
<YAxis tick={{ fontSize: 12, fill: '#86909c' }} />
<Tooltip
  contentStyle={{
    background: '#ffffff',
    border: '1px solid #e5e6eb',
    borderRadius: 8,
    fontSize: 14
  }}
/>
<Legend verticalAlign="bottom" iconType="circle" />
```

## 注意事项
- 页面文件不得包含 `<Sidebar />` 或外层 `flex h-screen` 容器（layout.tsx 已提供）
- 指标卡片始终 4 列等宽，不得改为 3 列或 2 列
- 图表区块始终采用 2/3 + 1/3 的黄金分割比例
- 每个图表区块必须有独立的 CardTitle（H2 级别）
- 筛选器数量根据需求定，不得自行添加未说明的筛选项
- 分段选择器（日期范围、时间维度等）必须使用 shadcn Tabs，不得用原生 button
- 日期输入必须使用 shadcn Input type="date"，不得用原生 `<input>`
- 筛选器变更后所有卡片、图表、汇总数字必须同步更新

## 参考页面
使用时参考本模板中的代码片段即可，具体数据和指标根据 PM 需求替换。
