---
name: ticket-writing
description: >
  Write Jira ticket descriptions for John using his preferred templates
  (Epic, Spike, Story) and Atlassian Document Format (ADF). Use when
  creating or rewriting ticket descriptions, especially epics.
---

# Ticket Writing

## When to use

- User asks to draft or rewrite a Jira ticket description
- User asks to create an epic, spike, or story with a description
- User says "write a ticket for X" or "draft an epic for X"

## Principles

1. **ADF only.** Descriptions are written as Atlassian Document Format
   JSON — never wiki markup (`h2.`, `*bold*`, `{code}`) and never
   Markdown. Pass ADF via `--fields-json '{"description": <adf>}'`.
2. **Templates guide structure.** Use the templates below as the
   skeleton. Sections marked "(optional)" can be omitted if not
   relevant.
3. **Draft first.** Show the user the rendered structure (Markdown
   preview) for approval before writing to Jira.
4. **Jira CRUD via /jira-cli.** For the actual create/update commands,
   load the jira-cli skill. This skill only owns what goes *inside*
   the description field.

## ADF Cheat Sheet

ADF is a JSON document with `{"version": 1, "type": "doc", "content":
[...]}`. Common node types:

```json
// Heading
{"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Section"}]}

// Paragraph
{"type": "paragraph", "content": [{"type": "text", "text": "Hello"}]}

// Bold text
{"type": "text", "text": "important", "marks": [{"type": "strong"}]}

// Bullet list
{"type": "bulletList", "content": [
  {"type": "listItem", "content": [
    {"type": "paragraph", "content": [{"type": "text", "text": "Item"}]}
  ]}
]}

// Ordered list
{"type": "orderedList", "content": [
  {"type": "listItem", "content": [
    {"type": "paragraph", "content": [{"type": "text", "text": "Step 1"}]}
  ]}
]}

// Nested list (nest bulletList/orderedList inside a listItem, after the paragraph)
{"type": "listItem", "content": [
  {"type": "paragraph", "content": [{"type": "text", "text": "Parent"}]},
  {"type": "bulletList", "content": [
    {"type": "listItem", "content": [
      {"type": "paragraph", "content": [{"type": "text", "text": "Child"}]}
    ]}
  ]}
]}

// Code block
{"type": "codeBlock", "content": [{"type": "text", "text": "code here"}]}

// Link
{"type": "text", "text": "link text", "marks": [{"type": "link", "attrs": {"href": "https://..."}}]}
```

Rules:
- Every listItem must contain at least one paragraph as its first child.
- Text nodes live inside paragraphs, headings, or codeBlocks — never
  directly under doc or listItem.
- Marks (strong, em, code, link) go on text nodes, not paragraphs.

## Templates

### Epic

```
## Overview
(1-2 paragraphs: what problem this solves and why)

## Acceptance Criteria
(bullet list of observable outcomes)

## Success Metric                         ← optional
(one line: how do we know this shipped?)

## Scope
**In scope:**
(bullet list)

**Out of scope:**
(bullet list)

## Requirement Detail
(subsections as needed — storage, API, validation, migration, etc.)

## Implementation Suggestions             ← optional
(ordered list or bullets of approach hints)
```

### Spike

```
## Goal
(1 sentence: what decision or artifact this produces)

## Context
(1-2 paragraphs: background the reader needs)

## Questions to Answer                    ← optional
(bullet list of unknowns to resolve)

## Acceptance Criteria
(bullet list — focus on deliverables: doc, decision, prototype)
```

### Story

```
## Context                                ← optional
(brief background if not obvious from the epic)

## Acceptance Criteria
(bullet list of done conditions)

## Technical Notes                        ← optional
(implementation hints, edge cases, dependencies)
```

## Workflow

1. User describes what the ticket is about.
2. Pick the template (Epic/Spike/Story) based on issue type — ask if
   ambiguous.
3. Fill in the template from the user's description. Ask clarifying
   questions only for required sections that can't be inferred.
4. Present a Markdown preview of the description for approval.
5. On approval, build the ADF JSON and pass it via
   `--fields-json '{"description": ...}'` (for create or update).
