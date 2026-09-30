-- 03-documents.sql : Phase 5 - storage place for supporting documents.
-- Paste this WHOLE block into the Supabase SQL Editor and press Run.
-- It does NOT change the grievances table and deletes nothing.
-- Files are kept in a private "folder" (bucket) called grievance-docs.
-- Each file is saved under the Grievance ID, e.g. MCL-2026-00001/171234-0-letter.pdf
-- Limits: 5 MB per file; only PDF, JPG and PNG. Use MADE-UP documents only.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('grievance-docs', 'grievance-docs', false, 5242880,
        array['application/pdf', 'image/jpeg', 'image/png'])
on conflict (id) do update
  set file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- anon and authenticated may add and read files. No update and no delete.
drop policy if exists "grievance_docs_insert" on storage.objects;
drop policy if exists "grievance_docs_select" on storage.objects;
create policy "grievance_docs_insert" on storage.objects
  for insert to anon, authenticated with check (bucket_id = 'grievance-docs');
create policy "grievance_docs_select" on storage.objects
  for select to anon, authenticated using (bucket_id = 'grievance-docs');
