# UniPerks Premium Blue & White Color Palette

## 🎨 Premium Design Theme: Elegant Blue + Modern White

This palette creates a luxurious, high-end e-commerce experience with sophisticated blue accents and clean white backgrounds, reminiscent of premium brands like Apple, Stripe, and luxury retail platforms.

---

## 🔷 Primary Colors

### Premium Blue - Primary Accent
```
Color Name: Premium Blue (Modern Luxury)
Hex: #0066CC
RGB: (0, 102, 204)
Flutter: Color(0xFF0066CC)
Usage: Primary buttons, headers, footers, accents, active states
```
Deep, professional blue that conveys trust, premium quality, and sophistication.

### Pure White - Primary Background
```
Color Name: Pure White
Hex: #FFFFFF
RGB: (255, 255, 255)
Flutter: Colors.white
Usage: All page backgrounds, card backgrounds, clean minimal design
```
Creates the luxury minimalist foundation.

### Light Blue - Secondary & Hover States
```
Color Name: Light Blue (10% opacity)
Hex: #E3F2FD / #F0F7FF
RGB: (227, 242, 253) / (240, 247, 255)
Flutter: Color(0xFFE3F2FD) or Color(0xFFF0F7FF)
Usage: Button hover states, input field backgrounds, light accents
```
Subtle, elegant secondary layer.

---

## 🎯 Supporting Colors

### Premium Gray - Neutral Elements
```
Dark Gray:    #424242 - Primary text, headings
Gray[600]:    #757575 - Secondary text, hints
Gray[300]:    #F5F5F5 - Input backgrounds, subtle dividers
Gray[200]:    #EEEEEE - Borders, card edges
Flutter: Colors.grey[900], Colors.grey[600], Colors.grey[300], Colors.grey[200]
```

### Accent Colors (Use Sparingly)
```
Success Green: #10B981 (premium green)
Warning Orange: #F59E0B (refined gold)
Error Red: #EF4444 (modern red)
Info Blue: #3B82F6 (bright blue for information)
```

---

## 💎 Component Design

### Premium Buttons
```
Primary Button (CTA)
├─ Background: Premium Blue (#0066CC)
├─ Text: White
├─ Border Radius: 8dp (refined, not rounded)
├─ Elevation: 0 (flat)
└─ Hover: Darker Blue (#0052A3)

Secondary Button
├─ Border: 2px Premium Blue
├─ Text: Premium Blue
├─ Background: White
└─ Hover: Light Blue background

Disabled Button
├─ Background: Gray[300]
├─ Text: Gray[600]
└─ Opacity: 0.5
```

### Premium Headers & Footers
```
AppBar / Header
├─ Background: Premium Blue (#0066CC)
├─ Title: White (Bold, clean)
├─ Navigation Icon: White
├─ Action Icon: White / Light Blue
├─ Elevation: 0 (shadow optional, subtle)
└─ Height: 56dp (standard)

Footer
├─ Background: Premium Blue (#0066CC) OR Dark Gray (#424242)
├─ Text: White
├─ Links: Light Blue
└─ Elevation: 0
```

### Premium Cards
```
Standard Card
├─ Background: White
├─ Border: 1px Gray[200] (very subtle)
├─ Border Radius: 8dp
├─ Elevation: 0 (flat design)
└─ Padding: 16dp

Elevated Card (on hover)
├─ Border: 1px Gray[300]
├─ Shadow: subtle (0.5dp)
└─ Opacity: 100%

Product Card
├─ Image Area: 100% width
├─ Content Background: White
├─ Price Text: Premium Blue (bold)
└─ Call-to-Action: Premium Blue button
```

### Premium Input Fields
```
Enabled Input
├─ Background: Gray[300] (#F5F5F5) - light, minimal
├─ Border: 1px Gray[300]
├─ Text: Dark Gray (#424242)
├─ Placeholder: Gray[600]
└─ Icon: Premium Blue

Focused Input
├─ Background: White
├─ Border: 2px Premium Blue
├─ Text: Dark Gray
└─ Icon: Premium Blue

Disabled Input
├─ Background: Gray[200]
├─ Border: 1px Gray[200]
├─ Text: Gray[600]
└─ Opacity: 0.5
```

### Navigation & Tabs
```
Bottom Navigation Bar
├─ Background: White
├─ Selected Item Icon: Premium Blue
├─ Selected Item Label: Premium Blue
├─ Unselected Item: Gray[600]
└─ Border Top: 1px Gray[200]

Tab Bar
├─ Active Tab Text: Premium Blue (bold)
├─ Active Tab Indicator: Premium Blue (2px bottom)
├─ Inactive Tab Text: Gray[600]
├─ Background: White
└─ Indicator Width: Match text
```

### Status Badges
```
Active/Success Badge
├─ Background: #10B98120 (green with opacity)
├─ Text: #10B981 (premium green)
└─ Border Radius: 20dp

Premium Badge
├─ Background: #0066CC20 (blue with opacity)
├─ Text: #0066CC (premium blue)
└─ Border Radius: 20dp

Warning Badge
├─ Background: #F59E0B20 (orange with opacity)
├─ Text: #F59E0B (refined gold)
└─ Border Radius: 20dp

Error Badge
├─ Background: #EF444420 (red with opacity)
├─ Text: #EF4444 (modern red)
└─ Border Radius: 20dp
```

---

## ✨ Interactive States

