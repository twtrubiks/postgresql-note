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
-- Name: test_employee; Type: TABLE; Schema: public; Owner: odoo
--

CREATE TABLE public.test_employee (
    id integer NOT NULL,
    name character varying,
    manager_id integer
);


ALTER TABLE public.test_employee OWNER TO odoo;

--
-- Data for Name: test_employee; Type: TABLE DATA; Schema: public; Owner: odoo
--

COPY public.test_employee (id, name, manager_id) FROM stdin;
5	E	\N
1	A	3
2	B	4
3	C	4
4	D	5
\.


--
-- Name: test_employee test_employee_pkey; Type: CONSTRAINT; Schema: public; Owner: odoo
--

ALTER TABLE ONLY public.test_employee
    ADD CONSTRAINT test_employee_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

