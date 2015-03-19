--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: can_ban_users_of; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE can_ban_users_of (
    id integer NOT NULL,
    permission_id integer,
    users_of_permission_id integer
);


ALTER TABLE public.can_ban_users_of OWNER TO wendy;

--
-- Name: can_ban_users_of_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE can_ban_users_of_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.can_ban_users_of_id_seq OWNER TO wendy;

--
-- Name: can_ban_users_of_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE can_ban_users_of_id_seq OWNED BY can_ban_users_of.id;


--
-- Name: can_delete_messages_of; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE can_delete_messages_of (
    id integer NOT NULL,
    permission_id integer,
    messages_of_permission_id integer
);


ALTER TABLE public.can_delete_messages_of OWNER TO wendy;

--
-- Name: can_delete_messages_of_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE can_delete_messages_of_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.can_delete_messages_of_id_seq OWNER TO wendy;

--
-- Name: can_delete_messages_of_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE can_delete_messages_of_id_seq OWNED BY can_delete_messages_of.id;


--
-- Name: can_delete_threads_of; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE can_delete_threads_of (
    id integer NOT NULL,
    permission_id integer,
    threads_of_permission_id integer
);


ALTER TABLE public.can_delete_threads_of OWNER TO wendy;

--
-- Name: can_delete_threads_of_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE can_delete_threads_of_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.can_delete_threads_of_id_seq OWNER TO wendy;

--
-- Name: can_delete_threads_of_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE can_delete_threads_of_id_seq OWNED BY can_delete_threads_of.id;


--
-- Name: can_edit_messages_of; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE can_edit_messages_of (
    id integer NOT NULL,
    permission_id integer,
    messages_of_permission_id integer
);


ALTER TABLE public.can_edit_messages_of OWNER TO wendy;

--
-- Name: can_edit_messages_of_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE can_edit_messages_of_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.can_edit_messages_of_id_seq OWNER TO wendy;

--
-- Name: can_edit_messages_of_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE can_edit_messages_of_id_seq OWNED BY can_edit_messages_of.id;


--
-- Name: can_edit_threads_of; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE can_edit_threads_of (
    id integer NOT NULL,
    permission_id integer,
    threads_of_permission_id integer
);


ALTER TABLE public.can_edit_threads_of OWNER TO wendy;

--
-- Name: can_edit_threads_of_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE can_edit_threads_of_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.can_edit_threads_of_id_seq OWNER TO wendy;

--
-- Name: can_edit_threads_of_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE can_edit_threads_of_id_seq OWNED BY can_edit_threads_of.id;


--
-- Name: const; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE const (
    id integer NOT NULL,
    name text,
    value text
);


ALTER TABLE public.const OWNER TO wendy;

--
-- Name: const_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE const_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.const_id_seq OWNER TO wendy;

--
-- Name: const_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE const_id_seq OWNED BY const.id;


--
-- Name: host; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE host (
    id integer NOT NULL,
    host character varying(128),
    defaultlng integer DEFAULT 1
);


ALTER TABLE public.host OWNER TO wendy;

--
-- Name: host_alias; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE host_alias (
    id integer NOT NULL,
    host integer,
    alias character varying(128) NOT NULL
);


ALTER TABLE public.host_alias OWNER TO wendy;

--
-- Name: host_alias_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE host_alias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.host_alias_id_seq OWNER TO wendy;

--
-- Name: host_alias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE host_alias_id_seq OWNED BY host_alias.id;


--
-- Name: host_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE host_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.host_id_seq OWNER TO wendy;

--
-- Name: host_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE host_id_seq OWNED BY host.id;


--
-- Name: hostlanguage; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE hostlanguage (
    id integer NOT NULL,
    host integer,
    lng integer DEFAULT 1
);


ALTER TABLE public.hostlanguage OWNER TO wendy;

--
-- Name: hostlanguage_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE hostlanguage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hostlanguage_id_seq OWNER TO wendy;

--
-- Name: hostlanguage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE hostlanguage_id_seq OWNED BY hostlanguage.id;


--
-- Name: language; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE language (
    id integer NOT NULL,
    lng character varying(8),
    descr character varying(32)
);


ALTER TABLE public.language OWNER TO wendy;

--
-- Name: language_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.language_id_seq OWNER TO wendy;

--
-- Name: language_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE language_id_seq OWNED BY language.id;


--
-- Name: macros; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE macros (
    id integer NOT NULL,
    name character varying(64),
    body text,
    istext boolean DEFAULT true,
    host integer,
    address character varying(256),
    lng integer,
    created timestamp without time zone DEFAULT now(),
    accessed timestamp without time zone,
    active boolean DEFAULT true NOT NULL,
    ac integer DEFAULT 0 NOT NULL,
    CONSTRAINT m_chk CHECK (((name)::text ~ '^[A-Z_0-9-]+$'::text))
);


ALTER TABLE public.macros OWNER TO wendy;

--
-- Name: macros_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE macros_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.macros_id_seq OWNER TO wendy;

