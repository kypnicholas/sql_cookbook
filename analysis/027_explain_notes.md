

# Reading `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)` — A Performance Guide

Case study: “before” vs “after” for a Top‑N revenue query in Supabase/Postgres.

**Note**: node‑level annotated comparison at the bottom of this file focuses on the **biggest time nodes** in the plan. It is not a full node‑by‑node comparison.

---

## 0) What changed in the SQL?

### ✅ Query "before"
The “before” query includes an extra join relation:

- `JOIN public.customer c ON c.customer_id = i.customer_id`

### ✅ Query "after"
The “after” query **removes the join to `customer`**.

**Resulting behavior:** the engine still computes the same targets:

- `SUM(il.unit_price * il.quantity) AS revenue`
- `COUNT(*) AS line_items`
- Grouped by: `(ar.name, g.name)`
- Ordered by: `revenue DESC` with `LIMIT 10`.

> **The Core Difference:** One join subtree is entirely eliminated from the execution pipeline.

---

## 1) First glance: headline execution metrics

### 🔴 Before

- **Execution Time:** `7.355 ms`
- **Top-level node:** `Limit` with `Sort (top-N heapsort)`

### 🟢 After

- **Execution Time:** `6.776 ms`
- **Improvement:** `0.579 ms` (~7.87%)

This is the *what*. Next we explore the *why* by mapping execution steps.

---

## 2) Mental model: pipelines of work

Your plan is dominated by a classic pipeline:

```text
Join tree  →  Aggregate (Hashed)  →  Sort (top‑N heapsort)  →  Limit 10
```

Read this top‑down (or inside‑out):

1. **Join tree** — decides which rows exist and handles raw CPU / tuple‑matching overhead.
2. **Aggregate** — groups incoming rows into `(artist, genre)` buckets.
3. **Sort** — ranks the final buckets by `revenue DESC`.
4. **Limit** — returns only the top 10 items.

Even though sorting and aggregation look heavy, the structure and width of the **join tree** govern downstream input size and memory profile.

---

## 3) Key JSON fields (what to trace, with your plan’s numbers)

### A) Time placement fields

Always trace these anchors first:

- **`Actual Total Time`** — cumulative duration (ms) for a node, including children.
- **`Actual Startup Time`** — time until the node produced its first row.
- **`Actual Rows`** — number of rows emitted by the operator.
- **`Loops`** — how many times the operation repeated (multiplicative effect).

Top‑level `Limit` encapsulates the tree below it:

- **Before:** `7.055 ms`
- **After:** `6.528 ms`

### B) Strategy fields (planner choices that reveal shape)

Watch for:

- **`Hash Join / Join Type`** (`Inner`, `Left`)
- **`Aggregate -> Strategy`** — `Hashed`
- **`Sort -> Sort Method`** — `top‑N heapsort`

These indicate a hash‑based grouping and a partial sort optimized for `LIMIT` rather than a full sort.

### C) Spill / memory fields (green vs red flags)

Spilling to disk is the worst performance signal. Watch for:

- **`HashAgg Batches`** $> 1$ or any **`Disk Usage`** $> 0$.
- **`Sort Space Type`**: `Disk` (or non‑zero temp block counters).
- **`Temp Read Blocks / Temp Written Blocks`** non‑zero.

In your dataset:

- `HashAgg Batches`: `1`
- `Disk Usage`: `0`
- `Sort Space Type`: `Memory`
- `Temp * Blocks`: `0`

> **Detective interpretation:** the query runs fully in memory; bottlenecks are structural/CPU, not I/O.

### D) Buffers: I/O vs CPU overhead

With `BUFFERS` enabled you can tell whether work was I/O bound:

- **`Shared Read Blocks`**: `0`
- **`Shared Hit Blocks`**: `~75–77`

> **Detective interpretation:** dataset pages are cached in RAM (hit blocks). The speedup came from eliminating CPU cycles, not fewer disk reads.

---

## 4) Where the improvement likely came from (node‑level deltas)

### 🔍 The #1 meaningful delta: the customer branch is gone

The **"Before"** plan contained an inner hash join branch:

```json
"Hash Cond": "(i.customer_id = c.customer_id)",
"Join Type": "Inner"
```

That required building/probing hash tables to match invoices to customers. The **"After"** plan omits this branch. Removing it eliminates:

- Hash‑table build and probe overhead
- Join operator control‑flow logic
- Intermediate tuple formatting along the access path

Even though both plans finish with a `Hash Aggregate` and `top‑N heapsort`, the eliminated join reduced CPU and control overhead.

---

## 5) Why row counts can remain the same yet run faster

Despite identical final `Aggregate -> Actual Rows` and `LIMIT` outputs, total CPU work depends on:

- Number of logical operators executed per block
- Hash table compilation and key matching cycles
- **Tuple Width (`Plan Width`)** — narrower tuples are faster to process
- Depth and step count of the executor pipeline

