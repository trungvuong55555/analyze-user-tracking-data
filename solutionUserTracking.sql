-- cau 1

create or replace function distance (x1 int, y1 int, x2 int, y2 int)
returns float 
language plpgsql
as $$
declare
final_result float;
begin
	select sqrt(pow(x1-x2,2) + pow(y1-y2,2)) into final_result;
	return final_result;	
end;
$$;

select distance(1,2,5,3);

-- cau 2

SELECT EXTRACT(EPOCH FROM TIMESTAMP '2011-05-17 10:40:28') * 1000;

-- cau 3

create or replace function count_appear (userId int, start_timestamp timestamp, end_timestamp timestamp)
returns int
language plpgsql
as $$
declare
final_result int;
start_miliseconds bigint;
end_miliseconds bigint;
begin
	SELECT EXTRACT(EPOCH FROM  start_timestamp) * 1000 into start_miliseconds;
	SELECT EXTRACT(EPOCH FROM  end_timestamp )* 1000 into end_miliseconds;
	select count(*) from tracking t where t.user_id = userId and t.millisecond >=  start_miliseconds and t.millisecond < end_miliseconds into final_result;
	return final_result;
end;
$$;

select count_appear (20, TIMESTAMP '2023-06-07 10:40:28', TIMESTAMP '2023-06-07 20:40:28');

-- cau 4
create or replace function range_movement (x int, y int, r float, start_timestamp timestamp, end_timestamp timestamp)
returns table (name varchar(500), age int, lat int, lon int, distance float, miliseconds bigint)
language plpgsql
as $$
declare
start_miliseconds bigint;
end_miliseconds bigint;
begin
	SELECT EXTRACT(EPOCH FROM  start_timestamp) * 1000 into start_miliseconds;
	SELECT EXTRACT(EPOCH FROM  end_timestamp )* 1000 into end_miliseconds;
	
	return query 
		select * from 
		(select b."name" , b.age , a.lat , a.lon, distance(a.lat, a.lon, x, y) distance, a.millisecond 
		from tracking a inner join users b on a.user_id = b.user_id 
		where a.millisecond < end_miliseconds and a.millisecond>= start_miliseconds) c
		where c.distance <= r;
end;
$$ ;

select * from range_movement (0, 0, 100, TIMESTAMP '2023-06-07 00:40:28', TIMESTAMP '2023-06-07 20:40:28');

-- cau 5

create or replace function sum_movement_by_milisecond (userId int, start_miliseconds bigint, end_miliseconds bigint)
returns float
language plpgsql
as $$
declare 
sum_distance float;
begin	
	select sum(distance(lat, lat1, lon, lon1))
	from 
	(
		select lat, lon, (lead(lat) over (order by millisecond)) lat1, (lead(lon) over (order by millisecond)) lon1
		from tracking t 
		where user_id = userId and t.millisecond >= start_miliseconds and t.millisecond  < end_miliseconds
		order by t.millisecond 
	) t1
	where t1.lat1 is not null into sum_distance;

	if(sum_distance is null) then
		return 0;
	end if;
	return sum_distance;	
end;
$$;


create or replace function sum_movement (userId int, start_timestamp timestamp, end_timestamp timestamp)
returns float
language plpgsql
as $$
declare 
start_miliseconds bigint;
end_miliseconds bigint;
sum_distance float;
begin
	SELECT EXTRACT(EPOCH FROM  start_timestamp) * 1000 into start_miliseconds;
	SELECT EXTRACT(EPOCH FROM  end_timestamp )* 1000 into end_miliseconds;

	select sum_movement_by_milisecond(userId, start_miliseconds, end_miliseconds) into sum_distance;
	return sum_distance;
	
end;
$$;

select sum_movement (10, TIMESTAMP '2023-06-07 10:40:28', TIMESTAMP '2023-06-07 20:40:28');

-- cau 6

create or replace function quality_movement (userId int, start_timestamp timestamp, end_timestamp timestamp)
returns varchar(20)
language plpgsql
as $$
declare 
sum_distance float;
begin	
	select sum_movement(userId, start_timestamp, end_timestamp) into sum_distance;
	if(sum_distance > 1000) then return 'long distance';
	else return 'close distance'; end if;
end;
$$;

select quality_movement(10, TIMESTAMP '2023-06-07 10:40:28', TIMESTAMP '2023-06-07 20:40:28');


