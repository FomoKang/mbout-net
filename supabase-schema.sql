create table if not exists public.posts (
  id text primary key,
  author_id text not null,
  author_base text not null,
  author_name text not null,
  author_type text not null default 'guest',
  author_ip text not null default '',
  author_level integer not null default 0,
  author_verified boolean not null default false,
  style text not null default 'paper',
  category text not null default 'sad',
  bg_color text not null default '#f8f3e7',
  text_color text not null default '#1d1c18',
  media_type text not null default '',
  media_url text not null default '',
  media_name text not null default '',
  media_size integer not null default 0,
  body_html text not null,
  likes integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.comments (
  id text primary key,
  post_id text not null references public.posts(id) on delete cascade,
  author_id text not null,
  author_base text not null,
  author_name text not null,
  author_type text not null default 'guest',
  author_ip text not null default '',
  author_level integer not null default 0,
  author_verified boolean not null default false,
  body_html text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.reports (
  id text primary key,
  post_id text not null references public.posts(id) on delete cascade,
  reporter_id text not null,
  reason text not null default 'card-report',
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  display_name text not null default '',
  level integer not null default 1,
  xp integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.reports enable row level security;
alter table public.profiles enable row level security;

alter table public.posts
  add column if not exists category text not null default 'sad';

alter table public.posts
  add column if not exists media_type text not null default '',
  add column if not exists media_url text not null default '',
  add column if not exists media_name text not null default '',
  add column if not exists media_size integer not null default 0;

drop policy if exists "Public posts are readable" on public.posts;
create policy "Public posts are readable"
  on public.posts for select
  using (true);

drop policy if exists "Anyone can create posts" on public.posts;
create policy "Anyone can create posts"
  on public.posts for insert
  with check (true);

drop policy if exists "Anyone can update post likes" on public.posts;
create policy "Anyone can update post likes"
  on public.posts for update
  using (true)
  with check (true);

drop policy if exists "Public comments are readable" on public.comments;
create policy "Public comments are readable"
  on public.comments for select
  using (true);

drop policy if exists "Anyone can create comments" on public.comments;
create policy "Anyone can create comments"
  on public.comments for insert
  with check (true);

drop policy if exists "Anyone can create reports" on public.reports;
create policy "Anyone can create reports"
  on public.reports for insert
  with check (true);

drop policy if exists "Profiles are readable" on public.profiles;
create policy "Profiles are readable"
  on public.profiles for select
  using (true);

drop policy if exists "Users can create their own profile" on public.profiles;
create policy "Users can create their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  desired_username text;
begin
  desired_username := nullif(
    regexp_replace(
      regexp_replace(coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)), '[[:space:]]+', '', 'g'),
      '[^a-zA-Z0-9_]',
      '',
      'g'
    ),
    ''
  );

  if desired_username is null then
    desired_username := 'fan' || left(new.id::text, 8);
  end if;

  if exists (select 1 from public.profiles where username = desired_username) then
    desired_username := desired_username || '-' || left(new.id::text, 4);
  end if;

  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    desired_username,
    coalesce(new.raw_user_meta_data->>'display_name', '')
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

do $$
begin
  alter publication supabase_realtime add table public.posts;
exception
  when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.comments;
exception
  when duplicate_object then null;
end $$;