--
-- Name: macros_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE macros_id_seq OWNED BY macros.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE messages (
    id integer NOT NULL,
    subject text,
    content text,
    author integer,
    posted timestamp without time zone DEFAULT now(),
    thread integer,
    modified timestamp without time zone,
    pinned_img text
);


ALTER TABLE public.messages OWNER TO wendy;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messages_id_seq OWNER TO wendy;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: perlproc; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE perlproc (
    id integer NOT NULL,
    name character varying(64),
    body text
);


ALTER TABLE public.perlproc OWNER TO wendy;

--
-- Name: perlproc_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE perlproc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.perlproc_id_seq OWNER TO wendy;

--
-- Name: perlproc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE perlproc_id_seq OWNED BY perlproc.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE permissions (
    id integer NOT NULL,
    title text,
    post_messages boolean DEFAULT true,
    edit_messages boolean DEFAULT false,
    delete_messages boolean DEFAULT false,
    create_threads boolean DEFAULT true,
    edit_threads boolean DEFAULT false,
    delete_threads boolean DEFAULT false,
    vote boolean DEFAULT true,
    use_adminka boolean DEFAULT false
);


ALTER TABLE public.permissions OWNER TO wendy;

--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.permissions_id_seq OWNER TO wendy;

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    user_id integer,
    session_key text,
    expires timestamp without time zone
);


ALTER TABLE public.sessions OWNER TO wendy;

--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sessions_id_seq OWNER TO wendy;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: threads; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE threads (
    id integer NOT NULL,
    title text,
    created timestamp without time zone DEFAULT now(),
    content text,
    author integer,
    updated timestamp without time zone,
    modified timestamp without time zone,
    pinned_img text,
    vote_question text,
    vote boolean
);


ALTER TABLE public.threads OWNER TO wendy;

--
-- Name: threads_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE threads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.threads_id_seq OWNER TO wendy;

--
-- Name: threads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE threads_id_seq OWNED BY threads.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name text,
    password text,
    email text,
    registered timestamp without time zone DEFAULT now(),
    avatar text DEFAULT ''::text,
    permission_id integer DEFAULT 1,
    banned boolean DEFAULT false,
    deleted boolean DEFAULT false
);


ALTER TABLE public.users OWNER TO wendy;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO wendy;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE votes (
    id integer NOT NULL,
    voting_option integer,
    user_id integer
);


ALTER TABLE public.votes OWNER TO wendy;

--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.votes_id_seq OWNER TO wendy;

--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


--
-- Name: voting_options; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE voting_options (
    id integer NOT NULL,
    title text,
    thread integer
);


ALTER TABLE public.voting_options OWNER TO wendy;

--
-- Name: voting_options_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE voting_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.voting_options_id_seq OWNER TO wendy;

--
-- Name: voting_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE voting_options_id_seq OWNED BY voting_options.id;


--
-- Name: wemodule; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE wemodule (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    host integer
);


ALTER TABLE public.wemodule OWNER TO wendy;

--
-- Name: wemodule_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE wemodule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wemodule_id_seq OWNER TO wendy;

--
-- Name: wemodule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE wemodule_id_seq OWNED BY wemodule.id;


--
-- Name: weuser; Type: TABLE; Schema: public; Owner: wendy; Tablespace: 
--

CREATE TABLE weuser (
    id integer NOT NULL,
    login character varying(32),
    password character varying(32),
    host integer,
    flag integer DEFAULT 0
);


ALTER TABLE public.weuser OWNER TO wendy;

--
-- Name: weuser_id_seq; Type: SEQUENCE; Schema: public; Owner: wendy
--

CREATE SEQUENCE weuser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.weuser_id_seq OWNER TO wendy;

--
-- Name: weuser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wendy
--

