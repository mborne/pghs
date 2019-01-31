
-- create an automatic history on the table _table
CREATE OR REPLACE FUNCTION pgvs_create_history_trigger( _table text, _schema text DEFAULT 'public') RETURNS void AS $$
DECLARE
	history_table_name text;
	trigger_name text;
BEGIN
	-- TODO quote_ident( _table )

	history_table_name := _schema || '.' || _table || '_h';
	trigger_name := _schema || '.' || _table || '_tg_history';

	-- create trigger
	execute $x$
	create or replace function $x$ || trigger_name || $x$() returns trigger as $t$
		begin
		-- handle DELETE, UPpgvs_date and INSERT
		-- auto-increment pgvs_version and auto-define pgvs_date
		IF (TG_OP = 'DELETE') THEN
			OLD.pgvs_version := OLD.pgvs_version + 1 ;
			OLD.pgvs_date := now();
			OLD.pgvs_state := 'D';
			INSERT INTO $x$ || history_table_name || $x$ SELECT OLD.* ;
			RETURN OLD;
		ELSIF (TG_OP = 'UPDATE') THEN
			NEW.pgvs_version := OLD.pgvs_version + 1 ;
			NEW.pgvs_date := now() ;
			NEW.pgvs_state := 'U';
			INSERT INTO $x$ || history_table_name || $x$ SELECT NEW.* ;
			RETURN NEW;
		ELSIF (TG_OP = 'INSERT') THEN
            NEW.pgvs_version := 1 ;
			NEW.pgvs_date := now();
			NEW.pgvs_state := 'I';
			INSERT INTO $x$ || history_table_name || $x$ SELECT NEW.* ;
			RETURN NEW;
		END IF;
		return new;
		end;
	$t$ language plpgsql;
	$x$;

	-- add trigger to table
	execute $x$
	DROP TRIGGER IF EXISTS pgvs_history_trigger ON $x$ || _schema || '.' || _table || $x$ ;
	CREATE TRIGGER pgvs_history_trigger
		BEFORE INSERT OR UPDATE OR DELETE ON $x$ || _schema || '.' || _table || $x$
			FOR EACH ROW EXECUTE PROCEDURE $x$ || trigger_name || $x$() ;
 	$x$;
END
$$ LANGUAGE plpgsql;


