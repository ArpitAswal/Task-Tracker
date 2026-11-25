---
description: Generate or update project documentation — context.md, README.md, or CHANGELOG.md — with strict quality gates that prevent implementation bloat and ensure every entry is architecture-level.
---

## Step 0 — Quality Gate (Mandatory — Run Before Any Write)

Load `skills/context-and-decisions/SKILL.md` and pass every piece of information through its three filters:

1. **WHY vs WHAT**: Include architectural rationale (why a technology was chosen). Reject implementation mechanics (widget names, pixel math, layout percentages).
2. **Stability**: Include decisions stable over months. Reject volatile data (private keys, local Firebase IDs, sprint-specific task notes).
3. **Audience**: Include content that orients a developer to Task Tracker's architecture. Reject OS history tutorials and blog-style Q&A sections.

**If any information fails any filter → reject it. Do not write it into the document. Move on.**

---

## Step 1 — Identify Target Document

| Document | Trigger | Persona to Load |
|---|---|---|
| `context.md` | New library added, architectural pattern changed, project phase shift | `personas/documentation-writer.md` |
| `CHANGELOG.md` | New version being released, feature merged, bug shipped | `personas/documentation-writer.md` |
| `README.md` | New feature visible to external developers, setup steps changed | `personas/documentation-writer.md` |

---

## Step 2 — Read Current State

1. Read the full current content of the target file.
2. Read `context.md` for current project architectural context.
3. For `CHANGELOG.md`: run `git log --oneline -20` to gather commit messages — distil them through the quality gate before writing.
4. Never overwrite content that is still accurate.

---

## Step 3 — Write Using Per-Document Rules

### `context.md` Gate
- [ ] Explains a *why* (trade-off, constraint, choice), not a *what* (class name, widget, pixel value).
- [ ] No pixel dimensions (`dp`, `px`, `%` layout ratios).
- [ ] No widget/internal class names (`Consumer<TaskProvider>`, `PageView`, `CustomPainter`).
- [ ] File length stays **under 150 lines** after the addition.

### `CHANGELOG.md` Gate
- [ ] Describes a **user-visible outcome**, not a code change.
- [ ] No code variable or method names (`_disposed`, `zonedSchedule`, `TaskFilterState`).
- [ ] No hardcoded secrets, local Firebase IDs, or pixel math (`38% left pane`, `380dp`).
- [ ] No GitHub release artifact prose — link to the GitHub Releases page instead.

### `README.md` Gate
- [ ] Never include real private keys or project secrets (safe placeholders only).
- [ ] No tutorial or Q&A section teaching general OS history — link to official docs instead.
- [ ] No duplicate feature lists across sections.
- [ ] No widget-tree-level detail in architecture sections.

---

## Step 4 — Apply and Review

1. Apply all changes to the target file.
2. Re-read the full file and apply the three filters from Step 0 one final time on the complete output.
3. Fix any violation before proceeding.

---

## Step 5 — Report and Stop for Review

Output a summary of changes:
- What was added / changed / removed.
- How many quality violations were rejected and what category they fell into (WHY/WHAT, Stability, Audience).
- Current line count for `context.md`.

**Stop here. Do not finalize until the user reviews the summary.**
