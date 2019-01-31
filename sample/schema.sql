CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP SCHEMA IF EXISTS sample CASCADE ;

CREATE SCHEMA sample;

CREATE TABLE sample.poi (
    -- required attributes ("id" name may change)
    id serial primary key,
    pgvs_version integer NOT NULL,
    pgvs_date    timestamp NOT NULL,
    pgvs_state   char(1) NOT NULL,
    -- type specific attributes
    name text,
    geometry geometry(Point,4326)
);

-- all objets over time
CREATE TABLE sample.poi_h (
    id integer,
    pgvs_version integer NOT NULL,
    pgvs_date timestamp NOT NULL,
    pgvs_state char(1) NOT NULL,
    name text,
    geometry geometry(Point,4326),

    -- primary key to detect edition conflicts
    PRIMARY KEY (id,pgvs_version)
);

SELECT pgvs_create_history_trigger('poi','sample');

insert into sample.poi (name,geometry)
	select
		uuid_generate_v4()::text as name, 
		ST_SetSRID(ST_MakePoint(random() * 50.0, random() * 50.0),4326) as geometry 
	from (
		select * from generate_series(1,1000) as number
	) t;

UPDATE sample.poi
    SET geometry = ST_Translate(geometry,0.001,0.001)
WHERE id % 5 = 0;
