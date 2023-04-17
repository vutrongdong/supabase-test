--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1 (Debian 15.1-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";


--
-- Name: moddatetime; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "moddatetime" WITH SCHEMA "extensions";


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


--
-- Name: check_team_permissions("uuid", "text"[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."check_team_permissions"("check_project_id" "uuid", "perms" "text"[]) RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
    select exists (
      select users_projects.id
      from users_projects
      join projects ON projects.id = users_projects.project_id
      left join users_projects_permissions ON users_projects_permissions.user_project_id = users_projects.id
      where users_projects.user_id = auth.uid() and users_projects.project_id = check_project_id and (projects.user_id = auth.uid() or users_projects_permissions.permission = ANY(perms))
    )
$$;


ALTER FUNCTION "public"."check_team_permissions"("check_project_id" "uuid", "perms" "text"[]) OWNER TO "postgres";

--
-- Name: handle_new_project(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."handle_new_project"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public.users_projects (user_id, project_id)
  values (new.user_id, new.id);
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_project"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."projects" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "name" "text" NOT NULL,
    "website" character varying,
    "status" smallint,
    "user_id" "uuid" DEFAULT "auth"."uid"()
);


ALTER TABLE "public"."projects" OWNER TO "postgres";

--
-- Name: qr_code_statistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."qr_code_statistics" (
    "created_at" timestamp with time zone DEFAULT "now"(),
    "time_type" smallint,
    "ts" bigint,
    "scan" bigint,
    "qr_code_id" "uuid",
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "project_id" "uuid",
    "unique_scan" bigint
);


ALTER TABLE "public"."qr_code_statistics" OWNER TO "postgres";

--
-- Name: qr_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."qr_codes" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "project_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "name" "text" NOT NULL,
    "type" smallint,
    "meta" "jsonb" NOT NULL,
    "dynamic" boolean,
    "data" "text" NOT NULL,
    "user_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "active" boolean,
    "preview_url" "text"
);


ALTER TABLE "public"."qr_codes" OWNER TO "postgres";

--
-- Name: qr_landing_pages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."qr_landing_pages" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "project_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "name" "text" NOT NULL,
    "type" smallint,
    "meta" "jsonb" NOT NULL,
    "user_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "slug" "text" NOT NULL,
    "status" smallint
);


ALTER TABLE "public"."qr_landing_pages" OWNER TO "postgres";

--
-- Name: qr_order_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."qr_order_categories" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "name" "text",
    "slug" "text",
    "user_id" "uuid" DEFAULT "auth"."uid"(),
    "qr_order_id" "uuid",
    "project_id" "uuid"
);


ALTER TABLE "public"."qr_order_categories" OWNER TO "postgres";

--
-- Name: qr_order_product_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."qr_order_product_category" (
    "product_id" "uuid",
    "category_id" "uuid",
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL
);


ALTER TABLE "public"."qr_order_product_category" OWNER TO "postgres";

--
-- Name: qr_order_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."qr_order_products" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone,
    "name" "text",
    "slug" "text",
    "price" "text",
    "status" boolean,
    "description" "text",
    "image" "text",
    "user_id" "uuid" DEFAULT "auth"."uid"(),
    "qr_order_id" "uuid",
    "project_id" "uuid"
);


ALTER TABLE "public"."qr_order_products" OWNER TO "postgres";

--
-- Name: qr_order_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."qr_order_requests" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone,
    "customer_id" "text",
    "customer_name" "text",
    "type" smallint,
    "items" "json",
    "note" "text",
    "status" smallint,
    "project_id" "uuid",
    "table_id" "uuid",
    "qr_order_id" "uuid"
);


ALTER TABLE "public"."qr_order_requests" OWNER TO "postgres";

--
-- Name: qr_order_tables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."qr_order_tables" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone,
    "name" "text",
    "user_id" "uuid" DEFAULT "auth"."uid"(),
    "project_id" "uuid",
    "qr_order_id" "uuid",
    "preview_url" "text",
    "meta" "json",
    "data" "text"
);


ALTER TABLE "public"."qr_order_tables" OWNER TO "postgres";

--
-- Name: qr_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."qr_orders" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "introduce" "text",
    "currency_unit" "text",
    "theme_color" character varying,
    "logo" character varying,
    "user_id" "uuid" DEFAULT "auth"."uid"(),
    "status" boolean,
    "project_id" "uuid"
);


ALTER TABLE "public"."qr_orders" OWNER TO "postgres";

--
-- Name: qr_page_statistics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."qr_page_statistics" (
    "time_type" smallint,
    "ts" bigint,
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "project_id" "uuid",
    "view" bigint,
    "url" "text",
    "qr_code_id" "uuid"
);


ALTER TABLE "public"."qr_page_statistics" OWNER TO "postgres";

--
-- Name: short_links; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."short_links" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "short_id" character varying NOT NULL,
    "short_url" character varying NOT NULL,
    "target_url" character varying NOT NULL,
    "active" boolean,
    "user_id" "uuid" DEFAULT "auth"."uid"(),
    "project_id" "uuid",
    "qr_code_id" "uuid"
);


ALTER TABLE "public"."short_links" OWNER TO "postgres";

--
-- Name: users_projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."users_projects" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "user_id" "uuid",
    "project_id" "uuid" NOT NULL,
    "user_email" "text",
    "status" smallint,
    "updated_at" timestamp with time zone
);


ALTER TABLE "public"."users_projects" OWNER TO "postgres";

--
-- Name: users_projects_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."users_projects_permissions" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "user_project_id" "uuid" NOT NULL,
    "permission" "text" NOT NULL
);


ALTER TABLE "public"."users_projects_permissions" OWNER TO "postgres";

--
-- Name: qr_order_categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");


--
-- Name: qr_order_products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."projects"
    ADD CONSTRAINT "projects_pkey" PRIMARY KEY ("id");


--
-- Name: qr_orders qr-orders_name_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_orders"
    ADD CONSTRAINT "qr-orders_name_key1" UNIQUE ("name");


--
-- Name: qr_orders qr-orders_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_orders"
    ADD CONSTRAINT "qr-orders_pkey1" PRIMARY KEY ("id");


--
-- Name: qr_orders qr-orders_slug_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_orders"
    ADD CONSTRAINT "qr-orders_slug_key1" UNIQUE ("slug");


--
-- Name: qr_code_statistics qr_code_statistic_uniq_idx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_code_statistics"
    ADD CONSTRAINT "qr_code_statistic_uniq_idx" UNIQUE NULLS NOT DISTINCT ("project_id", "qr_code_id", "time_type", "ts");


