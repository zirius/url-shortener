CREATE TABLE IF NOT EXISTS urls (
  url text NOT NULL,
  slug text NOT NULL,
  ip VARCHAR(40),
  created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated timestamp without time zone
 );

ALTER TABLE urls
  ADD CONSTRAINT urls_pk PRIMARY KEY (url);
ALTER TABLE urls
  ADD CONSTRAINT urls_slug_key UNIQUE (slug);

CREATE INDEX idx_url ON urls USING btree (url);
CREATE INDEX idx_slug ON urls USING btree (slug);

ALTER TABLE urls
  ADD COLUMN counter INT DEFAULT 0 NOT NULL;

CREATE INDEX idx_counter ON urls USING btree (counter);

ALTER TABLE urls
  ADD COLUMN access_ips character varying[];

CREATE TABLE IF NOT EXISTS url_stats (
  slug text NOT NULL,
  country text NOT NULL DEFAULT '',
  city text NOT NULL DEFAULT '',
  ip text NOT NULL,
  counter int NOT NULL DEFAULT 0,
  properties jsonb NOT NULL DEFAULT '{}'::jsonb,
  created timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated timestamp without time zone
);

ALTER TABLE url_stats
  ADD CONSTRAINT urls_stats_slug_ip_pkey UNIQUE (slug, ip);

CREATE INDEX idx_url_stats_slug ON url_stats USING btree (slug);
CREATE INDEX idx_url_stats_country ON url_stats USING btree (country);
CREATE INDEX idx_url_stats_city ON url_stats USING btree (city);