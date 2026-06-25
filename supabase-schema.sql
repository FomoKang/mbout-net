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
  bg_color text not null default '#f8f3e7',
  text_color text not null default '#1d1c18',
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

alter table public.posts enable row level security;
alter table public.comments enable row level security;

create policy "Public posts are readable"
  on public.posts for select
  using (true);

create policy "Anyone can create posts"
  on public.posts for insert
  with check (true);

create policy "Anyone can update post likes"
  on public.posts for update
  using (true)
  with check (true);

create policy "Public comments are readable"
  on public.comments for select
  using (true);

create policy "Anyone can create comments"
  on public.comments for insert
  with check (true);

alter publication supabase_realtime add table public.posts;
alter publication supabase_realtime add table public.comments;
