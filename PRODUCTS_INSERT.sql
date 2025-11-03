-- ⚡ Sample Products Insert
-- Run this AFTER running SQL_QUICK_SETUP.md to populate the products table

INSERT INTO products (name, description, price, image_url, category, discount, rating) VALUES
-- Clothing
('University Hoodie', 'Comfortable cotton hoodie with embroidered university logo. Perfect for cool weather and campus life.', 45.99, 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400', 'Clothing', 20, 4.5),
('Campus T-Shirt', 'Official campus t-shirt made from 100% premium cotton. Available in multiple colors.', 24.99, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400', 'Clothing', 15, 4.3),
('UPSI Sports Jersey', 'Official UPSI sports jersey for athletics and recreation. Breathable fabric.', 35.99, 'https://images.unsplash.com/photo-1622445275576-721325c20a46?w=400', 'Clothing', 10, 4.7),
('University Cap', 'Adjustable cap with embroidered university crest. Perfect for sunny days.', 18.99, 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=400', 'Clothing', 0, 4.2),

-- Stationery
('Study Planner 2025', 'Academic year planner with monthly and weekly spreads. Includes goal-setting pages.', 12.99, 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400', 'Stationery', 15, 4.6),
('Premium Notebook Set', 'Set of 3 hardcover notebooks with lined pages. Perfect for lectures and notes.', 22.99, 'https://images.unsplash.com/photo-1517971129774-8a2b38fa128e?w=400', 'Stationery', 25, 4.4),
('Gel Pen Set (12 colors)', 'Smooth-writing gel pens in vibrant colors. Ideal for note-taking and highlighting.', 8.99, 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400', 'Stationery', 0, 4.1),
('Scientific Calculator', 'Advanced scientific calculator approved for exams. 240+ functions.', 28.99, 'https://images.unsplash.com/photo-1611532736579-6b16e2b50449?w=400', 'Stationery', 10, 4.8),

-- Accessories
('Laptop Bag', 'Durable laptop bag with padded compartment. Fits up to 15.6" laptops.', 35.99, 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400', 'Accessories', 25, 4.5),
('Coffee Mug', 'Insulated coffee mug with university branding. Keeps drinks hot for 6 hours.', 18.99, 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=400', 'Accessories', 10, 4.0),
('Water Bottle', 'Stainless steel water bottle with flip-top lid. 750ml capacity.', 15.99, 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400', 'Accessories', 0, 4.3),
('Tote Bag', 'Eco-friendly canvas tote bag with university logo. Perfect for books and supplies.', 12.99, 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=400', 'Accessories', 20, 4.2),
('USB Flash Drive 32GB', 'High-speed USB 3.0 flash drive. Store and transfer files quickly.', 16.99, 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=400', 'Accessories', 15, 4.4),

-- Books
('Study Skills Handbook', 'Comprehensive guide to effective study techniques and time management.', 29.99, 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400', 'Books', 30, 4.7),
('Mathematics Reference Guide', 'Essential mathematics formulas and concepts for university students.', 24.99, 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400', 'Books', 20, 4.6),
('English Grammar Mastery', 'Complete guide to English grammar with exercises and examples.', 19.99, 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400', 'Books', 10, 4.5),
('Research Methods Guide', 'Step-by-step guide to conducting academic research and writing papers.', 34.99, 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400', 'Books', 25, 4.8),

-- Electronics
('Wireless Mouse', 'Ergonomic wireless mouse with silent clicking. Long battery life.', 19.99, 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', 'Electronics', 0, 4.2),
('USB-C Hub', '7-in-1 USB-C hub with HDMI, USB ports, and SD card reader.', 42.99, 'https://images.unsplash.com/photo-1625948515291-69613efd103f?w=400', 'Electronics', 15, 4.6),
('Bluetooth Headphones', 'Wireless over-ear headphones with noise cancellation. 30-hour battery.', 79.99, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', 'Electronics', 20, 4.7),
('Portable Charger 10000mAh', 'Compact power bank with dual USB ports. Fast charging support.', 29.99, 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', 'Electronics', 10, 4.3);

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Successfully inserted 21 sample products!';
  RAISE NOTICE 'Categories: Clothing (4), Stationery (4), Accessories (5), Books (4), Electronics (4)';
END $$;
