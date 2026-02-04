-- ============================================================================
-- QUICKSERVE DATABASE SETUP SCRIPT
-- ============================================================================
-- RUN THIS ENTIRE SCRIPT IN YOUR SUPABASE SQL EDITOR
-- This will create all necessary tables, storage buckets, and security policies
-- ============================================================================

-- 1. CREATE USERS TABLE (MOST IMPORTANT!)
-- This table stores user profiles for both customers and service providers
create table if not exists public.users (
  id uuid references auth.users on delete cascade primary key,
  email text not null unique,
  full_name text not null,
  role text not null check (role in ('customer', 'service_provider')),
  phone_number text,
  profile_image text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security on Users
alter table public.users enable row level security;

-- Users Table Policies
create policy "Users can read own profile"
  on public.users for select
  using ( auth.uid() = id );

create policy "Users can insert own profile"
  on public.users for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile"
  on public.users for update
  using ( auth.uid() = id );

-- 2. CREATE CATEGORIES TABLE
create table if not exists public.categories (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  icon text not null,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on Categories
alter table public.categories enable row level security;

-- Categories Policies (Public read)
create policy "Public Categories Read"
  on public.categories for select
  using ( true );

-- 4. Create the Storage Bucket for Service Images
insert into storage.buckets (id, name, public)
values ('services', 'services', true)
on conflict (id) do nothing;

-- 5. Set up Storage Policies (Allow public read, allow authenticated upload)
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'services' );

create policy "Authenticated Upload"
  on storage.objects for insert
  with check ( bucket_id = 'services' and auth.role() = 'authenticated' );

create policy "Authenticated Update"
  on storage.objects for update
  with check ( bucket_id = 'services' and auth.role() = 'authenticated' );

-- 6. Create Services Table (if not exists)
create table if not exists public.services (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text,
  price numeric not null,
  category_id uuid references public.categories(id),
  provider_id uuid references public.users(id),
  provider_name text,
  duration text,
  image_url text,
  rating numeric default 0,
  review_count integer default 0,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 7. Enable Row Level Security (RLS) on Services
alter table public.services enable row level security;

-- 8. Policies for Services
create policy "Public Services Read"
  on public.services for select
  using ( true );

create policy "Provider Create Services"
  on public.services for insert
  with check ( auth.role() = 'authenticated' );

create policy "Provider Update Own Services"
  on public.services for update
  using ( auth.uid() = provider_id );

-- 9. CREATE BOOKINGS TABLE
create table if not exists public.bookings (
  id uuid default gen_random_uuid() primary key,
  service_id uuid references public.services(id) on delete cascade not null,
  customer_id uuid references public.users(id) on delete cascade not null,
  provider_id uuid references public.users(id) on delete cascade not null,
  status text not null check (status in ('pending', 'confirmed', 'completed', 'cancelled', 'on_hold')) default 'pending',
  booking_date timestamp with time zone not null,
  total_amount numeric not null,
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 10. Enable RLS on Bookings
alter table public.bookings enable row level security;

-- 11. Bookings Policies
create policy "Users can read own bookings"
  on public.bookings for select
  using ( auth.uid() = customer_id or auth.uid() = provider_id );

create policy "Customers can create bookings"
  on public.bookings for insert
  with check ( auth.uid() = customer_id );

create policy "Customers and Providers can update own bookings"
  on public.bookings for update
  using ( auth.uid() = customer_id or auth.uid() = provider_id );

-- 12. CREATE NOTIFICATIONS TABLE
create table if not exists public.notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  booking_id uuid references public.bookings(id) on delete cascade,
  title text not null,
  message text not null,
  type text not null check (type in ('new_order', 'order_confirmed', 'order_cancelled', 'order_on_hold', 'order_completed')),
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 13. Enable RLS on Notifications
alter table public.notifications enable row level security;

-- 14. Notifications Policies
create policy "Users can read own notifications"
  on public.notifications for select
  using ( auth.uid() = user_id );

create policy "System can create notifications"
  on public.notifications for insert
  with check ( true );

create policy "Users can update own notifications"
  on public.notifications for update
  using ( auth.uid() = user_id );

-- 15. Create function to auto-create notifications when booking status changes
create or replace function notify_booking_status_change()
returns trigger as $$
declare
  notification_title text;
  notification_message text;
  notification_type text;
  target_user_id uuid;
begin
  -- Determine notification details based on status change
  if NEW.status = 'confirmed' and OLD.status = 'pending' then
    notification_title := 'Order Confirmed!';
    notification_message := 'Your booking has been confirmed by the service provider.';
    notification_type := 'order_confirmed';
    target_user_id := NEW.customer_id;
  elsif NEW.status = 'cancelled' then
    notification_title := 'Order Cancelled';
    notification_message := 'Your booking has been cancelled.';
    notification_type := 'order_cancelled';
    target_user_id := NEW.customer_id;
  elsif NEW.status = 'on_hold' then
    notification_title := 'Order On Hold';
    notification_message := 'Your booking has been put on hold by the service provider.';
    notification_type := 'order_on_hold';
    target_user_id := NEW.customer_id;
  elsif NEW.status = 'completed' then
    notification_title := 'Order Completed';
    notification_message := 'Your booking has been completed. Thank you!';
    notification_type := 'order_completed';
    target_user_id := NEW.customer_id;
  elsif NEW.status = 'pending' and OLD.status is null then
    -- New booking created - notify provider
    notification_title := 'New Order Received!';
    notification_message := 'You have received a new booking request.';
    notification_type := 'new_order';
    target_user_id := NEW.provider_id;
  else
    return NEW;
  end if;

  -- Create notification
  insert into public.notifications (user_id, booking_id, title, message, type)
  values (target_user_id, NEW.id, notification_title, notification_message, notification_type);

  return NEW;
end;
$$ language plpgsql security definer;

-- 16. Create trigger for booking notifications
drop trigger if exists booking_status_change_trigger on public.bookings;
create trigger booking_status_change_trigger
  after insert or update of status on public.bookings
  for each row
  execute function notify_booking_status_change();

