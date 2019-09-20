SELECT * FROM SULIM_INDEX_AVG_PORD_INCR_PCNT;

SELECT * FROM SULIM_INDEX_PPP;

SELECT * FROM SULIM_INDEX_AVG_CNCL_CNT;

SELECT * FROM SULIM_INDEX_OWNE_CNT;

SELECT * FROM SULIM_INDEX_HG_PCNT;

SELECT * FROM SULIM_INDEX_PORD_PCNT;

DROP TABLE SULIM_INDEX_PRDC_PORD_CNT;
CREATE TABLE SULIM_INDEX_PRDC_PORD_CNT AS
WITH VW_TMP AS (
SELECT SALE_YYMM, SUM(CNT) PORD_CNT
  FROM SULIM_SALE_CNT
 GROUP BY SALE_YYMM
)
SELECT AVG_PORD_INCR_PCNT
      ,PPP
      ,AVG_CNCL_CNT
      ,OWNE_CNT
      ,HG_PCNT
      ,PORD_PCNT
      ,PORD_CNT
  FROM VW_TMP A
      ,SULIM_INDEX_AVG_PORD_INCR_PCNT B1
      ,SULIM_INDEX_PPP B2
      ,SULIM_INDEX_AVG_CNCL_CNT B3
      ,SULIM_INDEX_OWNE_CNT B4
      ,SULIM_INDEX_HG_PCNT B5
      ,SULIM_INDEX_PORD_PCNT B6
 WHERE 1=1
   AND A.SALE_YYMM = B1.SALE_YYMM
   AND A.SALE_YYMM = B2.SALE_YYMM
   AND A.SALE_YYMM = B3.SALE_YYMM
   AND A.SALE_YYMM = B4.SALE_YYMM
   AND A.SALE_YYMM = B5.SALE_YYMM
   AND A.SALE_YYMM = B6.SALE_YYMM
   AND A.SALE_YYMM = '201906'
;

SELECT AVG_PORD_INCR_PCNT
      ,PPP
      ,AVG_CNCL_CNT
      ,OWNE_CNT
      ,HG_PCNT
      ,PORD_PCNT
      ,PORD_CNT
  FROM SULIM_INDEX_PRDC_PORD_CNT
  ;
  
WITH VW_TMP AS (
SELECT SALE_YYMM, SUM(CNT) PORD_CNT
  FROM SULIM_SALE_CNT
 GROUP BY SALE_YYMM
)
SELECT AVG_PORD_INCR_PCNT*100 AS AVG_PORD_INCR_PCNT,
       PPP AS PPP,
       ROUND(AVG_CNCL_CNT)/10000 AVG_CNCL_CNT,
       OWNE_CNT/10000 AS OWNE_CNT,
       HG_PCNT*100 AS HG_PCNT,
       PORD_PCNT*10 AS PORD_PCNT,
       PORD_CNT
  FROM VW_TMP A
      ,SULIM_INDEX_AVG_PORD_INCR_PCNT B1
      ,SULIM_INDEX_PPP B2
      ,SULIM_INDEX_AVG_CNCL_CNT B3
      ,SULIM_INDEX_OWNE_CNT B4
      ,SULIM_INDEX_HG_PCNT B5
      ,SULIM_INDEX_PORD_PCNT B6
 WHERE 1=1
   AND A.SALE_YYMM = B1.SALE_YYMM
   AND A.SALE_YYMM = B2.SALE_YYMM
   AND A.SALE_YYMM = B3.SALE_YYMM
   AND A.SALE_YYMM = B4.SALE_YYMM
   AND A.SALE_YYMM = B5.SALE_YYMM
   AND A.SALE_YYMM = B6.SALE_YYMM
   AND A.SALE_YYMM = '201505'