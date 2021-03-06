use mwarin_ht;

select "dropping indexes" as what_is_happening;
-- Will cause a warning on a clean db.
drop index gd_prop_prop on gd_prop;
drop index gd_prop_val  on gd_prop;
drop index gd_str_str   on gd_str;

select "dropping tables" as what_is_happening;
-- Putting the drops in reverse order so they can be dropped.
drop table if exists gd_item_cluster;
drop table if exists gd_weights;
drop table if exists gd_prop;
drop table if exists gd_str;
drop table if exists gd_cluster_weights;
drop table if exists gd_cluster;
drop table if exists gd_item;

select "creating tables" as what_is_happening;
-- Create the tables.
create table gd_item (
  gd_item_id INT  not null auto_increment,
  raw 	     TEXT null, -- Whole MARC record? Or should we just link to it?
  hashsum    CHAR(64) not null,
  primary key (gd_item_id)
);

create table gd_cluster (
  gd_cluster_id INT not null auto_increment,
  primary key (gd_cluster_id)
);

-- For keeping unique strings. Normalization ftw.
create table gd_str (
  gd_str_id INT not null auto_increment,
  str          VARCHAR(500) not null,
  primary key (gd_str_id)
);

create table gd_cluster_weights (
  gd_cluster_id INT not null,
  prop 		INT not null,
  weight        INT default 1,
  primary key (gd_cluster_id, prop),
  foreign key (gd_cluster_id) references gd_cluster(gd_cluster_id),
  foreign key (prop)	      references gd_str(gd_str_id)
);

-- No longer keeps prop and val as varchars, but as FKs to gd_str:s.
create table gd_prop (
  gd_prop_id INT not null auto_increment,
  gd_item_id INT not null,
  prop       INT not null,
  val  	     INT not null,
  primary key (gd_prop_id),
  foreign key (gd_item_id) references gd_item(gd_item_id),
  foreign key (prop)       references gd_str(gd_str_id),
  foreign key (val) 	   references gd_str(gd_str_id)
);

create table gd_item_cluster (
  gd_item_id    INT not null,
  gd_cluster_id INT not null,
  primary key (gd_item_id, gd_cluster_id),
  foreign key (gd_item_id)    references gd_item(gd_item_id),
  foreign key (gd_cluster_id) references gd_cluster(gd_cluster_id)
);

create table gd_weights (
  gd_weight_id INT not null auto_increment,
  prop_str     varchar(50) not null unique,
  weight       INT not null default 1,
  primary key (gd_weight_id)
);

-- Keeping track of things.
create table gd_facts (
  gd_fact_name varchar(50) not null,
  gd_fact_value varchar(20) not null,
  primary key (gd_fact_name)
);

select "creating views" as what_is_happening;
-- 2 views to make it easier to display actual properties and values.
create or replace view v_gd_prop_str as 
select distinct gp.prop, gs.str from gd_prop AS gp JOIN gd_str AS gs ON (gp.prop = gs.gd_str_id);

create or replace view v_gd_val_str as 
select distinct gp.val, gs.str from gd_prop AS gp JOIN gd_str AS gs ON (gp.val = gs.gd_str_id);

-- View that contains info about which clusters are the same.
-- Needs at least:
--   SET group_concat_max_len=65536;
-- ... or a lot of group_concat() strings will be unintentionally identical.
create or replace view v_gd_cluster_ident as 
select gd_cluster_id, password(group_concat(distinct gd_item_id order by gd_item_id asc)) as ident from gd_item_cluster group by gd_cluster_id;

-- View that tells you which property-value pairs co-occur.
create or replace view v_gd_ready_clusters as
select count(gp.val) as cv, gp.prop, gp.val from gd_prop as gp group by gp.prop, gp.val having cv between 2 and 50;

select "creating additional indexes" as what_is_happening;
-- Additional indexes.
create index gd_prop_prop on gd_prop (prop)    using btree;
create index gd_prop_val  on gd_prop (val)     using btree;
create index gd_str_str   on gd_str (str)      using btree;
create index gd_item_hash on gd_item (hashsum) using btree;
create index gd_weights_prop_str on gd_weights (prop_str) using btree;
