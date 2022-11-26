--Zad 1
CREATE TABLE MOVIES(
    ID NUMBER(12) PRIMARY KEY,
    TITLE VARCHAR2(400) NOT NULL,
    CATEGORY VARCHAR2(50),
    YEAR CHAR(4),
    CAST VARCHAR2(4000),
    DIRECTOR VARCHAR2(4000),
    STORY VARCHAR2(4000),
    PRICE NUMBER(5,2),
    COVER BLOB,
    MIME_TYPE VARCHAR2(50)
);

--Zad 2
INSERT INTO MOVIES
SELECT D.ID, D.TITLE, D.CATEGORY, TRIM(TO_CHAR(D.YEAR,'9999')), D.CAST, D.DIRECTOR, D.STORY, D.PRICE, C.IMAGE, C.MIME_TYPE
FROM DESCRIPTIONS D LEFT JOIN COVERS C ON D.ID = C.MOVIE_ID;

SELECT * FROM MOVIES;

--Zad 3
SELECT ID, TITLE FROM MOVIES
WHERE COVER IS NULL;

--Zad 4
SELECT ID, TITLE, DBMS_LOB.GETLENGTH(COVER) AS "FILESIZE" FROM MOVIES
WHERE COVER IS NOT NULL;

--Zad 5
SELECT ID, TITLE, DBMS_LOB.GETLENGTH(COVER) AS "FILESIZE" FROM MOVIES
WHERE COVER IS NULL;

--Zad 6
SELECT * FROM ALL_DIRECTORIES;

--Zad 7
UPDATE MOVIES
SET COVER = EMPTY_BLOB(),
MIME_TYPE = 'image/jpeg'
WHERE ID = 66;

--Zad 8
SELECT ID, TITLE, DBMS_LOB.GETLENGTH(COVER) AS "FILESIZE" FROM MOVIES
WHERE ID IN (65, 66);

--Zad 9
DECLARE
    LOBSS BLOB;
    FIL BFILE := BFILENAME('ZSBD_DIR','escape.jpg');
BEGIN   
    SELECT COVER INTO LOBSS
    FROM MOVIES
    WHERE ID = 66
    FOR UPDATE;
    
    DBMS_LOB.FILEOPEN(FIL, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADFROMFILE(LOBSS,FIL,DBMS_LOB.GETLENGTH(FIL));
    DBMS_LOB.FILECLOSE(FIL);
    COMMIT;
END;

--Zad 10
CREATE TABLE TEMP_COVERS(
    MOVIE_ID NUMBER(12),
    IMAGE BFILE,
    MIME_TYPE VARCHAR2(50)
);

--Zad 11
INSERT INTO TEMP_COVERS
VALUES (65, BFILENAME('ZSBD_DIR', 'eagles.jpg'), 'image/jpeg');

--Zad 12
SELECT MOVIE_ID, DBMS_LOB.GETLENGTH(IMAGE) FILESIZE
FROM TEMP_COVERS;

--Zad 13
DECLARE
    LOBSS   blob;
    FIL   BFILE;
    M_TYPE varchar2(50);
BEGIN
    SELECT IMAGE, MIME_TYPE
    INTO FIL, M_TYPE
    FROM TEMP_COVERS
    WHERE MOVIE_ID = 65;

    DBMS_LOB.CREATETEMPORARY(LOBSS, true, dbms_lob.session);
    DBMS_LOB.FILEOPEN(FIL, dbms_lob.file_readonly);
    DBMS_LOB.LOADFROMFILE(LOBSS, FIL, dbms_lob.getlength(FIL));
    DBMS_LOB.FILECLOSE(FIL);

    UPDATE MOVIES
    SET COVER = LOBSS,
        MIME_TYPE = M_TYPE
    WHERE ID = 65;

    DBMS_LOB.FREETEMPORARY(LOBSS);
    COMMIT;
END;

--Zad 14
SELECT ID, DBMS_LOB.GETLENGTH(COVER) AS "FILESIZE" FROM MOVIES
WHERE ID IN (65, 66);

--Zad 15
DROP TABLE MOVIES;
DROP TABLE TEMP_COVERS;
