-- Seed data for users and loads

-- Demo user ID expected by the app
-- fd89ca03-c7fb-4a44-8685-ea2c1563c98d

insert into public.users (id, name, cdl_number, cdl_expiry_date, medical_cert_expiry_date, phone_number, email, is_active, role)
values
  ('fd89ca03-c7fb-4a44-8685-ea2c1563c98d', 'Demo Driver', 'CDL123456', '2026-10-27T20:14:28+00', '2026-04-25T20:14:28+00', '555-0123', 'demo@ptiplus.com', true, 'driver')
on conflict (id) do update set
  name = excluded.name,
  cdl_number = excluded.cdl_number,
  cdl_expiry_date = excluded.cdl_expiry_date,
  medical_cert_expiry_date = excluded.medical_cert_expiry_date,
  phone_number = excluded.phone_number,
  email = excluded.email,
  is_active = excluded.is_active,
  role = excluded.role;

-- Additional sample users
insert into public.users (name, cdl_number, cdl_expiry_date, medical_cert_expiry_date, phone_number, email, is_active, role)
values
  ('John Smith', 'CDL987654', '2026-09-01T12:00:00+00', '2026-03-01T12:00:00+00', '555-0101', 'john.smith@ptiplus.com', true, 'driver'),
  ('Maria Garcia', 'CDL789012', '2027-01-01T12:00:00+00', '2026-06-01T12:00:00+00', '555-0102', 'maria.garcia@ptiplus.com', true, 'dispatcher')
on conflict (email) do nothing;

-- Sample loads for demo driver
insert into public.loads (driver_id, reference_number, pickup_city, pickup_state, pickup_date, dropoff_city, dropoff_state, dropoff_date, status, weight_lbs, rate_usd, broker_name, notes)
values
  ('fd89ca03-c7fb-4a44-8685-ea2c1563c98d', 'REF-78421', 'Dallas', 'TX', '2025-11-09T16:00:00+00', 'Atlanta', 'GA', '2025-11-10T22:00:00+00', 'assigned', 38000, 2100, 'Acme Logistics', 'Handle with care'),
  ('fd89ca03-c7fb-4a44-8685-ea2c1563c98d', 'REF-78422', 'Memphis', 'TN', '2025-11-08T10:00:00+00', 'Chicago', 'IL', '2025-11-09T20:00:00+00', 'inTransit', 42000, 1850, 'North Freight', null),
  ('fd89ca03-c7fb-4a44-8685-ea2c1563c98d', 'REF-78423', 'Phoenix', 'AZ', '2025-11-06T08:00:00+00', 'Los Angeles', 'CA', '2025-11-07T12:00:00+00', 'delivered', 40000, 1600, 'Sunrise Carriers', 'Delivered early');