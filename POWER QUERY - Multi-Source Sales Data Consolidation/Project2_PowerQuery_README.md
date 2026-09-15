# Project 2: Multi-Source Sales Data Consolidation (Power Query)

**Tool:** Excel Power Query (Get & Transform)
**Tool category in portfolio:** Single-tool mastery (Phase 1 of 7)

## The Business Problem

A company has 3 regional offices (Lagos, Abuja, Port Harcourt). Each exports its monthly
sales data independently, with **zero coordination** on format:

| | Office A (Lagos) | Office B (Abuja) | Office C (Port Harcourt) |
|---|---|---|---|
| Headers | `Rep Name`, `Deal Date`... | `Sales_Rep`, `Date_Closed`... | `name`, `closed_on`... |
| Date format | `YYYY-MM-DD` | `DD/MM/YYYY` | `MM/DD/YYYY` |
| Amount | Plain number | Text: `"$2,392,237"` | Plain number, **some blank** |
| Rep names | Title Case | ALL CAPS | mixed case, `"  extra spaces  "` |
| Issues | — | — | duplicate rows |

This is a near-exact replica of what happens at any multi-branch or multi-department
company before someone forces a standard. **Combining these by hand every month is the
single most common time-sink analysts complain about** — and it's exactly what Power Query
exists to automate permanently.

## Files in This Project

| File | Purpose |
|---|---|
| `PowerQuery_Practice_Source.xlsx` | 3 sheets of raw messy data — **your practice input** |
| `PowerQuery_Answer_Key.xlsx` | The target clean, combined output + a data quality log |
| `combined_clean_data.csv` / `data_quality_log.txt` | Same answer key, in raw form |

## Step-by-Step: How to Clean & Combine This in Power Query

Open `PowerQuery_Practice_Source.xlsx` in **desktop Excel** (Power Query needs the real
Excel app, not just any spreadsheet viewer) and follow this exactly:

### 1. Load each sheet as a query
`Data` tab → `From Table/Range` on each of the 3 sheets (select the data first). Excel will
ask to format as a Table — accept it. This opens the **Power Query Editor** for each source.

### 2. Clean Office A (Lagos) — the "clean-ish" one
- Confirm column types: `Deal Date` → Date, `Deal Amount` → Whole Number
- Rename columns to the standard schema: `Rep Name`, `Date`, `Amount`, `Product`
- Add a custom column: `Source Office` = `"Lagos HQ"`

### 3. Clean Office B (Abuja) — currency text + date format + casing
- `Amount ($)` column: `Transform` → `Extract` won't work on currency; instead use
  `Add Column` → `Custom Column` with:
  `= Number.From(Text.Remove([Amount ($)], {"$", ","}))`
- `Date_Closed`: Power Query may misread `DD/MM/YYYY` as `MM/DD/YYYY`. Set the column's
  **Locale** explicitly: right-click the column → `Change Type` → `Using Locale` →
  choose a locale that reads day-first correctly, or split/reconstruct via
  `Date.FromText([Date_Closed], "en-GB")`
- `Sales_Rep`: `Transform` → `Format` → `Capitalize Each Word` (fixes ALL CAPS)
- Rename columns to match the standard schema, add `Source Office = "Abuja Branch"`

### 4. Clean Office C (Port Harcourt) — whitespace, dupes, blanks
- `name`: `Transform` → `Format` → `Trim` (removes leading/trailing spaces), then
  `Capitalize Each Word`
- `closed_on`: set locale to `en-US` (month-first) when converting to Date type
- `amt`: filter out or flag blank rows — `Home` → `Remove Rows` → `Remove Blank Rows`,
  but **first duplicate the query** so you have an audit trail of what got removed
  (this is what the Data Quality Log sheet documents)
- `Home` → `Remove Rows` → `Remove Duplicates` (after selecting all columns) to catch the
  exact-duplicate row
- Rename columns, add `Source Office = "Port Harcourt Branch"`

### 5. Combine everything
`Home` → `Append Queries` → `Append as New` → select all 3 cleaned queries. This stacks
them into one table with identical column names — which only works because you standardized
the schema in steps 2–4 first.

### 6. Load it
`Close & Load To...` → `Table` → new worksheet. This becomes your single source of truth,
and — this is the entire point of Power Query — **next month, you just refresh the query**
(`Data` → `Refresh All`) instead of repeating this whole process by hand.

## Key Techniques Demonstrated

- Combining structurally different sources into one schema (schema standardization)
- Locale-aware date parsing (the #1 cause of silently-wrong dates in real data)
- Text cleanup: `Trim`, `Capitalize Each Word`, stripping currency symbols
- `Remove Duplicates` and `Remove Blank Rows` — with a documented audit trail, not silent deletion
- `Append Queries` to stack multiple sources into one table
- Building a **repeatable, refreshable** pipeline instead of a one-time manual fix

## How to Build Your Own Version

Any recurring multi-source consolidation works: weekly reports from different regional
managers, exports from different software systems that don't talk to each other, or your
own GPC Energy fleet logs if different depots export data differently. The pattern is
always: standardize schema → clean per-source quirks → append → load as a refreshable query.

## What to Say About This in an Interview

"I built a Power Query pipeline that consolidates 3 regional offices' sales exports —
each in a different date format, currency format, and naming convention — into one clean,
refreshable table, with a documented log of every row that was removed or corrected, so the
cleanup is auditable, not a black box."
