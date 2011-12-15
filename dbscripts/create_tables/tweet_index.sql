-- DROP INDEX gin_twtext;
CREATE INDEX gin_twtext ON tweets USING gin(twtextvector);

-- DROP INDEX btree_created_at;
CREATE INDEX CONCURRENTLY btree_created_at on tweets using btree(created_at);
