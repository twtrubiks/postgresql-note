--
-- PostgreSQL database dump
--

-- Dumped from database version 10.9 (Debian 10.9-1.pgdg90+1)
-- Dumped by pg_dump version 10.9 (Debian 10.9-1.pgdg90+1)

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

SET default_with_oids = false;

--
-- Name: distinct_tutorial; Type: TABLE; Schema: public; Owner: odoo
--

CREATE TABLE public.distinct_tutorial (
    id integer NOT NULL,
    amount integer DEFAULT 0 NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.distinct_tutorial OWNER TO odoo;

--
-- Data for Name: distinct_tutorial; Type: TABLE DATA; Schema: public; Owner: odoo
--

COPY public.distinct_tutorial (id, amount, user_id) FROM stdin;
1	100	1
2	100	1
3	300	2
4	300	2
5	300	2
6	100	3
7	150	4
8	150	4
\.


--
-- Name: distinct_tutorial distinct_tutorial_pkey; Type: CONSTRAINT; Schema: public; Owner: odoo
--

ALTER TABLE ONLY public.distinct_tutorial
    ADD CONSTRAINT distinct_tutorial_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

