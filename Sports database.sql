create database sports_booking;
use sports_booking;

create table members (
id varchar(255) unique primary key,
password_ varchar(255) not null ,
email varchar(255) not null ,
member_since timestamp not null default now(),
payment_due decimal(6,2) not null default 0
);

create table pending_terminations (
id varchar(255) unique primary key,
email varchar(255) not null ,
request_date timestamp not null default now(),
payment_due decimal(6,2) not null default 0
);

create table room (
id varchar(255) unique primary key,
room_type varchar (255) not null,
price decimal(6,2) not null
);
rename table room to rooms;

create table bookings (
id int  auto_increment primary key,
room_id varchar(255) not null,
booked_date date not null,
booked_time time not null,
member_id varchar(255) not null,
datetime_of_booking timestamp not null default now(),
payment_status varchar(255) not null default 'Unpaid',
unique uc1 (room_id, booked_date, booked_time));

alter table bookings 
add constraint fk1 foreign key(member_id) references members(id) on delete cascade on update cascade,
add constraint fk2 foreign key(room_id) references rooms(id) on delete cascade on update cascade;

insert into members
values ('afeil', 'feil1988<3', 'Abdul.Feil@hotmail.com', '2017-04-15 12:10:13', 0),
('amely_18', 'loseweightin18', 'Amely.Bauch91@yahoo.com', '2018-02-06 16:48:43', 0),
('bbahringer', 'iambeau17', 'Beaulah_Bahringer@yahoo.com', '2017-12-28 05:36:50', 0),
('little31', 'whocares31', 'Anthony_Little31@gmail.com', '2017-06-01 21:12:11', 10),
('macejkovic73', 'jadajeda12', 'Jada.Macejkovic73@gmail.com', '2017-05-30 17:30:22', 0),
('marvin1', 'if0909mar', 'Marvin_Schulist@gmail.com', '2017-09-09 02:30:49', 10),
('nitzsche77', 'bret77@#', 'Bret_Nitzsche77@gmail.com', '2018-01-09 17:36:49', 0),
('noah51', '18Oct1976#51', 'Noah51@gmail.com', '2017-12-16 22:59:46', 0),
('oreillys', 'reallycool#1', 'Martine_OReilly@yahoo.com', '2017-10-12 05:39:20', 0),
('wyattgreat', 'wyatt111', 'Wyatt_Wisozk2@gmail.com', '2017-07-18 16:28:35', 0);

insert into rooms
values ('AR', 'Archery Range', 120),
('B1', 'Badminton Court', 8),
('B2', 'Badminton Court', 8),
('MPF1', 'Multi Purpose Field', 50),
('MPF2', 'Multi Purpose Field', 60),
('T1', 'Tennis Court', 10),
('T2', 'Tennis Court', 10);

insert into bookings 
values (1, 'AR', '2017-12-26', '13:00:00', 'oreillys', '2017-12-20 20:31:27', 'Paid'),
(2, 'MPF1', '2017-12-30', '17:00:00', 'noah51', '2017-12-22 05:22:10', 'Paid'),
(3, 'T2', '2017-12-31', '16:00:00', 'macejkovic73', '2017-12-28 18:14:23', 'Paid'),
(4, 'T1', '2018-03-05', '08:00:00', 'little31', '2018-02-22 20:19:17', 'Unpaid'),
(5, 'MPF2', '2018-03-02', '11:00:00', 'marvin1', '2018-03-01 16:13:45', 'Paid'),
(6, 'B1', '2018-03-28', '16:00:00', 'marvin1', '2018-03-23 22:46:36', 'Paid'),
(7, 'B1', '2018-04-15', '14:00:00', 'macejkovic73', '2018-04-12 22:23:20', 'Cancelled'),
(8, 'T2', '2018-04-23', '13:00:00', 'macejkovic73', '2018-04-19 10:49:00', 'Cancelled'),
(9, 'T1', '2018-05-25', '10:00:00', 'marvin1', '2018-05-21 11:20:46', 'Unpaid'),
(10, 'B2', '2018-06-12', '15:00:00', 'bbahringer', '2018-05-30 14:40:23', 'Paid');

create view member_bookings as
select b.id, b.room_id, r.room_type , b.booked_date, b.booked_time, b.member_id, b.datetime_of_booking, r.price, b.payment_status
from bookings b 
join rooms r
on b.room_id = r.id
order by b.id;

select * from member_bookings;

#Creating procedures to add details

delimiter $$
create procedure insert_new_member (in p_id varchar(255), in p_password varchar(255), in p_email varchar(255))
begin
insert into members(id, password_, email) values (p_id, p_password, p_email);
end $$ 

create procedure delete_member (in p_id varchar(255))
begin
delete from members where id = p_id;
end$$

create procedure update_member_password (in p_id varchar(255), in p_password varchar(255))
begin 
update members 
set password_ = p_password
where id = p_id;
end $$

