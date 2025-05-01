# Supabase Setup Guide for Hawker Hub

This document guides you through setting up your Supabase backend for the Hawker Hub application.

## 1. Supabase Project Setup

1. Go to [Supabase](https://supabase.com/) and sign up/login
2. Create a new project
3. Note your project URL and anon key (public API key)
4. Update these in `lib/main.dart`

## 2. Database Schema Setup

Execute the following SQL in your Supabase SQL Editor:

```sql
-- Users table
CREATE TABLE public.users (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  role TEXT NOT NULL CHECK (role IN ('user', 'hawker', 'admin')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Hawkers table
CREATE TABLE public.hawkers (
  id UUID REFERENCES users(id) NOT NULL PRIMARY KEY,
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
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventory items
CREATE TABLE public.inventory (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  hawker_id UUID REFERENCES hawkers(id) NOT NULL,
  name TEXT NOT NULL,
  price FLOAT NOT NULL,
  quantity INTEGER NOT NULL,
  unit TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders table
CREATE TABLE public.orders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) NOT NULL,
  hawker_id UUID REFERENCES hawkers(id) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'completed', 'cancelled')),
  total_amount FLOAT NOT NULL,
  delivery_address TEXT NOT NULL,
  notes TEXT,
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  review TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Order items
CREATE TABLE public.order_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) NOT NULL,
  name TEXT NOT NULL,
  price FLOAT NOT NULL,
  quantity INTEGER NOT NULL,
  unit TEXT NOT NULL
);

-- Row Level Security Setup
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.hawkers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Users policies
CREATE POLICY "Users can view their own data" ON users
  FOR SELECT USING (auth.uid() = id);
  
CREATE POLICY "Admins can view all users" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Hawkers policies
CREATE POLICY "Public can view verified hawkers" ON hawkers
  FOR SELECT USING (is_verified = true);
  
CREATE POLICY "Hawkers can update their own data" ON hawkers
  FOR UPDATE USING (auth.uid() = id);
  
CREATE POLICY "Admins can manage all hawkers" ON hawkers
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Inventory policies
CREATE POLICY "Public can view inventory" ON inventory
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM hawkers WHERE id = inventory.hawker_id AND is_verified = true
    )
  );
  
CREATE POLICY "Hawkers can manage their inventory" ON inventory
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM hawkers WHERE id = inventory.hawker_id AND id = auth.uid()
    )
  );

-- Orders policies
CREATE POLICY "Users can view and create their orders" ON orders
  FOR SELECT USING (user_id = auth.uid());
  
CREATE POLICY "Users can create orders" ON orders
  FOR INSERT WITH CHECK (user_id = auth.uid());
  
CREATE POLICY "Hawkers can view orders assigned to them" ON orders
  FOR SELECT USING (
    hawker_id = auth.uid()
  );
  
CREATE POLICY "Hawkers can update their orders" ON orders
  FOR UPDATE USING (
    hawker_id = auth.uid()
  );

-- Order items policies
CREATE POLICY "Public can view order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders WHERE id = order_items.order_id AND 
      (user_id = auth.uid() OR hawker_id = auth.uid() OR
        EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
      )
    )
);
```

## 3. Create Admin User

1. Sign up a new user through the app or through Supabase Auth UI
2. In Supabase SQL Editor, run:

```sql
-- Replace 'user-id-here' with the actual UUID of the user you want to make admin
UPDATE users
SET role = 'admin'
WHERE id = 'user-id-here';
```

## 4. Set up Storage for Profile Images

1. Create a new bucket called 'profiles'
2. Set the bucket to public
3. Set up RLS policies:

```sql
-- Allow users to upload their own profile images
CREATE POLICY "Allow users to upload their own avatars"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'profiles' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow public access to profile images
CREATE POLICY "Give public access to profiles"
ON storage.objects FOR SELECT
USING (bucket_id = 'profiles');
```

## 5. Testing

1. You can use the app's built-in test functionality (purple cloud button in debug mode)
2. Make sure all CRUD operations work as expected

## 6. Troubleshooting

- Check the Supabase dashboard logs for any errors
- Verify the RLS policies are properly set up
- Ensure your app is using the correct Supabase URL and anon key 