# Purchase History Feature Setup

## Overview
Purchase History has been integrated directly into the **Profile Page**. Users can now view their past orders, items purchased, and vouchers applied at checkout.

## Changes Made

### 1. Database Schema (SUPABASE_MIGRATION.md)
Added three new database elements:

**user_carts** — Updated with voucher snapshot fields:
- `applied_voucher_id` (bigint)
- `applied_voucher_title` (text)
- `applied_voucher_discount` (integer, percentage)

**orders** — New table for purchase records:
- `id` (bigint, primary key)
- `username` (text)
- `subtotal`, `discount_amount`, `total_amount` (numeric)
- `item_count` (integer)
- `voucher_id`, `voucher_title`, `voucher_discount` (snapshot)
- `status` (text, default 'paid')
- `created_at` (timestamp)
- Index: `idx_orders_username_created_at`

**order_items** — New table for line items:
- `id` (bigint, primary key)
- `order_id` (bigint, foreign key)
- `product_id`, `product_name`, `image_url`
- `unit_price`, `quantity`, `line_total` (numeric)
- `created_at` (timestamp)
- Index: `idx_order_items_order_id`

### 2. Backend Models
- `lib/models/order.dart` — Order model with totals and voucher snapshot
- `lib/models/order_item.dart` — OrderItem model for line items

### 3. Backend Service
- `lib/services/order_service.dart` — Service to create and fetch orders:
  - `createOrder()` — Persists order and items to Supabase
  - `getOrdersForUser()` — Fetches user's order history (sorted by date, newest first)
  - `getOrderItems()` — Fetches items for a specific order

### 4. Checkout Integration
**lib/pages/cart_page.dart** — Updated `_proceedToCheckout()`:
- Rebuilds totals from current cart and applied voucher
- Calls `OrderService.createOrder()` to persist order + items
- Awards 10% cashback coins based on final total
- Clears cart and removes applied voucher
- Shows reward badge and success snackbar

### 5. UI — Profile Page
**lib/pages/profile_page.dart** — Enhanced with embedded Purchase History:
- "Purchase History" menu item now navigates to full order list page
- New embedded widgets:
  - `_PurchaseHistoryView` — Scaffold with order list
  - `_PurchaseHistoryViewState` — State management
  - `_OrderItemTile` — Individual order item display
- Order list shows:
  - Order ID, item count, total amount
  - Order date and time
  - Tap to see itemized details + voucher info (if used)

### 6. Navigation
- Removed "Purchase History" from user dashboard profile popup menu
- Purchase History now only accessible via **Profile Page** → "Purchase History" menu item

## SQL to Run in Supabase

Copy these into **Supabase SQL Editor** and run each block:

### Create orders table
```sql
CREATE TABLE orders (
  id bigint primary key generated always as identity,
  username text not null,
  subtotal numeric(10,2) not null default 0,
  discount_amount numeric(10,2) not null default 0,
  total_amount numeric(10,2) not null default 0,
  item_count integer not null default 0,
  voucher_id bigint,
  voucher_title text,
  voucher_discount integer,
  status text not null default 'paid',
  created_at timestamp not null default now()
);

CREATE INDEX idx_orders_username_created_at ON orders (username, created_at desc);
```

### Create order_items table
```sql
CREATE TABLE order_items (
  id bigint primary key generated always as identity,
  order_id bigint not null references orders(id) on delete cascade,
  product_id bigint,
  product_name text not null,
  image_url text,
  unit_price numeric(10,2) not null,
  quantity integer not null default 1,
  line_total numeric(10,2) not null,
  created_at timestamp not null default now()
);

CREATE INDEX idx_order_items_order_id ON order_items (order_id);
```

### Update user_carts (add voucher fields if not already present)
```sql
ALTER TABLE user_carts 
ADD COLUMN IF NOT EXISTS applied_voucher_id bigint,
ADD COLUMN IF NOT EXISTS applied_voucher_title text,
ADD COLUMN IF NOT EXISTS applied_voucher_discount integer;
```

## Feature Flow

1. **User browses products** → Adds to cart → Applies optional voucher
2. **User clicks "BUY NOW"** → Checkout dialog appears
3. **User confirms purchase** → OrderService creates order + items in DB
4. **Coins awarded** → 10% cashback on final total (after discount)
5. **Cart cleared** → Applied voucher removed
6. **Success badge & snackbar** → User sees confirmation
7. **User navigates to Profile** → Clicks "Purchase History"
8. **Order list loads** → Shows all past purchases sorted by date
9. **User taps an order** → Bottom sheet shows itemized details + voucher applied

## Files Changed

- `SUPABASE_MIGRATION.md` — Schema documentation
- `lib/models/order.dart` — New
- `lib/models/order_item.dart` — New
- `lib/services/order_service.dart` — New
- `lib/pages/cart_page.dart` — Updated checkout integration
- `lib/pages/profile_page.dart` — Updated with embedded purchase history
- `lib/user_dashboard.dart` — Removed purchase history from profile menu
- `lib/pages/purchase_history_page.dart` — Can be deleted (functionality now in profile_page.dart)

## Notes

- Vouchers are **snapshots** in the order (preserves what was applied at purchase time)
- Redeemed vouchers are **not marked as consumed** (can be reused). If single-use is desired, add a consumed flag.
- **Coins awarded** = 10% of final total (after all discounts)
- **Refresh indicator** on purchase history allows manual pull-to-refresh
- **Network errors** are caught; UI shows generic error message if needed
- Orders sorted by `created_at DESC` (newest first)

## Testing

1. Run `flutter pub get` (no new dependencies)
2. Run `flutter run` and log in as any user
3. Add products to cart
4. (Optional) Apply a voucher
5. Click "BUY NOW" → Confirm purchase
6. Observe coins awarded and reward badge
7. Navigate to Profile → "Purchase History"
8. See your order listed
9. Tap order to see details + items + voucher applied

## What's Next (Optional)

- Add a **filters** tab (by date range, price range, status)
- Add **export order** to PDF
- Mark orders as **delivered/pending** (admin-side)
- Implement **order cancellation** (within X days)
- Add **order notes** or **customer support** link per order
