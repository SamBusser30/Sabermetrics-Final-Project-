use retrosheet; 

select count(event_cd = 23), pit_id from events group by pit_id order by count(event_cd = 23) desc;

select * from lkup_cd_event ;

#create table with only events that result in the end of an at bat (what's important for my stat) 
drop table if exists AB_end;
create table AB_end as 
select pit_id, event_cd, event_runs_ct from events where event_cd in (2,3,14,15,16,18,19,20,21,22,23);

#select id.first, id.last, count(event_cd = 23) from AB_end 
#join id on AB_end.pit_id = id.id
#group by pit_id
#order by count(event_cd = 23) desc;

#select id.first, id.last, (event_cd=20 + (2*event_cd=21) + (3*event_cd=22) + (4*event_cd=23))/count(pit_id) as slg_allowed from AB_end
#join id on AB_end.pit_id = id.id
#group by pit_id having count(pit_id) > 300
#order by slg_allowed desc;

#drop table if exists min_batters;
#create table min_batters as 
#select * from AB_end
#group by pit_id having count(pit_id) > 500; 



#creating table with batters faced so can limit it to pitchers who faced 1000 batters or more
drop table if exists batters_faced;
create table batters_faced as 
select id.first, id.last, pit_id, count(pit_id) as batters_faced from AB_end 
join id on id.id = AB_end.pit_id
group by pit_id having count(pit_id) > 1000 
order by count(pit_id);

select * from batters_faced;

#joining AB_end and batters_face to get every event for all pitchers who faced more than 1000 batters. 
drop table if exists new_events;
create table new_events as 
select id.first, id.last, AB_end.pit_id, event_cd, event_runs_ct, bf.batters_faced from AB_end 
join id on id.id = AB_end.pit_id
join batters_faced bf on AB_end.pit_id = bf.pit_id;


#Now create tables for all four types of hits, strikeouts and earned runs. 
drop table if exists 1B;
create table 1B as
select first, last, pit_id, count(*) as 1B from new_events where event_cd = 20 group by pit_id;

drop table if exists 2B;
create table 2B as
select first, last, pit_id, count(*) as 2B from new_events where event_cd = 21 group by pit_id;

drop table if exists 3B;
create table 3B as
select first, last, pit_id, count(*) as 3B from new_events where event_cd = 22 group by pit_id;

drop table if exists HR;
create table HR as
select first, last, pit_id, count(*) as HR from new_events where event_cd = 23 group by pit_id;

drop table if exists k;
create table k as
select first, last, pit_id, count(*) as k from new_events where event_cd = 3 group by pit_id;

drop table if exists er;
create table er as 
select first, last, pit_id, sum(event_runs_ct) as er from new_events where event_cd not in(18) group by pit_id;

#create table now with every pitchers event counts, and batters faced -> will use this table to calculate the stat. 
drop table if exists stat;
create table stat as 
select new_events.first, new_events.last, new_Events.pit_id, 1b.1b, 2b.2b, 3b.3b, hr.hr, k.k, er.er, batters_faced from new_Events
join 1b on new_events.pit_id = 1b.pit_id
join 2b on new_Events.pit_id = 2b.pit_id
join 3b on new_Events.pit_id = 3b.pit_id
join hr on new_Events.pit_id = hr.pit_id
join k on new_Events.pit_id = k.pit_id
join er on new_events.pit_id = er.pit_id
group by new_Events.pit_id;

select first, last, (1b + (2*2b) + (3*3b)+ (4*hr) - (1.5*k) + (4 * er))/batters_faced as Tossing_Percentage from stat order by Tossing_Percentage;



#Computing ERA for each pitcher in new_events
drop table if exists innings_pitched;
create table innings_pitched as
select pit_id, count(inn_new_fl) as innings_pitched from events where inn_new_fl = 'T' group by pit_id order by count(inn_new_fl) desc;
select * from innings_pitched;

drop table if exists era_table;
create table era_table as
select stat.pit_id, first, last, er, inn.innings_pitched, (er/inn.innings_pitched)*9 as era from stat
join innings_pitched inn on stat.pit_id = inn.pit_id
group by stat.pit_id
order by innings_pitched desc;
select * from era_table;

#this will give a table with tossing percentage and ERA
select stat.first, stat.last, (1b + (2*2b) + (3*3b)+ (4*hr) - (1.5*k) + (4 * stat.er))/batters_faced as Tossing_Percentage, era_table.era from stat
join era_table on era_table.pit_id = stat.pit_id
order by Tossing_Percentage;


