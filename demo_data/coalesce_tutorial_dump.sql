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
-- Name: coalesce_tutorial; Type: TABLE; Schema: public; Owner: odoo
--

CREATE TABLE public.coalesce_tutorial (
    id integer NOT NULL,
    test1 integer,
    test2 integer,
    test3 integer,
    date timestamp without time zone
);


ALTER TABLE public.coalesce_tutorial OWNER TO odoo;

--
-- Data for Name: coalesce_tutorial; Type: TABLE DATA; Schema: public; Owner: odoo
--

COPY public.coalesce_tutorial (id, test1, test2, test3, date) FROM stdin;
1	1	\N	\N	2022-01-01 10:00:00
2	\N	1	\N	2022-02-01 11:00:00
3	\N	\N	1	2022-03-01 12:00:00
4	\N	\N	\N	2022-04-01 13:00:00
\.


--
-- Name: coalesce_tutorial coalesce_tutorial_pkey; Type: CONSTRAINT; Schema: public; Owner: odoo
--

ALTER TABLE ONLY public.coalesce_tutorial
    ADD CONSTRAINT coalesce_tutorial_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

