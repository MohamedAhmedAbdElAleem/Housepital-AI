## Design System: Housepital

### Pattern
- **Name:** Glass & Grid Engine (Rich Dashboard)
- **Conversion Focus:** Visually rich, multi-layered dashboard. Overlapping 3D headers (Canopy), glassmorphism, and dense grids for actions. Premium, energetic, and tangible.
- **CTA Placement:** Integrated within rich gradient tiles and overlapping floating elements.
- **Color Strategy:** Deep, rich gradients using Brand colors + Secondary palettes. Glassmorphic overlays (white/black with alpha) for depth. Text: High-contrast White on rich backgrounds, Black/Dark grey on light surfaces.
- **Sections:** 1. Overlapping Canopy Header, 2. Glassmorphic Primary Cards (Wallet), 3. Dense 50/50 Grid Actions, 4. Horizontally scrolling dynamic carousels.

### Style
- **Name:** Premium Medical & Accessible
- **Keywords:** Glassmorphism, deep gradients, layered depth (z-axis overlap), large text (16px+), WCAG compliant contrast, solid energetic colors, large watermark background icons.
- **Best For:** Modern healthcare dashboards, premium patient apps, fintech-style wallets.
- **Performance:** ⚡ Excellent | **Accessibility:** ✓ WCAG AAA (maintaining contrast on gradients)

### Colors (Light Mode)
| Role | Hex | Description |
|------|-----|-------------|
| Primary | #2ECC71 | Healing Green (primary500) |
| Secondary | #3498BB | Trust Blue (secondary500) |
| Success / CTA | #43A048 | Actionable Medical Green (success500) |
| Warning | #FB8A00 | Alert Orange (warning500) |
| Wallet / Premium | #2B32B2 to #1488CC | Deep Indigo to Bright Blue Gradient |
| AI / Future | #667EEA to #764BA2 | Rich Purple to Magenta Gradient |
| Background | #F9F9F9 | Soft light background (light100) |
| Surface | #FDFDFD | Clean surface color (light50) |
| Text Primary | #232323 | High contrast dark grey (dark500) |

### Colors (Dark Mode)
| Role | Hex | Description |
|------|-----|-------------|
| Primary | #2ECC71 | Healing Green (primary500) - Kept for brand consistency |
| Secondary | #3498BB | Trust Blue (secondary500) |
| Success / CTA | #43A048 | Actionable Medical Green (success500) |
| Warning | #FB8A00 | Alert Orange (warning500) |
| Background | #0F0F0F | Deep dark background (dark900) |
| Surface | #191919 | Elevated dark surface (dark700) |
| Text Primary | #FDFDFD | High contrast light text (light50) |
| Text Secondary | #A7A7A7 | Muted light text (light700) |

*Notes: Gradients and glassmorphic overlays adapt to Dark Mode by adjusting shadow opacities and alpha channels, ensuring the UI remains rich but not blinding.*

### Typography
- **Heading (Primary):** Poppins
- **Body (Secondary):** Inter
- **Mood:** Modern, premium, energetic, trustworthy, cutting-edge
- **Best For:** Healthcare dashboards, patient apps, staff tracking
- **Google Fonts:** https://fonts.google.com/share?selection.family=Inter:wght@300;400;500;600;700|Poppins:wght@300;400;500;600;700
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Poppins:wght@300;400;500;600;700&display=swap');
```

### Key Effects
- **Depth & Overlap:** Elements physically overlap boundaries (e.g., pulling grids up over the header using negative transform offsets).
- **Glassmorphism:** Using `Colors.white.withAlpha(20)` for rings, borders, and overlays over solid gradients.
- **Watermarks:** Massive, semi-transparent icons (`size: 100+`, `alpha: 25`) placed in the bottom right of gradient tiles.
- **Soft Shadows:** Dropping harsh borders for soft, colored drop shadows (e.g., `blurRadius: 20`, matching the gradient color with `alpha: 80`).
- Clear focus rings, ARIA labels, 44x44px minimum touch targets.

### Avoid (Anti-patterns)
- Flat, isolated "floating island" cards with harsh grey borders.
- Excessive empty white space that feels like a "void".
- Unnecessary physics-defying animations (keep motion subtle and purposeful).

### Pre-Delivery Checklist
- [ ] No emojis as icons (use SVG: Heroicons/Lucide/Material Rounded)
- [ ] Overlapping elements do not block touch targets.
- [ ] Hover/Tap states with smooth transitions (150-300ms)
- [ ] Text contrast on gradient backgrounds meets WCAG AAA standards.
- [ ] Focus states visible for keyboard nav.
- [ ] Responsive: Elements scale down gracefully on 375px screens.