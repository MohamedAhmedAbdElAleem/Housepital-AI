# 🌙 Housepital AI - Dark Mode Specification

This document defines the official Dark Mode standards for Housepital AI to ensure consistency across the Customer App, Staff App, and Admin Dashboard.

## 🎨 Dark Palette (Deep Slate & Obsidian)

Dark mode is not just inverted light mode. It uses a range of deep greys and blacks to maintain depth while being easy on the eyes.

### Surface & Background
| Role | Hex Code | Usage |
|------|----------|-------|
| **Background (Deep)** | `#0F0F0F` | Main app background (Dark-900) |
| **Surface (Primary)** | `#191919` | Main cards, sidebar, bottom nav (Dark-700) |
| **Surface (Secondary)** | `#202020` | Secondary containers, list items (Dark-600) |
| **Elevated Surface** | `#232323` | Modal dialogs, elevated cards (Dark-500) |
| **Borders / Dividers**| `#4F4F4F` | Subtle separation (Dark-400) |

### Text & Contrast
| Role | Hex Code | Usage |
|------|----------|-------|
| **Text Primary** | `#FDFDFD` | Main headings and body text (Light-50) |
| **Text Secondary** | `#A7A7A7` | Muted descriptions, labels (Light-700) |
| **Text Tertiary** | `#818181` | Placeholders, disabled text (Light-800) |
| **On Primary/Success**| `#FDFDFD` | Text on colored buttons |

---

## 🟢 Brand & Semantic Colors

Brand colors remain vibrant but are checked for contrast against `#0F0F0F`.

| Role | Light Mode Hex | Dark Mode Adjustment |
|------|----------------|----------------------|
| **Primary (Healing Green)** | `#2ECC71` | Keep (Primary-500) |
| **Secondary (Trust Blue)** | `#3498BB` | Keep (Secondary-500) |
| **Success (Medical Green)**| `#43A048` | Keep (Success-500) |
| **Warning (Alert Orange)** | `#FB8A00` | Keep (Warning-500) |
| **Error (Alert Red)** | `#F44336` | Keep (Error-500) |

---

## ✨ Effects & Visual Styles

### 1. Glassmorphism in Dark Mode
Instead of white-based glass, use semi-transparent dark layers with a subtle light border.
- **Fill:** `rgba(25, 25, 25, 0.7)`
- **Border:** `rgba(255, 255, 255, 0.05)` (A very thin, light stroke adds "edge" definition)
- **Blur:** `backdrop-filter: blur(12px)`

### 2. Gradients
Gradients should transition to darker shades to prevent "blinding" patches.
- **Wallet Gradient:** `#1488CC` to `#0B4A6F` (Darkened second stop)
- **AI Gradient:** `#667EEA` to `#4A367C` (Darkened second stop)

### 3. Shadows
Avoid black shadows on dark backgrounds. Use **inner glows** or **light strokes** for depth.
- **Elevation:** Instead of a shadow, use a slightly lighter surface color (e.g., move from Dark-700 to Dark-600).
- **Glow (Optional):** Use a low-opacity version of the primary color as a drop shadow for high-priority elements.

---

## 🛠️ Implementation Guide

### Flutter (Mobile)
Use the `AppColors` constants and the `Theme.of(context)` pattern.

```dart
// Example of accessing dark-safe colors
Container(
  color: Theme.of(context).colorScheme.surface, // Automatically switches
  child: Text(
    'Housepital AI',
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
)
```

### Tailwind (Admin Web)
Use the `dark:` utility class.

```html
<div class="bg-white dark:bg-dark-900 border-slate-200 dark:border-dark-400">
  <h1 class="text-slate-900 dark:text-light-50">Dashboard</h1>
  <p class="text-slate-500 dark:text-light-700">Welcome back</p>
</div>
```

---

## 🚫 Anti-Patterns
- **Pure Black (#000000):** Too harsh for OLED screens and kills depth. Use `#0F0F0F`.
- **Inverted Logos:** Never just invert the logo colors. Ensure the brand marks are legible on dark backgrounds using a white version or a glow.
- **Grey Text on Grey Background:** Always ensure a contrast ratio of at least 4.5:1 (WCAG AA).
- **Harsh White Borders:** Use `Dark-400` or `Dark-300` for borders, not light greys.

---

**Uniformity is Key.** Every element must respect the `Dark-X00` and `Light-X00` mapping defined here. 🌙
