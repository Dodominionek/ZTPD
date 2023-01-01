-- Contains
-- Zad 1
CREATE TABLE CYTATY AS SELECT * FROM ZSBD_TOOLS.CYTATY;

SELECT * FROM CYTATY;

-- Zad 2
SELECT AUTOR, TEKST
FROM CYTATY
WHERE UPPER(TEKST) LIKE '%PESYMISTA%' AND UPPER(TEKST) LIKE '%OPTYMISTA%';

-- Zad 3
CREATE INDEX cytaty_tekst_indeks
ON CYTATY(TEKST)
INDEXTYPE IS CTXSYS.CONTEXT;

-- Zad 4
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'PESYMISTA AND OPTYMISTA', 1) > 0;

-- Zad 5
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'PESYMISTA ~ OPTYMISTA', 1) > 0;

-- Zad 6
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'NEAR((PESYMISTA, OPTYMISTA), 3)') > 0;

-- Zad 7
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'NEAR((PESYMISTA, OPTYMISTA), 10)') > 0;

-- Zad 8
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0;

-- Zad 9
SELECT AUTOR, TEKST, SCORE(1) AS DOPASOWANIE
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0;

-- Zad 10
SELECT AUTOR, TEKST, SCORE(1) AS DOPASOWANIE
FROM CYTATY
WHERE CONTAINS(TEKST, 'życi%', 1) > 0 AND ROWNUM <= 1;

-- Zad 11
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'FUZZY(problem,,,N)', 1) > 0;

-- Zad 12
INSERT INTO CYTATY VALUES(
    39,
    'Bertrand Russell',
    'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.'
);
COMMIT;

SELECT * FROM CYTATY;

-- Zad 13
SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'głupcy', 1) > 0;
-- Słowo głupcy nie znajduje się wśród indeksowanych słów

-- Zad 14
SELECT TOKEN_TEXT
FROM DR$cytaty_tekst_indeks$I
WHERE TOKEN_TEXT = 'głupcy';

-- Zad 15
DROP INDEX cytaty_tekst_indeks;

CREATE INDEX cytaty_tekst_indeks
ON CYTATY(TEKST)
INDEXTYPE IS CTXSYS.CONTEXT;

-- Zad 16
SELECT TOKEN_TEXT
FROM DR$cytaty_tekst_indeks$I
WHERE TOKEN_TEXT = 'głupcy';

SELECT AUTOR, TEKST
FROM CYTATY
WHERE CONTAINS(TEKST, 'głupcy', 1) > 0;

-- Zad 17
DROP INDEX cytaty_tekst_indeks;

DROP TABLE CYTATY;

-- Zaawansowane indeksowanie i wyszukiwanie
-- Zad 1
CREATE TABLE QUOTES AS SELECT * FROM ZSBD_TOOLS.QUOTES;

SELECT * FROM QUOTES;

-- Zad 2
CREATE INDEX QUOTES_TEXT_INDEX
ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT;

-- Zad 3
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'work', 1) > 0;

SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '$work', 1) > 0;

SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'working’', 1) > 0;

SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '$working’', 1) > 0;

-- Zad 4
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'it', 1) > 0;

--system nie zwrócil żadnych wiyników, dlatego że 'it' jest na liście 'stopwords' 

-- Zad 5
SELECT * FROM CTX_STOPLISTS;

--system wykorzystal domyślna stopliste DEFAULT_STOPLIST

-- Zad 6
SELECT * FROM CTX_STOPWORDS;

-- Zad 7
DROP INDEX QUOTES_TEXT_INDEX;

CREATE INDEX QUOTES_TEXT_INDEX
ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST');

-- Zad 8
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'it', 1) > 0;
--tym razem system zwrócil wyniki

-- Zad 9
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool AND humans', 1) > 0;

-- Zad 10
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'fool AND computer', 1) > 0;

-- Zad 11
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '(fool AND humans) WITHIN SENTENCE', 1) > 0;
--sekcja SENTENCE nie istnieje

-- Zad 12
DROP INDEX QUOTES_TEXT_INDEX;

-- Zad 13
BEGIN ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
    ctx_ddl.add_special_section('nullgroup',  'SENTENCE');
    ctx_ddl.add_special_section('nullgroup',  'PARAGRAPH');
END;

-- Zad 14
CREATE INDEX QUOTES_TEXT_INDEX
ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('stoplist CTXSYS.EMPTY_STOPLIST section group nullgroup');

-- Zad 15
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '(fool AND humans) WITHIN SENTENCE', 1) > 0;

SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, '(fool AND computer) WITHIN SENTENCE', 1) > 0;

--pierwsze zapytania zwraca pusty wynik, ale wzorce dzialaja

-- Zad 16
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'humans', 1) > 0;

--system zwrócil też cytaty  zawierajace przedrostek 'non-' ponieważ nie traktuje '-' jako prawdziwy znak

-- Zad 17
DROP INDEX QUOTES_TEXT_INDEX;

BEGIN ctx_ddl.create_preference('lex_z_m','BASIC_LEXER');
    ctx_ddl.set_attribute('lex_z_m', 'printjoins', '-');
    ctx_ddl.set_attribute('lex_z_m', 'index_text', 'YES');
END;

CREATE INDEX QUOTES_TEXT_INDEX
ON QUOTES(TEXT)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('
    stoplist CTXSYS.EMPTY_STOPLIST
    section group nullgroup
    LEXER lex_z_m
    ');
    
-- Zad 18
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'humans', 1) > 0;
--system nie zwrócil cytatów zawierajacych przedrostek 'non-'

-- Zad 19
SELECT AUTHOR, TEXT
FROM QUOTES
WHERE CONTAINS(TEXT, 'non\-humans', 1) > 0;


-- Zad 20
DROP TABLE QUOTES;

BEGIN
    ctx_ddl.drop_preference('lex_z_m');
END;
