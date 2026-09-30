-- 04-escalation-date.sql : adds ONE column so we know WHEN a grievance was last escalated.
-- Why: the officer page needs to search by escalation date, and this date was not stored before.
-- Paste this WHOLE block into the Supabase SQL Editor and press Run.
-- It does not delete anything. Old escalated grievances keep an empty date (we do not know it).

alter table grievances add column if not exists escalated_at timestamptz;

-- Same automatic escalation rule as 02-auto-escalation.sql, now also saving the date.
create or replace function escalate_overdue_grievances()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  n integer;
begin
  with calc as (
    select id,
           (current_date - due_date) as late_days,
           case
             when current_date - due_date >= 15 then 4
             when current_date - due_date >= 8 then 3
             else 2
           end as new_level
    from grievances
    where status <> 'Resolved'
      and due_date is not null
      and due_date < current_date
  )
  update grievances g
  set escalation_level = c.new_level,
      escalated_at = now(),
      remarks = coalesce(g.remarks || E'\n\n', '') ||
                '[' || to_char(now(), 'DD Mon YYYY HH24:MI') || '] SYSTEM: automatically escalated to level ' ||
                c.new_level || ' (overdue by ' || c.late_days || ' days)'
  from calc c
  where g.id = c.id
    and c.new_level > g.escalation_level;
  get diagnostics n = row_count;
  return n;
end;
$$;

grant execute on function escalate_overdue_grievances() to anon, authenticated;
