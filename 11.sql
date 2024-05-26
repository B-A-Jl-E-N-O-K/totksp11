--Configuration

\! chcp 1251

\l

\c

DELETE FROM item;
DELETE FROM sales_order;

INSERT INTO sales_order (order_date, customer_id, ship_date, total) VALUES
('2024-01-01', 1, '2024-06-05', 10.00),
('2024-02-02', 2, '2024-07-05', 15.00),
('2024-03-03', 3, '2024-08-05', 20.00),
('2024-04-04', 4, '2024-09-05', 11.00),
('2024-05-05', 5, '2024-10-05', 16.00);

SELECT * FROM sales_order;

INSERT INTO item (order_id, product_id, actual_price, quantity, total) VALUES
(307119, 1, 10.00, 1, 10.00),
(307120, 2, 20.00, 1, 20.00),
(307121, 3, 30.00, 1, 30.00),
(307122, 4, 40.00, 1, 40.00),
(307123, 5, 50.00, 1, 50.00);



INSERT INTO customer (name, address, city, state, zip_code, area_code, phone_number, salesperson_id, credit_limit) VALUES
('Artem Zverev', '?', 'Moscow', '?', '?', 123, 4236, 1, 1000.00);

SELECT * FROM customer;


INSERT INTO sales_order (order_date, customer_id, ship_date, total) VALUES
('2024-05-25', 6, '2024-05-25', 10.00);

INSERT INTO item (order_id, product_id, actual_price, quantity, total) VALUES
(6, 1, 10.00, 1, 10.00);


--Task 1

CREATE EXTENSION plpython3u;


CREATE OR REPLACE FUNCTION tmprun(func text, params jsonb)
RETURNS text
TRANSFORM FOR TYPE jsonb
AS $python$
	p = plpy.prepare("SELECT * FROM " + plpy.quote_ident(func) + "($1)", ["jsonb"])
	r = p.execute([params])
	cols = r.colnames()
	collen = {col: len(col) for col in cols}
	for i in range(len(r)):
    	for col in cols:
        	if len( str(r[i][col]) ) > collen[col]:
            	collen[col] = len( str(r[i][col]) )
	res = ""
	res += " ".join( [col.center(collen[col]," ") for col in cols]) + "\n"
	res += " ".join( ["-"*collen[col] for col in cols]) + "\n"
	for i in range(len(r)):
    	res += " ".join( [str(r[i][col]).ljust(collen[col]," ") for col in cols]) + "\n"
	return res
$python$ LANGUAGE plpython3u VOLATILE;

CREATE OR REPLACE FUNCTION test_function(params jsonb)
RETURNS TABLE(id INT, value TEXT)
AS $$
DECLARE
    table_name text;
    query_text text;
BEGIN
    table_name := params ->> 'table_name';
    query_text := 'SELECT product_id, description::text FROM ' || quote_ident(table_name);
    RETURN QUERY EXECUTE query_text;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM tmprun('test_function', '{"table_name" : "product"}');

--Task2

ALTER TABLE customer ADD COLUMN email text;
UPDATE customer SET email = '' WHERE customer_id = 6;

CREATE OR REPLACE FUNCTION public.sendmail(from_addr text, to_addr text, subj text, msg text)
 RETURNS void
 LANGUAGE plpython3u
AS $function$
	import smtplib
	server = smtplib.SMTP('smtp.mail.ru', 587)
	server.starttls()
	server.login()
	server.sendmail(
    	from_addr,
    	to_addr,
        "\r\n".join([
        	"From: %s" % from_addr,
        	"To: %s" % to_addr,
            "Content-Type: text/plain; charset=\"UTF-8\"",
        	"Subject: %s" % subj,
            "\r\n%s" % msg
    	]).encode('utf-8')
	)
	server.quit()
$function$;

create table programs (program_id SERIAL PRIMARY KEY, name text, func text);

CREATE OR REPLACE FUNCTION public.register_program(name text, func text)
    	RETURNS bigint
    	LANGUAGE sql
   	   AS $function$
       	INSERT INTO programs(name, func) VALUES (name, func)
   	   RETURNING program_id;
    	$function$;

SELECT register_program('Send a mail', 'sendmail_task');

CREATE FUNCTION public.sendmail_task(params jsonb)
RETURNS text
AS $$
	SELECT sendmail(
    	from_addr => params->>'from_addr',
    	to_addr   => params->>'to_addr',
    	subj  	=> params->>'subj',
    	msg   	=> params->>'msg'
	);
	SELECT 'OK';
$$ LANGUAGE sql VOLATILE;

CREATE TABLE public.tasks (
	task_id SERIAL PRIMARY KEY ,
	program_id bigint NOT NULL,
	status text DEFAULT 'scheduled'::text NOT NULL,
	params jsonb,
	pid integer,
	started timestamp with time zone,
	finished timestamp with time zone,
	result text,
	host text,
	port text,
	CONSTRAINT tasks_check CHECK ((((host IS NOT NULL) AND (port IS NOT NULL)) OR ((host IS NULL) AND (port IS NULL)))),
	CONSTRAINT tasks_status_check CHECK ((status = ANY (ARRAY['scheduled'::text, 'running'::text, 'finished'::text, 'error'::text])))
);

CREATE FUNCTION public.run_program(program_id bigint, params jsonb DEFAULT NULL::jsonb, host text DEFAULT NULL::text, port text DEFAULT NULL::text) RETURNS bigint
	LANGUAGE sql SECURITY DEFINER
	AS $$
	INSERT INTO tasks(program_id, status, params, host, port)
	VALUES (program_id, 'scheduled', params, host, port)
	RETURNING task_id;
$$;

CREATE FUNCTION public.checkout(user_id bigint) returns void
AS $$
BEGIN
    PERFORM before_checkout(user_id);    
END;
$$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.before_checkout(user_id bigint)
RETURNS void
AS $$
DECLARE
    params jsonb;
BEGIN
    SELECT jsonb_build_object(
        'from_addr', '',
        'to_addr', c.email,
        'subj', 'Подтверждение заказа для пользователя ' || c.name,
        'msg', format(
                  E'Добрый день %s!\nБлагодарим за покупку.\nСумма заказа: $%s.',
                  c.name,
                  total
              )
    )
    INTO params
    FROM customer c
    JOIN (
        SELECT
            so.customer_id,
            SUM(i.total) AS total
        FROM sales_order so
        JOIN item i ON so.order_id = i.order_id
        WHERE so.customer_id = user_id
        GROUP BY so.customer_id
    ) AS order_totals ON order_totals.customer_id = c.customer_id;

    PERFORM public.run_program(
		1,
        params,
		NULL,
		NULL
    );
END;
$$ LANGUAGE plpgsql VOLATILE;

select checkout(6);
select * from tasks;


CREATE OR REPLACE FUNCTION public.execute_tasks()
RETURNS VOID
AS $$
DECLARE
    task_record RECORD;
    program_name TEXT;
    task_params JSONB;
BEGIN
    FOR task_record IN SELECT * FROM tasks WHERE status = 'scheduled' LOOP
        SELECT func INTO program_name FROM programs WHERE program_id = task_record.program_id;
        task_params := task_record.params;
        PERFORM tmprun(program_name, task_params);
        UPDATE tasks SET status = 'finished', finished = current_timestamp WHERE task_id = task_record.task_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


select execute_tasks();