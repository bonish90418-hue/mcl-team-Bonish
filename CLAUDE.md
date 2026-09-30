# CLAUDE.md - read this first, in every session

## About us
- We are a team of 4-5 people from Mahanadi Coalfields Limited (MCL) at an
  IIM Sambalpur MDP. We are NOT programmers.
- Explain everything in plain English, in short sentences. If you must use a
  technical word, explain it in one line.
- We build ONE small web tool in phases. Only one Claude session works at a
  time. The Progress Log at the end of this file is our handover logbook.

## What we are building
- A tool with at most 3 pages: index.html (entry page), dashboard.html
  (dashboard) and at most one more page.
- Every record has location, urgency (Low / Medium / High) and status
  (Open / In progress / Resolved), plus the columns in "Our tool" below.
- All data is MADE UP. Never add real names, phone numbers, employee IDs or
  real MCL figures.

## Technical rules
1. Plain HTML, CSS and JavaScript only. Pages stay in the top folder; SQL
   files go in the database folder. No frameworks, no npm, no package.json,
   no build step.
2. Vercel publishes the site from the main branch. Use relative links only,
   e.g. href="dashboard.html".
3. Load Supabase from the jsDelivr CDN, then our settings, in this order:
     <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
     <script src="config.js"></script>
   Then create the client like this (do not call the variable "supabase"):
     const db = window.supabase.createClient(window.SUPABASE_URL,
                                              window.SUPABASE_PUBLISHABLE_KEY);
4. The Project URL and the publishable key live only in config.js. Never use
   or ask for a secret key, a service_role key or the database password.
5. For charts, load Chart.js from the jsDelivr CDN.
6. No login or sign-up. Anyone with the link can use the tool.
7. You may not be able to reach our database. Do NOT try to test the database
   connection. Write the code; we test it on the live website.
8. If anything fails, show a friendly message on the page that also includes
   the actual error text, so we can pass it on.
9. Every page must work well on a mobile phone: large buttons, readable text,
   no sideways scrolling. Use the same header and menu on every page.
10. Never delete config.js or CLAUDE.md.

## Database rules
- Our Data Keeper runs all SQL by pasting it into the Supabase SQL Editor.
  You cannot run SQL yourself.
- Give SQL as ONE block that runs in one go. Also save it in the database
  folder: 01-setup.sql, then 02-..., 03-... for later changes.
- One table. It must have: id uuid primary key default gen_random_uuid()
  and created_at timestamptz not null default now().
- Enable Row Level Security. Add policies that let the roles anon and
  authenticated SELECT, INSERT and UPDATE. No delete.
- Always include: grant select, insert, update on the table to anon,
  authenticated; (new Supabase projects need it, or the website gets
  "permission denied").
- Never drop a table or delete rows.
- Avoid changing the table after Phase 1. If a change is really needed, give
  one small block and explain it in one sentence.

## How to work with us
- Make one change at a time. Do not change parts that already work unless we
  ask.
- After each change, reply in 3 short bullets: what you changed and what we
  should test on the live website.
- Commit and push your work at every stopping point.

## Takeover and handover
- At the START of every session: read the Progress Log below and summarize it
  in 3 bullets (what exists, what works, what is next).
- At a "save point": add a new entry at the end of the Progress Log (phase,
  builder, what was built, what works, known problems, next step). Then
  commit and push.

## Our tool (filled in during Phase 1)
- Team: MCL team, IIM Sambalpur MDP
- Tool name: Integrated Grievance Management and Monitoring System (MCL)
- Problem: Grievances reach many offices, so there is no single record, no tracking of delays and no combined report.
- Who records / who decides: Anyone (or an office official) records a grievance; officers and Area/HQ heads decide and monitor.
- Table name and columns: grievances - id, created_at, grievance_no (auto), complainant_name, contact, stakeholder_category, neis_no, address, location, category, subject, description, preferred_mode, registration_mode, submission_date, urgency, status, department (auto), assigned_officer, due_date (auto SLA), escalation_level (1-4), reopened, remarks, resolved_at
- Pages: index.html = entry page; dashboard.html = dashboard

## Progress Log (newest entry at the bottom)
- Phase 0 (starter): placeholder index.html, config.js without settings and
  this CLAUDE.md. Next: Phase 1 - the table and the entry page.
