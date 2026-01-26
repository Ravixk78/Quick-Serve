-- QuickServe Supabase Database Schema
-- Run this script in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- USERS TABLE
-- =============================================
-- Note: Auth users are managed by Supabase Auth
-- This table extends the auth.users with additional profile information

CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('customer', 'service_provider')),
    phone_number TEXT,
    profile_image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users can view own profile"
    ON public.users
    FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own profile"
    ON public.users
    FOR UPDATE
    USING (auth.uid() = id);

-- Anyone can insert (during signup)
CREATE POLICY "Anyone can create profile"
    ON public.users
    FOR INSERT
    WITH CHECK (true);

-- =============================================
-- CATEGORIES TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    icon TEXT NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Anyone can read categories
CREATE POLICY "Anyone can view categories"
    ON public.categories
    FOR SELECT
    USING (true);

-- Insert sample categories
INSERT INTO public.categories (name, icon, description) VALUES
    ('Cleaning', 'cleaning', 'Home & Office Cleaning Services'),
    ('Plumbing', 'plumbing', 'Repair & Installation Services'),
    ('Electrical', 'electrical', 'Wiring & Repair Services'),
    ('Carpentry', 'carpentry', 'Furniture & Fixture Services'),
    ('Painting', 'painting', 'Interior & Exterior Painting'),
    ('Landscaping', 'landscaping', 'Garden & Lawn Care Services')
ON CONFLICT DO NOTHING;

-- =============================================
-- SERVICES TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    image_url TEXT,
    rating NUMERIC(3, 2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    duration TEXT,
    provider_name TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

-- Anyone can read active services
CREATE POLICY "Anyone can view active services"
    ON public.services
    FOR SELECT
    USING (is_active = true);

-- Providers can manage their own services
CREATE POLICY "Providers can manage own services"
    ON public.services
    FOR ALL
    USING (auth.uid() = provider_id);

-- Insert sample services (you'll need to update provider_id and category_id)
-- After you create some service provider accounts, run:
-- INSERT INTO public.services (name, description, price, category_id, provider_id, provider_name, rating, review_count, duration)
-- VALUES ('Deep House Cleaning', 'Complete house cleaning with professional staff', 2500.00, 'category-uuid', 'provider-uuid', 'CleanPro Services', 4.8, 124, '3-4 hours');

-- =============================================
-- BOOKINGS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID REFERENCES public.services(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    booking_date TIMESTAMP WITH TIME ZONE NOT NULL,
    total_amount NUMERIC(10, 2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;

-- Customers can view their own bookings
CREATE POLICY "Customers can view own bookings"
    ON public.bookings
    FOR SELECT
    USING (auth.uid() = customer_id);

-- Providers can view bookings for their services
CREATE POLICY "Providers can view bookings for their services"
    ON public.bookings
    FOR SELECT
    USING (auth.uid() = provider_id);

-- Customers can create bookings
CREATE POLICY "Customers can create bookings"
    ON public.bookings
    FOR INSERT
    WITH CHECK (auth.uid() = customer_id);

-- Customers can update their own bookings (cancel)
CREATE POLICY "Customers can update own bookings"
    ON public.bookings
    FOR UPDATE
    USING (auth.uid() = customer_id);

-- Providers can update bookings for their services (confirm/complete)
CREATE POLICY "Providers can update bookings for their services"
    ON public.bookings
    FOR UPDATE
    USING (auth.uid() = provider_id);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_services_category ON public.services(category_id);
CREATE INDEX IF NOT EXISTS idx_services_provider ON public.services(provider_id);
CREATE INDEX IF NOT EXISTS idx_services_active ON public.services(is_active);
CREATE INDEX IF NOT EXISTS idx_bookings_customer ON public.bookings(customer_id);
CREATE INDEX IF NOT EXISTS idx_bookings_provider ON public.bookings(provider_id);
CREATE INDEX IF NOT EXISTS idx_bookings_service ON public.bookings(service_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_date ON public.bookings(booking_date);

-- =============================================
-- FUNCTIONS AND TRIGGERS
-- =============================================

-- Function to update service rating when a review is added (for future implementation)
CREATE OR REPLACE FUNCTION update_service_rating()
RETURNS TRIGGER AS $$
BEGIN
    -- This is a placeholder for future review functionality
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- VIEWS FOR COMMON QUERIES
-- =============================================

-- View for bookings with service and provider details
CREATE OR REPLACE VIEW bookings_with_details AS
SELECT 
    b.id,
    b.service_id,
    b.customer_id,
    b.provider_id,
    b.status,
    b.booking_date,
    b.total_amount,
    b.notes,
    b.created_at,
    s.name as service_name,
    s.image_url as service_image,
    s.provider_name,
    u.full_name as customer_name
FROM public.bookings b
LEFT JOIN public.services s ON b.service_id = s.id
LEFT JOIN public.users u ON b.customer_id = u.id;

-- =============================================
-- GRANT PERMISSIONS
-- =============================================

-- Grant access to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- =============================================
-- NOTES
-- =============================================

-- After running this script:
-- 1. Update lib/config/supabase_config.dart with your Supabase URL and anon key
-- 2. Create test accounts (customers and service providers)
-- 3. Add sample services using the Supabase dashboard or through the app
-- 4. Test the booking flow

-- To create a service provider account programmatically, you can use:
-- INSERT INTO public.users (id, email, full_name, role, created_at)
-- VALUES ('user-uuid-from-auth', 'provider@example.com', 'Provider Name', 'service_provider', NOW());

-- Remember to enable email confirmations in Supabase Auth settings if needed
-- For production, you should also set up:
-- - Email templates
-- - Password recovery
-- - Email confirmation
-- - Rate limiting
-- - Additional security policies
