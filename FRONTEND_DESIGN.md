# 🎨 Frontend Design System

> Minimalist, mobile-first design system for optimized for clarity, speed, and focus.

---

## 🎯 Design Principles

- **Minimalism**: Remove unnecessary elements. Focus on content and action.
- **Mobile-First**: Design for small screens first, then scale up for desktop.
- **High Contrast**: Ensure readability in both light and dark modes.
- **Consistent Spacing**: Use a strict 4px base unit grid system.

---

## 🌓 Color Palette

We use HSL variables for flexible opacity and easy theme switching.

### ☀️ Light Mode (Normal)

| Variable | HSL Value | Usage |
| :--- | :--- | :--- |
| `--background` | `0 0% 100%` | Main page background |
| `--foreground` | `240 10% 3.9%` | Primary text |
| `--card` | `0 0% 100%` | Card backgrounds |
| `--card-foreground` | `240 10% 3.9%` | Card text |
| `--popover` | `0 0% 100%` | Modals and tooltips |
| `--popover-foreground` | `240 10% 3.9%` | Popover text |
| `--primary` | `240 5.9% 10%` | Buttons, active states |
| `--primary-foreground` | `0 0% 98%` | Text on primary |
| `--secondary` | `240 4.8% 95.9%` | Subtle buttons, accents |
| `--secondary-foreground` | `240 5.9% 10%` | Text on secondary |
| `--muted` | `240 4.8% 95.9%` | De-emphasized backgrounds |
| `--muted-foreground` | `240 3.8% 46.1%` | De-emphasized text |
| `--accent` | `240 4.8% 95.9%` | Hover states |
| `--accent-foreground` | `240 5.9% 10%` | Text on accent |
| `--destructive` | `0 84.2% 60.2%` | Error states, delete actions |
| `--destructive-foreground` | `0 0% 98%` | Text on destructive |
| `--success` | `142 76% 36%` | Success states, confirmations |
| `--success-foreground` | `0 0% 98%` | Text on success |
| `--warning` | `38 92% 50%` | Warning states, cautions |
| `--warning-foreground` | `240 10% 3.9%` | Text on warning |
| `--border` | `240 5.9% 90%` | Dividers and borders |
| `--input` | `240 5.9% 90%` | Form field borders |
| `--ring` | `240 5.9% 10%` | Focus ring color |
| `--radius` | `0.5rem` | Default border radius |

### 🌙 Dark Mode

| Variable | HSL Value | Usage |
| :--- | :--- | :--- |
| `--background` | `240 10% 3.9%` | Main page background |
| `--foreground` | `0 0% 98%` | Primary text |
| `--card` | `240 10% 3.9%` | Card backgrounds |
| `--card-foreground` | `0 0% 98%` | Card text |
| `--popover` | `240 10% 3.9%` | Modals and tooltips |
| `--popover-foreground` | `0 0% 98%` | Popover text |
| `--primary` | `0 0% 98%` | Buttons, active states |
| `--primary-foreground` | `240 5.9% 10%` | Text on primary |
| `--secondary` | `240 3.7% 15.9%` | Subtle buttons, accents |
| `--secondary-foreground` | `0 0% 98%` | Text on secondary |
| `--muted` | `240 3.7% 15.9%` | De-emphasized backgrounds |
| `--muted-foreground` | `240 5% 64.9%` | De-emphasized text |
| `--accent` | `240 3.7% 15.9%` | Hover states |
| `--accent-foreground` | `0 0% 98%` | Text on accent |
| `--destructive` | `0 62.8% 30.6%` | Error states, delete actions |
| `--destructive-foreground` | `0 0% 98%` | Text on destructive |
| `--success` | `142 69% 28%` | Success states, confirmations |
| `--success-foreground` | `0 0% 98%` | Text on success |
| `--warning` | `38 92% 40%` | Warning states, cautions |
| `--warning-foreground` | `0 0% 98%` | Text on warning |
| `--border` | `240 3.7% 15.9%` | Dividers and borders |
| `--input` | `240 3.7% 15.9%` | Form field borders |
| `--ring` | `240 4.9% 83.9%` | Focus ring color |
| `--radius` | `0.5rem` | Default border radius |

---

## 🔤 Typography

### Font Stack

| Category | Font Family | Fallback |
| :--- | :--- | :--- |
| **Sans** | Inter | `system-ui, -apple-system, sans-serif` |
| **Mono** | JetBrains Mono | `ui-monospace, monospace` |

