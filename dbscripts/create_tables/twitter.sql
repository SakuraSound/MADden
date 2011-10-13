-- DROP TABLE tweets;
CREATE TABLE tweets (
	id bigint PRIMARY KEY,
	id_str character(20),
	twuser character(20) NOT NULL,
	twuser_id_str character(20),
	user_profile_image text default null,
	created_at timestamp without time zone NOT NULL,
	twtext text,
	twtextvector tsvector default null
	-- More to come
);