--
-- Name: qr_code_statistics qr_code_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_code_statistics"
    ADD CONSTRAINT "qr_code_statistics_pkey" PRIMARY KEY ("id");


--
-- Name: qr_codes qr_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_codes"
    ADD CONSTRAINT "qr_codes_pkey" PRIMARY KEY ("id");


--
-- Name: qr_landing_pages qr_landing_pages_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_landing_pages"
    ADD CONSTRAINT "qr_landing_pages_slug_key" UNIQUE ("slug");


--
-- Name: qr_order_product_category qr_order_product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_product_category"
    ADD CONSTRAINT "qr_order_product_category_pkey" PRIMARY KEY ("id");


--
-- Name: qr_order_requests qr_order_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_requests"
    ADD CONSTRAINT "qr_order_requests_pkey" PRIMARY KEY ("id");


--
-- Name: qr_order_tables qr_order_tables_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_tables"
    ADD CONSTRAINT "qr_order_tables_pkey1" PRIMARY KEY ("id");


--
-- Name: qr_page_statistics qr_page_statistic_uniq_idx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_page_statistics"
    ADD CONSTRAINT "qr_page_statistic_uniq_idx" UNIQUE NULLS NOT DISTINCT ("project_id", "qr_code_id", "url", "time_type", "ts");


--
-- Name: qr_page_statistics qr_page_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_page_statistics"
    ADD CONSTRAINT "qr_page_statistics_pkey" PRIMARY KEY ("id");


--
-- Name: qr_landing_pages qr_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_landing_pages"
    ADD CONSTRAINT "qr_pages_pkey" PRIMARY KEY ("id");


--
-- Name: short_links short_links_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."short_links"
    ADD CONSTRAINT "short_links_pkey" PRIMARY KEY ("id");


--
-- Name: short_links short_links_qr_code_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."short_links"
    ADD CONSTRAINT "short_links_qr_code_id_key" UNIQUE ("qr_code_id");


--
-- Name: short_links short_links_short_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."short_links"
    ADD CONSTRAINT "short_links_short_id_key" UNIQUE ("short_id");


--
-- Name: short_links short_links_short_url_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."short_links"
    ADD CONSTRAINT "short_links_short_url_key" UNIQUE ("short_url");


--
-- Name: users_projects_permissions users_projects_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."users_projects_permissions"
    ADD CONSTRAINT "users_projects_permissions_pkey" PRIMARY KEY ("id");


--
-- Name: users_projects_permissions users_projects_permissions_uniq_idx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."users_projects_permissions"
    ADD CONSTRAINT "users_projects_permissions_uniq_idx" UNIQUE ("user_project_id", "permission");


--
-- Name: users_projects users_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."users_projects"
    ADD CONSTRAINT "users_projects_pkey" PRIMARY KEY ("id");


--
-- Name: users_projects users_projects_uniq_idx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."users_projects"
    ADD CONSTRAINT "users_projects_uniq_idx" UNIQUE ("user_id", "project_id");


--
-- Name: projects handle_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "handle_updated_at" BEFORE UPDATE ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "extensions"."moddatetime"('updated_at');


--
-- Name: qr_codes handle_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "handle_updated_at" BEFORE UPDATE ON "public"."qr_codes" FOR EACH ROW EXECUTE FUNCTION "extensions"."moddatetime"('updated_at');


--
-- Name: qr_landing_pages handle_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "handle_updated_at" BEFORE UPDATE ON "public"."qr_landing_pages" FOR EACH ROW EXECUTE FUNCTION "extensions"."moddatetime"('updated_at');


--
-- Name: qr_order_categories handle_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "handle_updated_at" BEFORE UPDATE ON "public"."qr_order_categories" FOR EACH ROW EXECUTE FUNCTION "extensions"."moddatetime"('updated_at');


--
-- Name: qr_order_products handle_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "handle_updated_at" BEFORE UPDATE ON "public"."qr_order_products" FOR EACH ROW EXECUTE FUNCTION "extensions"."moddatetime"('updated_at');


--
-- Name: qr_order_requests handle_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "handle_updated_at" BEFORE UPDATE ON "public"."qr_order_requests" FOR EACH ROW EXECUTE FUNCTION "extensions"."moddatetime"('updated_at');


--
-- Name: qr_orders handle_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "handle_updated_at" BEFORE UPDATE ON "public"."qr_orders" FOR EACH ROW EXECUTE FUNCTION "extensions"."moddatetime"('updated_at');


--
-- Name: projects on_public_project_created; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "on_public_project_created" AFTER INSERT ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_project"();


--
-- Name: projects projects_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."projects"
    ADD CONSTRAINT "projects_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: qr_code_statistics qr_code_statistics_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_code_statistics"
    ADD CONSTRAINT "qr_code_statistics_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: qr_code_statistics qr_code_statistics_qr_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_code_statistics"
    ADD CONSTRAINT "qr_code_statistics_qr_code_id_fkey" FOREIGN KEY ("qr_code_id") REFERENCES "public"."qr_codes"("id") ON DELETE CASCADE;


--
-- Name: qr_codes qr_codes_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_codes"
    ADD CONSTRAINT "qr_codes_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");


--
-- Name: qr_codes qr_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_codes"
    ADD CONSTRAINT "qr_codes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: qr_landing_pages qr_landing_pages_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_landing_pages"
    ADD CONSTRAINT "qr_landing_pages_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");


--
-- Name: qr_landing_pages qr_landing_pages_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_landing_pages"
    ADD CONSTRAINT "qr_landing_pages_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: qr_order_categories qr_order_categories_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_categories"
    ADD CONSTRAINT "qr_order_categories_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");


--
-- Name: qr_order_categories qr_order_categories_qr_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_categories"
    ADD CONSTRAINT "qr_order_categories_qr_order_id_fkey" FOREIGN KEY ("qr_order_id") REFERENCES "public"."qr_orders"("id");


--
-- Name: qr_order_categories qr_order_categories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_categories"
    ADD CONSTRAINT "qr_order_categories_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: qr_order_product_category qr_order_product_category_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_product_category"
    ADD CONSTRAINT "qr_order_product_category_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."qr_order_categories"("id");


--
-- Name: qr_order_product_category qr_order_product_category_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_product_category"
    ADD CONSTRAINT "qr_order_product_category_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."qr_order_products"("id");


--
-- Name: qr_order_products qr_order_products_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_products"
    ADD CONSTRAINT "qr_order_products_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");


--
-- Name: qr_order_products qr_order_products_qr_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_products"
    ADD CONSTRAINT "qr_order_products_qr_order_id_fkey" FOREIGN KEY ("qr_order_id") REFERENCES "public"."qr_orders"("id");


