"use client"

import { useState } from "react"
import {
  Search, Plus, Settings, Copy, Trash2, Inbox,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table"
import {
  AlertDialog, AlertDialogAction, AlertDialogCancel,
  AlertDialogContent, AlertDialogDescription, AlertDialogFooter,
  AlertDialogHeader, AlertDialogTitle,
} from "@/components/ui/alert-dialog"

/* ─── Types ─── */
interface Product {
  id: string
  name: string
  category: string
  price: number
  status: "Active" | "Draft" | "Archived"
  createdAt: Date
}

/* ─── Mock Data ─── */
const MOCK: Product[] = [
  { id:"1", name:"Wireless Headphones", category:"Electronics", price:79.99, status:"Active", createdAt:new Date("2026-05-10T09:30:00") },
  { id:"2", name:"Organic Green Tea", category:"Food", price:12.50, status:"Active", createdAt:new Date("2026-05-08T14:15:00") },
  { id:"3", name:"Running Shoes", category:"Clothing", price:120.00, status:"Draft", createdAt:new Date("2026-04-28T11:00:00") },
  { id:"4", name:"Bluetooth Speaker", category:"Electronics", price:45.00, status:"Active", createdAt:new Date("2026-04-15T16:45:00") },
  { id:"5", name:"Linen Shirt", category:"Clothing", price:58.00, status:"Archived", createdAt:new Date("2026-03-22T08:00:00") },
]

/* ─── Helpers ─── */
function fmtDate(d: Date) {
  const date = d.toLocaleDateString("en-US", { month:"2-digit", day:"2-digit", year:"numeric" })
  const time = d.toLocaleTimeString("en-US", { hour:"2-digit", minute:"2-digit", hour12:true })
  return `${date}\n${time}`
}

function fmtPrice(n: number) {
  return `$${n.toFixed(2)}`
}

const STATUS_STYLES: Record<string, string> = {
  Active: "bg-[#00b42a]/10 text-[#00b42a]",
  Draft: "bg-[#86909c]/10 text-[#86909c]",
  Archived: "bg-[#f53f3f]/10 text-[#f53f3f]",
}

/* ═══════════════════════════════════════════ */
export default function ProductListPage() {
  const [search, setSearch] = useState("")
  const [deleteTarget, setDeleteTarget] = useState<Product | null>(null)

  const filtered = MOCK.filter(p =>
    p.name.toLowerCase().includes(search.toLowerCase()) ||
    p.category.toLowerCase().includes(search.toLowerCase())
  )

  return (
    <div className="flex flex-col flex-1">
      {/* Breadcrumb */}
      <nav className="text-sm text-[#4e5969] mb-3">
        Home <span className="mx-1.5 text-[#c9cdd4]">/</span> Products
      </nav>

      {/* Page Header */}
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold text-[#1d2129]">Products</h1>
        <div className="flex items-center gap-2">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#86909c]" />
            <Input
              placeholder="Enter keyword to search"
              value={search}
              onChange={e => setSearch(e.target.value)}
              className="w-60 pl-10 bg-white border-[#e5e6eb] text-[#1d2129] placeholder:text-[#86909c]"
            />
          </div>
          <Button className="bg-[#165dff] hover:bg-[#165dff]/90 text-white">
            <Plus className="mr-1 h-4 w-4" />
            Add
          </Button>
        </div>
      </div>

      {/* Table */}
      {filtered.length > 0 ? (
        <Table className="border-0">
          <TableHeader>
            <TableRow className="h-[52px] bg-[#f2f3f5] border-0 hover:bg-[#f2f3f5]">
              <TableHead className="text-sm font-semibold text-[#1d2129]">Name</TableHead>
              <TableHead className="text-sm font-semibold text-[#1d2129]">Category</TableHead>
              <TableHead className="text-sm font-semibold text-[#1d2129] text-right">Price</TableHead>
              <TableHead className="text-sm font-semibold text-[#1d2129]">Status</TableHead>
              <TableHead className="text-sm font-semibold text-[#1d2129]">Created</TableHead>
              <TableHead className="text-sm font-semibold text-[#1d2129] text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filtered.map(p => (
              <TableRow key={p.id} className="h-[52px] border-b border-[#e5e6eb]">
                <TableCell className="text-sm text-[#1d2129]">{p.name}</TableCell>
                <TableCell className="text-sm text-[#4e5969]">{p.category}</TableCell>
                <TableCell className="text-sm text-[#1d2129] text-right">{fmtPrice(p.price)}</TableCell>
                <TableCell>
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${STATUS_STYLES[p.status]}`}>
                    {p.status}
                  </span>
                </TableCell>
                <TableCell className="text-sm text-[#4e5969] whitespace-pre-line">{fmtDate(p.createdAt)}</TableCell>
                <TableCell className="text-right">
                  <div className="flex items-center justify-end gap-2">
                    <Button variant="link" className="text-[#165dff] p-0 h-auto text-sm font-normal">
                      Manage
                    </Button>
                    <Button variant="ghost" size="icon" className="h-8 w-8 text-[#4e5969] hover:text-[#1d2129]">
                      <Settings className="h-4 w-4" />
                    </Button>
                    <Button variant="ghost" size="icon" className="h-8 w-8 text-[#4e5969] hover:text-[#1d2129]">
                      <Copy className="h-4 w-4" />
                    </Button>
                    <Button
                      variant="ghost" size="icon"
                      className="h-8 w-8 text-[#f53f3f] hover:text-[#f76560]"
                      onClick={() => setDeleteTarget(p)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      ) : (
        <div className="flex flex-col items-center justify-center py-16 text-[#86909c]">
          <Inbox className="h-12 w-12 mb-3 opacity-40" />
          <p className="text-sm">No results found</p>
        </div>
      )}

      {/* Delete Confirmation Dialog */}
      <AlertDialog open={!!deleteTarget} onOpenChange={() => setDeleteTarget(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="text-[#1d2129]">Confirm Delete</AlertDialogTitle>
            <AlertDialogDescription className="text-[#4e5969]">
              Are you sure you want to delete "{deleteTarget?.name}"?
              This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel className="border-[#e5e6eb] text-[#4e5969]">Cancel</AlertDialogCancel>
            <AlertDialogAction
              className="bg-[#f53f3f] hover:bg-[#f76560] text-white"
              onClick={() => {
                // TODO: call delete API
                setDeleteTarget(null)
              }}
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  )
}
