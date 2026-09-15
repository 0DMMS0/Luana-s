create or replace function public.expand_weekly_class()
returns trigger language plpgsql security definer set search_path=public as $$
declare d date;
begin
  if new.recurrence_type = 'weekly' and new.recurrence_until is not null and new.recurrence_until > new.class_date then
    d := new.class_date + 7;
    while d <= new.recurrence_until loop
      insert into public.classes (name,discipline,instructor_id,class_date,start_time,end_time,capacity,room,instructor_name,location,recurrence_type,recurrence_until,min_age,max_age,waitlist_enabled)
      values (new.name,new.discipline,new.instructor_id,d,new.start_time,new.end_time,new.capacity,new.room,new.instructor_name,new.location,'none',null,new.min_age,new.max_age,new.waitlist_enabled);
      d := d + 7;
    end loop;
  end if;
  return new;
end; $$;
drop trigger if exists classes_expand_weekly on public.classes;
create trigger classes_expand_weekly after insert on public.classes
for each row execute function public.expand_weekly_class();