### Font Sizes

| Token | Size | Line Height | Usage |
| :--- | :--- | :--- | :--- |
| `text-xs` | 12px (0.75rem) | 16px (1rem) | Captions, badges |
| `text-sm` | 14px (0.875rem) | 20px (1.25rem) | Secondary text, labels |
| `text-base` | 16px (1rem) | 24px (1.5rem) | Body text (default) |
| `text-lg` | 18px (1.125rem) | 28px (1.75rem) | Emphasized body |
| `text-xl` | 20px (1.25rem) | 28px (1.75rem) | Subheadings |
| `text-2xl` | 24px (1.5rem) | 32px (2rem) | Section headings |
| `text-3xl` | 30px (1.875rem) | 36px (2.25rem) | Page titles |
| `text-4xl` | 36px (2.25rem) | 40px (2.5rem) | Hero headings |

### Font Weights

| Token | Weight | Usage |
| :--- | :--- | :--- |
| `font-normal` | 400 | Body text |
| `font-medium` | 500 | Labels, buttons |
| `font-semibold` | 600 | Subheadings, emphasis |
| `font-bold` | 700 | Headings, strong emphasis |

---

## 📐 Spacing & Sizing

Based on a **4px base unit** for consistent rhythm.

### Spacing Scale

| Token | Value | Pixels | Usage |
| :--- | :--- | :--- | :--- |
| `0` | 0 | 0px | Reset |
| `0.5` | 0.125rem | 2px | Micro adjustments |
| `1` | 0.25rem | 4px | Tight spacing |
| `2` | 0.5rem | 8px | Compact elements |
| `3` | 0.75rem | 12px | Small gaps |
| `4` | 1rem | 16px | Default spacing |
| `5` | 1.25rem | 20px | Medium gaps |
| `6` | 1.5rem | 24px | Section padding |
| `8` | 2rem | 32px | Large gaps |
| `10` | 2.5rem | 40px | Container padding |
| `12` | 3rem | 48px | Section margins |
| `16` | 4rem | 64px | Page sections |
| `20` | 5rem | 80px | Hero spacing |
| `24` | 6rem | 96px | Large separators |

### Component Sizing

| Token | Value | Usage |
| :--- | :--- | :--- |
| `h-9` | 36px | Small buttons, inputs |
| `h-10` | 40px | Default buttons, inputs |
| `h-11` | 44px | Touch-friendly targets |
| `h-12` | 48px | Large buttons |
| `h-14` | 56px | Mobile nav items |

---

## 📱 Breakpoints & Responsive

### Breakpoint Scale

| Prefix | Min Width | Target |
| :--- | :--- | :--- |
| (default) | 0px | Mobile phones (portrait) |
| `sm` | 640px | Mobile phones (landscape) |
| `md` | 768px | Tablets |
| `lg` | 1024px | Small laptops, tablets landscape |
| `xl` | 1280px | Desktops |
| `2xl` | 1536px | Large desktops |

### Layout Patterns

| Breakpoint | Columns | Container Max | Navigation |
| :--- | :--- | :--- | :--- |
| Mobile | 1 | 100% | Bottom bar / hamburger |
| `sm` | 1-2 | 640px | Bottom bar / hamburger |
| `md` | 2-3 | 768px | Sidebar (collapsible) |
| `lg` | 3-4 | 1024px | Sidebar + header |
| `xl`+ | 4-6 | 1280px | Full sidebar + header |

### Mobile-First Rules

1. **Single Column**: Content defaults to a single column on mobile.
2. **Touch Targets**: Minimum 44x44px for all interactive elements.
3. **Navigation**: Bottom navigation bar or hamburger menu on mobile; sidebar/header on desktop.
4. **Content Priority**: Show essential content first; progressive disclosure for secondary actions.
5. **Thumb Zone**: Place primary actions within easy thumb reach on mobile.

---

## 🏗️ Components

- **Cards**: Minimal borders (`1px`) or very subtle shadows. Standard border radius (`--radius`).
- **Inputs**: Clean, outlined styles with clear focus ring (`--ring`) indicators.
- **Buttons**: Flat or very slight gradient. Focus on clear labels and icons (Lucide).
- **Transitions**: Fast (150ms-200ms) ease-in-out for theme switching and interactive states.
- **Shadows**: Use sparingly. Prefer `shadow-sm` for subtle elevation, `shadow-md` for modals.
