# pghs - PostgreSQL History System

## Description

PL/pgSQL helper to create a trigger filling an history table with all changes over time.

## How it works?

* For a given table `{schema}.{table}` and an history table named `{schema}.{table}_h`
* `SELECT pghs_create_history_trigger(_table,_schema)` creates a trigger filling `{schema}.{table}_h` when INSERT, UPDATE or DELETE are performed on `{schema}.{table}`

## Requirements

* `{schema}.{table}` and `{schema}.{table}_h` have the same columns with the same order
* The following attributes are required on each table (they are managed by the trigger)

| name         | type             | description                |
| ------------ | ---------------- | -------------------------- |
| pghs_version | integer NOT NULL | 1, 2, 3...                 |
| pghs_date    | timestamp        | `NOW()` (transaction time) |
| pghs_state   | char(1)          | 'I', 'U' or 'D'            |

* `(id,pghs_version)` is the primary key of `{schema}.{table}_h` (it allows conflict detection)


## Sample

### 1) Prepare database

```bash
createdb pghs
psql -d pghs -f pghs.sql
psql -d pghs -f sample/poi.schema.sql
```

### 2) Edit sample.poi as usual

```bash
psql -d pghs -f sample/poi.data.sql
```

(you may also edit table using QuantumGIS for example)

### 3) See what's happen

Each time a row is INSERTED, UPDATED or DELETED in `sample.poi`, the row is duplicated in `sample.poi_h`


## Advanced used

### Alter table columns

Don't forget to update both tables :

```sql
ALTER table sample.poi add column title text;
ALTER table sample.poi_h add column title text;
```

(no need to re-create the trigger)

### Retrieve table state at a given time

```sql
select * from sample.poi_h t
	where t.pghs_version = (
		select max(pghs_version)
			from sample.poi_h t2
		where t2.id = t.id
		and t2.pghs_date < '2019-01-31 11:36:00'::timestamp
	)
;
```

### Offline edition

They are no requirements on the `id` type. You may use `uuid` instead of `serial`.

## License

[MIT](LICENSE)



