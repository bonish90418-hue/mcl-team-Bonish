-- 01-setup.sql : Phase 1 - one table "grievances" for the MCL Grievance tool.
-- Paste this WHOLE block into the Supabase SQL Editor and press Run.
-- All data is made up. Never enter real names, phone numbers or employee IDs.

-- A counter used to make grievance numbers like MCL-2026-00001
create sequence if not exists grievance_no_seq;

create table if not exists grievances (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),

  grievance_no text unique,                       -- made automatically
  complainant_name text not null,
  contact text not null,                          -- made-up phone or email
  stakeholder_category text not null,             -- employee, land oustee, contractor...
  neis_no text,                                   -- only for employees (made up)
  address text,
  location text not null,                         -- Area / Project / Unit
  category text not null,                         -- Land, HR, Finance, Project/Area, Other
  subject text not null,
  description text not null,
  preferred_mode text not null default 'Phone',   -- Phone, Email, SMS, In person
  registration_mode text not null default 'Web portal',
  submission_date date not null default current_date,

  urgency text not null default 'Medium'
    check (urgency in ('Low','Medium','High')),
  status text not null default 'Open'
    check (status in ('Open','In progress','Resolved')),

  department text,                                -- filled automatically from category
  assigned_officer text,                          -- made-up officer name/designation
  due_date date,                                  -- filled automatically from category SLA
  escalation_level int not null default 1
    check (escalation_level between 1 and 4),     -- 1 Dealing Officer ... 4 HQ
  reopened boolean not null default false,
  remarks text,
  resolved_at timestamptz
);

-- Automatically fill grievance number, department and due date on new records
create or replace function grievances_before_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.grievance_no is null then
    new.grievance_no := 'MCL-' || to_char(now(), 'YYYY') || '-' ||
                        lpad(nextval('grievance_no_seq')::text, 5, '0');
  end if;
  if new.department is null then
    new.department := case new.category
      when 'Land and R&R' then 'Land and Revenue'
      when 'Employment and HR' then 'Personnel and HR'
      when 'Finance' then 'Finance'
      when 'Project / Area' then 'Project / Area Office'
      else 'General Administration' end;
  end if;
  if new.due_date is null then
    new.due_date := new.submission_date + case new.category
      when 'Land and R&R' then 30
      when 'Employment and HR' then 21
      when 'Finance' then 15
      when 'Project / Area' then 21
      else 15 end;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_grievances_before_insert on grievances;
create trigger trg_grievances_before_insert
before insert on grievances
for each row execute function grievances_before_insert();

-- Row Level Security: anyone with the link can read, add and update. No delete.
alter table grievances enable row level security;

drop policy if exists "grievances_select" on grievances;
drop policy if exists "grievances_insert" on grievances;
drop policy if exists "grievances_update" on grievances;
create policy "grievances_select" on grievances for select to anon, authenticated using (true);
create policy "grievances_insert" on grievances for insert to anon, authenticated with check (true);
create policy "grievances_update" on grievances for update to anon, authenticated using (true) with check (true);

grant select, insert, update on grievances to anon, authenticated;