create procedure update_member_email (in p_id varchar(255), in p_email varchar(255))
begin 
update members 
set email = p_email
where id = p_id;
end $$

create procedure make_booking(in p_room_id varchar(255), in p_booked_date date, in p_booked_time time, in p_member_id varchar(255))
begin
declare v_price decimal(6,2);
declare v_payment_due decimal(6,2);
insert into bookings (room_id, booked_date, booked_time, member_id)
values(p_room_id, p_booked_date, p_booked_time, p_member_id);
select price into v_price from rooms where id = p_room_id;
select payment_due into v_payment_due from members where id = p_member_id;
update members set payment_due = v_payment_due+v_price where id=p_member_id;
end $$ 

create procedure update_payment(in p_id int)
begin 
declare v_member_id varchar(255);
declare v_payment_due decimal(6,2);
declare v_price decimal(6,2);
update bookings 
set payment_status = 'Paid'
where id = p_id;
select member_id into v_member_id from member_bookings where id = p_id;
select price into v_price from member_bookings  where id = p_id;
select payment_due into v_payment_due from members where id = v_member_id;
update members
set payment_due = v_payment_due - v_price
where id = v_member_id;
end $$

create procedure view_bookings(in p_id varchar(255))
begin
select * from member_bookings;
end $$

create procedure search_room(in p_room_type varchar(255), in p_booked_date date, p_booked_time time)
begin
select * from rooms where id != (select room_id from bookings 
where booked_date = p_booked_date and booked_time = p_booked_time and payment_status != 'Cannelled') and room_type=p_room_type;
end $$

create procedure cancel_booking(in p_booking_id int, out p_message varchar(255))
begin
declare v_cancellation int; 
declare v_member_id varchar(255);
declare v_payment_status varchar(255);
declare v_booked_date date;
declare v_price decimal(6,2);
declare v_payment_due decimal(6,2);
set v_cancellation = 0;
select member_id, booked_date, price, payment_status 
into v_member_id, v_booked_date, v_price, v_payment_status from member_bookings where id = p_booking_id;
select payment_due into v_payment_due from members where id = v_member_id;
if curdate() >= v_booked_date then
select "Cancellation cannot be done on/after the booked date" into p_message;
elseif v_payment_satatus = "Cancelled" or v_payment_status='Paid' then
select "Booking has already been cancelled or paid" into p_message;
else update bookings
set payment_status ='Cancelled' where id=p_booking_id;
set v_payment_due = v_payment_due - v_price;
set v_cancellation = check_cancellation(p_booking_id);
if v_cancellation>=2 then set v_payment_due = v_payment_due+10;
end if;
update members set payment_due = v_payment_due where id = v_member_id;
select 'Booking Cancelled' into p_message;
end if;
end $$

#Trigger

create trigger payment_check before delete on members
for each row
begin
declare v_payment_due decimal(6,2);
select payment_due into v_payment_due from members where id = old.id;
if v_payment_due >0 then insert into pending_terminations(id, email, payment_due)
values (old.id, old.email, old.payment_due);
end if;
end $$

create function check_cancellation(p_booking_id int) returns int deterministic
begin
declare v_done int;
declare v_cancellation int;
declare v_current_payment_status varchar(255);
declare cur cursor for
select payment_status from bookings where member_id = (select member_id FROM bookings WHERE id = p_booking_id) 
order by datetime_of_booking desc;
declare continue handler for not found set v_done =1;
set v_done =0;
set v_cancellation = 0;
open cur;
cancellation_loop : Loop
fetch cur into v_current_payment_status;
if v_current_payment_status != 'Cancelled' or v_done = 1
then leave cancellation_loop;
else set v_cancellation = v_cancellation+1;
end if;
end loop;
close cur;
return v_cancellationl;
end $$
Delimiter ;

select * from members;
select * from bookings;
select * from rooms;
select * from pending_terminations;

call insert_new_member('angelolott', '1234abcd','angelonlott@gmail.com');

call delete_member('afeil');
call delete_member ('little31');

select * from pending_terminations;

CALL update_member_password ('noah51', '18Oct1976');
CALL update_member_email ('noah51', 'noah51@hotmail.com');
SELECT * FROM members;

CALL update_payment (9);
SELECT * FROM members WHERE id = 'marvin1';
SELECT * FROM bookings WHERE member_id = 'marvin1';

CALL search_room('Archery Range', '2017-12-26', '13:00:00');
CALL search_room('Badminton Court', '2018-04-15', '14:00:00');
CALL make_booking ('AR', '2017-12-26', '13:00:00', 'noah51');
CALL make_booking ('T1', CURDATE() + INTERVAL 2 WEEK,
'11:00:00', 'noah51');
CALL make_booking ('AR', CURDATE() + INTERVAL 2 WEEK,
'11:00:00', 'macejkovic73');

select * from bookings;

CALL cancel_booking(1, @message);
SELECT @message;
