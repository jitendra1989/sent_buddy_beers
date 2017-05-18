--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bars; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bars (
    id integer NOT NULL,
    name character varying(255),
    address character varying(255),
    affiliate_id integer,
    token character varying(255),
    default_currency character varying(3) DEFAULT 'EUR'::character varying,
    lat numeric(15,10),
    lng numeric(15,10),
    phone_number character varying(255),
    description text,
    logo_file_name character varying(255),
    logo_content_type character varying(255),
    logo_file_size integer,
    logo_updated_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    percent_cut integer DEFAULT 70,
    percent_expired_cut integer DEFAULT 100,
    active boolean DEFAULT false,
    country_id integer,
    city_id integer,
    contact_name character varying(255),
    lead character varying(255),
    contact_email character varying(255),
    url character varying(255),
    customer_voucher_limit integer DEFAULT 0 NOT NULL,
    internet_enabled boolean,
    bro_id integer,
    outstanding_ious_count integer DEFAULT 0 NOT NULL,
    pending boolean DEFAULT true NOT NULL,
    opening_hours text,
    cached_slug character varying(255),
    twitter_handle character varying(255)
);


--
-- Name: bars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bars_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bars_id_seq OWNED BY bars.id;


--
-- Name: beers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE beers (
    id integer NOT NULL,
    name character varying(255),
    brand_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    drink_type_id integer,
    volume character varying(255)
);


--
-- Name: beers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE beers_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: beers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE beers_id_seq OWNED BY beers.id;


