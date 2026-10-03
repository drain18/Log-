# Design system

This document is the reference you open every time you build a new screen, so keeping it current helps you more than it helps anyone reading.

## Fonts Used

- **Source Serif 4** (Bold) — headings, app name, screen titles
- **Plus Jakarta Sans** (Regular) — body text, captions, UI labels

## Palette

| Role | Color (hex) | Used For |
|---|---|---|
| Primary | `#2D4B3E` | main buttons, active states, app bar |
| Secondary / accent | `#8DAA91` | highlights, secondary actions |
| Background | `#F9F7F2` | screen background |
| Surface | `#FFFFFF` | cards, sheets, dialogs |
| Error | `#DC2626` | validation errors, destructive actions |
| Text (on background) | `#1E293B` / Neutral `#475569` | body text |

## Type scale

| Style | Font Family | Size (sp) | Weight | Used for |
|---|---|---|---|---|
| Heading | Source Serif 4 | 28–32 | Bold | Screen titles ("Log!", entry titles, "AI Summary") |
| Body | Plus Jakarta Sans | 16 | Regular | Entry text, lists, chat messages, normal content |
| Caption | Plus Jakarta Sans | 12–14 | Regular / Medium | Timestamps, hints, small labels, button text, calendar dates, "entry #1" |

## Spacing

**Base unit: 8 px**

- Tight spacing (between related items): 8 px
- Standard spacing (between sections / cards): 16 px
- Screen edge padding: 16 px (mobile) / 24 px (desktop)

Use multiples of 8 everywhere (padding, gaps, margins). This keeps every screen consistent with the clean, airy feel in your wireframes.

## Components

One row per reusable widget: what it is, which file it lives in, what parameters it takes, which screens use it.

| Component | Appears on screens | Looks like | Contains |
|---|---|---|---|
| App Bar / Header | Home, Entry, Record, Summary, Delete | Light background, "Log!" title left or center, optional date or back arrow | App name (Source Serif 4), optional navigation icons |
| Primary Button | Record, Summary, Delete, Entry | Solid `#2D4B3E`, white text, rounded (8–12 px radius) | Label ("Record", "Summarize", "Yes", "Save") |
| Secondary / Outlined Button | Delete dialog, Entry actions | Outlined or inverted version of primary | Label ("No", "Edit", "Delete") |
| Mic FAB / Record Button | Home, Entry, Record | Circular dark green button with mic icon at bottom center | Mic icon only |
| Entry Card / List Item | Home (calendar markers → list), Entry detail, Summary | Rounded rectangle, surface color, light border or shadow | Entry number, date (DD/MM/YY), text preview lines, optional delete/edit |
| Delete Confirmation Dialog | Entry (from calendar or list) | Centered modal, surface color, rounded | Title "delete this entry are you sure?", Yes/No buttons |
| AI Summary Box | Summary screen | Rounded surface container with subtle border | "AI Summary" label + summarized text |
| Progress / Waveform Indicator | Recording screen | Circular timer or horizontal progress + waveform bars | Time being recorded + play controls |
| Bottom Nav / Action Bar | Most screens (desktop especially) | Horizontal bar with Calendar / Record / Summarize | Icon + label buttons |
| Search / Input Field | (Future AI chat + typing option) | Rounded light field with search icon | Placeholder "Search" or free-text entry |
| Icon Button Set | Entry, Summary, Home | Small circular or square icon buttons | Single icon in primary or neutral color (edit, delete, home, search, profile) |

## Changes since the last version
- Initial population with project design system (Source Serif 4 & Plus Jakarta Sans typography).

