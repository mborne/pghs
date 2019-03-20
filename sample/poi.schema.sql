CREATE EXTENSION IF NOT EXISTS postgis;

DROP SCHEMA IF EXISTS sample CASCADE ;

CREATE SCHEMA sample;

CREATE TABLE sample.poi (
    -- required attributes ("id" name may change)
    id serial primary key,
    pghs_version integer NOT NULL,
    pghs_date    timestamp NOT NULL,
    pghs_state   char(1) NOT NULL,
    -- type specific attributes
    name text,
    geometry geometry(Point,4326)
);

-- all objets over time
CREATE TABLE sample.poi_h (
    id integer,
    pghs_version integer NOT NULL,
    pghs_date timestamp NOT NULL,
    pghs_state char(1) NOT NULL,
    name text,
    geometry geometry(Point,4326),

    PRIMARY KEY (id,pghs_version)
);

SELECT pghs_create_history_trigger('poi','sample');
