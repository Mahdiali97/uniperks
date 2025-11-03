# UniPerks Modern Design - Color & Style Guide

## Primary Colors

### White (Primary Background)
```dart
backgroundColor: Colors.white;
```
- Used for all page backgrounds
- Creates clean, minimalist appearance
- Used in all Scaffold backgrounds

### Orange (Primary Action/Accent)
```dart
Color: Colors.orange (default Flutter orange)
Hex: #FF9800
```
- Primary button color
- Icons for active actions
- Tab indicators
- Focus states on input fields
- Hover/selected states

### Amber (Coins/Rewards)
```dart
Color: Colors.amber
```
- Exclusive use for coins display
- Never mixed with other accent elements

### Gray (Inactive/Disabled States)
```dart
Color: Colors.grey[400-600]
```
- Disabled buttons
- Inactive tab items
- Secondary text

---

## Component Specifications

### Buttons

#### Primary Button (ElevatedButton)
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  ),
)
```
- **Height**: 56dp for primary actions
- **Radius**: 12dp
- **Elevation**: None (flat design)
- **Text Style**: Bold, 16-18px

#### Secondary Button (OutlinedButton)
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: const BorderSide(color: Colors.orange),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```
- **Border**: 1px orange
- **Radius**: 12dp
- **Background**: Transparent

### Cards

#### Standard Card
```dart
Card(
  elevation: 0,
  color: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: Colors.grey[200]!),
  ),
)
```
- **Elevation**: 0 (no shadow)
- **Border**: 1px `Colors.grey[200]`
- **Border Radius**: 12dp
- **Padding**: 12-16dp inside card

### Input Fields

#### TextFormField
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    prefixIcon: Icon(Icons.icon, color: Colors.orange),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.orange,
        width: 2,
      ),
    ),
  ),
)
```
- **Border Radius**: 12dp
- **Focus Color**: Orange (2px width)
- **Enabled Border**: Gray `Colors.grey[300]`
- **Icon Color**: Orange for active elements

### AppBar

#### Standard AppBar
```dart
AppBar(
  title: const Text(
    'Title',
    style: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: Colors.white,
  elevation: 0,
  iconTheme: const IconThemeData(color: Colors.black87),
  actions: [
    IconButton(
      icon: const Icon(Icons.action, color: Colors.orange),
      onPressed: () {},
    ),
  ],
)
```
- **Background**: White
- **Elevation**: 0
- **Title Color**: Black87, Bold
- **Icon Color**: Orange for actions, Black87 for navigation

### Bottom Navigation

#### BottomNavigationBar
```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: Colors.white,
  selectedItemColor: Colors.orange,
  unselectedItemColor: Colors.grey,
)
```
- **Background**: White
- **Selected**: Orange
- **Unselected**: Gray

### TabBar

#### TabBar
```dart
TabBar(
  labelColor: Colors.orange,
  unselectedLabelColor: Colors.grey,
  indicatorColor: Colors.orange,
)
```
- **Active Text**: Orange
- **Inactive Text**: Gray
- **Indicator**: Orange underline

---

## Typography Hierarchy

### Headings
- **Headline Large**: 32px - Page titles
- **Headline Medium**: 28px - Section headers
- **Headline Small**: 24px - Subsection titles
- **Title Large**: 22px - Card titles
- **Title Medium**: 16px - Item titles
- **Title Small**: 14px - Small titles

### Body Text
- **Body Large**: 16px - Primary content
- **Body Medium**: 14px - Secondary content
- **Body Small**: 12px - Tertiary content, hints

### Font Weight
- **Bold**: Headers, active states, prices, important info
- **Normal**: Body text, descriptions

---

## Spacing Standards

### Padding
- **Small**: 8dp - Inside small components
- **Medium**: 12-16dp - Inside cards, sections
- **Large**: 20-24dp - Page margins
- **Extra Large**: 32-40dp - Between major sections

### Margins
- **Between Cards**: 12dp vertical
- **Between Sections**: 24dp
- **From Edge**: 16dp
- **Section Dividers**: 20-24dp

---

## Border & Radius Standards

### Border Radius
- **Small Components**: 8dp (rare)
- **Standard**: 12dp (buttons, cards, input fields)
- **Large**: 16dp (large containers)
- **Circle**: 20dp+ (for circles)

### Borders
- **Card Borders**: 1px `Colors.grey[200]`
- **Input Enabled**: 1px `Colors.grey[300]`
- **Input Focused**: 2px `Colors.orange`
- **Chip Borders**: 1px color-based

---

## Elevation Rules

- **Removed**: Use 0 elevation on cards (modern flat design)
- **Buttons**: 0 elevation (keep flat)
- **Navigation**: Use borders instead of shadows
- **Depth**: Create with colors and borders, not shadows

---

## Icon Usage

### Icons Colors
- **Orange**: Primary actions, active states, selected items
- **Black87**: Navigation, app bar title
- **Gray**: Disabled, secondary actions
- **Amber**: Coins, rewards only
- **Green**: Success, active states
- **Red**: Errors, deletions, expired

### Icon Sizes
- **AppBar**: 24dp
- **Navigation**: 24dp (bottom nav)
- **Large Display**: 28-32dp
- **Card Icons**: 24-28dp
- **Inline Icons**: 16-18dp

---

## Status Colors

- **Success**: Green (`Colors.green`)
- **Error/Delete**: Red (`Colors.red`)
- **Warning**: Amber/Orange
- **Info**: Blue (`Colors.blue`)
- **Inactive/Disabled**: Gray

---

## Quick Reference

| Element | Main Color | Accent | Border |
|---------|-----------|--------|---------|
| Background | White | - | - |
| Primary Button | Orange | - | None |
| Card | White | - | Gray 200 |
| Input (Normal) | White | - | Gray 300 |
| Input (Focus) | White | - | Orange 2px |
| AppBar | White | - | None |
| Tab (Active) | - | Orange | Orange underline |
| Tab (Inactive) | - | Gray | - |
| Icon (Active) | Orange | - | - |
| Icon (Inactive) | Gray | - | - |

---

**Design Pattern**: Modern E-Commerce Flat Design with Clean Whites and Orange Accents
