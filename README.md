# MBOUT.NET

Static MVP for a Korean football fan voice feed.

## Fastest Deploy

1. Install or use Vercel CLI.
2. Run from this folder:

```powershell
npx vercel --prod
```

The site works as a static MVP immediately. Without Supabase it stores posts in each browser only and shows the current browser as 1 connected user.

## Real Online Count And Shared Feed

For real `현재 n명 접속 중` plus shared posts/comments:

1. Create a Supabase project.
2. Open Supabase SQL Editor.
3. Run `supabase-schema.sql`.
4. Edit `mbout.config.js`:

```js
window.MBOUT_CONFIG = {
  supabaseUrl: "https://YOUR_PROJECT.supabase.co",
  supabaseAnonKey: "YOUR_SUPABASE_ANON_KEY"
};
```

After redeploy, MBOUT.NET uses:

- Supabase Presence for live connected browser count.
- Supabase Postgres for shared posts, comments, and likes.
- Supabase Realtime to refresh the feed across users.

## Next Production Step

The fastest real-service path is:

1. Deploy this static MVP on Vercel.
2. Add Supabase keys to `mbout.config.js`.
3. Replace open public write policies with proper moderation/rate limits before large traffic.