ALTER SEQUENCE weuser_id_seq OWNED BY weuser.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_ban_users_of ALTER COLUMN id SET DEFAULT nextval('can_ban_users_of_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_delete_messages_of ALTER COLUMN id SET DEFAULT nextval('can_delete_messages_of_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_delete_threads_of ALTER COLUMN id SET DEFAULT nextval('can_delete_threads_of_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_edit_messages_of ALTER COLUMN id SET DEFAULT nextval('can_edit_messages_of_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_edit_threads_of ALTER COLUMN id SET DEFAULT nextval('can_edit_threads_of_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY const ALTER COLUMN id SET DEFAULT nextval('const_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY host ALTER COLUMN id SET DEFAULT nextval('host_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY host_alias ALTER COLUMN id SET DEFAULT nextval('host_alias_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY hostlanguage ALTER COLUMN id SET DEFAULT nextval('hostlanguage_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY language ALTER COLUMN id SET DEFAULT nextval('language_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY macros ALTER COLUMN id SET DEFAULT nextval('macros_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY perlproc ALTER COLUMN id SET DEFAULT nextval('perlproc_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY threads ALTER COLUMN id SET DEFAULT nextval('threads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY voting_options ALTER COLUMN id SET DEFAULT nextval('voting_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY wemodule ALTER COLUMN id SET DEFAULT nextval('wemodule_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY weuser ALTER COLUMN id SET DEFAULT nextval('weuser_id_seq'::regclass);


--
-- Data for Name: can_ban_users_of; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY can_ban_users_of (id, permission_id, users_of_permission_id) FROM stdin;
1	3	1
2	2	1
3	2	3
\.


--
-- Name: can_ban_users_of_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('can_ban_users_of_id_seq', 1, false);


--
-- Data for Name: can_delete_messages_of; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY can_delete_messages_of (id, permission_id, messages_of_permission_id) FROM stdin;
1	3	1
2	2	1
3	2	3
\.


--
-- Name: can_delete_messages_of_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('can_delete_messages_of_id_seq', 1, false);


--
-- Data for Name: can_delete_threads_of; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY can_delete_threads_of (id, permission_id, threads_of_permission_id) FROM stdin;
1	3	1
2	2	1
3	2	3
\.


--
-- Name: can_delete_threads_of_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('can_delete_threads_of_id_seq', 1, false);


--
-- Data for Name: can_edit_messages_of; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY can_edit_messages_of (id, permission_id, messages_of_permission_id) FROM stdin;
1	3	1
2	2	1
3	2	3
\.


--
-- Name: can_edit_messages_of_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('can_edit_messages_of_id_seq', 1, false);


--
-- Data for Name: can_edit_threads_of; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY can_edit_threads_of (id, permission_id, threads_of_permission_id) FROM stdin;
1	3	1
2	2	1
3	2	3
\.


--
-- Name: can_edit_threads_of_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('can_edit_threads_of_id_seq', 1, false);


--
-- Data for Name: const; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY const (id, name, value) FROM stdin;
3	avatar_max_filesize	10000000000
5	pinned_image_max_filesize	10000000000
7	messages_on_page	5
8	thread_title_max_length	50
9	vote_question_max_length	50
10	message_subject_max_length	50
13	num_of_adminka_users_cols	5
16	arrowdown_width	10
17	arrowdown_height	10
18	arrow_image_width	10
19	arrow_image_height	10
21	users_on_page	10
14	arrowup_image	arrowup.jpg
15	arrowdown_image	arrowdown.jpg
11	proper_image_filetypes	jpeg, png
2	avatars_dir	/static/img/avatars
4	images_dir	/static/img/
6	pinned_images_dir	/static/img/pinned/
12	images_tmp_dir	/static/img/tmp/
1	session_expires_after	3000
20	icon_delete	icon_delete.png
\.


--
-- Name: const_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('const_id_seq', 21, true);


--
-- Data for Name: host; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY host (id, host, defaultlng) FROM stdin;
1	localhost	1
2	mzavoloka.ru	1
\.


--
-- Data for Name: host_alias; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY host_alias (id, host, alias) FROM stdin;
\.


--
-- Name: host_alias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('host_alias_id_seq', 1, false);


--
-- Name: host_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('host_id_seq', 1, true);


--
-- Data for Name: hostlanguage; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY hostlanguage (id, host, lng) FROM stdin;
1	1	1
2	2	1
3	2	2
\.


--
-- Name: hostlanguage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('hostlanguage_id_seq', 1, true);


--
-- Data for Name: language; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY language (id, lng, descr) FROM stdin;
1	en	English
2	ru	Russian
3	fr	French
4	de	German
5	ja	Japanese
6	cn	Chinese
7	et	Estonian
8	ua	Ukrainian
9	es	Spanish
\.


--
-- Name: language_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('language_id_seq', 9, true);


--
-- Data for Name: macros; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY macros (id, name, body, istext, host, address, lng, created, accessed, active, ac) FROM stdin;
473	OPTION	Опция	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
474	SOME_USERS_ALREADY_VOTED_FOR_THIS_OPTION	Some users already voted for this option	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
475	SOME_USERS_ALREADY_VOTED_FOR_THIS_OPTION	Некоторые пользователи уже проголосовали за эту опцию	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
476	DELETE	Delete	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
477	DELETE	Удалить	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
478	ADD_OPTION	Add option	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
479	ADD_OPTION	Добавить опцию	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
480	EDIT	Edit	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
481	EDIT	Редактировать	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
482	BACK_TO_THREAD	Back to thread	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
483	BACK_TO_THREAD	Вернуться в тред	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
484	CREATE	Create	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
485	CREATE	Создать	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
486	NUMBER_OF_REQUESTED_THREAD	Number of requested thread	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
487	NUMBER_OF_REQUESTED_THREAD	Номер запрашиваемого треда	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
488	THREAD	thread	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
489	THREAD	тред	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
490	CREATED_BY	created by	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
491	CREATED_BY	создал	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
492	YOUR_CHOICE	your choice	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
493	YOUR_CHOICE	ваш выбор	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
494	VOTES	Votes	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
495	VOTES	Голосов	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
496	VOTE	Vote	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
497	VOTE	Проголосовать	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
498	MESSAGE_HAS_BEEN_MODIFIED	Message has been modified	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
499	MESSAGE_HAS_BEEN_MODIFIED	Сообщение было отредактировано	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
500	AVATAR	Avatar	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
501	AVATAR	Аватарка	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
502	VOTED	Voted	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
503	VOTED	Проголосовал	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
504	REPLY	Reply	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
505	REPLY	Ответить	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
506	POSTED_BY	posted by	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
507	POSTED_BY	отправил	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
508	PAGES	Pages	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
509	PAGES	Страницы:	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
512	REGISTER	Register	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
514	NAME	Name	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
515	NAME	Имя	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
516	EMAIL	Email	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
517	EMAIL	Email	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
518	PASSWORD	Password	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
519	PASSWORD	Пароль	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
520	CONFIRM	Confirm	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
521	CONFIRM	Подтверждение	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
522	BACK	Back	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
523	BACK	Назад	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
524	USER_BANNED	User banned	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
525	USER_BANNED	Пользователь забанен	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
526	UNBAN	Unban	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
527	UNBAN	Разбанить	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
528	BAN	Ban	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
529	BAN	Забанить	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
530	ITS_YOU	It's you	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
531	ITS_YOU	Это вы	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
532	PERMISSIONS	Permissions	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
533	PERMISSIONS	Права	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
534	REGISTRATION_DATE	Registration date	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
535	REGISTRATION_DATE	Дата регистрации	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
536	CHANGE	Change	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
537	CHANGE	Изменить	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
538	NUMBER_OF_MESSAGES	Number of messages	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
539	NUMBER_OF_MESSAGES	Количество сообщений	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
540	NUMBER_OF_CREATED_THREADS	Number of created threads	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
541	NUMBER_OF_CREATED_THREADS	Создано тредов	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
542	UPLOAD_AVATAR	Upload avatar	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
543	UPLOAD_AVATAR	Загрузить аватарку	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
544	UPLOAD	Upload	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
545	UPLOAD	Загрузить	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
546	CHANGE_PASSWORD	Change password	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
547	CHANGE_PASSWORD	Изменить пароль	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
548	VIEW_PROFILE_OF_USER	View profile of user	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
549	VIEW_PROFILE_OF_USER	Просмотреть профиль пользователя	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
550	VIEW_YOUR_PROFILE	View your profile	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
551	VIEW_YOUR_PROFILE	Открыть свой профиль	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
552	EDIT_MESSAGE	Edit message	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
513	REGISTER	Зарегистрироваться	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
553	EDIT_MESSAGE	Редактировать сообщение	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
554	SUBJECT	Subject	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
560	ENTER_YOUR_LOGIN_AND_PASSWORD	Enter your login and password	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
561	ENTER_YOUR_LOGIN_AND_PASSWORD	Введите ваш логин и пароль	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
562	MIKHAIL_ZAVOLOKA	Mikhail Zavoloka	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
563	MIKHAIL_ZAVOLOKA	Михаил Заволока	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
564	PASSWORD_CHANGE	Password change	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
565	PASSWORD_CHANGE	Изменение пароля	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
566	ENTER_CURRENT_PASSWORD	Enter current password	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
567	ENTER_CURRENT_PASSWORD	Введите текущий пароль	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
568	ENTER_NEW_PASSWORD	Enter new password	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
569	ENTER_NEW_PASSWORD	Введите новый пароль	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
570	CONFIRM_NEW_PASSWORD	Confirm new passworn	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
571	CONFIRM_NEW_PASSWORD	Подтвердите новый пароль	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
572	FORUM_SETTINGS	Forum settings	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
573	FORUM_SETTINGS	Настройки форума	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
574	EDIT_USERS	Edit users	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
575	EDIT_USERS	Редактирование пользователей	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
576	EDIT_PERMISSIONS	Edit permissions	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
577	EDIT_PERMISSIONS	Редактирование прав	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
578	ALL_CONSTANTS	All constants	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
579	ALL_CONSTANTS	Все константы	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
580	VALUE	Value	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
581	VALUE	Значение	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
582	CANCEL	Cancel	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
583	CANCEL	Отмена	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
584	ADD	Add	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
585	ADD	Добавить	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
586	SAVE	Save	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
587	SAVE	Сохранить	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
588	TO_ADMIN_MAINPAGE	To admin mainpage	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
589	TO_ADMIN_MAINPAGE	На главную админки	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
590	TO_FORUM_MAINPAGE	To forum mainpage	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
591	TO_FORUM_MAINPAGE	На главную форума	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
592	CREATE_NEW_USER	Create new user	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
593	CREATE_NEW_USER	Создание нового пользователя	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
594	ID	Id	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
595	ID	Id	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
596	BANNED	Banned	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
597	BANNED	Забанен	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
598	APPLY_CHANGES	Apply changes	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
599	APPLY_CHANGES	Применить изменения	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
600	ALL_USERS	All users	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
601	ALL_USERS	Все пользователи	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
602	USER	User	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
603	USER	Пользователь	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
604	DELETE_USER	Delete user	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
605	DELETE_USER	Удалить пользователя	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
606	USER_LIST	User list	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
607	USER_LIST	Список пользователей	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
608	REGISTERED	Registered	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
609	REGISTERED	Зарегистрирован	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
610	OT	from	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
611	OT	от	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
612	PO	to	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
613	PO	по	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
614	DO	to	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
615	DO	до	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
616	ANY_MULTIPLE	Any	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
617	ANY_MULTIPLE	Любые	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
618	CREATE_USER	Create user	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
619	CREATE_USER	Создать пользователя	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
620	RESET	Reset	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
621	RESET	Сброс	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
622	SEARCH	Search	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
623	SEARCH	Искать	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
624	COLUMNS	Columns	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
625	COLUMNS	Колонок	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
626	NO_MORE_ITS_ENOUGH_ALREADY	No more. It's enough already	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
627	NO_MORE_ITS_ENOUGH_ALREADY	Все, больше нельзя. И так уже много	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
2	ANY_TEST_MACROS	This is ANY address test macros.	t	2	ANY	1	2015-03-12 14:48:05.511113	\N	t	0
438	FORUM	Forum	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
439	FORUM	Форум	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
440	YOU_ARE_NOT_AUTHORIZED	You are not authorized	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
441	YOU_ARE_NOT_AUTHORIZED	Вы не авторизованы	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
442	ADMINKA	Adminka	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
443	ADMINKA	Админка	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
444	CREATE_THREAD	Create thread	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
445	CREATE_THREAD	Создать тред	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
446	PROFILE	Profile	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
447	PROFILE	Профиль	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
448	SIGN_OUT	Sign out	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
449	SIGN_OUT	Выход	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
450	SIGN_UP	Sign up	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
451	SIGN_UP	Зарегистрироваться	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
452	SIGN_IN	Sign in	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
453	SIGN_IN	Войти	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
454	TO_MAINPAGE	To mainpage	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
455	TO_MAINPAGE	На главную	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
456	EDIT_THREAD	Edit thread	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
457	EDIT_THREAD	Редактировать тред	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
458	HEADER	Header	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
459	HEADER	Заголовок	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
460	THREAD_IS_ABOUT	Thread is about	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
461	THREAD_IS_ABOUT	О чем тред	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
462	PINNED_IMAGE	Pinned image	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
463	PINNED_IMAGE	Прикрепленное изображение	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
464	PIN_IMAGE	Pin image	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
465	PIN_IMAGE	Прикрепить изображение	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
466	VOTING	Voting	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
467	VOTING	Голосование	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
468	QUESTION	Question	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
469	QUESTION	Вопрос	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
470	SOME_USERS_ALREADY_PARTICIPATED_IN_THIS_VOTING	Some users already participated in this voting	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
471	SOME_USERS_ALREADY_PARTICIPATED_IN_THIS_VOTING	Некоторые пользователи уже проголосовали в этом опросе	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
472	OPTION	Option	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
510	REPLY_TO_THREAD	Reply to thread	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
511	REPLY_TO_THREAD	Ответить в тред	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
634	CREATE_NEW_THREAD	Create new thread	t	2	ANY	1	2015-03-16 18:12:24.147298	\N	t	0
635	CREATE_NEW_THREAD	Создать новый тред	t	2	ANY	2	2015-03-16 18:12:24.147298	\N	t	0
555	SUBJECT	Тема	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
556	MESSAGE_BODY	Message body	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
557	MESSAGE_BODY	Текст сообщения	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
558	MESSAGE	message	t	2	ANY	1	2015-03-16 02:19:10.657295	\N	t	0
559	MESSAGE	сообщение	t	2	ANY	2	2015-03-16 02:19:10.657295	\N	t	0
\.


--
-- Name: macros_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('macros_id_seq', 635, true);


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY messages (id, subject, content, author, posted, thread, modified, pinned_img) FROM stdin;
2	asdfqfe	OMG, I can't delete or edit your message!!! That sucks.	6	2015-03-16 18:34:07	2	2015-03-16 18:35:59	59728540560460027360
3	your message was modifed	I modified your message.	6	2015-03-16 18:41:34	5	\N	70248148922276468366
4	Just making some flame to reach another page	Just making some flame to reach another page 1	7	2015-03-16 19:32:12.337526	6	\N	\N
5	Just making some flame to reach another page	Just making some flame to reach another page 2	7	2015-03-16 19:32:21.739399	6	\N	\N
6	Just making some flame to reach another page	Just making some flame to reach another page 3	7	2015-03-16 19:32:29.453113	6	\N	\N
7	Just making some flame to reach another page	Just making some flame to reach another page 4	7	2015-03-16 19:32:43.988215	6	\N	\N
8	Just making some flame to reach another page	Just making some flame to reach another page 5	7	2015-03-16 19:32:54.480288	6	\N	\N
9	Just making some flame to reach another page	Just making some flame to reach another page 6	7	2015-03-16 19:33:02.152157	6	\N	\N
10	Just making some flame to reach another page	Just making some flame to reach another page 7	7	2015-03-16 19:33:11.549058	6	\N	\N
11	Lol	And now you're banned for flame! AHAHAHA.	6	2015-03-16 19:44:17	6	\N	83666506148171667525
\.


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('messages_id_seq', 11, true);


--
-- Data for Name: perlproc; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY perlproc (id, name, body) FROM stdin;
1	rand_num	return rand();
\.


--
-- Name: perlproc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('perlproc_id_seq', 1, true);


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY permissions (id, title, post_messages, edit_messages, delete_messages, create_threads, edit_threads, delete_threads, vote, use_adminka) FROM stdin;
1	regular	t	f	f	t	f	f	t	f
2	admin	t	t	t	t	t	t	t	t
3	moderator	t	t	t	t	t	t	t	f
\.


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('permissions_id_seq', 1, true);


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY sessions (id, user_id, session_key, expires) FROM stdin;
1	1	rfdscAy1bzuq7n0F91OsFQ	2014-12-18 22:02:31
2	1	ZwZbs/GsLqB99dw8SHyiOQ	2014-12-18 22:03:05
3	1	2tECcprLUYbC54+/vSTQIg	2014-12-18 22:09:46
4	1	8avBNuoEom14ScvWbx1VvA	2014-12-18 22:12:42
5	2	WsiQ//buyvISA5mBNuoMGQ	2014-12-27 23:14:05
6	3	ksAm5cHB2g1QzPyJr1FDDA	2014-12-27 23:15:46
7	3	P7A0hMX7ExWx0NTJcg3P9Q	2014-12-27 23:15:52
8	3	GMvwP0z/YjnorTqygLOK0w	2015-03-11 15:56:31
9	3	RJTp0J/1+BMXeHhpD5Aifw	2015-03-11 15:57:27
10	3	Spn3C29ZYVd3PLyHl6oCjg	2015-03-11 16:04:30
11	3	yQPkTzzRY5scG4n/GaMo3w	2015-03-11 16:05:53
12	3	pOuE7y4Uhmolgz7odu7mSA	2015-03-11 16:06:24
13	3	/AYEYDvMh+BVsKmppiLBeg	2015-03-11 16:09:21
14	3	oo53YyT0bod6Db5ecxEcVw	2015-03-11 16:11:26
15	3	/X9OiEPF+wAbliNC9cv6Bg	2015-03-11 16:13:38
16	3	Z2GEowMae0+G1526zU2Mow	2015-03-11 23:06:13
17	3	n5uXuVWVRVgURyHr2Gf5/w	2015-03-11 23:07:04
18	3	hgW18eig7KcknOg002b4bA	2015-03-11 23:07:10
19	3	k8oi+dfoF0pq4TBjWXW6nA	2015-03-11 23:08:47
20	3	8O5i2rBDnTMF9x5ZwN6fnQ	2015-03-11 23:30:02
21	3	ICj4BYRA6qhJl7msTA+tEQ	2015-03-11 23:42:23
22	3	oOKOiRqlCaEb+QPWU3QYwg	2015-03-11 23:45:35
24	3	nmfaEIZPQnMGSEooBgBiXg	2015-03-11 23:55:11
25	3	t0DnfWOFGhOR+fy3jrGsFw	2015-03-11 23:55:18
26	3	xqQjVMwcKu6qKojQVY7EOQ	2015-03-11 23:55:48
28	3	+XUBCwX0LH+M3W3Xqzd3JQ	2015-03-11 23:57:36
29	3	FbKTqpCt2ctEyeZt1Ac+Ug	2015-03-11 23:59:47
30	3	rimTyQbO17ZJOQoBq682kA	2015-03-11 23:59:53
31	3	5bkCpjuBjFsHJjZ87LFm/g	2015-03-12 00:00:31
32	3	JdXPpWR+HC3OfHPyPgf5MQ	2015-03-12 00:00:55
33	3	ExP3sXmeP5YP/TyNpCzHtw	2015-03-12 00:02:07
34	3	ZBotxqxkhMfHIG/vYW9O2Q	2015-03-12 00:03:16
35	3	35bccLpPuOGJTUsvYg5biQ	2015-03-12 00:03:45
36	3	WxFPcVMl/MHyiG0RebofKA	2015-03-12 00:05:57
53	5	8PJ9sjpS0UgM7Av0aVKPMg	2015-03-16 20:54:22
43	4	yEKUJVlZGpGgIxueBi+74w	2015-03-14 14:45:03
54	3	B8f4YkqYjwpA0reLXwthRQ	2015-03-19 18:27:00
\.


--
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('sessions_id_seq', 54, true);


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY threads (id, title, created, content, author, updated, modified, pinned_img, vote_question, vote) FROM stdin;
1	Some new thread	2015-03-13 09:03:09	asdfsadfsdf	3	2015-03-14 14:37:56	\N	\N		\N
2	jasdpoojpiqj	2015-03-16 16:58:28	ds ljf;sdjf irgjvxc</textarea><script>alert(1)</script>	5	2015-03-16 18:34:07	\N	\N		\N
5	Soaf	2015-03-16 17:55:09	sfsadfsadfsdfdf	3	2015-03-16 18:43:32	2015-03-16 18:43:32	42179715708753355497	are you  ??	\N
6	af	2015-03-16 18:43:44	sdfsdf	6	2015-03-16 19:44:17	\N	\N	sdf	t
7	Sadf	2015-03-16 20:01:32	sdfdsf	7	2015-03-16 20:01:32	\N	82479330447265580708	fsadf	t
\.


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('threads_id_seq', 7, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY users (id, name, password, email, registered, avatar, permission_id, banned, deleted) FROM stdin;
1	123	123	123@123.dsf	2014-12-18 21:57:31		1	f	f
2	sadf	asdf	asd@fdsaf.f	2014-12-27 23:09:05		1	f	f
3	asdf	asdf	asdf@as.dfa	2014-12-27 23:10:46		1	f	f
4	new_user	new_user	new@mail.user	2015-03-14 14:39:23		1	f	f
5	admin	admin	ad@mi.n	2015-03-16 16:50:02		2	f	f
6	moderator	moderator	mod@er.atorf	2015-03-16 18:28:37	6	3	f	f
7	qwer	qwer	q@w.er	2015-03-16 19:31:25		1	t	f
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('users_id_seq', 7, true);


--
-- Data for Name: votes; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY votes (id, voting_option, user_id) FROM stdin;
1	9	6
2	9	3
3	10	5
\.


--
-- Name: votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('votes_id_seq', 3, true);


--
-- Data for Name: voting_options; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY voting_options (id, title, thread) FROM stdin;
7	asdf	5
8	sdf	5
9	sadf	6
10	sdf	6
11	sdfsadf	7
12	sdfsdf	7
13	sdfsadf	7
\.


--
-- Name: voting_options_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('voting_options_id_seq', 13, true);


--
-- Data for Name: wemodule; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY wemodule (id, name, host) FROM stdin;
\.


--
-- Name: wemodule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('wemodule_id_seq', 1, false);


--
-- Data for Name: weuser; Type: TABLE DATA; Schema: public; Owner: wendy
--

COPY weuser (id, login, password, host, flag) FROM stdin;
1	root	itsme	1	0
\.


--
-- Name: weuser_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wendy
--

SELECT pg_catalog.setval('weuser_id_seq', 1, true);


--
-- Name: can_ban_users_of_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY can_ban_users_of
    ADD CONSTRAINT can_ban_users_of_pkey PRIMARY KEY (id);


--
-- Name: can_delete_messages_of_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY can_delete_messages_of
    ADD CONSTRAINT can_delete_messages_of_pkey PRIMARY KEY (id);


--
-- Name: can_delete_threads_of_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY can_delete_threads_of
    ADD CONSTRAINT can_delete_threads_of_pkey PRIMARY KEY (id);


--
-- Name: can_edit_messages_of_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY can_edit_messages_of
    ADD CONSTRAINT can_edit_messages_of_pkey PRIMARY KEY (id);


--
-- Name: can_edit_threads_of_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY can_edit_threads_of
    ADD CONSTRAINT can_edit_threads_of_pkey PRIMARY KEY (id);


--
-- Name: const_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY const
    ADD CONSTRAINT const_pkey PRIMARY KEY (id);


--
-- Name: hl_uniq; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY hostlanguage
    ADD CONSTRAINT hl_uniq UNIQUE (host, lng);


--
-- Name: host_alias_alias_key; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY host_alias
    ADD CONSTRAINT host_alias_alias_key UNIQUE (alias);


--
-- Name: host_alias_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY host_alias
    ADD CONSTRAINT host_alias_pkey PRIMARY KEY (id);


--
-- Name: host_host_key; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY host
    ADD CONSTRAINT host_host_key UNIQUE (host);


--
-- Name: host_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY host
    ADD CONSTRAINT host_pkey PRIMARY KEY (id);


--
-- Name: hostlanguage_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY hostlanguage
    ADD CONSTRAINT hostlanguage_pkey PRIMARY KEY (id);


--
-- Name: language_lng_key; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_lng_key UNIQUE (lng);


--
-- Name: language_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_pkey PRIMARY KEY (id);


--
-- Name: m_uni; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY macros
    ADD CONSTRAINT m_uni UNIQUE (name, host, address, lng);


--
-- Name: macros_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY macros
    ADD CONSTRAINT macros_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: mod_uni; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY wemodule
    ADD CONSTRAINT mod_uni UNIQUE (name, host);


--
-- Name: perlproc_name_key; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY perlproc
    ADD CONSTRAINT perlproc_name_key UNIQUE (name);


--
-- Name: perlproc_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY perlproc
    ADD CONSTRAINT perlproc_pkey PRIMARY KEY (id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: threads_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: voting_options_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY voting_options
    ADD CONSTRAINT voting_options_pkey PRIMARY KEY (id);


--
-- Name: wemodule_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY wemodule
    ADD CONSTRAINT wemodule_pkey PRIMARY KEY (id);


--
-- Name: weuser_login_key; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY weuser
    ADD CONSTRAINT weuser_login_key UNIQUE (login);


--
-- Name: weuser_pkey; Type: CONSTRAINT; Schema: public; Owner: wendy; Tablespace: 
--

ALTER TABLE ONLY weuser
    ADD CONSTRAINT weuser_pkey PRIMARY KEY (id);


--
-- Name: active_idx; Type: INDEX; Schema: public; Owner: wendy; Tablespace: 
--

CREATE INDEX active_idx ON macros USING btree (active);


--
-- Name: address_idx; Type: INDEX; Schema: public; Owner: wendy; Tablespace: 
--

CREATE INDEX address_idx ON macros USING btree (address);


--
-- Name: host_idx; Type: INDEX; Schema: public; Owner: wendy; Tablespace: 
--

CREATE INDEX host_idx ON macros USING btree (host);


--
-- Name: lng_idx; Type: INDEX; Schema: public; Owner: wendy; Tablespace: 
--

CREATE INDEX lng_idx ON macros USING btree (lng);


--
-- Name: can_ban_users_of_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_ban_users_of
    ADD CONSTRAINT can_ban_users_of_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions(id);


--
-- Name: can_ban_users_of_users_of_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_ban_users_of
    ADD CONSTRAINT can_ban_users_of_users_of_permission_id_fkey FOREIGN KEY (users_of_permission_id) REFERENCES permissions(id);


--
-- Name: can_delete_messages_of_messages_of_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_delete_messages_of
    ADD CONSTRAINT can_delete_messages_of_messages_of_permission_id_fkey FOREIGN KEY (messages_of_permission_id) REFERENCES permissions(id);


--
-- Name: can_delete_messages_of_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_delete_messages_of
    ADD CONSTRAINT can_delete_messages_of_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions(id);


--
-- Name: can_delete_threads_of_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_delete_threads_of
    ADD CONSTRAINT can_delete_threads_of_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions(id);


--
-- Name: can_delete_threads_of_threads_of_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_delete_threads_of
    ADD CONSTRAINT can_delete_threads_of_threads_of_permission_id_fkey FOREIGN KEY (threads_of_permission_id) REFERENCES permissions(id);


--
-- Name: can_edit_messages_of_messages_of_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_edit_messages_of
    ADD CONSTRAINT can_edit_messages_of_messages_of_permission_id_fkey FOREIGN KEY (messages_of_permission_id) REFERENCES permissions(id);


--
-- Name: can_edit_messages_of_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_edit_messages_of
    ADD CONSTRAINT can_edit_messages_of_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions(id);


--
-- Name: can_edit_threads_of_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_edit_threads_of
    ADD CONSTRAINT can_edit_threads_of_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions(id);


--
-- Name: can_edit_threads_of_threads_of_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY can_edit_threads_of
    ADD CONSTRAINT can_edit_threads_of_threads_of_permission_id_fkey FOREIGN KEY (threads_of_permission_id) REFERENCES permissions(id);


--
-- Name: host_alias_host_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY host_alias
    ADD CONSTRAINT host_alias_host_fkey FOREIGN KEY (host) REFERENCES host(id);


--
-- Name: host_defaultlng_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY host
    ADD CONSTRAINT host_defaultlng_fkey FOREIGN KEY (defaultlng) REFERENCES language(id);


--
-- Name: hostlanguage_host_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY hostlanguage
    ADD CONSTRAINT hostlanguage_host_fkey FOREIGN KEY (host) REFERENCES host(id);


--
-- Name: hostlanguage_lng_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY hostlanguage
    ADD CONSTRAINT hostlanguage_lng_fkey FOREIGN KEY (lng) REFERENCES language(id);


--
-- Name: macros_host_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY macros
    ADD CONSTRAINT macros_host_fkey FOREIGN KEY (host) REFERENCES host(id);


--
-- Name: macros_lng_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY macros
    ADD CONSTRAINT macros_lng_fkey FOREIGN KEY (lng) REFERENCES language(id);


--
-- Name: messages_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_author_fkey FOREIGN KEY (author) REFERENCES users(id);


--
-- Name: messages_thread_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_thread_fkey FOREIGN KEY (thread) REFERENCES threads(id);


--
-- Name: sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: threads_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_author_fkey FOREIGN KEY (author) REFERENCES users(id);


--
-- Name: users_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions(id);


--
-- Name: votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: votes_voting_option_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_voting_option_fkey FOREIGN KEY (voting_option) REFERENCES voting_options(id);


--
-- Name: voting_options_thread_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY voting_options
    ADD CONSTRAINT voting_options_thread_fkey FOREIGN KEY (thread) REFERENCES threads(id);


--
-- Name: wemodule_host_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY wemodule
    ADD CONSTRAINT wemodule_host_fkey FOREIGN KEY (host) REFERENCES host(id);


--
-- Name: weuser_host_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wendy
--

ALTER TABLE ONLY weuser
    ADD CONSTRAINT weuser_host_fkey FOREIGN KEY (host) REFERENCES host(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

