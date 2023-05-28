--
-- PostgreSQL database dump
--

-- Dumped from database version 13.6 (Debian 13.6-1.pgdg110+1)
-- Dumped by pg_dump version 13.6 (Debian 13.6-1.pgdg110+1)

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
-- Name: json_tutorial; Type: TABLE; Schema: public; Owner: odoo
--

CREATE TABLE public.json_tutorial (
    id integer NOT NULL,
    data jsonb
);


ALTER TABLE public.json_tutorial OWNER TO odoo;

--
-- Data for Name: json_tutorial; Type: TABLE DATA; Schema: public; Owner: odoo
--

COPY public.json_tutorial (id, data) FROM stdin;
1	{"a": "1"}
2	{"b": "2"}
4	{"c": "3"}
5	{"a": "1", "c": "3"}
3	{"a": "1", "b": "2", "c": "21"}
\.


--
-- Name: json_tutorial json_tutorial_pkey; Type: CONSTRAINT; Schema: public; Owner: odoo
--

ALTER TABLE ONLY public.json_tutorial
    ADD CONSTRAINT json_tutorial_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

