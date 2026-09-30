-- 02-auto-escalation.sql : Phase 4 - automatic escalation of late grievances.
-- Paste this WHOLE block into the Supabase SQL Editor and press Run.
-- It adds ONE function. It does not change the table and does not delete anything.
--
-- Rule (pending grievances only, counted from the due date):
--   1 to 7 days late   -> Level 2 (Section / Department Head)
--   8 to 14 days late  -> Level 3 (Area Head / Competent Authority)
--   15 or more days    -> Level 4 (Corporate / HQ Monitoring)
-- The level only goes UP, never down. A dated SYSTEM line is added to remarks.
-- The dashboard and officer pages call this function every time they open.

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
