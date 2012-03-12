-- A function to create qgrams from strings in postgres
-- Taken from http://pages.stern.nyu.edu/~panos/datacleaning/qgrams.sql

CREATE OR REPLACE FUNCTION cgrant_make_qgram(doc_id numeric, q numeric, words TEXT) 
RETURNS TABLE (docid numeric, pos numeric, token text) AS $$
DECLARE 
  slen integer := length(words);
  fpads TEXT := E'#######';
  bpads TEXT := E'%%%%%%%';
BEGIN
  RETURN QUERY SELECT doc_id, g::numeric, substr(substr(fpads,1,q::integer-1) || upper(words) || substr(bpads,1,q::integer-1), g, q::integer)
    FROM generate_series(1, slen+q::integer-1) AS g 
    WHERE g <= slen + q-1;
END;
$$ LANGUAGE plpgsql STRICT IMMUTABLE;

/*
SELECT cgrant_make_qgram(1, 3, 'Hello');
 cgrant_make_qgram 
-------------------
 (1,1,##H)
 (1,2,#HE)
 (1,3,HEL)
 (1,4,ELL)
 (1,5,LLO)
 (1,6,LO%)
 (1,7,O%%)
(7 rows)
*/


-- Compares two strings by creating qgrams
-- This returns the set of overlapped qgrams
-- k is the distance of possible matches
CREATE OR REPLACE FUNCTION cgrant_compare(doc_id1 numeric, s1 text, doc_id2 numeric, s2 text, k numeric) RETURNS TABLE (token1 text, token2 text) AS
$$
DECLARE s1len integer;
DECLARE s2len integer;
DECLARE qlen integer := 3;
BEGIN
	SELECT INTO s1len char_length FROM char_length(s1);
	SELECT INTO s2len char_length FROM char_length(s2);
	RAISE NOTICE 's1len: %, s2len: %', s1len, s2len;
	RETURN QUERY	
		SELECT d1.token, d2.token
		FROM cgrant_make_qgram(doc_id1, qlen, s1) as d1,
		cgrant_make_qgram(doc_id2, qlen, s2) as d2
		WHERE d1.token = d2.token AND abs(d1.pos - d2.pos) < k
		GROUP BY d1.token, d2.token;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

/*
select cgrant_compare(0, 'The big black dog', 1, 'The bigger black dog', 4);
*/


-- This returns the distance measure for the two strings
-- k is the distance of possible matches
CREATE OR REPLACE FUNCTION cgrant_distance(doc_id1 numeric, s1 text, doc_id2 numeric, s2 text, k numeric) RETURNS decimal AS
$$
DECLARE s1len integer;
DECLARE s2len integer;
DECLARE qlen integer := 3;
DECLARE overlap decimal;
BEGIN
	SELECT INTO s1len char_length FROM char_length(s1);
	SELECT INTO s2len char_length FROM char_length(s2);
	overlap := count(*) FROM
		(SELECT d1.token, d2.token
			FROM cgrant_make_qgram(doc_id1, qlen, s1) as d1,
			cgrant_make_qgram(doc_id2, qlen, s2) as d2
			WHERE d1.token = d2.token AND abs(d1.pos - d2.pos) < k
			GROUP BY d1.token, d2.token) as q;
	-- RAISE NOTICE 'overlap: %', overlap;
	IF s1len < s2len THEN
		RETURN overlap / (s1len+qlen-1);
	ELSE
		RETURN overlap / (s2len+qlen-1);
	END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


-- This is a qgram with out the padding
CREATE OR REPLACE FUNCTION cgrant_make_naked_qgram(doc_id numeric, q numeric, words TEXT) 
RETURNS TABLE (docid numeric, pos numeric, token text) AS $$
DECLARE
  slen integer := length(words);
  fpads TEXT := E'#######';
  bpads TEXT := E'%%%%%%%';
BEGIN  RETURN QUERY SELECT doc_id, g::numeric, substr(upper(words), g, q::integer)
    FROM generate_series(1, slen-q::integer+1) AS g
    WHERE g <= slen;
END;
$$ LANGUAGE plpgsql STRICT IMMUTABLE;

-- SELECT cgrant_make_naked_qgram(1,3,'Tim Tebow');
-- (1,1,TIM) 
-- (1,2,"IM ") 
-- (1,3,"M T") 
-- (1,4," TE") 
-- (1,5,TEB) 
-- (1,6,EBO) 
-- (1,7,BOW) 



-- Approximate find  for tweets_10000
CREATE OR REPLACE FUNCTION cgrant_approx_find_10000(searchterm TEXT)
RETURNS TABLE (docid NUMERIC) 
AS
$$
SELECT qt.docid
  FROM cgrant_make_naked_qgram(1,3, $1) AS st, qtweets_10000 AS qt
  WHERE st.token = qt.gram
  GROUP BY  qt.docid
  HAVING COUNT(DISTINCT qt.gram) >= (SELECT COUNT(token) FROM cgrant_make_naked_qgram(1,3, $1))
$$ LANGUAGE sql IMMUTABLE;

-- SELECT docid FROM  cgrant_approx_find_10000('Dolphins')

-- select t.twtext 
-- from tweets_10000 t, cgrant_approx_find_10000('Dolphins') d
-- where t.id = d.docid;

-- Compare approximate match with like:
--(select twtext from tweets_10000 where twtext ILIKE '%Tim Tebow%')
--except
--(select t.twtext 
--	from tweets_10000 t, cgrant_approx_find_10000('Tim Tebow') d
--	where t.id = d.docid)
--except
--(select twtext from tweets_10000 where twtext ILIKE '%Tim Tebow%')




-- tweets_1000
CREATE OR REPLACE FUNCTION cgrant_approx_find_1000(searchterm TEXT)
RETURNS TABLE (docid NUMERIC) 
AS
$$
SELECT qt.docid
  FROM cgrant_make_naked_qgram(1,3, $1) AS st, qtweets_1000 AS qt
  WHERE st.token = qt.gram
  GROUP BY  qt.docid
  HAVING COUNT(DISTINCT qt.gram) >= (SELECT COUNT(token) FROM cgrant_make_naked_qgram(1,3, $1))
$$ LANGUAGE sql IMMUTABLE;


-- tweets_100
CREATE OR REPLACE FUNCTION cgrant_approx_find_100(searchterm TEXT)
RETURNS TABLE (docid NUMERIC) 
AS
$$
SELECT qt.docid
  FROM cgrant_make_naked_qgram(1,3, $1) AS st, qtweets_100 AS qt
  WHERE st.token = qt.gram
  GROUP BY  qt.docid
  HAVING COUNT(DISTINCT qt.gram) >= (SELECT COUNT(token) FROM cgrant_make_naked_qgram(1,3, $1))
$$ LANGUAGE sql IMMUTABLE;



-- tweets_10
CREATE OR REPLACE FUNCTION cgrant_approx_find_10(searchterm TEXT)
RETURNS TABLE (docid NUMERIC) 
AS
$$
SELECT qt.docid
  FROM cgrant_make_naked_qgram(1,3, $1) AS st, qtweets_10 AS qt
  WHERE st.token = qt.gram
  GROUP BY  qt.docid
  HAVING COUNT(DISTINCT qt.gram) >= (SELECT COUNT(token) FROM cgrant_make_naked_qgram(1,3, $1))
$$ LANGUAGE sql IMMUTABLE;


