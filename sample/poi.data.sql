CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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