--
-- Name: qr_order_products qr_order_products_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_products"
    ADD CONSTRAINT "qr_order_products_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: qr_order_requests qr_order_requests_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_requests"
    ADD CONSTRAINT "qr_order_requests_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");


--
-- Name: qr_order_requests qr_order_requests_qr_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_requests"
    ADD CONSTRAINT "qr_order_requests_qr_order_id_fkey" FOREIGN KEY ("qr_order_id") REFERENCES "public"."qr_orders"("id");


--
-- Name: qr_order_requests qr_order_requests_table_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_requests"
    ADD CONSTRAINT "qr_order_requests_table_id_fkey" FOREIGN KEY ("table_id") REFERENCES "public"."qr_order_tables"("id");


--
-- Name: qr_order_tables qr_order_tables_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_tables"
    ADD CONSTRAINT "qr_order_tables_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");


--
-- Name: qr_order_tables qr_order_tables_qr_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_tables"
    ADD CONSTRAINT "qr_order_tables_qr_order_id_fkey" FOREIGN KEY ("qr_order_id") REFERENCES "public"."qr_orders"("id");


--
-- Name: qr_order_tables qr_order_tables_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_order_tables"
    ADD CONSTRAINT "qr_order_tables_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: qr_orders qr_orders_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_orders"
    ADD CONSTRAINT "qr_orders_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");


--
-- Name: qr_orders qr_orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_orders"
    ADD CONSTRAINT "qr_orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: qr_page_statistics qr_page_statistics_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_page_statistics"
    ADD CONSTRAINT "qr_page_statistics_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;


--
-- Name: qr_page_statistics qr_page_statistics_qr_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."qr_page_statistics"
    ADD CONSTRAINT "qr_page_statistics_qr_code_id_fkey" FOREIGN KEY ("qr_code_id") REFERENCES "public"."qr_codes"("id") ON DELETE CASCADE;


--
-- Name: short_links short_links_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."short_links"
    ADD CONSTRAINT "short_links_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");


--
-- Name: short_links short_links_qr_code_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."short_links"
    ADD CONSTRAINT "short_links_qr_code_id_fkey" FOREIGN KEY ("qr_code_id") REFERENCES "public"."qr_codes"("id") ON DELETE CASCADE;


--
-- Name: short_links short_links_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."short_links"
    ADD CONSTRAINT "short_links_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: users_projects_permissions users_projects_permissions_user_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."users_projects_permissions"
    ADD CONSTRAINT "users_projects_permissions_user_project_id_fkey" FOREIGN KEY ("user_project_id") REFERENCES "public"."users_projects"("id") ON DELETE CASCADE;


--
-- Name: users_projects users_projects_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."users_projects"
    ADD CONSTRAINT "users_projects_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id");


--
-- Name: users_projects users_projects_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."users_projects"
    ADD CONSTRAINT "users_projects_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");


--
-- Name: qr_landing_pages Enable delete for project team; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for project team" ON "public"."qr_landing_pages" FOR DELETE TO "authenticated" USING (( SELECT "public"."check_team_permissions"("qr_landing_pages"."project_id", ARRAY['qr_landing_page_delete'::"text"]) AS "check_team_permissions"));


--
-- Name: qr_codes Enable delete for users based on project team; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on project team" ON "public"."qr_codes" FOR DELETE USING (( SELECT "public"."check_team_permissions"("qr_codes"."project_id", ARRAY['qr_code_delete'::"text"]) AS "check_team_permissions"));


--
-- Name: qr_order_requests Enable delete for users based on project team; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on project team" ON "public"."qr_order_requests" FOR DELETE TO "authenticated" USING (true);


--
-- Name: qr_order_categories Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on user_id" ON "public"."qr_order_categories" FOR DELETE USING (true);


--
-- Name: qr_order_product_category Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on user_id" ON "public"."qr_order_product_category" FOR DELETE USING (true);


--
-- Name: qr_order_products Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on user_id" ON "public"."qr_order_products" FOR DELETE USING (("auth"."uid"() = "user_id"));


--
-- Name: qr_order_tables Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on user_id" ON "public"."qr_order_tables" FOR DELETE USING (("auth"."uid"() = "user_id"));


--
-- Name: qr_orders Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on user_id" ON "public"."qr_orders" FOR DELETE USING (true);


--
-- Name: short_links Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on user_id" ON "public"."short_links" FOR DELETE USING (("auth"."uid"() = "user_id"));


--
-- Name: users_projects Enable delete for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users based on user_id" ON "public"."users_projects" FOR DELETE USING (("auth"."uid"() IN ( SELECT "projects"."user_id"
   FROM "public"."projects"
  WHERE ("projects"."id" = "users_projects"."project_id"))));


--
-- Name: qr_order_requests Enable insert for  all user; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for  all user" ON "public"."qr_order_requests" FOR INSERT WITH CHECK (true);


--
-- Name: projects Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."projects" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: qr_order_categories Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."qr_order_categories" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: qr_order_product_category Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."qr_order_product_category" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: qr_order_products Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."qr_order_products" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: qr_order_tables Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."qr_order_tables" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: qr_orders Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."qr_orders" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: short_links Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."short_links" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: qr_codes Enable insert for project team; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for project team" ON "public"."qr_codes" FOR INSERT TO "authenticated" WITH CHECK (( SELECT "public"."check_team_permissions"("qr_codes"."project_id", ARRAY['qr_code_create'::"text"]) AS "check_team_permissions"));


--
-- Name: qr_landing_pages Enable insert for project team; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for project team" ON "public"."qr_landing_pages" FOR INSERT TO "authenticated" WITH CHECK (( SELECT "public"."check_team_permissions"("qr_landing_pages"."project_id", ARRAY['qr_landing_page_create'::"text"]) AS "check_team_permissions"));


--
-- Name: qr_codes Enable read access based on project team permissions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access based on project team permissions" ON "public"."qr_codes" FOR SELECT USING (( SELECT "public"."check_team_permissions"("qr_codes"."project_id", ARRAY['qr_code_view'::"text"]) AS "check_team_permissions"));


--
-- Name: qr_landing_pages Enable read access based on project team permissions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access based on project team permissions" ON "public"."qr_landing_pages" FOR SELECT USING (( SELECT "public"."check_team_permissions"("qr_landing_pages"."project_id", ARRAY['qr_landing_page_view'::"text"]) AS "check_team_permissions"));


--
-- Name: qr_order_categories Enable read access based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access based on user_id" ON "public"."qr_order_categories" FOR SELECT USING (true);


