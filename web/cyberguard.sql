--
-- PostgreSQL database dump consolidado para CyberGuard
--

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

-- ==========================================
-- TABLA: usuarios
-- ==========================================

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombre_usuario character varying(100) NOT NULL,
    empresa character varying(100),
    email character varying(150),
    password text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.usuarios OWNER TO postgres;

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.usuarios_id_seq OWNER TO postgres;
ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;
ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);

-- ==========================================
-- TABLA: incidentes
-- ==========================================

CREATE TABLE public.incidentes (
    id integer NOT NULL,
    usuario_id integer,
    tipo_incidente character varying(100) NOT NULL,
    criticidad character varying(20) NOT NULL,
    descripcion text NOT NULL,
    medidas_tomadas text,
    tecnico_responsable character varying(100),
    fecha_reporte timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.incidentes OWNER TO postgres;

CREATE SEQUENCE public.incidentes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.incidentes_id_seq OWNER TO postgres;
ALTER SEQUENCE public.incidentes_id_seq OWNED BY public.incidentes.id;
ALTER TABLE ONLY public.incidentes ALTER COLUMN id SET DEFAULT nextval('public.incidentes_id_seq'::regclass);

-- ==========================================
-- DATOS INICIALES (Data for Name: usuarios)
-- ==========================================

COPY public.usuarios (id, nombre_usuario, empresa, email, password, created_at) FROM stdin;
1	pau	CyberGuard	paucortesyuste@gmail.com	$2y$12$tcnY8PpWIJkakjxAoI6S1u4SJvjEeCunNMQbDT2XC47zhb7pfqQoO	2026-04-20 19:11:18.783394
2	admin	Seguridad	admin@cyberguard.local	$2y$12$F7MyUJXVYeN77/1eduVqq.WxsvWkvZ4J7WFeZoq2ut9THIFtDQA06	2026-04-20 19:11:30.775342
\.

SELECT pg_catalog.setval('public.usuarios_id_seq', 2, true);

-- ==========================================
-- RESTRICCIONES (Constraints)
-- ==========================================

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_email_key UNIQUE (email);

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_nombre_key UNIQUE (nombre_usuario);

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.incidentes
    ADD CONSTRAINT incidentes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.incidentes
    ADD CONSTRAINT incidentes_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE SET NULL;

-- ==========================================
-- PERMISOS PARA CYBERUSER (Configurado en Terraform)
-- ==========================================

GRANT ALL ON SCHEMA public TO cyberuser;

-- Permisos Usuarios
GRANT ALL ON TABLE public.usuarios TO cyberuser;
GRANT SELECT, USAGE ON SEQUENCE public.usuarios_id_seq TO cyberuser;

-- Permisos Incidentes
GRANT ALL ON TABLE public.incidentes TO cyberuser;
GRANT SELECT, USAGE ON SEQUENCE public.incidentes_id_seq TO cyberuser;

-- ==========================================
-- FIN DEL DUMP
-- ==========================================
