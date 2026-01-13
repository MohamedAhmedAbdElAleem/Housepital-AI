# Housepital AI - Unified Branding Guidelines

## 🎨 Brand Identity

### Brand Name
**Housepital** / **Housepital AI**

### Tagline
*"Healthcare at Your Doorstep"* (Mobile)  
*"Real-time health informatics and patient management analytics"* (Admin)

### Brand Personality
- **Caring**: Medical-grade healthcare with a human touch
- **Accessible**: Healthcare at your doorstep
- **Trustworthy**: Professional and reliable service
- **Modern**: Technology-enabled healthcare solutions

---

## 🎯 Logo & Icon

### Primary Logo
- **Icon**: Medical cross / Shield with checkmark
- **Style**: Clean and modern
- **Container**: Circular or rounded square
- **Size**: 80px × 80px (login), 40px × 40px (sidebar/app bar)

### Logo Colors
- **Primary**: Green-500 (`#2ECC71`) - Healing Green
- **Icon Color**: White (`#FFFFFF`)
- **Background**: White with opacity or gradient

---

## 🎨 Color Palette

### Primary Colors (Healing Green)
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Primary 500** | `#2ECC71` | Primary actions, buttons, active states |
| **Primary 600** | `#2ABA67` | Hover states |
| **Primary 700** | `#219150` | Pressed states, dark accents |
| **Primary 400** | `#58D68D` | Light accents |
| **Primary 300** | `#73DDA0` | Very light accents |

### Secondary Colors (Trust Blue)
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| **Secondary 500** | `#3498DB` | Information, links |
| **Secondary 600** | `#2F8AAA` | Secondary actions |

### Neutral Colors (Slate)
| Color Name | Hex Code | Tailwind | Usage |
|------------|----------|----------|-------|
| **Slate 900** | `#0F172A` | `slate-900` | Primary text, dark backgrounds |
| **Slate 800** | `#1E293B` | `slate-800` | Secondary text, headings |
| **Slate 700** | `#334155` | `slate-700` | Tertiary text |
| **Slate 500** | `#64748B` | `slate-500` | Muted text, placeholders |
| **Slate 400** | `#94A3B8` | `slate-400` | Icons, disabled text |
| **Slate 200** | `#E2E8F0` | `slate-200` | Borders, dividers |
| **Slate 100** | `#F1F5F9` | `slate-100` | Subtle backgrounds |
| **Slate 50** | `#F8FAFC` | `slate-50` | Input backgrounds, cards |
| **White** | `#FFFFFF` | `white` | Main backgrounds, text on dark |

### Semantic Colors
| Purpose | Color | Hex Code | Usage |
|---------|-------|----------|-------|
| **Success** | Green-500 | `#2ECC71` | Approvals, success states |
| **Error** | Red-500 | `#F44336` | Rejections, errors, alerts |
| **Warning** | Orange-500 | `#FB8A00` | System updates, warnings |
| **Info** | Blue-500 | `#3498DB` | Information, registrations |

### Background Gradients
```css
/* Mobile App Login Background */
background: linear-gradient(135deg, #2ECC71 0%, rgba(46, 204, 113, 0.8) 50%, #0D9F6E 100%);

/* Admin Web Login Background */
background: linear-gradient(135deg, #0F172A 0%, #1E293B 100%);

/* Sidebar Background */
background: linear-gradient(180deg, #0F172A 0%, #1E293B 50%, #0F172A 100%);
```

---

## 📝 Typography

### Font Family
**Primary Font**: `Inter` (Web) / `SF Pro` (iOS) / `Roboto` (Android)

### Font Weights
- **Regular**: 400 (body text)
- **Medium**: 500 (labels, secondary headings)
- **Semibold**: 600 (buttons, important text)
- **Bold**: 700 (headings, emphasis)

### Type Scale
| Element | Size | Weight | Usage |
|---------|------|--------|-------|
| **Hero Title** | 36px | 700 | App name, main titles |
| **Page Title** | 26-32px | 700 | Page headings |
| **Section Title** | 20-24px | 600 | Section headings |
| **Body Large** | 18px | 500 | Important text |
| **Body** | 15-16px | 400 | Regular text |
| **Body Small** | 14px | 400 | Secondary text |
| **Caption** | 12px | 500 | Labels, metadata |

---

## 🎭 UI Components

### Buttons

#### Primary Button (Green)
```css
background: #2ECC71;
color: white;
padding: 14px 20px;
border-radius: 16px;
font-weight: 600;
box-shadow: 0 2px 8px rgba(46, 204, 113, 0.2);

hover {
  background: #2ABA67;
}
```

#### Secondary Button
```css
background: white;
color: #2ECC71;
border: 1px solid #E2E8F0;
padding: 12px 16px;
border-radius: 12px;
```

### Input Fields
```css
background: #F8FAFC;
border: 1px solid #E2E8F0;
border-radius: 14px;
padding: 14px 16px;
color: #1E293B;

focus {
  border-color: #2ECC71;
  box-shadow: 0 0 0 3px rgba(46, 204, 113, 0.1);
}
```

### Cards
```css
background: white;
border-radius: 24px;
padding: 24-28px;
box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
```

---

## 🎨 Design Principles

### Border Radius
- **Extra Large**: `24px` - Cards, containers
- **Large**: `16px` - Buttons, major elements
- **Medium**: `14px` - Input fields
- **Small**: `8-12px` - Small elements, badges

### Shadows
```css
/* Card Shadow */
box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);

/* Button Shadow */
box-shadow: 0 2px 8px rgba(46, 204, 113, 0.2);

/* Hover Shadow */
box-shadow: 0 6px 24px rgba(0, 0, 0, 0.12);
```

---

## 🔒 Login Page Branding

### Mobile App
- **Background**: Green gradient (#2ECC71 to #0D9F6E)
- **Logo**: White logo in circular container with glow
- **Card**: White with 24px border radius
- **Primary Button**: Green (#2ECC71)
- **Text**: Slate tones on white card

### Admin Web
- **Background**: Dark slate gradient (#0F172A to #1E293B)
- **Logo**: Green shield icon
- **Card**: White with 24px border radius  
- **Primary Button**: Green (#2ECC71) - **UPDATED**
- **Text**: Slate tones

---

## 📱 Platform Consistency

### Shared Elements
- **Primary Color**: Green (#2ECC71)
- **Success Color**: Green (#2ECC71)
- **Error Color**: Red (#F44336)
- **Border Radius**: 14-24px
- **Card Style**: White, rounded, shadowed
- **Typography**: Clean, modern, readable

### Platform Differences
- **Mobile**: Green gradient background, lighter feel
- **Web Admin**: Dark background, professional feel
- **Both**: Use green for primary actions and success states

---

## 🚀 Implementation Checklist

### Colors to Update
- [x] Change indigo-600 → green-500 (#2ECC71)
- [x] Change indigo-700 → green-600 (#2ABA67)
- [x] Keep slate colors for neutrals
- [x] Update button hover states to green
- [x] Update active navigation to green
- [x] Update focus rings to green

### Components to Update
- [ ] Login page button
- [ ] Sidebar active state
- [ ] Primary buttons across all pages
- [ ] Success indicators
- [ ] Focus states on inputs
- [ ] Active filters/tabs

---

**Last Updated**: January 13, 2026  
**Version**: 2.0.0 (Unified with Mobile App)  
**Primary Color**: Green (#2ECC71) - Healing Green