--
-- Name: qr_order_products Enable read access based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access based on user_id" ON "public"."qr_order_products" FOR SELECT USING (true);


--
-- Name: qr_orders Enable read access based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access based on user_id" ON "public"."qr_orders" FOR SELECT USING (true);


--
-- Name: qr_code_statistics Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."qr_code_statistics" FOR SELECT TO "authenticated" USING (true);


--
-- Name: qr_order_tables Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."qr_order_tables" FOR SELECT USING (true);


--
-- Name: qr_page_statistics Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."qr_page_statistics" FOR SELECT TO "authenticated" USING (true);


--
-- Name: short_links Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."short_links" FOR SELECT USING (true);


--
-- Name: users_projects Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."users_projects" FOR SELECT TO "authenticated" USING (true);


--
-- Name: projects Enable read access for members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for members" ON "public"."projects" FOR SELECT USING ((("auth"."uid"() = "user_id") OR ("auth"."uid"() IN ( SELECT "users_projects"."user_id"
   FROM "public"."users_projects"
  WHERE ("users_projects"."project_id" = "projects"."id")))));


--
-- Name: qr_order_requests Enable read access for members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for members" ON "public"."qr_order_requests" FOR SELECT USING (true);


--
-- Name: qr_order_product_category Enable selected for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable selected for authenticated users only" ON "public"."qr_order_product_category" FOR SELECT USING (true);


--
-- Name: qr_landing_pages Enable update for project team; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for project team" ON "public"."qr_landing_pages" FOR UPDATE TO "authenticated" USING (( SELECT "public"."check_team_permissions"("qr_landing_pages"."project_id", ARRAY['qr_landing_page_update'::"text"]) AS "check_team_permissions")) WITH CHECK (( SELECT "public"."check_team_permissions"("qr_landing_pages"."project_id", ARRAY['qr_landing_page_update'::"text"]) AS "check_team_permissions"));


--
-- Name: qr_codes Enable update for users based on project team; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on project team" ON "public"."qr_codes" FOR UPDATE USING (( SELECT "public"."check_team_permissions"("qr_codes"."project_id", ARRAY['qr_code_update'::"text"]) AS "check_team_permissions")) WITH CHECK (( SELECT "public"."check_team_permissions"("qr_codes"."project_id", ARRAY['qr_code_update'::"text"]) AS "check_team_permissions"));


--
-- Name: qr_order_requests Enable update for users based on project team; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on project team" ON "public"."qr_order_requests" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);


--
-- Name: projects Enable update for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on user_id" ON "public"."projects" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: qr_order_categories Enable update for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on user_id" ON "public"."qr_order_categories" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--
-- Name: qr_order_product_category Enable update for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on user_id" ON "public"."qr_order_product_category" FOR UPDATE TO "authenticated" USING (true);


--
-- Name: qr_order_products Enable update for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on user_id" ON "public"."qr_order_products" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id"));


--
-- Name: qr_order_tables Enable update for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on user_id" ON "public"."qr_order_tables" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: qr_orders Enable update for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on user_id" ON "public"."qr_orders" FOR UPDATE USING (("auth"."uid"() = "user_id"));


--
-- Name: short_links Enable update for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on user_id" ON "public"."short_links" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));


--
-- Name: projects; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."projects" ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_code_statistics; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."qr_code_statistics" ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_codes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."qr_codes" ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_landing_pages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."qr_landing_pages" ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_order_categories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."qr_order_categories" ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_order_product_category; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."qr_order_product_category" ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_order_products; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."qr_order_products" ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_order_requests; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."qr_order_requests" ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_order_tables; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."qr_order_tables" ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_orders; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."qr_orders" ENABLE ROW LEVEL SECURITY;

--
-- Name: qr_page_statistics; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."qr_page_statistics" ENABLE ROW LEVEL SECURITY;

--
-- Name: short_links; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."short_links" ENABLE ROW LEVEL SECURITY;

--
-- Name: users_projects; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."users_projects" ENABLE ROW LEVEL SECURITY;

--
-- Name: users_projects_permissions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."users_projects_permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA "pgsodium_masks"; Type: ACL; Schema: -; Owner: postgres
--

-- REVOKE ALL ON SCHEMA "pgsodium_masks" FROM "supabase_admin";
-- REVOKE USAGE ON SCHEMA "pgsodium_masks" FROM "pgsodium_keyiduser";
-- GRANT ALL ON SCHEMA "pgsodium_masks" TO "postgres";
-- GRANT USAGE ON SCHEMA "pgsodium_masks" TO "pgsodium_keyiduser";


--
-- Name: SCHEMA "public"; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";


--
-- Name: FUNCTION "algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "armor"("bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."armor"("bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."armor"("bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."armor"("bytea") TO "dashboard_user";


--
-- Name: FUNCTION "armor"("bytea", "text"[], "text"[]); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) TO "dashboard_user";