- Phase 1 (Claude): database/01-setup.sql (one table `grievances`, auto grievance number, auto department and due date, RLS, grants) and index.html (registration form, shows the new Grievance ID). Works: not tested yet (Data Keeper must run the SQL, team must fill config.js). Known problems: menu link to dashboard.html leads nowhere until Phase 2; no file upload, login, email/SMS or PDF/Excel export (outside our rules for now). Next: Phase 2 - dashboard.html with counts, charts (category, area, month), overdue and SLA colours.
- Phase 2 (Claude): dashboard.html - period filter, 8 colour-coded number tiles (received, pending, disposed, overdue, escalated, reopened, average disposal time, SLA compliance), 6 charts (status, month trend, category, area, department, officer-wise pending) and a pending list sorted by urgency then age. No SQL change. Works: not tested yet. Known problems: nothing in the tool can mark a grievance Resolved or assign an officer yet, so disposal time, SLA % and officer chart stay empty until we edit rows in Supabase or build an officer page. Next: Phase 3 - one more page (officer page) to assign, update status, escalate and close grievances, plus a search / track-by-ID box.
- Phase 3 (Claude): officer.html (third and last page) - search by Grievance ID / name / NEIS / subject; views (new, pending, due in 5 days, overdue, escalated, disposed); filters by officer, category, area; colour-coded cards; "Open and update" panel to assign an officer, change status, urgency and escalation level (1-4), and add a remark. Every save adds a dated line to the remarks column (who, what, changes), so it works as a simple history. Resolving sets resolved_at; moving a Resolved case back marks it Reopened. Menu now has Register / Dashboard / Officer page on all pages. No SQL change. Works: not tested yet. Known problems: no login, so anyone with the link can update; escalation is set by hand (no automatic timer); no file upload, email/SMS or PDF/Excel export; remarks history is one text column, not a full audit table (one-table rule). Next: test end to end on the live site, then polish (heat map, Excel download, or automatic escalation flag).
- Excel download (Claude): dashboard.html now has a "Download Excel report" button. It makes one .xlsx file (follows the chosen period) with 15 sheets: Summary, All grievances, Daily, Weekly pending, Monthly, Area-wise, Department-wise, Category-wise, Ageing, SLA violations, Officer-wise pendency, Escalations, Disposal performance, Reopened. Uses the SheetJS library from the jsDelivr CDN (no install). No SQL change. Works: not tested yet. Known problems: needs internet for the library; no PDF export yet. Next: test the download on the live site; PDF or heat map if wanted.
- PDF export (Claude): dashboard.html now has a "Download PDF report" button next to the Excel one. Same reports and same period filter, in one landscape A4 PDF with page numbers. The report-building code is now shared (buildReports) so Excel and PDF always match. Uses jsPDF and jsPDF-AutoTable from the jsDelivr CDN. No SQL change. Works: not tested yet. Known problems: needs internet for the libraries; very large data sets make a long PDF; Hindi/Odia text may not print (standard PDF font). Next: test on live site; heat map or automatic escalation flag if wanted.
- Area-wise heat map (Claude): dashboard.html has a new "Area-wise heat map" card: one row per Area, one column per category, each cell coloured white to dark red by number of grievances. A drop-down switches between All, Pending only and Overdue only. Follows the period filter. Plain HTML/CSS, no new library, no SQL change. Works: not tested yet. Known problems: it is a colour grid, not a geographic map, because our table has no map coordinates (Area is typed text, so spelling differences make separate rows). Next: test on live site; maybe a fixed Area drop-down on the form, or automatic escalation flag.
- Automatic escalation flag (Claude): NEW database/02-auto-escalation.sql adds one function (no table change, nothing deleted). Pending grievances 1-7 days past due go to Level 2, 8-14 days to Level 3, 15+ days to Level 4; level only goes up; a dated SYSTEM line is added to remarks. dashboard.html and officer.html call it every time they open and show a blue/green note with how many were escalated; the officer page shows a red "Auto-escalated" tag. Data Keeper must run 02-auto-escalation.sql. Works: not tested yet. Known problems: it runs only when someone opens the dashboard or officer page (no background timer); if the SQL is not run, pages show a friendly error but still work; the 1/8/15-day steps are made up - MCL should set real ones. Alerts by email/SMS are still not built. Next: test on live site.
- Email and SMS alerts (Claude): officer.html now has a "Send an alert" box in the Open-and-update panel (acknowledgement, status update, disposal reply to the complainant, reminder to the officer) and a new view "Alert needed" (due soon, overdue or escalated). The buttons open the user's own email or SMS app with the message ready (mailto: and sms: links); the officer presses Send. No SQL change. IMPORTANT: real automatic sending is NOT built. It needs an email/SMS company account and a secret API key plus server code, which our rules do not allow (no secret keys, no backend). Known problems: sending is manual; the tool cannot tell if a message was sent, so the officer adds a remark; officer contact details are not stored, so reminders open with a blank 'To'; complainant contact is free text. Next: if MCL IT can provide an approved email/SMS gateway, that would be a separate decision for the team.
- Fixed Area drop-down (Claude): index.html - "Area / Project / Unit" is now a drop-down (Area 1 to Area 8, Corporate / HQ, Other) instead of typed text, so the heat map and area charts no longer split on spelling. The names are MADE-UP placeholders; the team can rename them in index.html (the list sits right after the comment). No SQL change (the column is still text). Old records with typed areas stay as they are. Known problems: the list is inside index.html only, so if you rename an area later, old records keep the old name.
- Track-by-ID box (Claude): index.html now has a "Track your grievance" card under the form. The complainant types the Grievance ID and sees a 4-step progress bar (Received, Assigned, In progress, Disposed), status, department, officer, date received and due date. It shows only these safe fields - never contact details, description or internal remarks. A link like index.html?id=MCL-2026-00001 checks straight away (can be used for a QR code). No SQL change. Known problems: the table is readable by anyone with the link (our no-login rule), so this box hides details on screen but is not real privacy; the Grievance ID is the only 'key'. Real privacy would need login, which our rules do not allow.
