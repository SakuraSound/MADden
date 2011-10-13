-- DROP INDEX gin_twtext
CREATE INDEX gin_twtext ON tweets USING gin(twtextvector);
