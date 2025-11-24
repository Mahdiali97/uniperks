-- Add delivery_method column to orders table
-- Run this in Supabase SQL Editor

ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS delivery_method text;

-- Optional: Add a check constraint to ensure valid values
ALTER TABLE orders 
ADD CONSTRAINT orders_delivery_method_check 
CHECK (delivery_method IS NULL OR delivery_method IN ('self_pickup', 'delivery'));
