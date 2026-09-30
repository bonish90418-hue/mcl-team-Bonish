// config.js - our team's database settings (filled in during Phase 1).
// Only the Project URL and the PUBLISHABLE key go here. Both are safe to be public.
// NEVER put a secret key, a service_role key or the database password in this file.

// Project URL - looks like https://abcdefghijklmnop.supabase.co
window.SUPABASE_URL = "https://dbhaeojtopqozwxqgjsi.supabase.co";

// Publishable key - starts with sb_publishable_
window.SUPABASE_PUBLISHABLE_KEY = "sb_publishable_aVOyjJQ2erigBeE5yBFEpQ_Cuo98heC";


// Officer page lock (a simple passcode, NOT real security - see CLAUDE.md).
// Only a scrambled version (hash) of the passcode is stored here, never the passcode itself.
// To change the passcode, ask Claude for a new one and paste the new salt and hash here.
window.OFFICER_LOCK = { salt: "27c7d287cf39f818be8995ba12ca8fae", hash: "98ae44a6347ad6813db34f0332cd278735c323e395a7e72394e836a5cc1adf7c", iterations: 200000 };