Removing an unnecessary table shrinks these parameters and reduces runtime even when output cardinality is unchanged.

---

## 6) Conceptual before / after pipeline (visual)

### 🔴 BEFORE

```text
invoice_line
   ↓
[join invoice]
   ↓
[join customer]  <--- (extra runtime overhead)
   ↓
[join track]
   ↓
[join album]
   ↓
[join artist]
   ↓
[left join genre]
   ↓
Hash Aggregate
   ↓
Sort (top‑N heapsort)
   ↓
Limit 10
```

### 🟢 AFTER

```text
invoice_line
   ↓
[join invoice]
   ↓
[join track]
   ↓
[join album]
   ↓
[join artist]
   ↓
[left join genre]
   ↓
Hash Aggregate
   ↓
Sort (top‑N heapsort)
   ↓
Limit 10
```

Same pipeline pattern, but reduced execution footprint after removing the extra join.

---

## 7) Practical checklist for any `EXPLAIN (ANALYZE, BUFFERS, VERBOSE)` JSON

- [ ] **Find biggest time sinks:** isolate elements with the highest `Actual Total Time`.
- [ ] **Examine memory spilling:** check `Disk Usage`, `HashAgg Batches > 1`, or `Sort Space Type: Disk`.
- [ ] **Audit storage I/O:** verify `Shared Read Blocks` and temp I/O counters.
- [ ] **Compare estimates vs reality:** compare `Plan Rows` vs `Actual Rows` (stale stats can mislead the planner).
- [ ] **Identify strategies:** determine join types (`Hash`, `Nested Loop`, `Merge`), grouping style, and sort strategy.

---

## 8) Key takeaway from this case

Stripping an unnecessary join removes join‑tree operations and reduces CPU overhead even if output cardinalities match. This is especially convincing when your profile shows:

1. **Zero memory spill** (runs 100% in RAM)
2. **Zero physical disk reads** (fully cached blocks)
3. **Same high‑level pipeline** (`Join` → `Hash Agg` → `Top‑N Sort` → `Limit`)

---
---

## 027 - Node-level annotated comparison (biggest time nodes only)

### Query
Top-N revenue by `(artist, genre)` with `LIMIT 10` over the last `100 years`.

### Summary delta
- **Execution Time:** `7.355 ms (before)` → `6.776 ms (after)`
- **Improvement:** `-0.579 ms` (≈ **-7.87%**)

Primary reason indicated by the structural change: the *removed* `customer` join subtree reduces join-tree/operator overhead, while the rest of the pipeline (hash aggregation + top-N sort + limit) remains essentially the same.

---

### Node-level comparison (biggest time nodes)

| Node (level) | Before (Actual Total Time) | After (Actual Total Time) | Takeaway |
|---|---:|---:|---|
| `Limit` (top node) | **7.055 ms** | **6.528 ms** | The overall time is reduced. Since `Limit` wraps the whole subtree, the speedup must come from improvements inside the join → aggregate → sort pipeline. |
| `Aggregate` (Hashed) | **6.96 ms** | **6.438 ms** | Hash aggregation itself is slightly faster after optimization. No spill indicators are present (`HashAgg Batches = 1`, `Disk Usage = 0`). |
| `Sort` (top-N heapsort) | **7.052 ms** | **6.525 ms** | Sort is still using `top-N heapsort` and stays bounded by `LIMIT`. `Sort Space Type = Memory`, `Sort Space Used ~26` (no spill). |
| Join subtree (upper join chain near root) | **~5.543 ms** (hash join total) | **~4.974 ms** (hash join total) | The upper join chain time decreases after optimization, consistent with fewer/cheaper join operations in the executor. |
| `invoice_line ↔ invoice` join section | **~1.809 ms** | **~1.295 ms** | The join work in the portion involving `invoice_line` and the date-filtered `invoice` side is faster after the change. |
| Hash build from `track` | **0.527 ms** | **0.538 ms** | Track scan/build work is roughly the same; the delta is more about join-tree overhead/tuple processing than this single input scan. |

---

### Plain takeaways

- **Biggest time is inside the same pipeline:** join-tree work feeds into **Hash Aggregate** and then **top-N Sort** (followed by `Limit`).
- **No spill / no temp I/O bottleneck:**  
  - `HashAgg Batches = 1`, `Disk Usage = 0`  
  - `Sort Space Type = Memory` and no temp read/write blocks  
  → the speedup is **not** from reducing disk/memory spills.
- **The join-tree got cheaper:**  
  - The **upper hash join / join chain** shows a meaningful time reduction (`~5.543 ms → ~4.974 ms`).
  - This aligns with the structural query change (removing the `customer` join subtree).
- **Final cardinality is similar:** grouped results still end up with the same order of magnitude, but **operator cost** decreases (less join overhead / fewer intermediate tuples processed), resulting in the reduced total runtime.


***

