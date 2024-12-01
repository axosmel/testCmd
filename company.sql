PGDMP                  
    |            san_juan_businesses    16.5    16.0 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    24576    san_juan_businesses    DATABASE     {   CREATE DATABASE san_juan_businesses WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';
 #   DROP DATABASE san_juan_businesses;
             	   koyeb-adm    false                        2615    24577    audit_trail    SCHEMA        CREATE SCHEMA audit_trail;
    DROP SCHEMA audit_trail;
             	   koyeb-adm    false                        2615    24578    backend_functions    SCHEMA     !   CREATE SCHEMA backend_functions;
    DROP SCHEMA backend_functions;
             	   koyeb-adm    false                        2615    24579    company_record    SCHEMA        CREATE SCHEMA company_record;
    DROP SCHEMA company_record;
             	   koyeb-adm    false            �           0    0    SCHEMA public    ACL     Q   REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;
                   pg_database_owner    false    9                        2615    24580    system    SCHEMA        CREATE SCHEMA system;
    DROP SCHEMA system;
             	   koyeb-adm    false            �            1255    24581    extract_address(jsonb)    FUNCTION     O  CREATE FUNCTION backend_functions.extract_address(json_data jsonb) RETURNS TABLE(house_no text, purok text, street text, subdivision text, brgy text, city text, province text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        elem ->> 'houseNo' AS house_no,
        elem ->> 'purok' AS purok,
        elem ->> 'street' AS street,
        elem ->> 'subdivision' AS subdivision,
        elem ->> 'brgy' AS brgy,
        elem ->> 'city' AS city,
        elem ->> 'province' AS province
    FROM
        jsonb_array_elements(json_data -> 'addresseList') AS elem;
END;
$$;
 B   DROP FUNCTION backend_functions.extract_address(json_data jsonb);
       backend_functions       	   koyeb-adm    false    6            �            1255    24582    extract_contacts(jsonb)    FUNCTION     �  CREATE FUNCTION backend_functions.extract_contacts(json_data jsonb) RETURNS TABLE(contact_type text, contact_details text, prioritization text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        elem ->> 'contactType' AS contact_type,
        elem ->> 'contactDetails' AS contact_details,
        elem ->> 'prioritization' AS prioritization
    FROM
        jsonb_array_elements(json_data -> 'contact') AS elem;
END;
$$;
 C   DROP FUNCTION backend_functions.extract_contacts(json_data jsonb);
       backend_functions       	   koyeb-adm    false    6                       1255    24583     get_user_data(character varying)    FUNCTION     w  CREATE FUNCTION backend_functions.get_user_data(in_username character varying) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
	SELECT
	--  USERS TABLE
		u.user_id, u.firstname, u.middlename, u.lastname,
		u.sex, u.birthdate, u.registered_date,
	-- 	COMPANIES TABLE
		c.company_id, c.title, c.description, c.business, c.street,
		c.brgy, c.city, c.province, c.longitude, c.latitude,
	-- 	ROLES TABLE
		r.role_id, r.role_title, r.role_description,
	-- 	CONTACTS TABLE
		cts.contact_id, contact_type, contact_details, prioritization,
	-- 	ADDRESS TABLE
		addr.address_id, addr.house_no, addr.purok, addr.street,
		addr.subdivision, addr.brgy, addr.city, addr.province,
	-- 	ACCESS MATRIX TABLE
		am.matrix_id, am.matrix_title, am.matrix_description, am.access_type,
	-- 	FEATURES TABLE
		f.feature_id, f.feature_title, f.feature_description
	FROM users u
	FULL OUTER JOIN company_record.companies c
	ON u.company_id = c.company_id
	FULL OUTER JOIN roles r
	ON u.role_id = r.role_id
	FULL OUTER JOIN user_details ud
	ON u.user_id = ud.user_id
	FULL OUTER JOIN contacts cts
	ON ud.details_id = cts.user_details_id
	FULL OUTER JOIN address addr
	ON ud.details_id = addr.user_details_id
	FULL OUTER JOIN access_matrix am
	ON r.role_id = am.role_id
	FULL OUTER JOIN features f
	ON f.feature_id = am.feature_id
	WHERE u.user_id IS NOT NULL AND u.username = in_username;

END;
$$;
 N   DROP FUNCTION backend_functions.get_user_data(in_username character varying);
       backend_functions       	   koyeb-adm    false    6                       1255    24584 (   get_user_data_wrapper(character varying)    FUNCTION     �	  CREATE FUNCTION backend_functions.get_user_data_wrapper(in_username character varying) RETURNS TABLE(user_id bigint, firstname character varying, middlename character varying, lastname character varying, sex character varying, birthdate text, registered_date text, company_id bigint, title character varying, description character varying, business character varying, street character varying, brgy character varying, city character varying, province character varying, longitude character varying, latitude character varying, role_id bigint, role_title character varying, role_description character varying, contact_id bigint, contact_type character varying, contact_details character varying, prioritization character varying, address_id bigint, house_no character varying, purok character varying, addr_street character varying, subdivision character varying, addr_brgy character varying, addr_city character varying, addr_province character varying, matrix_id bigint, matrix_title character varying, matrix_description character varying, access_type character varying[], feature_id bigint, feature_title character varying, feature_description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
	
	SELECT
	--  USERS TABLE
		u.user_id, u.firstname, u.middlename, u.lastname,
		u.sex, u.birthdate::TEXT, u.registered_date::TEXT,
	-- 	COMPANIES TABLE
		c.company_id, c.title, c.description, c.business, c.street,
		c.brgy, c.city, c.province, c.longitude, c.latitude,
	-- 	ROLES TABLE
		r.role_id, r.role_title, r.role_description,
	-- 	CONTACTS TABLE
		cts.contact_id, cts.contact_type, cts.contact_details, cts.prioritization,
	-- 	ADDRESS TABLE
		addr.address_id, addr.house_no, addr.purok, addr.street,
		addr.subdivision, addr.brgy, addr.city, addr.province,
	-- 	ACCESS MATRIX TABLE
		am.matrix_id, am.matrix_title, am.matrix_description, am.access_type,
	-- 	FEATURES TABLE
		f.feature_id, f.feature_title, f.feature_description
	FROM users u
	FULL OUTER JOIN company_record.companies c
	ON u.company_id = c.company_id
	FULL OUTER JOIN roles r
	ON u.role_id = r.role_id
	FULL OUTER JOIN user_details ud
	ON u.user_id = ud.user_id
	FULL OUTER JOIN contacts cts
	ON ud.details_id = cts.user_details_id
	FULL OUTER JOIN address addr
	ON ud.details_id = addr.user_details_id
	FULL OUTER JOIN access_matrix am
	ON r.role_id = am.role_id
	FULL OUTER JOIN features f
	ON f.feature_id = am.feature_id
	WHERE u.user_id IS NOT NULL AND u.username = in_username;
END;
$$;
 V   DROP FUNCTION backend_functions.get_user_data_wrapper(in_username character varying);
       backend_functions       	   koyeb-adm    false    6                       1255    24585 �   insert_user(bigint, bigint, character varying, character varying, character varying, date, character varying, character varying, character varying, character varying, timestamp with time zone)    FUNCTION     =  CREATE FUNCTION backend_functions.insert_user(in_role_id bigint, in_company_id bigint, in_firstname character varying, in_middlename character varying, in_lastname character varying, in_birthdate date, in_sex character varying, in_username character varying, in_password character varying, in_pin character varying, in_registered_date timestamp with time zone) RETURNS TABLE(user_id integer, dtls_id integer, status_code integer, status_message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		usr_id INT;
		dtls_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
		out_details_id INT;
		out_user_id INT;
		out_status_code INT;
		out_status_message TEXT;
	BEGIN			
		CALL public.insert_user(
			in_role_id, 
			in_company_id, 
			in_firstname, 
			in_middlename, 
			in_lastname, 
			in_birthdate, 
			in_sex, 
			in_username, 
			in_password, 
			in_pin, 
			in_registered_date, 
			out_user_id,
			out_details_id, 
			out_status_code, 
			out_status_message
		);
		
		RETURN QUERY SELECT out_user_id, out_details_id, out_status_code, out_status_message;
		
	END;
$$;
 h  DROP FUNCTION backend_functions.insert_user(in_role_id bigint, in_company_id bigint, in_firstname character varying, in_middlename character varying, in_lastname character varying, in_birthdate date, in_sex character varying, in_username character varying, in_password character varying, in_pin character varying, in_registered_date timestamp with time zone);
       backend_functions       	   koyeb-adm    false    6                       1255    24586 N   register_user(bigint, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION backend_functions.register_user(in_user_id bigint, in_username character varying, in_password character varying, in_pin character varying) RETURNS TABLE(user_id bigint, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_pending_id BIGINT;
    user_id BIGINT;
	user_role_id BIGINT;
	user_firstname CHARACTER VARYING;
	user_middlename CHARACTER VARYING;
	user_lastname CHARACTER VARYING;
	user_sex CHARACTER VARYING;
	user_company_id BIGINT;
	user_birthdate DATE;
    update_status BIGINT;
BEGIN
	SELECT
		role_id, firstname, middlename, lastname, sex, company_id, birthdate
	INTO
		user_role_id, user_firstname, user_middlename, user_lastname, user_sex, user_company_id, user_birthdate
	FROM
		pending_users WHERE pending_id = in_user_id;
		
	user_pending_id := public.check_user(
		user_firstname,
		user_middlename,
		user_lastname
	);
	
	IF user_pending_id IS NULL THEN
		INSERT INTO users (
			role_id, firstname, middlename, lastname, sex, company_id, birthdate, username, password, pin
		)VALUES
		(
			user_role_id, user_firstname, user_middlename, user_lastname, user_sex,
			user_company_id, user_birthdate, in_username, in_password, in_pin
		)
		RETURNING users.user_id INTO user_id;
		IF user_id IS NOT NULL THEN
			UPDATE public.pending_users SET status = 'VERIFIED' WHERE pending_id = in_user_id AND status = 'PENDING' RETURNING 1 INTO update_status;
			
			IF update_status IS NOT NULL THEN
				RETURN QUERY SELECT user_id , 'SUCCESSFULLY REGISTERED USER';
			ELSE
				RETURN QUERY SELECT in_user_id , 'SUCCESSFULLY REGISTERED USER BUT FAILED TO UPDATE STATUS';
			END IF;
		ELSE
		END IF;
	ELSE
		RETURN QUERY SELECT user_pending_id , 'FAILED TO REGISTER USER';
	END IF;
	
	EXCEPTION
		WHEN unique_violation THEN
			RETURN QUERY SELECT 409::BIGINT , 'PENDING USER DOES NOT EXIST';
		WHEN others THEN
			RETURN QUERY SELECT 500::BIGINT , 'PENDING USER DOES NOT EXIST -- ' || SQLERRM;
END;
$$;
 �   DROP FUNCTION backend_functions.register_user(in_user_id bigint, in_username character varying, in_password character varying, in_pin character varying);
       backend_functions       	   koyeb-adm    false    6            	           1255    24587 h   register_user(bigint, character varying, character varying, character varying, timestamp with time zone)    FUNCTION     	  CREATE FUNCTION backend_functions.register_user(in_user_id bigint, in_username character varying, in_password character varying, in_pin character varying, in_registered_date timestamp with time zone) RETURNS TABLE(user_id bigint, out_status bigint, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    user_pending_id BIGINT;
    var_user_id BIGINT;
    var_status_message TEXT;
	user_role_id BIGINT;
	user_firstname CHARACTER VARYING;
	user_middlename CHARACTER VARYING;
	user_lastname CHARACTER VARYING;
	user_sex CHARACTER VARYING;
	user_company_id BIGINT;
	user_birthdate DATE;
    update_status BIGINT;
BEGIN
	SELECT
		role_id, firstname, middlename, lastname, sex, company_id, birthdate
	INTO
		user_role_id, user_firstname, user_middlename, user_lastname, user_sex, user_company_id, user_birthdate
	FROM
		pending_users WHERE pending_id = in_user_id;
		
-- 	user_pending_id := public.check_user(
-- 		user_firstname,
-- 		user_middlename,
-- 		user_lastname
-- 	);

-- 	IF user_pending_id IS NULL THEN
	SELECT ui.user_id, ui.status_message INTO var_user_id, var_status_message  FROM backend_functions.insert_user(
		user_role_id, 
		user_company_id, 
		user_firstname, 
		user_middlename, 
		user_lastname, 
		user_birthdate, 
		user_sex, 
		in_username, 
		in_password, 
		in_pin, 
		in_registered_date
	)ui;
	IF var_user_id IS NOT NULL THEN
		UPDATE public.pending_users SET status = 'VERIFIED', username = username || '-USED' WHERE pending_id = in_user_id AND status = 'PENDING' RETURNING 1 INTO update_status;

		IF update_status IS NOT NULL THEN
			RETURN QUERY SELECT var_user_id, 200::BIGINT, 'SUCCESSFULLY REGISTERED USER';
		ELSE
			RETURN QUERY SELECT in_user_id, 201::BIGINT, 'SUCCESSFULLY REGISTERED USER BUT FAILED TO UPDATE STATUS';
		END IF;
	ELSE
		RETURN QUERY SELECT var_user_id , var_status_message;
	END IF;
-- 	ELSE
-- 		RETURN QUERY SELECT user_pending_id , 'PENDING USER NOT FOUND';
-- 	END IF;
	
	EXCEPTION
		WHEN unique_violation THEN
			RETURN QUERY SELECT 409::BIGINT, 409::BIGINT, 'PENDING USER DOES NOT EXIST';
		WHEN others THEN
			IF var_status_message IS NOT NULL THEN
				RETURN QUERY SELECT 500::BIGINT, 409::BIGINT, var_status_message;
			ELSE
				RETURN QUERY SELECT 500::BIGINT, 500::BIGINT, 'PENDING USER DOES NOT EXIST -- ' || SQLERRM || ' ' || var_status_message;
			END IF;
END;
$$;
 �   DROP FUNCTION backend_functions.register_user(in_user_id bigint, in_username character varying, in_password character varying, in_pin character varying, in_registered_date timestamp with time zone);
       backend_functions       	   koyeb-adm    false    6            
           1255    24588    check_company_by_id(bigint)    FUNCTION     8  CREATE FUNCTION company_record.check_company_by_id(in_company_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM company_record.companies WHERE company_id = in_company_id;
	RETURN query_result;
END;
$$;
 H   DROP FUNCTION company_record.check_company_by_id(in_company_id bigint);
       company_record       	   koyeb-adm    false    7                       1255    24589 )   check_company_by_title(character varying)    FUNCTION     G  CREATE FUNCTION company_record.check_company_by_title(in_company_title character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM company_record.companies WHERE title = in_company_title;
	RETURN query_result;
END;
$$;
 Y   DROP FUNCTION company_record.check_company_by_title(in_company_title character varying);
       company_record       	   koyeb-adm    false    7                       1255    24590 ,   check_feedback_by_visitor(character varying)    FUNCTION     R  CREATE FUNCTION company_record.check_feedback_by_visitor(in_visitors_name character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM company_record.feedbacks WHERE visitors_name = in_visitors_name;
	RETURN query_result;
END;
$$;
 \   DROP FUNCTION company_record.check_feedback_by_visitor(in_visitors_name character varying);
       company_record       	   koyeb-adm    false    7                       1255    24591 )   check_question(bigint, character varying)    FUNCTION     �  CREATE FUNCTION company_record.check_question(in_company_id bigint, in_question character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM company_record.feedback_questions fq
	INNER JOIN company_record.companies c ON fq.company_id = c.company_id
	WHERE c.company_id = in_company_id AND fq.question = in_question;
	RETURN query_result;
END;
$$;
 b   DROP FUNCTION company_record.check_question(in_company_id bigint, in_question character varying);
       company_record       	   koyeb-adm    false    7                       1255    24592 U   insert_answer(bigint, character varying, character varying, character varying, jsonb) 	   PROCEDURE     �  CREATE PROCEDURE company_record.insert_answer(IN in_company_id bigint, IN in_visitors_name character varying, IN in_comments character varying, IN in_rating character varying, IN in_answers jsonb, OUT id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		rting_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
	    IF (SELECT company_record.check_company_by_id(in_company_id)) IS NULL THEN
			status_code := '400';
			status_message := 'RECORD CONFLICT COMPANY NOT EXISTS';
			SELECT rting_id, status_code, status_message INTO id, status, message;
		ELSE
			IF (SELECT company_record.check_feedback_by_visitor(in_visitors_name)) IS NULL THEN
				INSERT INTO company_record.feedbacks(
					company_id, visitors_name, comments, rating, answers
				)VALUES(
					in_company_id, in_visitors_name, in_comments, in_rating, in_answers
				) RETURNING feedback_id INTO rting_id;
			ELSE
				rting_id = NULL;
			END IF;
			
			IF rting_id IS NOT NULL THEN
				status_code := '200';
				status_message := 'RECORD SUCCESSFULLY INSERTED';
				SELECT rting_id, status_code, status_message INTO id, status, message;
			ELSE
				status_code := '400';
				status_message := 'RECORD CONFLICT FEEDBACK EXISTS';
				SELECT rting_id, status_code, status_message INTO id, status, message;
			END IF;
		END IF;

		
		EXCEPTION
			WHEN unique_violation THEN
				status_code := '409';
				status_message := 'RECORD CONFLICT';
			SELECT rting_id, status_code, status_message INTO id, status, message;
			WHEN others THEN
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
			SELECT rting_id, status_code, status_message INTO id, status, message;
	END;
$$;
 �   DROP PROCEDURE company_record.insert_answer(IN in_company_id bigint, IN in_visitors_name character varying, IN in_comments character varying, IN in_rating character varying, IN in_answers jsonb, OUT id integer, OUT status integer, OUT message text);
       company_record       	   koyeb-adm    false    7                       1255    24593 �   insert_checkin(bigint, character varying, character varying, character varying, character varying, character varying, bigint, bigint, bigint, bigint, character varying, timestamp with time zone) 	   PROCEDURE     �
  CREATE PROCEDURE company_record.insert_checkin(IN in_company_id bigint, IN in_visitors_firstname character varying, IN in_visitors_middlename character varying, IN in_visitors_lastname character varying, IN in_visitors_city character varying, IN in_visitors_province character varying, IN in_adults_female_cnt bigint, IN in_adults_male_cnt bigint, IN in_kids_female_cnt bigint, IN in_kids_male_cnt bigint, IN in_visit_type character varying, IN in_time_in timestamp with time zone, OUT id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		chckn_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
	    IF (SELECT company_record.check_company_by_id(in_company_id)) IS NULL THEN
			status_code := '400';
			status_message := 'RECORD CONFLICT COMPANY NOT EXISTS';
			SELECT chckn_id, status_code, status_message INTO id, status, message;
		ELSE
			INSERT INTO company_record.checkins(
				company_id, visitors_firstname, visitors_middlename, visitors_lastname, visitors_city,
				visitors_province, adults_female_cnt, adults_male_cnt, kids_female_cnt, kids_male_cnt, visit_type, time_in
			)
			SELECT
				in_company_id, in_visitors_firstname, in_visitors_middlename, in_visitors_lastname, in_visitors_city,
				in_visitors_province, in_adults_female_cnt, in_adults_male_cnt, in_kids_female_cnt, in_kids_male_cnt, in_visit_type, in_time_in
			WHERE NOT EXISTS (
				SELECT * FROM company_record.checkins
				WHERE
					in_time_in::DATE = time_in::DATE
					AND in_visitors_firstname = visitors_firstname
					AND in_visitors_middlename = visitors_middlename
					AND in_visitors_lastname = visitors_lastname
			)
			RETURNING checkin_id INTO chckn_id;
			
			IF chckn_id IS NOT NULL THEN
				status_code := '200';
				status_message := 'RECORD SUCCESSFULLY INSERTED';
				SELECT chckn_id, status_code, status_message INTO id, status, message;
			ELSE
				status_code := '400';
				status_message := 'RECORD CONFLICT CHECKIN EXISTS';
				SELECT checkin_id INTO chckn_id
				FROM company_record.checkins
				WHERE
					time_in::DATE = in_time_in::DATE
					AND visitors_firstname = in_visitors_firstname
					AND visitors_middlename = in_visitors_middlename
					AND visitors_lastname = in_visitors_lastname;
				SELECT chckn_id, status_code, status_message INTO id, status, message;
			END IF;
		END IF;

		
		EXCEPTION
			WHEN unique_violation THEN
				status_code := '409';
				status_message := 'RECORD CONFLICT';
			SELECT chckn_id, status_code, status_message INTO id, status, message;
			WHEN others THEN
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
			SELECT chckn_id, status_code, status_message INTO id, status, message;
	END;
$$;
   DROP PROCEDURE company_record.insert_checkin(IN in_company_id bigint, IN in_visitors_firstname character varying, IN in_visitors_middlename character varying, IN in_visitors_lastname character varying, IN in_visitors_city character varying, IN in_visitors_province character varying, IN in_adults_female_cnt bigint, IN in_adults_male_cnt bigint, IN in_kids_female_cnt bigint, IN in_kids_male_cnt bigint, IN in_visit_type character varying, IN in_time_in timestamp with time zone, OUT id integer, OUT status integer, OUT message text);
       company_record       	   koyeb-adm    false    7                       1255    24594 �   insert_company(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     K  CREATE PROCEDURE company_record.insert_company(IN in_title character varying, IN in_description character varying, IN in_business character varying, IN in_street character varying, IN in_brgy character varying, IN in_city character varying, IN in_province character varying, IN in_longitude character varying, IN in_latitude character varying, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		cmpny_id INT;
		current_id INT;
	BEGIN
	    IF NOT EXISTS (SELECT 1 FROM company_record.companies WHERE title = in_title) THEN
			INSERT INTO company_record.companies(
				  title, description, business, street, brgy, city, province, longitude, latitude
			)VALUES(
				in_title, in_description, in_business, in_street, in_brgy ,in_city, in_province, in_longitude, in_latitude
			) RETURNING company_id INTO cmpny_id;
		ELSE
			cmpny_id = NULL;
		END IF;

		IF cmpny_id IS NULL THEN
			ROLLBACK;
-- 			current_id := nextval('company_record.company_company_id_seq') - 1;
-- 			IF current_id > 1 THEN
-- 				current_id := current_id - 1;
-- 			ELSE
-- 				current_id := 1;
-- 			END IF;
-- 			PERFORM setval('company_record.company_company_id_seq', current_id, true);
			SELECT '409', 'RECORD CONFLICT' INTO status, message;
		ELSE
			COMMIT;
			SELECT '200', 'RECORD SUCCESSFULLY INSERTED' INTO status, message;
		END IF;
	END;
$$;
 }  DROP PROCEDURE company_record.insert_company(IN in_title character varying, IN in_description character varying, IN in_business character varying, IN in_street character varying, IN in_brgy character varying, IN in_city character varying, IN in_province character varying, IN in_longitude character varying, IN in_latitude character varying, OUT status integer, OUT message text);
       company_record       	   koyeb-adm    false    7                       1255    24595 *   insert_question(bigint, character varying) 	   PROCEDURE       CREATE PROCEDURE company_record.insert_question(IN in_company_id bigint, IN in_question character varying, OUT id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		qstn_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
	    IF (SELECT company_record.check_company_by_id(in_company_id)) IS NULL THEN
			status_code := '400';
			status_message := 'RECORD CONFLICT COMPANY NOT EXISTS';
			SELECT qstn_id, status_code, status_message INTO id, status, message;
		ELSE
			IF (SELECT company_record.check_question(in_company_id, in_question)) IS NULL THEN
				INSERT INTO company_record.feedback_questions(
					company_id, question
				)VALUES(
					in_company_id, in_question
				) RETURNING question_id INTO qstn_id;
			ELSE
				qstn_id = NULL;
			END IF;
			
			IF qstn_id IS NOT NULL THEN
				status_code := '200';
				status_message := 'RECORD SUCCESSFULLY INSERTED';
				SELECT qstn_id, status_code, status_message INTO id, status, message;
			ELSE
				status_code := '400';
				status_message := 'RECORD CONFLICT QUESTION EXISTS';
				SELECT qstn_id, status_code, status_message INTO id, status, message;
			END IF;
		END IF;

		
		EXCEPTION
			WHEN unique_violation THEN
				status_code := '409';
				status_message := 'RECORD CONFLICT';
			SELECT qstn_id, status_code, status_message INTO id, status, message;
			WHEN others THEN
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
			SELECT qstn_id, status_code, status_message INTO id, status, message;
	END;
$$;
 �   DROP PROCEDURE company_record.insert_question(IN in_company_id bigint, IN in_question character varying, OUT id integer, OUT status integer, OUT message text);
       company_record       	   koyeb-adm    false    7                       1255    24596 2   visitor_checkout(bigint, timestamp with time zone) 	   PROCEDURE     �  CREATE PROCEDURE company_record.visitor_checkout(IN in_checkin_id bigint, IN in_time_out timestamp with time zone, OUT id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		chckn_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
		UPDATE company_record.checkins SET time_out = in_time_out WHERE checkin_id = in_checkin_id
		RETURNING checkin_id INTO chckn_id;

		IF chckn_id IS NOT NULL THEN
			status_code := '200';
			status_message := 'RECORD SUCCESSFULLY UPDATED';
			SELECT chckn_id, status_code, status_message INTO id, status, message;
		ELSE
			status_code := '400';
			status_message := 'RECORD CONFLICT CHECKIN DOES NOT EXISTS';
			SELECT chckn_id, status_code, status_message INTO id, status, message;
		END IF;

		
		EXCEPTION
			WHEN unique_violation THEN
				status_code := '409';
				status_message := 'RECORD CONFLICT';
			SELECT chckn_id, status_code, status_message INTO id, status, message;
			WHEN others THEN
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
			SELECT chckn_id, status_code, status_message INTO id, status, message;
	END;
$$;
 �   DROP PROCEDURE company_record.visitor_checkout(IN in_checkin_id bigint, IN in_time_out timestamp with time zone, OUT id integer, OUT status integer, OUT message text);
       company_record       	   koyeb-adm    false    7                       1255    24597 +   check_contact_by_details(character varying)    FUNCTION     ?  CREATE FUNCTION public.check_contact_by_details(in_contact_details character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM contacts WHERE contact_details = in_contact_details;
	RETURN query_result;
END;
$$;
 U   DROP FUNCTION public.check_contact_by_details(in_contact_details character varying);
       public       	   koyeb-adm    false                       1255    24598    check_feature_by_id(bigint)    FUNCTION        CREATE FUNCTION public.check_feature_by_id(in_feature_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM features WHERE feature_id = in_feature_id;
	RETURN query_result;
END;
$$;
 @   DROP FUNCTION public.check_feature_by_id(in_feature_id bigint);
       public       	   koyeb-adm    false                       1255    24599    check_feature_by_title(text)    FUNCTION     *  CREATE FUNCTION public.check_feature_by_title(in_feature_title text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM features WHERE feature_title = in_feature_title;
	RETURN query_result;
END;
$$;
 D   DROP FUNCTION public.check_feature_by_title(in_feature_title text);
       public       	   koyeb-adm    false                       1255    24600    check_matrix_by_title(text)    FUNCTION     +  CREATE FUNCTION public.check_matrix_by_title(in_matrix_title text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM access_matrix WHERE matrix_title = in_matrix_title;
	RETURN query_result;
END;
$$;
 B   DROP FUNCTION public.check_matrix_by_title(in_matrix_title text);
       public       	   koyeb-adm    false                       1255    24601 *   check_pending_user(text, text, text, text)    FUNCTION     �  CREATE FUNCTION public.check_pending_user(in_firstname text, in_middlename text, in_lastname text, in_email text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM pending_users WHERE (firstname = in_firstname AND middlename = in_middlename AND lastname = in_lastname) OR (email = in_email);
	RETURN query_result;
END;
$$;
 q   DROP FUNCTION public.check_pending_user(in_firstname text, in_middlename text, in_lastname text, in_email text);
       public       	   koyeb-adm    false                       1255    24602    check_role_by_id(bigint)    FUNCTION       CREATE FUNCTION public.check_role_by_id(in_role_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM roles WHERE role_id = in_role_id;
	RETURN query_result;
END;
$$;
 :   DROP FUNCTION public.check_role_by_id(in_role_id bigint);
       public       	   koyeb-adm    false                       1255    24603    check_role_by_title(text)    FUNCTION       CREATE FUNCTION public.check_role_by_title(in_role_title text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM roles WHERE role_title = in_role_title;
	RETURN query_result;
END;
$$;
 >   DROP FUNCTION public.check_role_by_title(in_role_title text);
       public       	   koyeb-adm    false                       1255    24604    check_user(text, text, text)    FUNCTION     w  CREATE FUNCTION public.check_user(in_firstname text, in_middlename text, in_lastname text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT user_id INTO query_result FROM users WHERE (firstname = in_firstname AND middlename = in_middlename AND lastname = in_lastname);
	RETURN query_result;
END;
$$;
 Z   DROP FUNCTION public.check_user(in_firstname text, in_middlename text, in_lastname text);
       public       	   koyeb-adm    false                       1255    24605     check_user_details_by_id(bigint)    FUNCTION     )  CREATE FUNCTION public.check_user_details_by_id(in_details_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    query_result INT;  -- Variable to store the new ID
BEGIN
	SELECT 1 INTO query_result FROM user_details WHERE details_id = in_details_id;
	RETURN query_result;
END;
$$;
 E   DROP FUNCTION public.check_user_details_by_id(in_details_id bigint);
       public       	   koyeb-adm    false                       1255    24606 �   insert_address(bigint, character varying, character varying, character varying, character varying, character varying, character varying) 	   PROCEDURE     S  CREATE PROCEDURE public.insert_address(IN in_user_details_id bigint, IN in_house_no character varying, IN in_street character varying, IN in_subdivision character varying, IN in_brgy character varying, IN in_city character varying, IN in_province character varying, OUT id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		addrss_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
	    IF (SELECT public.check_user_details_by_id(in_user_details_id)) IS NOT NULL THEN
			INSERT INTO public.address(
				  user_details_id, house_no, street, subdivision, brgy, city, province
			)VALUES(
				in_user_details_id, in_house_no, in_street, in_subdivision, in_brgy, in_city, in_province
			) RETURNING address_id INTO addrss_id;
		ELSE
			addrss_id = NULL;
		END IF;
		
		IF addrss_id IS NOT NULL THEN
			status_code := '200';
			status_message := 'RECORD SUCCESSFULLY INSERTED';
			SELECT addrss_id, status_code, status_message INTO id, status, message;
		ELSE
			status_code := '400';
			status_message := 'RECORD CONFLICT USER DETAILS NOT EXISTS';
			SELECT addrss_id, status_code, status_message INTO id, status, message;
		END IF;
		
		EXCEPTION
			WHEN unique_violation THEN
				ROLLBACK;
				status_code := '409';
				status_message := 'RECORD CONFLICT WITH RELATIONSHIP VIOKATION';
				SELECT addrss_id, status_code, status_message INTO id, status, message;
			WHEN others THEN
				ROLLBACK;
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
				SELECT addrss_id, status_code, status_message INTO id, status, message;
	END;
$$;
 ?  DROP PROCEDURE public.insert_address(IN in_user_details_id bigint, IN in_house_no character varying, IN in_street character varying, IN in_subdivision character varying, IN in_brgy character varying, IN in_city character varying, IN in_province character varying, OUT id integer, OUT status integer, OUT message text);
       public       	   koyeb-adm    false                       1255    24607 O   insert_contact(bigint, character varying, character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_contact(IN in_user_details_id bigint, IN in_contact_type character varying, IN in_contact_details character varying, IN in_prioritization character varying, OUT id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		cntct_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
		IF (SELECT public.check_contact_by_details(in_contact_details)) IS NOT NULL THEN
			status_code := '400';
			status_message := 'RECORD CONFLICT CONTACT EXISTS';
			SELECT cntct_id, status_code, status_message INTO id, status, message;
		ELSE
			IF (SELECT public.check_user_details_by_id(in_user_details_id)) IS NOT NULL THEN
				INSERT INTO public.contacts(
					  user_details_id, contact_type, contact_details, prioritization
				)VALUES(
					in_user_details_id, in_contact_type, in_contact_details, in_prioritization
				) RETURNING contact_id INTO cntct_id;
			ELSE
				cntct_id = NULL;
			END IF;

			IF cntct_id IS NOT NULL THEN
				status_code := '200';
				status_message := 'RECORD SUCCESSFULLY INSERTED';
				SELECT cntct_id, status_code, status_message INTO id, status, message;
			ELSE
				status_code := '400';
				status_message := 'RECORD CONFLICT USER DETAILS NOT EXISTS';
				SELECT cntct_id, status_code, status_message INTO id, status, message;
			END IF;
		END IF;
		
		EXCEPTION
			WHEN unique_violation THEN
				ROLLBACK;
				status_code := '409';
				status_message := 'RECORD CONFLICT WITH RELATIONSHIP VIOKATION';
				SELECT cntct_id, status_code, status_message INTO id, status, message;
			WHEN others THEN
				ROLLBACK;
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
				SELECT cntct_id, status_code, status_message INTO id, status, message;
	END;
$$;
 �   DROP PROCEDURE public.insert_contact(IN in_user_details_id bigint, IN in_contact_type character varying, IN in_contact_details character varying, IN in_prioritization character varying, OUT id integer, OUT status integer, OUT message text);
       public       	   koyeb-adm    false                       1255    24608 4   insert_feature(character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_feature(IN title character varying, IN description character varying, OUT id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		ft_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
	    IF (SELECT public.check_feature_by_title(title)) IS NULL THEN
			INSERT INTO public.features(
				  feature_title, feature_description
			)VALUES(
				title, description
			) RETURNING feature_id INTO ft_id;
		ELSE
			ft_id = NULL;
		END IF;

		IF ft_id IS NOT NULL THEN
			status_code := '200';
			status_message := 'RECORD SUCCESSFULLY INSERTED';
			SELECT ft_id, status_code, status_message INTO id, status, message;
		ELSE
			status_code := '400';
			status_message := 'RECORD CONFLICT FEATURE EXISTS';
			SELECT ft_id, status_code, status_message INTO id, status, message;
		END IF;
		
		EXCEPTION
			WHEN unique_violation THEN
				status_code := '409';
				status_message := 'RECORD CONFLICT';
			SELECT ft_id, status_code, status_message INTO id, status, message;
			WHEN others THEN
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
			SELECT ft_id, status_code, status_message INTO id, status, message;
	END;
$$;
 �   DROP PROCEDURE public.insert_feature(IN title character varying, IN description character varying, OUT id integer, OUT status integer, OUT message text);
       public       	   koyeb-adm    false                       1255    24609 X   insert_matrix(bigint, bigint, character varying, character varying, character varying[]) 	   PROCEDURE     r  CREATE PROCEDURE public.insert_matrix(IN in_role_id bigint, IN in_feature_id bigint, IN in_title character varying, IN in_description character varying, IN in_access_type character varying[], OUT id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		mtrx_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
	    IF (SELECT public.check_feature_by_id(in_feature_id)) IS NULL THEN
			status_code := '400';
			status_message := 'RECORD CONFLICT FEATURE NOT EXISTS';
			SELECT mtrx_id, status_code, status_message INTO id, status, message;
		ELSIF (SELECT public.check_role_by_id(in_role_id)) IS NULL THEN
			status_code := '400';
			status_message := 'RECORD CONFLICT ROLE NOT EXISTS';
			SELECT mtrx_id, status_code, status_message INTO id, status, message;
		ELSE
			IF (SELECT public.check_matrix_by_title(in_title)) IS NULL THEN
				INSERT INTO public.access_matrix(
					role_id, feature_id, matrix_title, matrix_description, access_type
				)VALUES(
					in_role_id, in_feature_id, in_title, in_description, in_access_type
				) RETURNING matrix_id INTO mtrx_id;
			ELSE
				mtrx_id = NULL;
			END IF;
			
			IF mtrx_id IS NOT NULL THEN
				status_code := '200';
				status_message := 'RECORD SUCCESSFULLY INSERTED';
				SELECT mtrx_id, status_code, status_message INTO id, status, message;
			ELSE
				status_code := '400';
				status_message := 'RECORD CONFLICT MATRIX EXISTS';
				SELECT mtrx_id, status_code, status_message INTO id, status, message;
			END IF;
		END IF;

		
		EXCEPTION
			WHEN unique_violation THEN
				status_code := '409';
				status_message := 'RECORD CONFLICT';
			SELECT mtrx_id, status_code, status_message INTO id, status, message;
			WHEN others THEN
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
			SELECT mtrx_id, status_code, status_message INTO id, status, message;
	END;
$$;
 �   DROP PROCEDURE public.insert_matrix(IN in_role_id bigint, IN in_feature_id bigint, IN in_title character varying, IN in_description character varying, IN in_access_type character varying[], OUT id integer, OUT status integer, OUT message text);
       public       	   koyeb-adm    false                        1255    24610 �   insert_pending_user(integer, integer, character varying, character varying, character varying, date, character varying, character varying, character varying, character varying, character varying, character varying, timestamp with time zone) 	   PROCEDURE     �	  CREATE PROCEDURE public.insert_pending_user(IN in_role_id integer, IN in_company_id integer, IN in_firstname character varying, IN in_middlename character varying, IN in_lastname character varying, IN in_birthdate date, IN in_sex character varying, IN in_username character varying, IN in_password character varying, IN in_pin character varying, IN in_email character varying, IN in_status character varying, IN in_date_encoded timestamp with time zone, OUT id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		pndng_usr_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
		IF (SELECT public.check_role_by_id(in_role_id)) IS NULL THEN
			status_code := '400';
			status_message := 'INVALID ROLE';
			SELECT pndng_usr_id, status_code, status_message INTO id, status, message;
		ELSIF (SELECT company_record.check_company_by_id(in_company_id)) IS NULL THEN
			status_code := '400';
			status_message := 'INVALID COMPANY';
			SELECT pndng_usr_id, status_code, status_message INTO id, status, message;
		ELSE
			IF (SELECT * FROM check_pending_user(in_firstname, in_middlename, in_lastname, in_email)) IS NULL THEN
				INSERT INTO public.pending_users(
					role_id, company_id, firstname, middlename, lastname, birthdate,
					sex, username, password, pin, email, status, date_encoded
				)VALUES(
					in_role_id, in_company_id, in_firstname, in_middlename, in_lastname, in_birthdate,
					in_sex, in_username, in_password, in_pin, in_email, in_status, in_date_encoded
				) RETURNING pending_id INTO pndng_usr_id;
			ELSE
				pndng_usr_id = NULL;
			END IF;
			
			IF pndng_usr_id IS NOT NULL THEN
				status_code := '200';
				status_message := 'RECORD SUCCESSFULLY INSERTED';
				SELECT pndng_usr_id, status_code, status_message INTO id, status, message;
			ELSE
				status_code := '400';
				status_message := 'RECORD CONFLICT USER EXISTS';
				SELECT pndng_usr_id, status_code, status_message INTO id, status, message;
			END IF;
		END IF;
		
		EXCEPTION
			WHEN unique_violation THEN
				ROLLBACK;
				status_code := '409';
				status_message := 'RECORD CONFLICT WITH RELATIONSHIP VIOKATION';
				SELECT pndng_usr_id, status_code, status_message INTO id, status, message;
			WHEN others THEN
				ROLLBACK;
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
				SELECT pndng_usr_id, status_code, status_message INTO id, status, message;
		
	END;
$$;
 �  DROP PROCEDURE public.insert_pending_user(IN in_role_id integer, IN in_company_id integer, IN in_firstname character varying, IN in_middlename character varying, IN in_lastname character varying, IN in_birthdate date, IN in_sex character varying, IN in_username character varying, IN in_password character varying, IN in_pin character varying, IN in_email character varying, IN in_status character varying, IN in_date_encoded timestamp with time zone, OUT id integer, OUT status integer, OUT message text);
       public       	   koyeb-adm    false            !           1255    24611 1   insert_role(character varying, character varying) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_role(IN title character varying, IN description character varying, OUT id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		rl_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
	    IF (SELECT public.check_role_by_title(title)) IS NULL THEN
			INSERT INTO public.roles(
				  role_title, role_description
			)VALUES(
				title, description
			) RETURNING role_id INTO rl_id;
		ELSE
			rl_id = NULL;
		END IF;
		
		IF rl_id IS NOT NULL THEN
			status_code := '200';
			status_message := 'RECORD SUCCESSFULLY INSERTED';
			SELECT rl_id, status_code, status_message INTO id, status, message;
		ELSE
			status_code := '400';
			status_message := 'RECORD CONFLICT ROLE EXISTS';
			SELECT rl_id, status_code, status_message INTO id, status, message;
		END IF;
		
		EXCEPTION
			WHEN unique_violation THEN
				ROLLBACK;
				status_code := '409';
				status_message := 'RECORD CONFLICT WITH RELATIONSHIP VIOKATION';
				SELECT rl_id, status_code, status_message INTO id, status, message;
			WHEN others THEN
				ROLLBACK;
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
				SELECT rl_id, status_code, status_message INTO id, status, message;
	END;
$$;
 �   DROP PROCEDURE public.insert_role(IN title character varying, IN description character varying, OUT id integer, OUT status integer, OUT message text);
       public       	   koyeb-adm    false            "           1255    24612 �   insert_user(bigint, bigint, character varying, character varying, character varying, date, character varying, character varying, character varying, character varying, timestamp with time zone) 	   PROCEDURE     �	  CREATE PROCEDURE public.insert_user(IN in_role_id bigint, IN in_company_id bigint, IN in_firstname character varying, IN in_middlename character varying, IN in_lastname character varying, IN in_birthdate date, IN in_sex character varying, IN in_username character varying, IN in_password character varying, IN in_pin character varying, IN in_registered_date timestamp with time zone, OUT id integer, OUT detials_id integer, OUT status integer, OUT message text)
    LANGUAGE plpgsql
    AS $$
	DECLARE
		usr_id INT;
		dtls_id INT;
		current_id INT;
		status_code INT;
		status_message TEXT;
	BEGIN
		IF (SELECT public.check_role_by_id(in_role_id)) IS NULL THEN
			status_code := '400';
			status_message := 'INVALID ROLE';
			SELECT usr_id, status_code, status_message INTO id, status, message;
		ELSIF (SELECT company_record.check_company_by_id(in_company_id)) IS NULL THEN
			status_code := '400';
			status_message := 'INVALID COMPANY';
			SELECT usr_id, status_code, status_message INTO id, status, message;
		ELSE
			IF (SELECT * FROM check_user(in_firstname, in_middlename, in_lastname)) IS NULL THEN
				INSERT INTO public.users(
					role_id, company_id, firstname, middlename, lastname, birthdate, sex, username, password, pin, registered_date
				)VALUES(
					in_role_id, in_company_id, in_firstname, in_middlename, in_lastname,
					in_birthdate, in_sex, in_username, in_password, in_pin, in_registered_date
				) RETURNING user_id INTO usr_id;
			ELSE
				usr_id = NULL;
			END IF;
			
			IF usr_id IS NOT NULL THEN
				INSERT INTO public.user_details(user_id)VALUES(usr_id)RETURNING details_id INTO dtls_id;
				status_code := '200';
				status_message := 'RECORD SUCCESSFULLY INSERTED';
				SELECT usr_id, dtls_id, status_code, status_message INTO id, detials_id, status, message;
			ELSE
				status_code := '400';
				status_message := 'RECORD CONFLICT USER EXISTS';
				SELECT usr_id, dtls_id, status_code, status_message INTO id, detials_id, status, message;
			END IF;
		END IF;
		
		EXCEPTION
			WHEN unique_violation THEN
				ROLLBACK;
				status_code := '409';
				status_message := 'RECORD CONFLICT WITH RELATIONSHIP VIOLATION';
				SELECT usr_id, dtls_id, status_code, status_message INTO id, detials_id, status, message;
			WHEN others THEN
				ROLLBACK;
				status_code := '500';
				status_message := 'SCRIPT ERROR - ' || SQLERRM;
				SELECT usr_id, dtls_id, status_code, status_message INTO id, detials_id, status, message;
		
	END;
$$;
 �  DROP PROCEDURE public.insert_user(IN in_role_id bigint, IN in_company_id bigint, IN in_firstname character varying, IN in_middlename character varying, IN in_lastname character varying, IN in_birthdate date, IN in_sex character varying, IN in_username character varying, IN in_password character varying, IN in_pin character varying, IN in_registered_date timestamp with time zone, OUT id integer, OUT detials_id integer, OUT status integer, OUT message text);
       public       	   koyeb-adm    false            �            1259    24613    actions    TABLE     �   CREATE TABLE audit_trail.actions (
    action_id bigint NOT NULL,
    title character varying(10),
    description character varying(50)
);
     DROP TABLE audit_trail.actions;
       audit_trail         heap 	   koyeb-adm    false    5            �            1259    24616    user_actions    TABLE     �   CREATE TABLE audit_trail.user_actions (
    user_action_id bigint NOT NULL,
    action_id bigint,
    user_id bigint,
    affected_table character varying(20),
    data_id bigint
);
 %   DROP TABLE audit_trail.user_actions;
       audit_trail         heap 	   koyeb-adm    false    5            �            1259    24619    user_in_out    TABLE     o   CREATE TABLE audit_trail.user_in_out (
    in_out_id bigint NOT NULL,
    user_id bigint,
    is_in boolean
);
 $   DROP TABLE audit_trail.user_in_out;
       audit_trail         heap 	   koyeb-adm    false    5            �            1259    24622    checkins    TABLE     #  CREATE TABLE company_record.checkins (
    checkin_id bigint NOT NULL,
    company_id bigint,
    visitors_firstname character varying(50),
    visitors_middlename character varying(50),
    visitors_lastname character varying(50),
    visitors_city character varying(50),
    visitors_province character varying(50),
    adults_female_cnt bigint,
    adults_male_cnt bigint,
    kids_male_cnt bigint,
    kids_female_cnt bigint,
    visit_type character varying(10),
    time_in timestamp with time zone,
    time_out timestamp with time zone
);
 $   DROP TABLE company_record.checkins;
       company_record         heap 	   koyeb-adm    false    7            �            1259    24625    checkins_checkin_id_seq    SEQUENCE     �   ALTER TABLE company_record.checkins ALTER COLUMN checkin_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME company_record.checkins_checkin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1
);
            company_record       	   koyeb-adm    false    222    7            �            1259    24626 	   companies    TABLE     �  CREATE TABLE company_record.companies (
    company_id bigint NOT NULL,
    title character varying(100),
    description character varying(200),
    business character varying(50),
    street character varying(50),
    brgy character varying(50),
    city character varying(50),
    province character varying(50),
    longitude character varying(50),
    latitude character varying(50)
);
 %   DROP TABLE company_record.companies;
       company_record         heap 	   koyeb-adm    false    7            �            1259    24631    company_company_id_seq    SEQUENCE     �   ALTER TABLE company_record.companies ALTER COLUMN company_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME company_record.company_company_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1
);
            company_record       	   koyeb-adm    false    224    7            �            1259    24632    feedback_questions    TABLE     �   CREATE TABLE company_record.feedback_questions (
    question_id bigint NOT NULL,
    company_id bigint,
    question character varying(100)
);
 .   DROP TABLE company_record.feedback_questions;
       company_record         heap 	   koyeb-adm    false    7            �            1259    24635 "   feedback_questions_question_id_seq    SEQUENCE     	  ALTER TABLE company_record.feedback_questions ALTER COLUMN question_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME company_record.feedback_questions_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1
);
            company_record       	   koyeb-adm    false    226    7            �            1259    24636 	   feedbacks    TABLE     �   CREATE TABLE company_record.feedbacks (
    feedback_id bigint NOT NULL,
    visitors_name character varying(50),
    comments character varying(300),
    rating character varying(3),
    company_id bigint,
    answers jsonb
);
 %   DROP TABLE company_record.feedbacks;
       company_record         heap 	   koyeb-adm    false    7            �            1259    24641    feedbacks_feedback_id_seq    SEQUENCE     �   ALTER TABLE company_record.feedbacks ALTER COLUMN feedback_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME company_record.feedbacks_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1
);
            company_record       	   koyeb-adm    false    228    7            �            1259    24642    access_matrix    TABLE     �   CREATE TABLE public.access_matrix (
    matrix_id bigint NOT NULL,
    role_id bigint,
    feature_id bigint,
    matrix_title character varying(50),
    matrix_description character varying(150),
    access_type character varying(150)[]
);
 !   DROP TABLE public.access_matrix;
       public         heap 	   koyeb-adm    false            �            1259    24647    access_matrix_matrix_id_seq    SEQUENCE     �   ALTER TABLE public.access_matrix ALTER COLUMN matrix_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.access_matrix_matrix_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1
);
            public       	   koyeb-adm    false    230            �            1259    24648    address    TABLE     N  CREATE TABLE public.address (
    address_id bigint NOT NULL,
    user_details_id bigint,
    house_no character varying(50),
    purok character varying(50),
    street character varying(50),
    subdivision character varying(50),
    brgy character varying(50),
    city character varying(50),
    province character varying(50)
);
    DROP TABLE public.address;
       public         heap 	   koyeb-adm    false            �            1259    24651    address_address_id_seq    SEQUENCE     �   ALTER TABLE public.address ALTER COLUMN address_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.address_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1
);
            public       	   koyeb-adm    false    232            �            1259    24652    contacts    TABLE     �   CREATE TABLE public.contacts (
    contact_id bigint NOT NULL,
    user_details_id bigint,
    contact_type character varying(50),
    contact_details character varying(50),
    prioritization character varying(50)
);
    DROP TABLE public.contacts;
       public         heap 	   koyeb-adm    false            �            1259    24655    contacts_contact_id_seq    SEQUENCE     �   ALTER TABLE public.contacts ALTER COLUMN contact_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.contacts_contact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1
);
            public       	   koyeb-adm    false    234            �            1259    24656    features    TABLE     �   CREATE TABLE public.features (
    feature_id bigint NOT NULL,
    feature_title character varying(50),
    feature_description character varying(150)
);
    DROP TABLE public.features;
       public         heap 	   koyeb-adm    false            �            1259    24659    features_feature_id_seq    SEQUENCE     �   ALTER TABLE public.features ALTER COLUMN feature_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.features_feature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999
    CACHE 1
);
            public       	   koyeb-adm    false    236            �            1259    24660    pending_users    TABLE     �  CREATE TABLE public.pending_users (
    pending_id bigint NOT NULL,
    role_id bigint NOT NULL,
    firstname character varying(30),
    middlename character varying(30),
    lastname character varying(30),
    sex character varying(30),
    username character varying(200),
    password character varying(200),
    pin character varying(100),
    company_id bigint,
    email character varying(50),
    birthdate date,
    status character varying(20),
    date_encoded timestamp with time zone
);
 !   DROP TABLE public.pending_users;
       public         heap 	   koyeb-adm    false            �            1259    24665    pending_users_pending_id_seq    SEQUENCE     �   ALTER TABLE public.pending_users ALTER COLUMN pending_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.pending_users_pending_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1
);
            public       	   koyeb-adm    false    238            �            1259    24669    roles    TABLE     �   CREATE TABLE public.roles (
    role_id bigint NOT NULL,
    role_title character varying(50),
    role_description character varying(100)
);
    DROP TABLE public.roles;
       public         heap 	   koyeb-adm    false            �            1259    24672    roles_role_id_seq    SEQUENCE     �   ALTER TABLE public.roles ALTER COLUMN role_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.roles_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1
);
            public       	   koyeb-adm    false    240            �            1259    24673    user_details    TABLE     Y   CREATE TABLE public.user_details (
    details_id bigint NOT NULL,
    user_id bigint
);
     DROP TABLE public.user_details;
       public         heap 	   koyeb-adm    false            �            1259    24676    user_details_details_id_seq    SEQUENCE     �   ALTER TABLE public.user_details ALTER COLUMN details_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.user_details_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1
);
            public       	   koyeb-adm    false    242            �            1259    24677    users    TABLE     �  CREATE TABLE public.users (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    firstname character varying(30),
    middlename character varying(30),
    lastname character varying(30),
    sex character varying(30),
    username character varying(200),
    password character varying(200),
    pin character varying(100),
    company_id bigint,
    birthdate date,
    registered_date timestamp with time zone
);
    DROP TABLE public.users;
       public         heap 	   koyeb-adm    false            �            1259    24682    users_user_id_seq    SEQUENCE     �   ALTER TABLE public.users ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1
);
            public       	   koyeb-adm    false    244            �            1259    24683    system_parameters    TABLE     �   CREATE TABLE system.system_parameters (
    parameter_id bigint NOT NULL,
    parameter_name character varying(50),
    parameter_value character varying(150)
);
 %   DROP TABLE system.system_parameters;
       system         heap 	   koyeb-adm    false    8            �            1259    24686 "   system_parameters_parameter_id_seq    SEQUENCE     �   ALTER TABLE system.system_parameters ALTER COLUMN parameter_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME system.system_parameters_parameter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 9999999999
    CACHE 1
);
            system       	   koyeb-adm    false    8    246            �          0    24613    actions 
   TABLE DATA           E   COPY audit_trail.actions (action_id, title, description) FROM stdin;
    audit_trail       	   koyeb-adm    false    219   �B      �          0    24616    user_actions 
   TABLE DATA           h   COPY audit_trail.user_actions (user_action_id, action_id, user_id, affected_table, data_id) FROM stdin;
    audit_trail       	   koyeb-adm    false    220   �B      �          0    24619    user_in_out 
   TABLE DATA           E   COPY audit_trail.user_in_out (in_out_id, user_id, is_in) FROM stdin;
    audit_trail       	   koyeb-adm    false    221   �B      �          0    24622    checkins 
   TABLE DATA             COPY company_record.checkins (checkin_id, company_id, visitors_firstname, visitors_middlename, visitors_lastname, visitors_city, visitors_province, adults_female_cnt, adults_male_cnt, kids_male_cnt, kids_female_cnt, visit_type, time_in, time_out) FROM stdin;
    company_record       	   koyeb-adm    false    222   �B      �          0    24626 	   companies 
   TABLE DATA           �   COPY company_record.companies (company_id, title, description, business, street, brgy, city, province, longitude, latitude) FROM stdin;
    company_record       	   koyeb-adm    false    224   PC      �          0    24632    feedback_questions 
   TABLE DATA           W   COPY company_record.feedback_questions (question_id, company_id, question) FROM stdin;
    company_record       	   koyeb-adm    false    226   D      �          0    24636 	   feedbacks 
   TABLE DATA           n   COPY company_record.feedbacks (feedback_id, visitors_name, comments, rating, company_id, answers) FROM stdin;
    company_record       	   koyeb-adm    false    228   .D      �          0    24642    access_matrix 
   TABLE DATA           v   COPY public.access_matrix (matrix_id, role_id, feature_id, matrix_title, matrix_description, access_type) FROM stdin;
    public       	   koyeb-adm    false    230   KD      �          0    24648    address 
   TABLE DATA           z   COPY public.address (address_id, user_details_id, house_no, purok, street, subdivision, brgy, city, province) FROM stdin;
    public       	   koyeb-adm    false    232   �D      �          0    24652    contacts 
   TABLE DATA           n   COPY public.contacts (contact_id, user_details_id, contact_type, contact_details, prioritization) FROM stdin;
    public       	   koyeb-adm    false    234   E      �          0    24656    features 
   TABLE DATA           R   COPY public.features (feature_id, feature_title, feature_description) FROM stdin;
    public       	   koyeb-adm    false    236   !E      �          0    24660    pending_users 
   TABLE DATA           �   COPY public.pending_users (pending_id, role_id, firstname, middlename, lastname, sex, username, password, pin, company_id, email, birthdate, status, date_encoded) FROM stdin;
    public       	   koyeb-adm    false    238   8F      �          0    24669    roles 
   TABLE DATA           F   COPY public.roles (role_id, role_title, role_description) FROM stdin;
    public       	   koyeb-adm    false    240   �G      �          0    24673    user_details 
   TABLE DATA           ;   COPY public.user_details (details_id, user_id) FROM stdin;
    public       	   koyeb-adm    false    242   �H      �          0    24677    users 
   TABLE DATA           �   COPY public.users (user_id, role_id, firstname, middlename, lastname, sex, username, password, pin, company_id, birthdate, registered_date) FROM stdin;
    public       	   koyeb-adm    false    244   �H      �          0    24683    system_parameters 
   TABLE DATA           Z   COPY system.system_parameters (parameter_id, parameter_name, parameter_value) FROM stdin;
    system       	   koyeb-adm    false    246    I      �           0    0    checkins_checkin_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('company_record.checkins_checkin_id_seq', 2, true);
          company_record       	   koyeb-adm    false    223            �           0    0    company_company_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('company_record.company_company_id_seq', 3, true);
          company_record       	   koyeb-adm    false    225            �           0    0 "   feedback_questions_question_id_seq    SEQUENCE SET     Y   SELECT pg_catalog.setval('company_record.feedback_questions_question_id_seq', 1, false);
          company_record       	   koyeb-adm    false    227            �           0    0    feedbacks_feedback_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('company_record.feedbacks_feedback_id_seq', 1, false);
          company_record       	   koyeb-adm    false    229            �           0    0    access_matrix_matrix_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.access_matrix_matrix_id_seq', 3, true);
          public       	   koyeb-adm    false    231            �           0    0    address_address_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.address_address_id_seq', 1, true);
          public       	   koyeb-adm    false    233            �           0    0    contacts_contact_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.contacts_contact_id_seq', 1, true);
          public       	   koyeb-adm    false    235            �           0    0    features_feature_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.features_feature_id_seq', 6, true);
          public       	   koyeb-adm    false    237            �           0    0    pending_users_pending_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.pending_users_pending_id_seq', 1, true);
          public       	   koyeb-adm    false    239            �           0    0    roles_role_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.roles_role_id_seq', 7, true);
          public       	   koyeb-adm    false    241            �           0    0    user_details_details_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.user_details_details_id_seq', 1, true);
          public       	   koyeb-adm    false    243            �           0    0    users_user_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.users_user_id_seq', 1, true);
          public       	   koyeb-adm    false    245            �           0    0 "   system_parameters_parameter_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('system.system_parameters_parameter_id_seq', 4, true);
          system       	   koyeb-adm    false    247            �           2606    24689    actions actions_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY audit_trail.actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (action_id);
 C   ALTER TABLE ONLY audit_trail.actions DROP CONSTRAINT actions_pkey;
       audit_trail         	   koyeb-adm    false    219            �           2606    24691    user_actions user_actions_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY audit_trail.user_actions
    ADD CONSTRAINT user_actions_pkey PRIMARY KEY (user_action_id);
 M   ALTER TABLE ONLY audit_trail.user_actions DROP CONSTRAINT user_actions_pkey;
       audit_trail         	   koyeb-adm    false    220            �           2606    24693    user_in_out user_in_out_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY audit_trail.user_in_out
    ADD CONSTRAINT user_in_out_pkey PRIMARY KEY (in_out_id);
 K   ALTER TABLE ONLY audit_trail.user_in_out DROP CONSTRAINT user_in_out_pkey;
       audit_trail         	   koyeb-adm    false    221            �           2606    24695    checkins checkins_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY company_record.checkins
    ADD CONSTRAINT checkins_pkey PRIMARY KEY (checkin_id);
 H   ALTER TABLE ONLY company_record.checkins DROP CONSTRAINT checkins_pkey;
       company_record         	   koyeb-adm    false    222            �           2606    24697    companies company_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY company_record.companies
    ADD CONSTRAINT company_pkey PRIMARY KEY (company_id);
 H   ALTER TABLE ONLY company_record.companies DROP CONSTRAINT company_pkey;
       company_record         	   koyeb-adm    false    224            �           2606    24699 *   feedback_questions feedback_questions_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY company_record.feedback_questions
    ADD CONSTRAINT feedback_questions_pkey PRIMARY KEY (question_id);
 \   ALTER TABLE ONLY company_record.feedback_questions DROP CONSTRAINT feedback_questions_pkey;
       company_record         	   koyeb-adm    false    226            �           2606    24701    feedbacks feedbacks_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY company_record.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (feedback_id);
 J   ALTER TABLE ONLY company_record.feedbacks DROP CONSTRAINT feedbacks_pkey;
       company_record         	   koyeb-adm    false    228            �           2606    24703     access_matrix access_matrix_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.access_matrix
    ADD CONSTRAINT access_matrix_pkey PRIMARY KEY (matrix_id);
 J   ALTER TABLE ONLY public.access_matrix DROP CONSTRAINT access_matrix_pkey;
       public         	   koyeb-adm    false    230            �           2606    24705    address address_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);
 >   ALTER TABLE ONLY public.address DROP CONSTRAINT address_pkey;
       public         	   koyeb-adm    false    232            �           2606    24707    contacts contacts_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (contact_id);
 @   ALTER TABLE ONLY public.contacts DROP CONSTRAINT contacts_pkey;
       public         	   koyeb-adm    false    234            �           2606    24709    features features_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.features
    ADD CONSTRAINT features_pkey PRIMARY KEY (feature_id);
 @   ALTER TABLE ONLY public.features DROP CONSTRAINT features_pkey;
       public         	   koyeb-adm    false    236            �           2606    24711     pending_users pending_users_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.pending_users
    ADD CONSTRAINT pending_users_pkey PRIMARY KEY (pending_id);
 J   ALTER TABLE ONLY public.pending_users DROP CONSTRAINT pending_users_pkey;
       public         	   koyeb-adm    false    238            �           2606    24713    roles roles_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);
 :   ALTER TABLE ONLY public.roles DROP CONSTRAINT roles_pkey;
       public         	   koyeb-adm    false    240            �           2606    24715    users unique_usernames 
   CONSTRAINT     U   ALTER TABLE ONLY public.users
    ADD CONSTRAINT unique_usernames UNIQUE (username);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT unique_usernames;
       public         	   koyeb-adm    false    244            �           2606    24717    user_details user_details_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.user_details
    ADD CONSTRAINT user_details_pkey PRIMARY KEY (details_id);
 H   ALTER TABLE ONLY public.user_details DROP CONSTRAINT user_details_pkey;
       public         	   koyeb-adm    false    242            �           2606    24719    users users_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public         	   koyeb-adm    false    244            �           2606    24721 (   system_parameters system_parameters_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY system.system_parameters
    ADD CONSTRAINT system_parameters_pkey PRIMARY KEY (parameter_id);
 R   ALTER TABLE ONLY system.system_parameters DROP CONSTRAINT system_parameters_pkey;
       system         	   koyeb-adm    false    246            �           1259    24722    fki_access_feature_fkey    INDEX     W   CREATE INDEX fki_access_feature_fkey ON public.access_matrix USING btree (feature_id);
 +   DROP INDEX public.fki_access_feature_fkey;
       public         	   koyeb-adm    false    230            �           1259    24723    fki_c    INDEX     A   CREATE INDEX fki_c ON public.user_details USING btree (user_id);
    DROP INDEX public.fki_c;
       public         	   koyeb-adm    false    242            �           1259    24724    fki_pending_user_company_fkey    INDEX     ]   CREATE INDEX fki_pending_user_company_fkey ON public.pending_users USING btree (company_id);
 1   DROP INDEX public.fki_pending_user_company_fkey;
       public         	   koyeb-adm    false    238            �           1259    24725    fki_role_access_fkey    INDEX     Q   CREATE INDEX fki_role_access_fkey ON public.access_matrix USING btree (role_id);
 (   DROP INDEX public.fki_role_access_fkey;
       public         	   koyeb-adm    false    230            �           1259    24726    fki_user_company_fkey    INDEX     M   CREATE INDEX fki_user_company_fkey ON public.users USING btree (company_id);
 )   DROP INDEX public.fki_user_company_fkey;
       public         	   koyeb-adm    false    244            �           1259    24727    fki_user_roles_fkey    INDEX     H   CREATE INDEX fki_user_roles_fkey ON public.users USING btree (role_id);
 '   DROP INDEX public.fki_user_roles_fkey;
       public         	   koyeb-adm    false    244            �           2606    24728    user_actions made_action_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY audit_trail.user_actions
    ADD CONSTRAINT made_action_fkey FOREIGN KEY (action_id) REFERENCES audit_trail.actions(action_id) NOT VALID;
 L   ALTER TABLE ONLY audit_trail.user_actions DROP CONSTRAINT made_action_fkey;
       audit_trail       	   koyeb-adm    false    3287    220    219            �           2606    24733    user_actions user_actions_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY audit_trail.user_actions
    ADD CONSTRAINT user_actions_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);
 M   ALTER TABLE ONLY audit_trail.user_actions DROP CONSTRAINT user_actions_fkey;
       audit_trail       	   koyeb-adm    false    3323    220    244                        2606    24738    user_in_out user_in_out_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY audit_trail.user_in_out
    ADD CONSTRAINT user_in_out_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);
 K   ALTER TABLE ONLY audit_trail.user_in_out DROP CONSTRAINT user_in_out_fkey;
       audit_trail       	   koyeb-adm    false    244    3323    221                       2606    24743    checkins comapny_visitors_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY company_record.checkins
    ADD CONSTRAINT comapny_visitors_fkey FOREIGN KEY (company_id) REFERENCES company_record.companies(company_id);
 P   ALTER TABLE ONLY company_record.checkins DROP CONSTRAINT comapny_visitors_fkey;
       company_record       	   koyeb-adm    false    224    222    3295                       2606    24748     feedbacks company_feedbacks_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY company_record.feedbacks
    ADD CONSTRAINT company_feedbacks_fkey FOREIGN KEY (company_id) REFERENCES company_record.companies(company_id) NOT VALID;
 R   ALTER TABLE ONLY company_record.feedbacks DROP CONSTRAINT company_feedbacks_fkey;
       company_record       	   koyeb-adm    false    3295    228    224                       2606    24753 5   feedback_questions feedback_questions_company_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY company_record.feedback_questions
    ADD CONSTRAINT feedback_questions_company_id_fkey FOREIGN KEY (company_id) REFERENCES company_record.companies(company_id);
 g   ALTER TABLE ONLY company_record.feedback_questions DROP CONSTRAINT feedback_questions_company_id_fkey;
       company_record       	   koyeb-adm    false    226    3295    224                       2606    24758 !   access_matrix access_feature_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.access_matrix
    ADD CONSTRAINT access_feature_fkey FOREIGN KEY (feature_id) REFERENCES public.features(feature_id) NOT VALID;
 K   ALTER TABLE ONLY public.access_matrix DROP CONSTRAINT access_feature_fkey;
       public       	   koyeb-adm    false    3309    230    236                       2606    24763 '   pending_users pending_user_company_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pending_users
    ADD CONSTRAINT pending_user_company_fkey FOREIGN KEY (company_id) REFERENCES company_record.companies(company_id) NOT VALID;
 Q   ALTER TABLE ONLY public.pending_users DROP CONSTRAINT pending_user_company_fkey;
       public       	   koyeb-adm    false    224    238    3295            	           2606    24768 $   pending_users pending_user_role_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pending_users
    ADD CONSTRAINT pending_user_role_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) NOT VALID;
 N   ALTER TABLE ONLY public.pending_users DROP CONSTRAINT pending_user_role_fkey;
       public       	   koyeb-adm    false    240    238    3314                       2606    24773    access_matrix role_access_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.access_matrix
    ADD CONSTRAINT role_access_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) NOT VALID;
 H   ALTER TABLE ONLY public.access_matrix DROP CONSTRAINT role_access_fkey;
       public       	   koyeb-adm    false    240    230    3314                       2606    24778    users user_company_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_company_fkey FOREIGN KEY (company_id) REFERENCES company_record.companies(company_id) NOT VALID;
 A   ALTER TABLE ONLY public.users DROP CONSTRAINT user_company_fkey;
       public       	   koyeb-adm    false    224    3295    244                       2606    24783 !   address user_details_address_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.address
    ADD CONSTRAINT user_details_address_fkey FOREIGN KEY (user_details_id) REFERENCES public.user_details(details_id) NOT VALID;
 K   ALTER TABLE ONLY public.address DROP CONSTRAINT user_details_address_fkey;
       public       	   koyeb-adm    false    3317    232    242                       2606    24788 #   contacts user_details_contacts_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT user_details_contacts_fkey FOREIGN KEY (user_details_id) REFERENCES public.user_details(details_id) NOT VALID;
 M   ALTER TABLE ONLY public.contacts DROP CONSTRAINT user_details_contacts_fkey;
       public       	   koyeb-adm    false    242    3317    234            
           2606    24793    user_details user_details_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_details
    ADD CONSTRAINT user_details_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) NOT VALID;
 H   ALTER TABLE ONLY public.user_details DROP CONSTRAINT user_details_fkey;
       public       	   koyeb-adm    false    3323    244    242                       2606    24798    users user_roles_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_roles_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) NOT VALID;
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT user_roles_fkey;
       public       	   koyeb-adm    false    244    240    3314            �      x������ � �      �      x������ � �      �      x������ � �      �   g   x��̱�@F���)�#"ۀn�Lp�%s�$1?(b����Z-�^à��Z4���:����u��!�[�V��w�(3?�P>In�B�D�,�-ϔ�	5�-�      �   �   x�m�M
� ൞b.P�Y��&�tj���M�)I	���d��
HVƐa��5���Hp�	��a�A��}��i��v�咼�t�4,��Hp"1�i��t'����"�F��+�ȵ��Þ�~�4d(v�#�*��9�8S9�(
�[��px]��˟���O4��d�^�s���UP      �      x������ � �      �      x������ � �      �   �   x���A
�@����)r���� ��1Az�һw�w�F���.t��.X��f��l�jq)���*W%_�����l�\��9D~,�-cO,� ٓ���}蛭{���=��f����iG����<�^�      �      x������ � �      �      x������ � �      �     x���Kn�0D��)x� @�{֢b�"��@��ʲ�:�EwS|3�'�P揌��Y�j-SN��t&�#�
-���3�L�*z/0a�O�k�s�~Hi�p����uq��oL�Д�h/EOVHYC�Wr��c�M*1�"%�?���Ǡ����Ӟ�v�=�d �pb_͈� ,G�(b��v~��'^0���Lɱ-w+�o7S������� ���5��7%Ǧ��%vk��W���9�c���ͧ�F�m���u��~y0��      �   o  x�����[1E��W̾$H�d�Y5��H2%C
�nd?k���@��nfY
Z�+��90\���λ��v����iw�]�����p=�D���^<��CCs�X��d��#�7m԰I��E��s+&�ul�VJ��d�-��� �EKUլp/�sf.s� ����F�(֑b�R�B�A�l6o����w{�������b/�M{]���k�� �:]���!Јp��y+�%���j����=@Yߞ�}��G1������tKcLI-���ۀ�1������gFkh���Ѷgʉ�K�=�$�lpjQ��G�ѕS
xNI�6gB>Dcw�Ikul��1��~�M��� �����[�?�~lV��o[p��      �   �   x���Kn� D��}�(R��h��phlk���i#M��&/lQ�^���Bc����$8�PH�\�N�*�� �id��s2σ\�R����v��t������}�Q���m�ДK���#������ك
�[;.�mظ�N[6'�5dXY�"r���-�i:+�p e"˞-�B���zb�;�(ͳ��
�^8�C�l��v��s&�&	�\�����Ǎ���l��#����Vs��|=c��d��      �      x������ � �      �      x������ � �      �   i   x�3��	Pv���+���M��IL/-��sH�M���K���2���v��LI-��KMK�K+�-L�J�2���Q�[R���h�ttq	r�4�0����� �$     