-- cau 7
create or replace function convert_milisecond_to_date(time_milisecond bigint)
returns int
language plpgsql
as $$
declare
convert_date int;
begin
	select to_char(to_timestamp(time_milisecond/1000),'yyyymmdd' )::INTEGER into convert_date;
	return convert_date;	
end;
$$;

select *, convert_milisecond_to_date(millisecond) as part_date
from tracking t ;

-- cau 8
create or replace function convert_milisecond_to_hour(time_milisecond bigint)
returns int
language plpgsql
as $$
declare
convert_hour int;
begin
	select mod(floor( time_milisecond/ (1000 * 60 * 60))::int , 24)  part_hour into convert_hour;
	return convert_hour;	
end;
$$;

select *, convert_milisecond_to_date(millisecond) part_date, convert_milisecond_to_hour(millisecond) part_hour
from tracking t ;

select part_hour
from 
(select convert_milisecond_to_hour(millisecond) part_hour
from tracking t ) t1
group by part_hour
order by part_hour;

-- cau 9
create or replace function stat_scope_by_part_hour (xR int, yR int, r float, part_date int)
returns table (part_hour int, density bigint)
language plpgsql
as $$
declare 
begin
	return query
		select t1.part_hour, count(*) density
		from 
			(select distance(lat, lon, xR, yR) distance, convert_milisecond_to_date(millisecond) partDate, convert_milisecond_to_hour(millisecond) part_hour
			from tracking t) t1
		where t1.distance <= r and t1.partDate = part_date
		group by t1.part_hour
		order by t1.part_hour;
end;
$$;

select * from stat_scope_by_part_hour (0, 0, 100, 20230607);

-- cau 10

create or replace function take_name_state(user_address text)
returns varchar(100)
language plpgsql
as $$
declare 
name_states varchar(100);
abb_states varchar(10);
begin
	select substring(user_address , length(user_address) -7, 2) into abb_states;
	select state from states where postal = abb_states into name_states;
	return name_states;
end;
$$;

select address , take_name_state(address) name_state from users u  ;

-- cau 11

create or replace function stat_scope_by_states (xR int, yR int, r float, part_day int)
returns table (part_date int, part_hour int, state varchar(100), appear bigint)
language plpgsql
as $$
declare
begin
	return query
		select t1.partDate, t1.part_hour, t1.name_state, count(*) appear 
		from 
			(
				select distance(a.lat, a.lon, xR, yR) distance,
					convert_milisecond_to_date(a.millisecond) partDate,
					convert_milisecond_to_hour(a.millisecond) part_hour,
					take_name_state(b.address) name_state
				from tracking a inner join users b on b.user_id = a.user_id  
			) t1
		where t1.distance <= r and t1.partDate = part_day
		group by t1.partDate, t1.part_hour, t1.name_state
		order by t1.part_hour;
end;
$$;

select * from stat_scope_by_states(0, 0, 500, 20230607);

-- cau 12
create or replace function stat_movement_each_user(start_timestamp timestamp, end_timestamp timestamp)
returns table (user_id int, user_name varchar(500), age int, weight int, high int, sum_distance float)
language plpgsql
as $$
declare
start_miliseconds bigint;
end_miliseconds bigint;
begin
	SELECT EXTRACT(EPOCH FROM  start_timestamp) * 1000 into start_miliseconds;
	SELECT EXTRACT(EPOCH FROM  end_timestamp )* 1000 into end_miliseconds;
	
	return query
		select t2.user_id , u."name" , u.age , u.weight , u.high , t2.sum_distance from 
		(
			select t1.user_id ,sum(distance(lat, lat1, lon, lon1)) sum_distance
			from 
			(
				select t.user_id,lat, lon, (lead(lat) over (order by millisecond)) lat1, (lead(lon) over (order by millisecond)) lon1
				from tracking t 
				where t.millisecond >= start_miliseconds and t.millisecond  < end_miliseconds
				order by t.millisecond 
			) t1
			where t1.lat1 is not null 
			group by t1.user_id 
		) t2 inner join users u on u.user_id = t2.user_id;

end;
$$;

select * from stat_movement_each_user(TIMESTAMP '2023-06-07 10:58:28', TIMESTAMP '2023-06-07 11:00:28');
