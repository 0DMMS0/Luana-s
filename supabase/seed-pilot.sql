-- Datos visibles y reversibles del piloto Luana/Ikigai.
insert into public.memberships(id,name,amount,active,billing_period,enrollment_fee,class_limit,auto_renew) values
('00000000-0000-0000-0000-000000000101','PILOTO IKIGAI Mensual',50000,true,'monthly',0,12,true)
on conflict(id) do update set name=excluded.name,amount=excluded.amount,active=true;
insert into public.students(id,full_name,email,phone,discipline,level,active,membership_id,membership_status) values
('00000000-0000-0000-0000-000000000102','PRUEBA LUANA 2026','prueba.luana@ikigai.local','5555-0102','MMA','Principiante',true,'00000000-0000-0000-0000-000000000101','active')
on conflict(id) do update set full_name=excluded.full_name,active=true;
insert into public.classes(id,name,discipline,class_date,start_time,end_time,capacity,room,location,instructor_name) values
('00000000-0000-0000-0000-000000000103','PRUEBA LUANA 2026 · Fundamentos','MMA',current_date,'18:00','19:00',20,'Sala 1','Academia Ikigai','Sensei Piloto')
on conflict(id) do update set class_date=current_date;
insert into public.student_progress(id,student_id,belt,stripes,evaluation_date,notes) values
('00000000-0000-0000-0000-000000000105','00000000-0000-0000-0000-000000000102','Blanco',1,current_date,'Registro inicial del piloto') on conflict(id) do nothing;
insert into public.class_reservations(id,class_id,student_id,status) values
('00000000-0000-0000-0000-000000000106','00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000102','booked') on conflict(id) do nothing;
insert into public.attendance(id,class_id,student_id,marked_at,present) values
('00000000-0000-0000-0000-000000000108','00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000102',now(),true) on conflict(id) do nothing;
insert into public.payments(id,student_id,amount,period,status,payment_method,paid_at) values
('00000000-0000-0000-0000-000000000107','00000000-0000-0000-0000-000000000102',50000,'Piloto 2026-09','paid','cash',now()) on conflict(id) do nothing;
insert into public.products(id,name,sku,category,price,stock,min_stock,active) values
('00000000-0000-0000-0000-000000000104','PRUEBA LUANA 2026 · Guantes','PILOTO-GUANTE-01','Equipo',25000,9,2,true) on conflict(id) do update set stock=9,active=true;
insert into public.sales(id,student_id,total,payment_method,status) values
('00000000-0000-0000-0000-000000000109','00000000-0000-0000-0000-000000000102',25000,'cash','completed') on conflict(id) do nothing;
insert into public.sale_items(id,sale_id,product_id,quantity,unit_price) values
('00000000-0000-0000-0000-000000000110','00000000-0000-0000-0000-000000000109','00000000-0000-0000-0000-000000000104',1,25000) on conflict(id) do nothing;
