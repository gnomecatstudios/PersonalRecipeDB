-- PersonalRecipeDB shared shopping-list storage
-- Run this entire file once in Supabase Dashboard > SQL Editor.

create table if not exists public.shopping_lists (
  user_id uuid primary key references auth.users(id) on delete cascade,
  list_data jsonb not null default '{"selected":[],"removed":[],"edits":{},"manual":[],"checked":[]}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.shopping_lists enable row level security;

drop policy if exists "Users can read their own shopping list" on public.shopping_lists;
create policy "Users can read their own shopping list"
on public.shopping_lists
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own shopping list" on public.shopping_lists;
create policy "Users can create their own shopping list"
on public.shopping_lists
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own shopping list" on public.shopping_lists;
create policy "Users can update their own shopping list"
on public.shopping_lists
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete their own shopping list" on public.shopping_lists;
create policy "Users can delete their own shopping list"
on public.shopping_lists
for delete
to authenticated
using ((select auth.uid()) = user_id);

create or replace function public.set_shopping_list_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists shopping_lists_set_updated_at on public.shopping_lists;
create trigger shopping_lists_set_updated_at
before update on public.shopping_lists
for each row
execute function public.set_shopping_list_updated_at();
