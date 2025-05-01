-- Create tables for Hawker Hub application

-- Users table to store user profiles
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  role TEXT NOT NULL CHECK (role IN ('user', 'hawker', 'admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);
  
CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);
  
CREATE POLICY "Admin can view all profiles" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admin can update all profiles" ON users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Hawkers table for hawker-specific data
CREATE TABLE IF NOT EXISTS hawkers (
  id UUID REFERENCES users(id) PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  location JSONB,
  is_verified BOOLEAN DEFAULT FALSE,
  is_open BOOLEAN DEFAULT FALSE,
  rating FLOAT DEFAULT 0,
  total_ratings INTEGER DEFAULT 0,
  profile_image TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE hawkers ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Hawkers can view their own profile" ON hawkers
  FOR SELECT USING (auth.uid() = id);
  
CREATE POLICY "Hawkers can update their own profile" ON hawkers
  FOR UPDATE USING (auth.uid() = id);
  
CREATE POLICY "Users can view verified hawkers" ON hawkers
  FOR SELECT USING (is_verified = TRUE);
  
CREATE POLICY "Admin can view all hawkers" ON hawkers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admin can update all hawkers" ON hawkers
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Inventory table for hawker items
CREATE TABLE IF NOT EXISTS inventory (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  hawker_id UUID REFERENCES hawkers(id) NOT NULL,
  name TEXT NOT NULL,
  quantity FLOAT NOT NULL,
  price FLOAT NOT NULL,
  unit TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Hawkers can manage their own inventory" ON inventory
  FOR ALL USING (
    hawker_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );
  
CREATE POLICY "Users can view inventory" ON inventory
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM hawkers WHERE id = hawker_id AND is_verified = TRUE
    )
  );

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) NOT NULL,
  hawker_id UUID REFERENCES hawkers(id) NOT NULL,
  total_amount FLOAT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  delivery_address TEXT NOT NULL,
  notes TEXT,
  rating FLOAT,
  is_rated BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own orders" ON orders
  FOR SELECT USING (user_id = auth.uid());
  
CREATE POLICY "Users can create orders" ON orders
  FOR INSERT WITH CHECK (user_id = auth.uid());
  
-- Simplified policy for ratings
CREATE POLICY "Users can update their own orders" ON orders
  FOR UPDATE USING (user_id = auth.uid());
  
-- Simplified policy for order status
CREATE POLICY "Hawkers can view their own orders" ON orders
  FOR SELECT USING (hawker_id = auth.uid());
  
CREATE POLICY "Hawkers can update their own orders" ON orders
  FOR UPDATE USING (hawker_id = auth.uid());
  
CREATE POLICY "Admin can view all orders" ON orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );
  
CREATE POLICY "Admin can update all orders" ON orders
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) NOT NULL,
  name TEXT NOT NULL,
  price FLOAT NOT NULL,
  quantity INTEGER NOT NULL,
  unit TEXT NOT NULL,
  negotiated_price FLOAT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders WHERE id = order_id AND user_id = auth.uid()
    )
  );
  
CREATE POLICY "Users can create order items" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders WHERE id = order_id AND user_id = auth.uid()
    )
  );
  
CREATE POLICY "Hawkers can view their own order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders WHERE id = order_id AND hawker_id = auth.uid()
    )
  );
  
CREATE POLICY "Admin can view all order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- IMPORTANT: Initial Admin Setup Instructions
/* 
   Instead of using the SQL function to create an admin user,
   follow these steps manually in the Supabase dashboard:

   1. Go to Authentication > Users in your Supabase dashboard
   2. Click "Invite user" 
   3. Enter email: admin@example.com
   4. After the user is created, note their UUID
   5. Go to the SQL Editor and run:
      
      INSERT INTO users (id, name, email, phone, role)
      VALUES ('97edc1a1-2d53-49b9-8720-d755d6b1f696', 'Admin User', 'austindsouza029@gmail.com', '+1111111111', 'admin');
      
   6. The admin user will need to complete the password setup through the email invitation
*/

-- Insert sample data (optional)
-- This is just an example of how to insert data once users are created
/*
INSERT INTO users (id, name, email, phone, role)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'John Doe', 'user@example.com', '+1234567890', 'user'),
  ('00000000-0000-0000-0000-000000000002', 'Raj Kumar', 'hawker@example.com', '+9876543210', 'hawker');

INSERT INTO hawkers (id, name, email, phone, address, is_verified, is_open)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 'Raj Kumar', 'hawker@example.com', '+9876543210', '123 Market St', true, true);
*/ 