--
-- Name: FUNCTION "crypt"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."crypt"("text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."crypt"("text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."crypt"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "dearmor"("text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."dearmor"("text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."dearmor"("text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."dearmor"("text") TO "dashboard_user";


--
-- Name: FUNCTION "decrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "decrypt_iv"("bytea", "bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "digest"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."digest"("bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."digest"("bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."digest"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "digest"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."digest"("text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."digest"("text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."digest"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "encrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "encrypt_iv"("bytea", "bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "gen_random_bytes"(integer); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) TO "dashboard_user";


--
-- Name: FUNCTION "gen_random_uuid"(); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."gen_random_uuid"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."gen_random_uuid"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."gen_random_uuid"() TO "dashboard_user";


--
-- Name: FUNCTION "gen_salt"("text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."gen_salt"("text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."gen_salt"("text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."gen_salt"("text") TO "dashboard_user";


--
-- Name: FUNCTION "gen_salt"("text", integer); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."gen_salt"("text", integer) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."gen_salt"("text", integer) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."gen_salt"("text", integer) TO "dashboard_user";


--
-- Name: FUNCTION "hmac"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "hmac"("text", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "moddatetime"(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

-- GRANT ALL ON FUNCTION "extensions"."moddatetime"() TO "postgres" WITH GRANT OPTION;


--
-- Name: FUNCTION "pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision) TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) TO "dashboard_user";


--
-- Name: FUNCTION "pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_key_id"("bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt"("text", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt"("text", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt_bytea"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt_bytea"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt_bytea"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt_bytea"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt"("text", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt_bytea"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt_bytea"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "sign"("payload" "json", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "try_cast_double"("inp" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") TO "dashboard_user";


--
-- Name: FUNCTION "url_decode"("data" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."url_decode"("data" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."url_decode"("data" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."url_decode"("data" "text") TO "dashboard_user";


--
-- Name: FUNCTION "url_encode"("data" "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v1"(); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v1"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v1mc"(); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v3"("namespace" "uuid", "name" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v4"(); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v4"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v4"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v4"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v5"("namespace" "uuid", "name" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_nil"(); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."uuid_nil"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_nil"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_nil"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_dns"(); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."uuid_ns_dns"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_dns"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_dns"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_oid"(); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."uuid_ns_oid"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_oid"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_oid"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_url"(); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."uuid_ns_url"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_url"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_url"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_x500"(); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."uuid_ns_x500"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_x500"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_x500"() TO "dashboard_user";


--
-- Name: FUNCTION "verify"("token" "text", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "comment_directive"("comment_" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

-- GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "postgres";
-- GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "anon";
-- GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "authenticated";
-- GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "service_role";


--
-- Name: FUNCTION "exception"("message" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

-- GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "postgres";
-- GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "anon";
-- GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "authenticated";
-- GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "service_role";


--
-- Name: FUNCTION "get_schema_version"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

-- GRANT ALL ON FUNCTION "graphql"."get_schema_version"() TO "postgres";
-- GRANT ALL ON FUNCTION "graphql"."get_schema_version"() TO "anon";
-- GRANT ALL ON FUNCTION "graphql"."get_schema_version"() TO "authenticated";
-- GRANT ALL ON FUNCTION "graphql"."get_schema_version"() TO "service_role";


--
-- Name: FUNCTION "increment_schema_version"(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

-- GRANT ALL ON FUNCTION "graphql"."increment_schema_version"() TO "postgres";
-- GRANT ALL ON FUNCTION "graphql"."increment_schema_version"() TO "anon";
-- GRANT ALL ON FUNCTION "graphql"."increment_schema_version"() TO "authenticated";
-- GRANT ALL ON FUNCTION "graphql"."increment_schema_version"() TO "service_role";


--
-- Name: FUNCTION "graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb"); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

-- GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "postgres";
-- GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "anon";
-- GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "authenticated";
-- GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "service_role";


--
-- Name: TABLE "key"; Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON TABLE "pgsodium"."key" FROM "supabase_admin";
-- REVOKE ALL ON TABLE "pgsodium"."key" FROM "pgsodium_keymaker";
-- GRANT ALL ON TABLE "pgsodium"."key" TO "postgres";
-- GRANT ALL ON TABLE "pgsodium"."key" TO "pgsodium_keymaker";


--
-- Name: TABLE "valid_key"; Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON TABLE "pgsodium"."valid_key" FROM "supabase_admin";
-- REVOKE ALL ON TABLE "pgsodium"."valid_key" FROM "pgsodium_keyholder";
-- REVOKE SELECT ON TABLE "pgsodium"."valid_key" FROM "pgsodium_keyiduser";
-- GRANT ALL ON TABLE "pgsodium"."valid_key" TO "postgres";
-- GRANT ALL ON TABLE "pgsodium"."valid_key" TO "pgsodium_keyholder";
-- GRANT SELECT ON TABLE "pgsodium"."valid_key" TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_aead_det_decrypt"("ciphertext" "bytea", "additional" "bytea", "key" "bytea", "nonce" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("ciphertext" "bytea", "additional" "bytea", "key" "bytea", "nonce" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("ciphertext" "bytea", "additional" "bytea", "key" "bytea", "nonce" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("ciphertext" "bytea", "additional" "bytea", "key" "bytea", "nonce" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("ciphertext" "bytea", "additional" "bytea", "key" "bytea", "nonce" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_aead_det_decrypt"("message" "bytea", "additional" "bytea", "key_uuid" "uuid", "nonce" "bytea"); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("message" "bytea", "additional" "bytea", "key_uuid" "uuid", "nonce" "bytea") TO "service_role";


--
-- Name: FUNCTION "crypto_aead_det_decrypt"("message" "bytea", "additional" "bytea", "key_id" bigint, "context" "bytea", "nonce" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("message" "bytea", "additional" "bytea", "key_id" bigint, "context" "bytea", "nonce" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("message" "bytea", "additional" "bytea", "key_id" bigint, "context" "bytea", "nonce" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("message" "bytea", "additional" "bytea", "key_id" bigint, "context" "bytea", "nonce" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("message" "bytea", "additional" "bytea", "key_id" bigint, "context" "bytea", "nonce" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key" "bytea", "nonce" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key" "bytea", "nonce" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key" "bytea", "nonce" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key" "bytea", "nonce" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key" "bytea", "nonce" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key_uuid" "uuid", "nonce" "bytea"); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key_uuid" "uuid", "nonce" "bytea") TO "service_role";


--
-- Name: FUNCTION "crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key_id" bigint, "context" "bytea", "nonce" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key_id" bigint, "context" "bytea", "nonce" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key_id" bigint, "context" "bytea", "nonce" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key_id" bigint, "context" "bytea", "nonce" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key_id" bigint, "context" "bytea", "nonce" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_aead_det_keygen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_keygen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_keygen"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_keygen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_keygen"() TO "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_keygen"() TO "service_role";


--
-- Name: FUNCTION "crypto_aead_det_noncegen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_noncegen"() FROM PUBLIC;
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_noncegen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_det_noncegen"() FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_noncegen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_noncegen"() TO PUBLIC;
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_noncegen"() TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_aead_ietf_decrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_decrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_decrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_decrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_decrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_aead_ietf_decrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_decrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_decrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_decrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_decrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_aead_ietf_encrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_encrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_encrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_encrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_encrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_aead_ietf_encrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_encrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_encrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_encrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_encrypt"("message" "bytea", "additional" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_aead_ietf_keygen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_keygen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_keygen"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_keygen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_keygen"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_aead_ietf_noncegen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_noncegen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_noncegen"() FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_noncegen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_ietf_noncegen"() TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_auth"("message" "bytea", "key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth"("message" "bytea", "key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth"("message" "bytea", "key" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth"("message" "bytea", "key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth"("message" "bytea", "key" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_auth"("message" "bytea", "key_id" bigint, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth"("message" "bytea", "key_id" bigint, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth"("message" "bytea", "key_id" bigint, "context" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth"("message" "bytea", "key_id" bigint, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth"("message" "bytea", "key_id" bigint, "context" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_auth_hmacsha256"("message" "bytea", "secret" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256"("message" "bytea", "secret" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256"("message" "bytea", "secret" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256"("message" "bytea", "secret" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256"("message" "bytea", "secret" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_auth_hmacsha256"("message" "bytea", "key_id" bigint, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256"("message" "bytea", "key_id" bigint, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256"("message" "bytea", "key_id" bigint, "context" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256"("message" "bytea", "key_id" bigint, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256"("message" "bytea", "key_id" bigint, "context" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_auth_hmacsha256_keygen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_keygen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_keygen"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_keygen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_keygen"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_auth_hmacsha256_verify"("hash" "bytea", "message" "bytea", "secret" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_verify"("hash" "bytea", "message" "bytea", "secret" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_verify"("hash" "bytea", "message" "bytea", "secret" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_verify"("hash" "bytea", "message" "bytea", "secret" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_verify"("hash" "bytea", "message" "bytea", "secret" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_auth_hmacsha256_verify"("hash" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_verify"("hash" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_verify"("hash" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_verify"("hash" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha256_verify"("hash" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_auth_hmacsha512"("message" "bytea", "secret" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512"("message" "bytea", "secret" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512"("message" "bytea", "secret" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512"("message" "bytea", "secret" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512"("message" "bytea", "secret" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_auth_hmacsha512"("message" "bytea", "key_id" bigint, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512"("message" "bytea", "key_id" bigint, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512"("message" "bytea", "key_id" bigint, "context" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512"("message" "bytea", "key_id" bigint, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512"("message" "bytea", "key_id" bigint, "context" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_auth_hmacsha512_verify"("hash" "bytea", "message" "bytea", "secret" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512_verify"("hash" "bytea", "message" "bytea", "secret" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512_verify"("hash" "bytea", "message" "bytea", "secret" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512_verify"("hash" "bytea", "message" "bytea", "secret" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512_verify"("hash" "bytea", "message" "bytea", "secret" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_auth_hmacsha512_verify"("hash" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512_verify"("hash" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512_verify"("hash" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512_verify"("hash" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_hmacsha512_verify"("hash" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_auth_keygen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_keygen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_keygen"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_keygen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_keygen"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_auth_verify"("mac" "bytea", "message" "bytea", "key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_verify"("mac" "bytea", "message" "bytea", "key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_verify"("mac" "bytea", "message" "bytea", "key" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_verify"("mac" "bytea", "message" "bytea", "key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_verify"("mac" "bytea", "message" "bytea", "key" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_auth_verify"("mac" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_verify"("mac" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_auth_verify"("mac" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_verify"("mac" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_auth_verify"("mac" "bytea", "message" "bytea", "key_id" bigint, "context" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_box"("message" "bytea", "nonce" "bytea", "public" "bytea", "secret" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_box"("message" "bytea", "nonce" "bytea", "public" "bytea", "secret" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_box"("message" "bytea", "nonce" "bytea", "public" "bytea", "secret" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_box"("message" "bytea", "nonce" "bytea", "public" "bytea", "secret" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_box"("message" "bytea", "nonce" "bytea", "public" "bytea", "secret" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_box_new_keypair"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_box_new_keypair"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_box_new_keypair"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_box_new_keypair"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_box_new_keypair"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_box_noncegen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_box_noncegen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_box_noncegen"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_box_noncegen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_box_noncegen"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_box_open"("ciphertext" "bytea", "nonce" "bytea", "public" "bytea", "secret" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_box_open"("ciphertext" "bytea", "nonce" "bytea", "public" "bytea", "secret" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_box_open"("ciphertext" "bytea", "nonce" "bytea", "public" "bytea", "secret" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_box_open"("ciphertext" "bytea", "nonce" "bytea", "public" "bytea", "secret" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_box_open"("ciphertext" "bytea", "nonce" "bytea", "public" "bytea", "secret" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_box_seed_new_keypair"("seed" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_box_seed_new_keypair"("seed" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_box_seed_new_keypair"("seed" "bytea") FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_box_seed_new_keypair"("seed" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_box_seed_new_keypair"("seed" "bytea") TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_generichash"("message" "bytea", "key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_generichash"("message" "bytea", "key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_generichash"("message" "bytea", "key" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_generichash"("message" "bytea", "key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_generichash"("message" "bytea", "key" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_generichash_keygen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_generichash_keygen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_generichash_keygen"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_generichash_keygen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_generichash_keygen"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_kdf_derive_from_key"("subkey_size" bigint, "subkey_id" bigint, "context" "bytea", "primary_key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_kdf_derive_from_key"("subkey_size" bigint, "subkey_id" bigint, "context" "bytea", "primary_key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_kdf_derive_from_key"("subkey_size" bigint, "subkey_id" bigint, "context" "bytea", "primary_key" "bytea") FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_kdf_derive_from_key"("subkey_size" bigint, "subkey_id" bigint, "context" "bytea", "primary_key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_kdf_derive_from_key"("subkey_size" bigint, "subkey_id" bigint, "context" "bytea", "primary_key" "bytea") TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_kdf_keygen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_kdf_keygen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_kdf_keygen"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_kdf_keygen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_kdf_keygen"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_kx_new_keypair"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_kx_new_keypair"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_kx_new_keypair"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_kx_new_keypair"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_kx_new_keypair"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_kx_new_seed"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_kx_new_seed"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_kx_new_seed"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_kx_new_seed"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_kx_new_seed"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_kx_seed_new_keypair"("seed" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_kx_seed_new_keypair"("seed" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_kx_seed_new_keypair"("seed" "bytea") FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_kx_seed_new_keypair"("seed" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_kx_seed_new_keypair"("seed" "bytea") TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_secretbox"("message" "bytea", "nonce" "bytea", "key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox"("message" "bytea", "nonce" "bytea", "key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox"("message" "bytea", "nonce" "bytea", "key" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox"("message" "bytea", "nonce" "bytea", "key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox"("message" "bytea", "nonce" "bytea", "key" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_secretbox"("message" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox"("message" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox"("message" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox"("message" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox"("message" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_secretbox_keygen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox_keygen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox_keygen"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox_keygen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox_keygen"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_secretbox_noncegen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox_noncegen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox_noncegen"() FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox_noncegen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox_noncegen"() TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_secretbox_open"("ciphertext" "bytea", "nonce" "bytea", "key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox_open"("ciphertext" "bytea", "nonce" "bytea", "key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox_open"("ciphertext" "bytea", "nonce" "bytea", "key" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox_open"("ciphertext" "bytea", "nonce" "bytea", "key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox_open"("ciphertext" "bytea", "nonce" "bytea", "key" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_secretbox_open"("message" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox_open"("message" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_secretbox_open"("message" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox_open"("message" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_secretbox_open"("message" "bytea", "nonce" "bytea", "key_id" bigint, "context" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_shorthash"("message" "bytea", "key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_shorthash"("message" "bytea", "key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_shorthash"("message" "bytea", "key" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_shorthash"("message" "bytea", "key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_shorthash"("message" "bytea", "key" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "crypto_shorthash_keygen"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_shorthash_keygen"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_shorthash_keygen"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_shorthash_keygen"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_shorthash_keygen"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_sign_final_create"("state" "bytea", "key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_final_create"("state" "bytea", "key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_final_create"("state" "bytea", "key" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_final_create"("state" "bytea", "key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_final_create"("state" "bytea", "key" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_sign_final_verify"("state" "bytea", "signature" "bytea", "key" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_final_verify"("state" "bytea", "signature" "bytea", "key" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_final_verify"("state" "bytea", "signature" "bytea", "key" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_final_verify"("state" "bytea", "signature" "bytea", "key" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_final_verify"("state" "bytea", "signature" "bytea", "key" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_sign_init"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_init"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_init"() FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_init"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_init"() TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_sign_new_keypair"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_new_keypair"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_new_keypair"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_new_keypair"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_new_keypair"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_sign_update"("state" "bytea", "message" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_update"("state" "bytea", "message" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_update"("state" "bytea", "message" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_update"("state" "bytea", "message" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_update"("state" "bytea", "message" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_sign_update_agg1"("state" "bytea", "message" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_update_agg1"("state" "bytea", "message" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_update_agg1"("state" "bytea", "message" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_update_agg1"("state" "bytea", "message" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_update_agg1"("state" "bytea", "message" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_sign_update_agg2"("cur_state" "bytea", "initial_state" "bytea", "message" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_update_agg2"("cur_state" "bytea", "initial_state" "bytea", "message" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_sign_update_agg2"("cur_state" "bytea", "initial_state" "bytea", "message" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_update_agg2"("cur_state" "bytea", "initial_state" "bytea", "message" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_sign_update_agg2"("cur_state" "bytea", "initial_state" "bytea", "message" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_signcrypt_new_keypair"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_new_keypair"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_new_keypair"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_new_keypair"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_new_keypair"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "crypto_signcrypt_sign_after"("state" "bytea", "sender_sk" "bytea", "ciphertext" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_sign_after"("state" "bytea", "sender_sk" "bytea", "ciphertext" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_sign_after"("state" "bytea", "sender_sk" "bytea", "ciphertext" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_sign_after"("state" "bytea", "sender_sk" "bytea", "ciphertext" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_sign_after"("state" "bytea", "sender_sk" "bytea", "ciphertext" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_signcrypt_sign_before"("sender" "bytea", "recipient" "bytea", "sender_sk" "bytea", "recipient_pk" "bytea", "additional" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_sign_before"("sender" "bytea", "recipient" "bytea", "sender_sk" "bytea", "recipient_pk" "bytea", "additional" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_sign_before"("sender" "bytea", "recipient" "bytea", "sender_sk" "bytea", "recipient_pk" "bytea", "additional" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_sign_before"("sender" "bytea", "recipient" "bytea", "sender_sk" "bytea", "recipient_pk" "bytea", "additional" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_sign_before"("sender" "bytea", "recipient" "bytea", "sender_sk" "bytea", "recipient_pk" "bytea", "additional" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_signcrypt_verify_after"("state" "bytea", "signature" "bytea", "sender_pk" "bytea", "ciphertext" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_after"("state" "bytea", "signature" "bytea", "sender_pk" "bytea", "ciphertext" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_after"("state" "bytea", "signature" "bytea", "sender_pk" "bytea", "ciphertext" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_after"("state" "bytea", "signature" "bytea", "sender_pk" "bytea", "ciphertext" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_after"("state" "bytea", "signature" "bytea", "sender_pk" "bytea", "ciphertext" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_signcrypt_verify_before"("signature" "bytea", "sender" "bytea", "recipient" "bytea", "additional" "bytea", "sender_pk" "bytea", "recipient_sk" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_before"("signature" "bytea", "sender" "bytea", "recipient" "bytea", "additional" "bytea", "sender_pk" "bytea", "recipient_sk" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_before"("signature" "bytea", "sender" "bytea", "recipient" "bytea", "additional" "bytea", "sender_pk" "bytea", "recipient_sk" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_before"("signature" "bytea", "sender" "bytea", "recipient" "bytea", "additional" "bytea", "sender_pk" "bytea", "recipient_sk" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_before"("signature" "bytea", "sender" "bytea", "recipient" "bytea", "additional" "bytea", "sender_pk" "bytea", "recipient_sk" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "crypto_signcrypt_verify_public"("signature" "bytea", "sender" "bytea", "recipient" "bytea", "additional" "bytea", "sender_pk" "bytea", "ciphertext" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_public"("signature" "bytea", "sender" "bytea", "recipient" "bytea", "additional" "bytea", "sender_pk" "bytea", "ciphertext" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_public"("signature" "bytea", "sender" "bytea", "recipient" "bytea", "additional" "bytea", "sender_pk" "bytea", "ciphertext" "bytea") FROM "pgsodium_keyholder";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_public"("signature" "bytea", "sender" "bytea", "recipient" "bytea", "additional" "bytea", "sender_pk" "bytea", "ciphertext" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."crypto_signcrypt_verify_public"("signature" "bytea", "sender" "bytea", "recipient" "bytea", "additional" "bytea", "sender_pk" "bytea", "ciphertext" "bytea") TO "pgsodium_keyholder";


--
-- Name: FUNCTION "derive_key"("key_id" bigint, "key_len" integer, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."derive_key"("key_id" bigint, "key_len" integer, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."derive_key"("key_id" bigint, "key_len" integer, "context" "bytea") FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."derive_key"("key_id" bigint, "key_len" integer, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."derive_key"("key_id" bigint, "key_len" integer, "context" "bytea") TO "pgsodium_keymaker";


--
-- Name: FUNCTION "pgsodium_derive"("key_id" bigint, "key_len" integer, "context" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."pgsodium_derive"("key_id" bigint, "key_len" integer, "context" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."pgsodium_derive"("key_id" bigint, "key_len" integer, "context" "bytea") FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."pgsodium_derive"("key_id" bigint, "key_len" integer, "context" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."pgsodium_derive"("key_id" bigint, "key_len" integer, "context" "bytea") TO "pgsodium_keymaker";


--
-- Name: FUNCTION "randombytes_buf"("size" integer); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_buf"("size" integer) FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_buf"("size" integer) FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_buf"("size" integer) TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_buf"("size" integer) TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "randombytes_buf_deterministic"("size" integer, "seed" "bytea"); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_buf_deterministic"("size" integer, "seed" "bytea") FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_buf_deterministic"("size" integer, "seed" "bytea") FROM "pgsodium_keymaker";
-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_buf_deterministic"("size" integer, "seed" "bytea") FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_buf_deterministic"("size" integer, "seed" "bytea") TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_buf_deterministic"("size" integer, "seed" "bytea") TO "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_buf_deterministic"("size" integer, "seed" "bytea") TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "randombytes_new_seed"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_new_seed"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_new_seed"() FROM "pgsodium_keymaker";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_new_seed"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_new_seed"() TO "pgsodium_keymaker";


--
-- Name: FUNCTION "randombytes_random"(); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_random"() FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_random"() FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_random"() TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_random"() TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "randombytes_uniform"("upper_bound" integer); Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_uniform"("upper_bound" integer) FROM "supabase_admin";
-- REVOKE ALL ON FUNCTION "pgsodium"."randombytes_uniform"("upper_bound" integer) FROM "pgsodium_keyiduser";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_uniform"("upper_bound" integer) TO "postgres";
-- GRANT ALL ON FUNCTION "pgsodium"."randombytes_uniform"("upper_bound" integer) TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "check_team_permissions"("check_project_id" "uuid", "perms" "text"[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."check_team_permissions"("check_project_id" "uuid", "perms" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."check_team_permissions"("check_project_id" "uuid", "perms" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_team_permissions"("check_project_id" "uuid", "perms" "text"[]) TO "service_role";


--
-- Name: FUNCTION "handle_new_project"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."handle_new_project"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_project"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_project"() TO "service_role";


--
-- Name: TABLE "pg_stat_statements"; Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON TABLE "extensions"."pg_stat_statements" FROM "postgres";
-- GRANT ALL ON TABLE "extensions"."pg_stat_statements" TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON TABLE "extensions"."pg_stat_statements" TO "dashboard_user";


--
-- Name: TABLE "pg_stat_statements_info"; Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON TABLE "extensions"."pg_stat_statements_info" FROM "postgres";
-- GRANT ALL ON TABLE "extensions"."pg_stat_statements_info" TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON TABLE "extensions"."pg_stat_statements_info" TO "dashboard_user";


--
-- Name: SEQUENCE "seq_schema_version"; Type: ACL; Schema: graphql; Owner: supabase_admin
--

-- GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "postgres";
-- GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "anon";
-- GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "authenticated";
-- GRANT ALL ON SEQUENCE "graphql"."seq_schema_version" TO "service_role";


--
-- Name: TABLE "decrypted_key"; Type: ACL; Schema: pgsodium; Owner: postgres
--

-- GRANT ALL ON TABLE "pgsodium"."decrypted_key" TO "pgsodium_keyholder";


--
-- Name: SEQUENCE "key_key_id_seq"; Type: ACL; Schema: pgsodium; Owner: postgres
--

-- REVOKE ALL ON SEQUENCE "pgsodium"."key_key_id_seq" FROM "supabase_admin";
-- REVOKE ALL ON SEQUENCE "pgsodium"."key_key_id_seq" FROM "pgsodium_keymaker";
-- GRANT ALL ON SEQUENCE "pgsodium"."key_key_id_seq" TO "postgres";
-- GRANT ALL ON SEQUENCE "pgsodium"."key_key_id_seq" TO "pgsodium_keymaker";


--
-- Name: TABLE "masking_rule"; Type: ACL; Schema: pgsodium; Owner: postgres
--

-- GRANT ALL ON TABLE "pgsodium"."masking_rule" TO "pgsodium_keyholder";


--
-- Name: TABLE "mask_columns"; Type: ACL; Schema: pgsodium; Owner: postgres
--

-- GRANT ALL ON TABLE "pgsodium"."mask_columns" TO "pgsodium_keyholder";


--
-- Name: TABLE "projects"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."projects" TO "anon";
GRANT ALL ON TABLE "public"."projects" TO "authenticated";
GRANT ALL ON TABLE "public"."projects" TO "service_role";


--
-- Name: TABLE "qr_code_statistics"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."qr_code_statistics" TO "anon";
GRANT ALL ON TABLE "public"."qr_code_statistics" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_code_statistics" TO "service_role";


--
-- Name: TABLE "qr_codes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."qr_codes" TO "anon";
GRANT ALL ON TABLE "public"."qr_codes" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_codes" TO "service_role";


--
-- Name: TABLE "qr_landing_pages"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."qr_landing_pages" TO "anon";
GRANT ALL ON TABLE "public"."qr_landing_pages" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_landing_pages" TO "service_role";


--
-- Name: TABLE "qr_order_categories"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."qr_order_categories" TO "anon";
GRANT ALL ON TABLE "public"."qr_order_categories" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_order_categories" TO "service_role";


--
-- Name: TABLE "qr_order_product_category"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."qr_order_product_category" TO "anon";
GRANT ALL ON TABLE "public"."qr_order_product_category" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_order_product_category" TO "service_role";


--
-- Name: TABLE "qr_order_products"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."qr_order_products" TO "anon";
GRANT ALL ON TABLE "public"."qr_order_products" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_order_products" TO "service_role";


--
-- Name: TABLE "qr_order_requests"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."qr_order_requests" TO "anon";
GRANT ALL ON TABLE "public"."qr_order_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_order_requests" TO "service_role";


--
-- Name: TABLE "qr_order_tables"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."qr_order_tables" TO "anon";
GRANT ALL ON TABLE "public"."qr_order_tables" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_order_tables" TO "service_role";


--
-- Name: TABLE "qr_orders"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."qr_orders" TO "anon";
GRANT ALL ON TABLE "public"."qr_orders" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_orders" TO "service_role";


--
-- Name: TABLE "qr_page_statistics"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."qr_page_statistics" TO "anon";
GRANT ALL ON TABLE "public"."qr_page_statistics" TO "authenticated";
GRANT ALL ON TABLE "public"."qr_page_statistics" TO "service_role";


--
-- Name: TABLE "short_links"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."short_links" TO "anon";
GRANT ALL ON TABLE "public"."short_links" TO "authenticated";
GRANT ALL ON TABLE "public"."short_links" TO "service_role";


--
-- Name: TABLE "users_projects"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."users_projects" TO "anon";
GRANT ALL ON TABLE "public"."users_projects" TO "authenticated";
GRANT ALL ON TABLE "public"."users_projects" TO "service_role";


--
-- Name: TABLE "users_projects_permissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."users_projects_permissions" TO "anon";
GRANT ALL ON TABLE "public"."users_projects_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."users_projects_permissions" TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";


--
-- PostgreSQL database dump complete
--

RESET ALL;
