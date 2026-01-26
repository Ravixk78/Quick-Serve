-- RUN THIS IN YOUR SUPABASE SQL EDITOR TO FIX "BUCKET NOT FOUND" AND SETUP TABLES

-- 1. Create the Storage Bucket for Service Images
insert into storage.buckets (id, name, public)
values ('services', 'services', true)
on conflict (id) do nothing;

-- 2. Set up Storage Policies (Allow public read, allow authenticated upload)
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'services' );

create policy "Authenticated Upload"
  on storage.objects for insert
  with check ( bucket_id = 'services' and auth.role() = 'authenticated' );

create policy "Authenticated Update"
  on storage.objects for update
  with check ( bucket_id = 'services' and auth.role() = 'authenticated' );

-- 3. Create Services Table (if not exists)
create table if not exists public.services (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text,
  price numeric not null,
  category_id text not null,
  provider_id uuid not null,
  provider_name text,
  duration text,
  image_url text,
  rating numeric default 0,
  review_count integer default 0,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Enable Row Level Security (RLS)
alter table public.services enable row level security;

-- 5. Policies for Services
create policy "Public Services Read"
  on public.services for select
  using ( true );

create policy "Provider Create Services"
  on public.services for insert
  with check ( auth.role() = 'authenticated' );

create policy "Provider Update Own Services"
  on public.services for update
  using ( auth.uid() = provider_id );