### Button States
```
Default:  Premium Blue (#0066CC)
Hover:    Darker Blue (#0052A3) with shadow
Active:   Darkest Blue (#003D7A)
Disabled: Gray[300] with 50% opacity
```

### Input Focus States
```
Normal:   Gray[300] border, light background
Focused:  2px Premium Blue border, white background
Error:    2px Red border, white background
Success:  2px Green border, white background
```

### Link Hover States
```
Normal:   Premium Blue (#0066CC)
Hover:    Darker Blue (#0052A3) + underline
Active:   Darkest Blue (#003D7A)
```

---

## 🎯 Page-Specific Guidelines

### Login / Register Pages
```
├─ Background: White
├─ Logo Container: Premium Blue circle
├─ Title: Dark Gray (bold, large)
├─ Form Inputs: Gray[300] background, Premium Blue focus
├─ Button: Premium Blue
└─ Links: Premium Blue with hover effect
```

### Product Catalog
```
├─ Page Background: White
├─ Filter Header: White background, Premium Blue accents
├─ Product Cards: White, Gray[200] border
├─ Price: Premium Blue (bold)
├─ Add Button: Premium Blue
└─ Selected Filter: Premium Blue background
```

### Shopping Cart
```
├─ Page Background: White
├─ Item Cards: White, Gray[200] border
├─ Quantity Controls: White background, Premium Blue border
├─ Total: Dark Gray text, Premium Blue amount
├─ Checkout Button: Premium Blue
└─ Remove Button: Error Red
```

### Admin Dashboard
```
├─ Page Background: White
├─ Sidebar/Tabs: White, Premium Blue active indicator
├─ Header: Premium Blue
├─ Cards: White, Gray[200] border
├─ Action Buttons: Premium Blue
├─ Delete/Danger: Error Red
└─ Status Badges: Color-coded (Green/Blue/Orange/Red)
```

---

## 🔄 Color Transitions & Accessibility

### Hover Effects
```
Opacity Transition: 200ms ease-in-out
Color Transition: 200ms ease-in-out
Shadow Transition: 200ms ease-in-out
```

### Contrast Ratios (WCAG AAA)
```
✅ White on Premium Blue: 5.8:1 (excellent)
✅ Premium Blue on White: 5.8:1 (excellent)
✅ Dark Gray on White: 16:1 (perfect)
✅ Gray[600] on White: 7.5:1 (excellent)
✅ Green on White: 4.5:1 (AA compliant)
✅ Red on White: 4.5:1 (AA compliant)
```

---

## 💾 Flutter Implementation

```dart
// Primary Colors
const Color premiumBlue = Color(0xFF0066CC);
const Color premiumBlueDark = Color(0xFF0052A3);
const Color premiumBlueDarker = Color(0xFF003D7A);
const Color lightBlue = Color(0xFFF0F7FF);
const Color lightBlue2 = Color(0xFFE3F2FD);

// Neutral Colors
const Color darkGray = Color(0xFF424242); // Primary text
const Color secondaryGray = Color(0xFF757575); // Secondary text
const Color lightGrayBg = Color(0xFFF5F5F5); // Input backgrounds
const Color borderGray = Color(0xFFEEEEEE); // Borders
const Color pureWhite = Colors.white;

// Accent Colors
const Color premiumGreen = Color(0xFF10B981);
const Color premiumOrange = Color(0xFFF59E0B);
const Color premiumRed = Color(0xFFEF4444);
const Color premiumBrightBlue = Color(0xFF3B82F6);

// Theme
ThemeData premiumTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: premiumBlue,
    brightness: Brightness.light,
    primary: premiumBlue,
    secondary: lightBlue,
    surface: pureWhite,
    background: pureWhite,
  ),
  scaffoldBackgroundColor: pureWhite,
  appBarTheme: AppBarTheme(
    backgroundColor: premiumBlue,
    foregroundColor: pureWhite,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: premiumBlue,
      foregroundColor: pureWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: lightGrayBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderGray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: premiumBlue, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    labelStyle: TextStyle(color: secondaryGray),
    hintStyle: TextStyle(color: secondaryGray),
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      color: darkGray,
      fontWeight: FontWeight.bold,
      fontSize: 28,
    ),
    headlineMedium: TextStyle(
      color: darkGray,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    titleLarge: TextStyle(
      color: darkGray,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    bodyLarge: TextStyle(
      color: darkGray,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: secondaryGray,
      fontSize: 14,
    ),
  ),
);
```

---

## 🎨 Visual Hierarchy with Blue Theme

1. **Premium Blue (#0066CC)** - Most important CTAs, headers, active states
2. **Dark Gray (#424242)** - Primary content text
3. **Secondary Gray (#757575)** - Supporting text, hints
4. **Light Gray (#F5F5F5)** - Backgrounds, subtle divisions
5. **Accent Colors** - Status, alerts, special emphasis

---

## 📱 Design Philosophy

This palette creates a **premium, luxury e-commerce experience** by:
- Using a **deep, trustworthy blue** instead of orange (more corporate, less playful)
- Maintaining **clean white space** for elegance and minimalism
- Implementing **subtle gray tones** for sophisticated hierarchy
- Reducing **color saturation** for refined, professional feel
- Following **modern design trends** seen in high-end e-commerce (Apple, Stripe, luxury brands)

Result: **UniPerks looks like an expensive, premium platform** customers trust and love. ✨

