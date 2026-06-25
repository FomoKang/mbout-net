# Again 2002

Static MVP for a Korean football fan voice feed.

Production domain:

```txt
https://again2002.com
https://www.again2002.com
```

Legacy domain:

```txt
https://mbout.net
https://www.mbout.net
```

## Deploy

GitHub is connected to Vercel. Push `main` to deploy:

```powershell
git add .
git commit -m "Update Again 2002"
git push origin main
```

## Supabase

Run `supabase-schema.sql` in the Supabase SQL Editor.
Run it again after updates too; it safely adds new columns such as `posts.category`.

`again.config.js` must contain:

```js
window.AGAIN2002_CONFIG = {
  supabaseUrl: "https://YOUR_PROJECT.supabase.co",
  supabaseAnonKey: "YOUR_SUPABASE_ANON_KEY"
};
```

The site uses:

- Supabase Auth for email/password DB accounts.
- `public.profiles` for internal username, visible nickname, level, and EXP.
- Supabase Presence for live connected browser count.
- Supabase Postgres for shared posts, comments, and likes.
- Supabase Realtime to refresh the feed across users.
- Canvas-generated 9:16 card images for Instagram/TikTok-style sharing.
- `public.reports` for small in-card moderation reports.

## Resend SMTP For Supabase Auth

Supabase default auth email is not production-ready. Configure Resend as custom SMTP in Supabase:

```txt
Host: smtp.resend.com
Port: 587
Username: resend
Password: YOUR_RESEND_API_KEY
Sender email: no-reply@auth.again2002.com
Sender name: Again 2002
```

Recommended sending domain:

```txt
auth.again2002.com
```

After Resend gives DNS records, add them at the domain registrar, then verify the domain in Resend.

In Supabase:

```txt
Authentication -> Settings -> SMTP Settings
Enable Custom SMTP
Enable email confirmations when Resend is verified
Authentication -> URL Configuration
Site URL: https://again2002.com
Redirect URLs:
https://again2002.com
https://www.again2002.com
```

If email confirmation opens `localhost` or `null`, check the URL Configuration above first. The app also sends `emailRedirectTo` as `https://again2002.com/` when opened from a local file.

## Before Large Traffic

- Add CAPTCHA or rate limits to signup.
- Keep auth emails short and non-promotional.
- Move moderation/rate limits server-side.
- Keep `mbout.net` as a redirect or legacy alias.