--
-- Name: beverages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE beverages (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: beverages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE beverages_id_seq
    START WITH 2
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: beverages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE beverages_id_seq OWNED BY beverages.id;


--
-- Name: brands; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brands (
    id integer NOT NULL,
    name character varying(255),
    beverage_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: brands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brands_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: brands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brands_id_seq OWNED BY brands.id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cities (
    id integer NOT NULL,
    name character varying(255),
    country_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cities_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: cities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cities_id_seq OWNED BY cities.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    iso character varying(255),
    name character varying(255),
    printable_name character varying(255),
    iso3 character varying(255),
    numcode integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE countries_id_seq
    START WITH 227
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: credit_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE credit_events (
    id integer NOT NULL,
    user_id integer,
    pegged_currency_amount_iso_currency_code character varying(255),
    premium_currency_amount character varying(255),
    offer_id character varying(255),
    socialgold_transaction_id character varying(255),
    net_payout_amount character varying(255),
    cc_token character varying(255),
    billing_country_code character varying(255),
    simulated boolean DEFAULT false NOT NULL,
    pegged_currency_amount character varying(255),
    offer_amount character varying(255),
    socialgold_transaction_status character varying(255),
    amount character varying(255),
    pegged_currency_label character varying(255),
    version character varying(255),
    premium_currency_label character varying(255),
    offer_amount_iso_currency_code character varying(255),
    billing_zip character varying(255),
    user_balance character varying(255),
    event_type character varying(255),
    external_ref_id character varying(255),
    "timestamp" character varying(255),
    signature character varying(255),
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: credit_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE credit_events_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: credit_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE credit_events_id_seq OWNED BY credit_events.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: drink_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE drink_types (
    id integer NOT NULL,
    beverage_id integer,
    type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: drink_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE drink_types_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: drink_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE drink_types_id_seq OWNED BY drink_types.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE emails (
    id integer NOT NULL,
    user_id integer,
    email character varying(255) NOT NULL,
    "primary" boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    pending boolean DEFAULT true NOT NULL,
    token character varying(255),
    notified boolean DEFAULT false NOT NULL
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE emails_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE emails_id_seq OWNED BY emails.id;


--
-- Name: galleries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE galleries (
    id integer NOT NULL,
    attachable_id integer,
    attachable_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: galleries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE galleries_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: galleries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE galleries_id_seq OWNED BY galleries.id;


--
-- Name: ious; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ious (
    id integer NOT NULL,
    recipient_id integer,
    recipient_name character varying(255),
    sender_id integer,
    sender_name character varying(255),
    beverage_id integer,
    brand_id integer,
    beer_id integer,
    bar_id integer,
    status character varying(255) DEFAULT 'sent'::character varying NOT NULL,
    token character varying(255),
    order_id integer,
    memo character varying(255),
    quantity integer,
    virtual boolean DEFAULT false NOT NULL,
    paid boolean DEFAULT false NOT NULL,
    expires_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    recipient_email character varying(255),
    recipient_facebook_uid integer,
    notified boolean DEFAULT false NOT NULL,
    cents integer DEFAULT 0 NOT NULL,
    expired boolean DEFAULT false NOT NULL,
    promotional boolean DEFAULT false NOT NULL,
    brand_name character varying(255),
    beer_name character varying(255),
    bar_name character varying(255),
    beverage_name character varying(255),
    price_id integer,
    currency character varying(255) DEFAULT 'EUR'::character varying NOT NULL,
    discounted_cents integer DEFAULT 0 NOT NULL,
    discounted boolean DEFAULT false NOT NULL
);


--
-- Name: ious_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ious_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: ious_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ious_id_seq OWNED BY ious.id;


--
-- Name: line_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE line_items (
    id integer NOT NULL,
    payment_id integer,
    bar_id integer,
    iou_id integer,
    voucher_id integer,
    payout_percent character varying(255),
    status character varying(255),
    cents integer,
    currency character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE line_items_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE line_items_id_seq OWNED BY line_items.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payments (
    id integer NOT NULL,
    affiliate_id integer,
    affiliate_name character varying(255),
    paid boolean DEFAULT false NOT NULL,
    cents integer DEFAULT 0 NOT NULL,
    beginning_at timestamp without time zone NOT NULL,
    ending_at timestamp without time zone NOT NULL,
    paid_at timestamp without time zone,
    currency character varying(255),
    notes text,
    admin_notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payments_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- Name: photos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE photos (
    id integer NOT NULL,
    gallery_id integer,
    title character varying(255),
    description text,
    photo_file_name character varying(255),
    photo_content_type character varying(255),
    photo_file_size character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE photos_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE photos_id_seq OWNED BY photos.id;


--
-- Name: prices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE prices (
    id integer NOT NULL,
    beer_id integer,
    bar_id integer,
    cents integer,
    currency character varying(255) DEFAULT 'EUR'::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    discounted_cents integer DEFAULT 0 NOT NULL,
    discounted boolean DEFAULT false NOT NULL
);


--
-- Name: prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE prices_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE prices_id_seq OWNED BY prices.id;


--
-- Name: qr_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE qr_images (
    id integer NOT NULL,
    md5 character varying(255) NOT NULL,
    ecc character varying(255),
    version integer DEFAULT 6,
    message character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: qr_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE qr_images_id_seq
    START WITH 112
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: qr_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE qr_images_id_seq OWNED BY qr_images.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: slugs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE slugs (
    id integer NOT NULL,
    name character varying(255),
    sluggable_id integer,
    sequence integer DEFAULT 1 NOT NULL,
    sluggable_type character varying(40),
    scope character varying(255),
    created_at timestamp without time zone
);


--
-- Name: slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE slugs_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE slugs_id_seq OWNED BY slugs.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255),
    login character varying(255),
    sex character varying(255),
    type character varying(255),
    active boolean DEFAULT false NOT NULL,
    crypted_password character varying(255),
    password_salt character varying(255),
    persistence_token character varying(255),
    single_access_token character varying(255),
    perishable_token character varying(255),
    login_count integer DEFAULT 0,
    failed_login_count integer DEFAULT 0,
    last_request_at timestamp without time zone,
    current_login_at timestamp without time zone,
    last_login_at timestamp without time zone,
    current_login_ip character varying(255),
    last_login_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    email_hash character varying(64),
    facebook_uid bigint,
    facebook_session_key character varying(255),
    oauth_token character varying(255),
    oauth_secret character varying(255),
    language character varying(5) DEFAULT 'en'::character varying NOT NULL,
    phone_number character varying(32),
    avatar_file_name character varying(255),
    avatar_content_type character varying(255),
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    credits character varying(255) DEFAULT '0'::character varying NOT NULL,
    company boolean DEFAULT false NOT NULL,
    default_currency character varying(255) DEFAULT 'EUR'::character varying NOT NULL,
    paypal_email character varying(255),
    bank_account_name character varying(255),
    bank_account_number character varying(255),
    bank_account_bank_code character varying(255),
    bank_name character varying(255),
    bank_address text,
    bank_account_iban character varying(255),
    bank_account_bic_swift character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: voucher_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE voucher_lists (
    id integer NOT NULL,
    bar_id integer NOT NULL,
    cents integer NOT NULL,
    currency character varying(255) DEFAULT 'EUR'::character varying NOT NULL,
    closed boolean DEFAULT false NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: voucher_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE voucher_lists_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: voucher_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE voucher_lists_id_seq OWNED BY voucher_lists.id;


--
-- Name: vouchers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vouchers (
    id integer NOT NULL,
    voucher_list_id integer NOT NULL,
    token character varying(255) NOT NULL,
    redemption_token character varying(255) NOT NULL,
    bar_id integer NOT NULL,
    iou_id integer,
    redeemed boolean DEFAULT false NOT NULL,
    cents integer NOT NULL,
    currency character varying(255) DEFAULT 'EUR'::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    redeemed_at timestamp without time zone,
    discounted_cents integer DEFAULT 0 NOT NULL,
    discounted boolean DEFAULT false NOT NULL
);


--
-- Name: vouchers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vouchers_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: vouchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE vouchers_id_seq OWNED BY vouchers.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE bars ALTER COLUMN id SET DEFAULT nextval('bars_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE beers ALTER COLUMN id SET DEFAULT nextval('beers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE beverages ALTER COLUMN id SET DEFAULT nextval('beverages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE brands ALTER COLUMN id SET DEFAULT nextval('brands_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE cities ALTER COLUMN id SET DEFAULT nextval('cities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE credit_events ALTER COLUMN id SET DEFAULT nextval('credit_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE drink_types ALTER COLUMN id SET DEFAULT nextval('drink_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE emails ALTER COLUMN id SET DEFAULT nextval('emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE galleries ALTER COLUMN id SET DEFAULT nextval('galleries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ious ALTER COLUMN id SET DEFAULT nextval('ious_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE line_items ALTER COLUMN id SET DEFAULT nextval('line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE photos ALTER COLUMN id SET DEFAULT nextval('photos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE prices ALTER COLUMN id SET DEFAULT nextval('prices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE qr_images ALTER COLUMN id SET DEFAULT nextval('qr_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE slugs ALTER COLUMN id SET DEFAULT nextval('slugs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE voucher_lists ALTER COLUMN id SET DEFAULT nextval('voucher_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE vouchers ALTER COLUMN id SET DEFAULT nextval('vouchers_id_seq'::regclass);


--
-- Name: bars_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bars
    ADD CONSTRAINT bars_pkey PRIMARY KEY (id);


--
-- Name: beers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY beers
    ADD CONSTRAINT beers_pkey PRIMARY KEY (id);


--
-- Name: beverages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY beverages
    ADD CONSTRAINT beverages_pkey PRIMARY KEY (id);


--
-- Name: brands_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: credit_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY credit_events
    ADD CONSTRAINT credit_events_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: drink_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY drink_types
    ADD CONSTRAINT drink_types_pkey PRIMARY KEY (id);


--
-- Name: emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: galleries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY galleries
    ADD CONSTRAINT galleries_pkey PRIMARY KEY (id);


--
-- Name: ious_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ious
    ADD CONSTRAINT ious_pkey PRIMARY KEY (id);


--
-- Name: line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY line_items
    ADD CONSTRAINT line_items_pkey PRIMARY KEY (id);


--
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY photos
    ADD CONSTRAINT photos_pkey PRIMARY KEY (id);


--
-- Name: prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY prices
    ADD CONSTRAINT prices_pkey PRIMARY KEY (id);


--
-- Name: qr_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY qr_images
    ADD CONSTRAINT qr_images_pkey PRIMARY KEY (id);


--
-- Name: slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY slugs
    ADD CONSTRAINT slugs_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: voucher_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY voucher_lists
    ADD CONSTRAINT voucher_lists_pkey PRIMARY KEY (id);


--
-- Name: vouchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vouchers
    ADD CONSTRAINT vouchers_pkey PRIMARY KEY (id);


--
-- Name: index_bars_on_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bars_on_address ON bars USING btree (address);


--
-- Name: index_bars_on_affiliate_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bars_on_affiliate_id ON bars USING btree (affiliate_id);


--
-- Name: index_bars_on_cached_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_bars_on_cached_slug ON bars USING btree (cached_slug);


--
-- Name: index_bars_on_city_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bars_on_city_id ON bars USING btree (city_id);


--
-- Name: index_bars_on_country_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bars_on_country_id ON bars USING btree (country_id);


--
-- Name: index_bars_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bars_on_name ON bars USING btree (name);


--
-- Name: index_bars_on_pending; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bars_on_pending ON bars USING btree (pending);


--
-- Name: index_beers_on_brand_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_beers_on_brand_id ON beers USING btree (brand_id);


--
-- Name: index_beers_on_drink_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_beers_on_drink_type_id ON beers USING btree (drink_type_id);


--
-- Name: index_beers_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_beers_on_name ON beers USING btree (name);


--
-- Name: index_beverages_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_beverages_on_name ON beverages USING btree (name);


--
-- Name: index_brands_on_beverage_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brands_on_beverage_id ON brands USING btree (beverage_id);


--
-- Name: index_brands_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_brands_on_name ON brands USING btree (name);


--
-- Name: index_cities_on_country_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cities_on_country_id ON cities USING btree (country_id);


--
-- Name: index_cities_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cities_on_name ON cities USING btree (name);


--
-- Name: index_countries_on_iso; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_countries_on_iso ON countries USING btree (iso);


--
-- Name: index_countries_on_printable_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_countries_on_printable_name ON countries USING btree (printable_name);


--
-- Name: index_drink_types_on_beverage_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_drink_types_on_beverage_id ON drink_types USING btree (beverage_id);


--
-- Name: index_emails_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_emails_on_email ON emails USING btree (email);


--
-- Name: index_emails_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_emails_on_token ON emails USING btree (token);


--
-- Name: index_emails_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_emails_on_user_id ON emails USING btree (user_id);


--
-- Name: index_galleries_on_attachable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_galleries_on_attachable_id ON galleries USING btree (attachable_id);


--
-- Name: index_galleries_on_attachable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_galleries_on_attachable_type ON galleries USING btree (attachable_type);


--
-- Name: index_ious_on_bar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_bar_id ON ious USING btree (bar_id);


--
-- Name: index_ious_on_beer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_beer_id ON ious USING btree (beer_id);


--
-- Name: index_ious_on_beverage_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_beverage_id ON ious USING btree (beverage_id);


--
-- Name: index_ious_on_brand_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_brand_id ON ious USING btree (brand_id);


--
-- Name: index_ious_on_order_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_order_id ON ious USING btree (order_id);


--
-- Name: index_ious_on_price_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_price_id ON ious USING btree (price_id);


--
-- Name: index_ious_on_promotional; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_promotional ON ious USING btree (promotional);


--
-- Name: index_ious_on_recipient_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_recipient_email ON ious USING btree (recipient_email);


--
-- Name: index_ious_on_recipient_facebook_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_recipient_facebook_uid ON ious USING btree (recipient_facebook_uid);


--
-- Name: index_ious_on_recipient_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_recipient_id ON ious USING btree (recipient_id);


--
-- Name: index_ious_on_sender_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_sender_id ON ious USING btree (sender_id);


--
-- Name: index_ious_on_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_status ON ious USING btree (status);


--
-- Name: index_ious_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_ious_on_token ON ious USING btree (token);


--
-- Name: index_line_items_on_bar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_line_items_on_bar_id ON line_items USING btree (bar_id);


--
-- Name: index_line_items_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_line_items_on_created_at ON line_items USING btree (created_at);


--
-- Name: index_line_items_on_iou_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_line_items_on_iou_id ON line_items USING btree (iou_id);


--
-- Name: index_line_items_on_payment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_line_items_on_payment_id ON line_items USING btree (payment_id);


--
-- Name: index_line_items_on_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_line_items_on_status ON line_items USING btree (status);


--
-- Name: index_line_items_on_voucher_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_line_items_on_voucher_id ON line_items USING btree (voucher_id);


--
-- Name: index_payments_on_affiliate_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_affiliate_id ON payments USING btree (affiliate_id);


--
-- Name: index_payments_on_paid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_payments_on_paid ON payments USING btree (paid);


--
-- Name: index_prices_on_beer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_prices_on_beer_id ON prices USING btree (beer_id);


--
-- Name: index_slugs_on_n_s_s_and_s; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_slugs_on_n_s_s_and_s ON slugs USING btree (name, sluggable_type, sequence, scope);


--
-- Name: index_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_slugs_on_sluggable_id ON slugs USING btree (sluggable_id);


--
-- Name: index_users_on_facebook_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_facebook_uid ON users USING btree (facebook_uid);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_name ON users USING btree (name);


--
-- Name: index_users_on_oauth_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_oauth_token ON users USING btree (oauth_token);


--
-- Name: index_users_on_twitter_handle; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_twitter_handle ON users USING btree (login);


--
-- Name: index_vouchers_on_bar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vouchers_on_bar_id ON vouchers USING btree (bar_id);


--
-- Name: index_vouchers_on_redeemed_and_bar_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vouchers_on_redeemed_and_bar_id ON vouchers USING btree (bar_id, redeemed);


--
-- Name: index_vouchers_on_voucher_list_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vouchers_on_voucher_list_id ON vouchers USING btree (voucher_list_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20091214101132');

INSERT INTO schema_migrations (version) VALUES ('20091214101336');

INSERT INTO schema_migrations (version) VALUES ('20091214101404');

INSERT INTO schema_migrations (version) VALUES ('20091214101421');

INSERT INTO schema_migrations (version) VALUES ('20091214101453');

INSERT INTO schema_migrations (version) VALUES ('20091214102117');

INSERT INTO schema_migrations (version) VALUES ('20091214102303');

INSERT INTO schema_migrations (version) VALUES ('20100204105406');

INSERT INTO schema_migrations (version) VALUES ('20100226105306');

INSERT INTO schema_migrations (version) VALUES ('20100226125009');

INSERT INTO schema_migrations (version) VALUES ('20100226131308');

INSERT INTO schema_migrations (version) VALUES ('20100226150036');

INSERT INTO schema_migrations (version) VALUES ('20100302145229');

INSERT INTO schema_migrations (version) VALUES ('20100303090326');

INSERT INTO schema_migrations (version) VALUES ('20100310115401');

INSERT INTO schema_migrations (version) VALUES ('20100319122325');

INSERT INTO schema_migrations (version) VALUES ('20100319125603');

INSERT INTO schema_migrations (version) VALUES ('20100323134021');

INSERT INTO schema_migrations (version) VALUES ('20100329154235');

INSERT INTO schema_migrations (version) VALUES ('20100330093208');

INSERT INTO schema_migrations (version) VALUES ('20100330095201');

INSERT INTO schema_migrations (version) VALUES ('20100330161538');

INSERT INTO schema_migrations (version) VALUES ('20100402083037');

INSERT INTO schema_migrations (version) VALUES ('20100402110214');

INSERT INTO schema_migrations (version) VALUES ('20100408165724');

INSERT INTO schema_migrations (version) VALUES ('20100413105710');

INSERT INTO schema_migrations (version) VALUES ('20100414101203');

INSERT INTO schema_migrations (version) VALUES ('20100414102409');

INSERT INTO schema_migrations (version) VALUES ('20100414103252');

INSERT INTO schema_migrations (version) VALUES ('20100416073030');

INSERT INTO schema_migrations (version) VALUES ('20100419132339');

INSERT INTO schema_migrations (version) VALUES ('20100420070941');

INSERT INTO schema_migrations (version) VALUES ('20100503212220');

INSERT INTO schema_migrations (version) VALUES ('20100504113740');

INSERT INTO schema_migrations (version) VALUES ('20100518130028');

INSERT INTO schema_migrations (version) VALUES ('20100521122154');

INSERT INTO schema_migrations (version) VALUES ('20100608100949');

INSERT INTO schema_migrations (version) VALUES ('20100626152609');

INSERT INTO schema_migrations (version) VALUES ('20100626152610');

INSERT INTO schema_migrations (version) VALUES ('20100626160500');

INSERT INTO schema_migrations (version) VALUES ('20100701153422');

INSERT INTO schema_migrations (version) VALUES ('20100705142524');

INSERT INTO schema_migrations (version) VALUES ('20100708134147');

INSERT INTO schema_migrations (version) VALUES ('20100713104337');

INSERT INTO schema_migrations (version) VALUES ('20100722143607');

INSERT INTO schema_migrations (version) VALUES ('20100730103826');

INSERT INTO schema_migrations (version) VALUES ('20100823150557');

INSERT INTO schema_migrations (version) VALUES ('20100831154045');

INSERT INTO schema_migrations (version) VALUES ('20100831162725');

INSERT INTO schema_migrations (version) VALUES ('20100908170422');

INSERT INTO schema_migrations (version) VALUES ('20100909133019');

INSERT INTO schema_migrations (version) VALUES ('20100909135116');

INSERT INTO schema_migrations (version) VALUES ('20100909140433');

INSERT INTO schema_migrations (version) VALUES ('20100910130627');

INSERT INTO schema_migrations (version) VALUES ('20100910131655');

INSERT INTO schema_migrations (version) VALUES ('20100916160321');

INSERT INTO schema_migrations (version) VALUES ('20100922131848');

INSERT INTO schema_migrations (version) VALUES ('20100926162748');

INSERT INTO schema_migrations (version) VALUES ('20100922154417');

INSERT INTO schema_migrations (version) VALUES ('20100922202255');

INSERT INTO schema_migrations (version) VALUES ('20100924153603');

INSERT INTO schema_migrations (version) VALUES ('20100926174213');

INSERT INTO schema_migrations (version) VALUES ('20100926190006');

INSERT INTO schema_migrations (version) VALUES ('20100927080121');

INSERT INTO schema_migrations (version) VALUES ('20101013094243');

INSERT INTO schema_migrations (version) VALUES ('20101018162814');

INSERT INTO schema_migrations (version) VALUES ('20101018195423');

INSERT INTO schema_migrations (version) VALUES ('20101019225332');