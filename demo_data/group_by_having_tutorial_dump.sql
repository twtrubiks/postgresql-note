--
-- PostgreSQL database dump
--

-- Dumped from database version 12.10 (Debian 12.10-1.pgdg110+1)
-- Dumped by pg_dump version 12.10 (Debian 12.10-1.pgdg110+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: group_by_having_tutorial; Type: TABLE; Schema: public; Owner: odoo
--

CREATE TABLE public.group_by_having_tutorial (
    user_id integer NOT NULL,
    amount integer DEFAULT 0 NOT NULL,
    id integer NOT NULL
);


ALTER TABLE public.group_by_having_tutorial OWNER TO odoo;

--
-- Data for Name: group_by_having_tutorial; Type: TABLE DATA; Schema: public; Owner: odoo
--

COPY public.group_by_having_tutorial (user_id, amount, id) FROM stdin;
1	10	1
1	20	2
2	30	3
2	40	4
3	0	5
3	10	6
\.


--
-- Name: group_by_having_tutorial group_by_having_tutorial_pkey; Type: CONSTRAINT; Schema: public; Owner: odoo
--

ALTER TABLE ONLY public.group_by_having_tutorial
    ADD CONSTRAINT group_by_having_tutorial_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

