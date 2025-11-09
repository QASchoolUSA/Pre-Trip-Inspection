-- Supabase schema for PTI Mobile App (users, loads)
-- Run this in Supabase SQL Editor in your project

-- Ensure UUID generation is available
create extension if not exists pgcrypto;

-- Users table
create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  cdl_number text,
  cdl_expiry_date timestamptz,
  medical_cert_expiry_date timestamptz,
  phone_number text,
  email text not null unique,
  is_active boolean not null default true,
  last_login_at timestamptz,
  role text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Loads table
create table if not exists public.loads (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid references public.users(id) on delete set null,
  reference_number text,
  pickup_city text,
  pickup_state text,
  pickup_date timestamptz not null,
  dropoff_city text,
  dropoff_state text,
  dropoff_date timestamptz not null,
  status text check (status in ('assigned','inTransit','delivered','cancelled')) not null default 'assigned',
  weight_lbs numeric,
  rate_usd numeric,
  broker_name text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Helpful indexes
create index if not exists idx_users_email on public.users(email);
create index if not exists idx_loads_driver_id on public.loads(driver_id);
create index if not exists idx_loads_pickup_date on public.loads(pickup_date);

-- Enable Row Level Security (policies are defined separately)
alter table public.users enable row level security;
alter table public.loads enable row level security;