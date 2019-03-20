
-- create a trigger filling {_schema}.{_table}_h when INSERT, UPDATE or DELETED
-- are performed on {_schema}.{_table}
CREATE OR REPLACE FUNCTION pghs_create_history_trigger( _table text, _schema text DEFAULT 'public') RETURNS void AS $$
DECLARE
	history_table_name text;
	trigger_name text;
BEGIN
	-- TODO quote_ident
	history_table_name := _schema || '.' || _table || '_h';
	trigger_name := _schema || '.' || _table || '_tg_history';

	-- generate trigger procedure
	execute $x$
	create or replace function $x$ || trigger_name || $x$() returns trigger as $t$
		begin
		-- handle DELETE, UPDATE and INSERT
		-- auto-increment pghs_version and auto-define pghs_date
		IF (TG_OP = 'DELETE') THEN
			OLD.pghs_version := OLD.pghs_version + 1 ;
			OLD.pghs_date := now();
			OLD.pghs_state := 'D';
			INSERT INTO $x$ || history_table_name || $x$ SELECT OLD.* ;
			RETURN OLD;
		ELSIF (TG_OP = 'UPDATE') THEN
			NEW.pghs_version := OLD.pghs_version + 1 ;
			NEW.pghs_date := now() ;
			NEW.pghs_state := 'U';
			INSERT INTO $x$ || history_table_name || $x$ SELECT NEW.* ;
			RETURN NEW;
		ELSIF (TG_OP = 'INSERT') THEN
            NEW.pghs_version := 1 ;
			NEW.pghs_date := now();
			NEW.pghs_state := 'I';
			INSERT INTO $x$ || history_table_name || $x$ SELECT NEW.* ;
			RETURN NEW;
		END IF;
		return new;
		end;
	$t$ language plpgsql;
	$x$;

	-- add trigger to table
	execute $x$
	DROP TRIGGER IF EXISTS pghs_history_trigger ON $x$ || _schema || '.' || _table || $x$ ;
	CREATE TRIGGER pghs_history_trigger
		BEFORE INSERT OR UPDATE OR DELETE ON $x$ || _schema || '.' || _table || $x$
			FOR EACH ROW EXECUTE PROCEDURE $x$ || trigger_name || $x$() ;
 	$x$;
END
$$ LANGUAGE plpgsql;


