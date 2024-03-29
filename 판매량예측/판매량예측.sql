/*******************************************************

  A.기초데이터 편성

 *******************************************************/
-- 1. 순주문/총주문
CREATE TABLE SULIM_ORD_CNT AS 
WITH VW_ORD_CNT AS (
SELECT SALE_YYMM
      ,SLPART_CD
      ,PRDG_CD
      ,SUM(DECODE(PORD_YN,'X',1,0)) PORD_CNT
      ,SUM(DECODE(TORD_YN,'X',1,0)) TORD_CNT
  FROM WJM.TW_CT_SALE_MST_MM
 WHERE 1=1
   AND TOVR_SALE_YN <> 'X'
 GROUP BY 
       SALE_YYMM
      ,SLPART_CD
      ,PRDG_CD
)
, VW_PRDG AS (
SELECT DISTINCT PRDG_CD, PRDG_NM
  FROM WJM.TD_PD_PROD
)
SELECT A.SALE_YYMM
      ,A.SLPART_CD
      ,B.SLPART_NM
      ,A.PRDG_CD
      ,C.PRDG_NM
      ,A.PORD_CNT
      ,A.TORD_CNT
  FROM VW_ORD_CNT A
      ,WJM.TD_CT_SLPART B
      ,VW_PRDG C
 WHERE A.SLPART_CD = B.SLPART_CD(+)
   AND A.PRDG_CD = C.PRDG_CD
;

-- 2. 해약
CREATE TABLE SULIM_CNCL_CNT AS
SELECT /*+ PARALLEL(8) FULL(A B C) */
       A.PROD_YM AS CNCL_YYMM
      ,B.SLPART_CD
      ,B.SLPART_NM
      ,C.PRDG_CD
      ,C.PRDG_NM
      ,COUNT(1) CNCL_CNT
  FROM WJO.TO_ZBWT1003 A
      ,WJM.TD_CT_SLPART B
      ,WJM.TD_PD_PROD C
 WHERE A.PROD_DAY = TO_CHAR(ADD_MONTHS(TO_DATE(A.PROD_YM,'YYYYMM'),1)-1,'DD')
   AND A.RTN_CONF_DT BETWEEN '19900101' AND '99991231'
   AND A.CONTRACT_ID   = '2'
   AND A.VALUATION_CK1 = 'X'
   AND A.CONTRACT_ID = B.SLPART_CD(+)
   AND A.GOODS_CD = C.PROD_CD(+)
 GROUP BY 
       A.PROD_YM
      ,B.SLPART_CD
      ,B.SLPART_NM
      ,C.PRDG_CD
      ,C.PRDG_NM
;

-- 4. 영업조직원수
DROP TABLE SULIM_ORGM_CNT;

CREATE TABLE SULIM_ORGM_CNT AS 
SELECT /*+ PARALLEL(4)*/
SUBSTR(A.PROD_YMD,1,6) SALE_YYMM,
A.CONTRACT_ID SLPART_CD,
COUNT(DISTINCT A.SALE_ORG_CD) ORG_CNT,
COUNT(DISTINCT A.SALE_UEMPL_NO) EMP_CNT

FROM WJO.TO_ZBWT0100 A
WHERE A.PROD_YMD = TO_CHAR(ADD_MONTHS(TO_DATE(SUBSTR(PROD_YMD,1,6),'YYYYMM'),1)-1,'YYYYMMDD')
GROUP BY
SUBSTR(A.PROD_YMD,1,6),
A.CONTRACT_ID;


/*******************************************************
  B. 판매량 예측 지표 편성 
 *******************************************************/

-- A-1_전월_해약건수_VS_당월_판매량
CREATE TABLE SULIM_PRDT_IDX_A_1 AS
SELECT 
    A.SALE_YYMM,

    SUM(DECODE(A.PRDG_CD,'001',A.PORD_CNT,0)) PORD_CNT_001,
    SUM(DECODE(A.PRDG_CD,'002',A.PORD_CNT,0)) PORD_CNT_002,
    SUM(DECODE(A.PRDG_CD,'004',A.PORD_CNT,0)) PORD_CNT_004,
    SUM(DECODE(A.PRDG_CD,'008',A.PORD_CNT,0)) PORD_CNT_008,
    SUM(DECODE(A.PRDG_CD,'003',A.PORD_CNT,0)) PORD_CNT_003,
    SUM(DECODE(A.PRDG_CD,'005',A.PORD_CNT,0)) PORD_CNT_005,
    SUM(DECODE(A.PRDG_CD,'510',A.PORD_CNT,0)) PORD_CNT_510,

    SUM(DECODE(A.PRDG_CD,'001',B.CNCL_CNT,0)) CNCL_CNT_001,
    SUM(DECODE(A.PRDG_CD,'002',B.CNCL_CNT,0)) CNCL_CNT_002,
    SUM(DECODE(A.PRDG_CD,'004',B.CNCL_CNT,0)) CNCL_CNT_004,
    SUM(DECODE(A.PRDG_CD,'008',B.CNCL_CNT,0)) CNCL_CNT_008,
    SUM(DECODE(A.PRDG_CD,'003',B.CNCL_CNT,0)) CNCL_CNT_003,
    SUM(DECODE(A.PRDG_CD,'005',B.CNCL_CNT,0)) CNCL_CNT_005,
    SUM(DECODE(A.PRDG_CD,'510',B.CNCL_CNT,0)) CNCL_CNT_510

  FROM SULIM_ORD_CNT A
      ,SULIM_CNCL_CNT B
 WHERE TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-1),'YYYYMM') = B.CNCL_YYMM
   AND A.PRDG_CD = B.PRDG_CD
   AND A.SLPART_CD = B.SLPART_CD
   AND A.SLPART_CD = '2'
GROUP BY
    A.SALE_YYMM
ORDER BY
    A.SALE_YYMM
;

-- C-1_전월_제품군별_판매량_VS_당월_판매량
CREATE TABLE SULIM_PRDT_IDX_C_1 AS
WITH VW_PROD_SALE_PCNT AS (
SELECT SALE_YYMM,
       SUM(PORD_CNT) PORD_CNT,
       SUM(DECODE(PRDG_CD,'001',PORD_CNT,0)) PORD_CNT_001,
       SUM(DECODE(PRDG_CD,'002',PORD_CNT,0)) PORD_CNT_002,
       SUM(DECODE(PRDG_CD,'003',PORD_CNT,0)) PORD_CNT_003,
       SUM(DECODE(PRDG_CD,'004',PORD_CNT,0)) PORD_CNT_004,
       SUM(DECODE(PRDG_CD,'005',PORD_CNT,0)) PORD_CNT_005,
       SUM(DECODE(PRDG_CD,'008',PORD_CNT,0)) PORD_CNT_008,
       SUM(DECODE(PRDG_CD,'510',PORD_CNT,0)) PORD_CNT_510,
              
       ROUND(SUM(DECODE(PRDG_CD,'001',PORD_CNT,0))/SUM(PORD_CNT),5) PORD_PCNT_001,
       ROUND(SUM(DECODE(PRDG_CD,'002',PORD_CNT,0))/SUM(PORD_CNT),5) PORD_PCNT_002,
       ROUND(SUM(DECODE(PRDG_CD,'003',PORD_CNT,0))/SUM(PORD_CNT),5) PORD_PCNT_003,
       ROUND(SUM(DECODE(PRDG_CD,'004',PORD_CNT,0))/SUM(PORD_CNT),5) PORD_PCNT_004,
       ROUND(SUM(DECODE(PRDG_CD,'005',PORD_CNT,0))/SUM(PORD_CNT),5) PORD_PCNT_005,
       ROUND(SUM(DECODE(PRDG_CD,'008',PORD_CNT,0))/SUM(PORD_CNT),5) PORD_PCNT_008,
       ROUND(SUM(DECODE(PRDG_CD,'510',PORD_CNT,0))/SUM(PORD_CNT),5) PORD_PCNT_510
  FROM SULIM_ORD_CNT
 WHERE SLPART_CD = '2'
 GROUP BY
       SALE_YYMM
)
SELECT A.SALE_YYMM,
--       A.PORD_CNT,

       A.PORD_CNT_001,
       A.PORD_CNT_002,
       A.PORD_CNT_004,
       A.PORD_CNT_008,
       A.PORD_CNT_003,
       A.PORD_CNT_005,
       A.PORD_CNT_510,

       B.PORD_CNT_001 AS B1_PORD_CNT_001,
       B.PORD_CNT_002 AS B1_PORD_CNT_002,
       B.PORD_CNT_004 AS B1_PORD_CNT_004,
       B.PORD_CNT_008 AS B1_PORD_CNT_008,
       B.PORD_CNT_003 AS B1_PORD_CNT_003,
       B.PORD_CNT_005 AS B1_PORD_CNT_005,
       B.PORD_CNT_510 AS B1_PORD_CNT_510
       
  FROM VW_PROD_SALE_PCNT A
      ,VW_PROD_SALE_PCNT B
 WHERE TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-1),'YYYYMM') = B.SALE_YYMM
 ORDER BY 
       1
;

-- E-2_3개월평균_인당생산성_전월반영_판매량_VS_당월_판매량
CREATE TABLE SULIM_PRDT_IDX_E_2 AS
WITH VW_SRC AS (
SELECT
    A.SALE_YYMM,
    A.SLPART_CD,
    A.PRDG_CD,
    A.PRDG_NM,
    B.EMP_CNT,
    SUM(A.PORD_CNT) PORD_CNT,
    ROUND(SUM(A.PORD_CNT)/B.EMP_CNT,4) PRDTVT
FROM
    SULIM_ORD_CNT A,
    SULIM_ORGM_CNT B
WHERE 1=1
AND A.SALE_YYMM = B.SALE_YYMM
AND A.SLPART_CD = B.SLPART_CD
GROUP BY
    A.SALE_YYMM,
    A.SLPART_CD,
    A.PRDG_CD,
    A.PRDG_NM,
    B.EMP_CNT
)
, VW_STTS AS (
SELECT
M.*,
ROUND(((B1.PRDTVT+B2.PRDTVT+B2.PRDTVT)/3) * B1.EMP_CNT) AS PRDCT_PORD_CNT
FROM
    VW_SRC M,
    VW_SRC B1,
    VW_SRC B2,
    VW_SRC B3
WHERE 1=1
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-1),'YYYYMM') = B1.SALE_YYMM AND M.SLPART_CD = B1.SLPART_CD AND M.PRDG_CD = B1.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-2),'YYYYMM') = B2.SALE_YYMM AND M.SLPART_CD = B2.SLPART_CD AND M.PRDG_CD = B2.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-3),'YYYYMM') = B3.SALE_YYMM AND M.SLPART_CD = B3.SLPART_CD AND M.PRDG_CD = B3.PRDG_CD
)
SELECT
SALE_YYMM,
SUM(DECODE(PRDG_CD,'001',PORD_CNT,0)) AS PORD_CNT_001,
SUM(DECODE(PRDG_CD,'002',PORD_CNT,0)) AS PORD_CNT_002,
SUM(DECODE(PRDG_CD,'004',PORD_CNT,0)) AS PORD_CNT_004,
SUM(DECODE(PRDG_CD,'008',PORD_CNT,0)) AS PORD_CNT_008,
SUM(DECODE(PRDG_CD,'003',PORD_CNT,0)) AS PORD_CNT_003,
SUM(DECODE(PRDG_CD,'005',PORD_CNT,0)) AS PORD_CNT_005,
SUM(DECODE(PRDG_CD,'510',PORD_CNT,0)) AS PORD_CNT_510,

SUM(DECODE(PRDG_CD,'001',PRDCT_PORD_CNT,0)) AS PRDCT_CNT_001,
SUM(DECODE(PRDG_CD,'002',PRDCT_PORD_CNT,0)) AS PRDCT_CNT_002,
SUM(DECODE(PRDG_CD,'004',PRDCT_PORD_CNT,0)) AS PRDCT_CNT_004,
SUM(DECODE(PRDG_CD,'008',PRDCT_PORD_CNT,0)) AS PRDCT_CNT_008,
SUM(DECODE(PRDG_CD,'003',PRDCT_PORD_CNT,0)) AS PRDCT_CNT_003,
SUM(DECODE(PRDG_CD,'005',PRDCT_PORD_CNT,0)) AS PRDCT_CNT_005,
SUM(DECODE(PRDG_CD,'510',PRDCT_PORD_CNT,0)) AS PRDCT_CNT_510

FROM
VW_STTS
WHERE 1=1
AND SLPART_CD = '2'
GROUP BY
SALE_YYMM
ORDER BY
SALE_YYMM
;

-- E-3_3개월평균_인당생산성_전월반영_일시불_VS_당월_일시불
CREATE TABLE SULIM_PRDT_IDX_E_3 AS
WITH VW_SRC AS (
SELECT
    A.SALE_YYMM,
    A.SLPART_CD,
    A.PRDG_CD,
    A.PRDG_NM,
    B.EMP_CNT,
    SUM(A.PORD_CNT) PORD_CNT,
    ROUND(SUM(A.PORD_CNT)/B.EMP_CNT,4) PRDTVT
FROM
    SULIM_ORD_CNT A,
    SULIM_ORGM_CNT B
WHERE 1=1
AND A.SALE_YYMM = B.SALE_YYMM
AND A.SLPART_CD = B.SLPART_CD
GROUP BY
    A.SALE_YYMM,
    A.SLPART_CD,
    A.PRDG_CD,
    A.PRDG_NM,
    B.EMP_CNT
)
, VW_STTS AS (
SELECT
M.*,
ROUND(((B1.PRDTVT+B2.PRDTVT+B2.PRDTVT)/3) * B1.EMP_CNT) AS PRDCT_PORD_CNT
FROM
    VW_SRC M,
    VW_SRC B1,
    VW_SRC B2,
    VW_SRC B3
WHERE 1=1
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-1),'YYYYMM') = B1.SALE_YYMM AND M.SLPART_CD = B1.SLPART_CD AND M.PRDG_CD = B1.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-2),'YYYYMM') = B2.SALE_YYMM AND M.SLPART_CD = B2.SLPART_CD AND M.PRDG_CD = B2.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-3),'YYYYMM') = B3.SALE_YYMM AND M.SLPART_CD = B3.SLPART_CD AND M.PRDG_CD = B3.PRDG_CD
)
SELECT
SALE_YYMM,
SUM(PORD_CNT) AS PORD_CNT,
SUM(PRDCT_PORD_CNT) AS PRDCT_CNT
FROM
VW_STTS
WHERE 1=1
AND SLPART_CD = '1'
GROUP BY
SALE_YYMM
ORDER BY
SALE_YYMM
;

-- F-1_최근6개월성장률반영_판매량_VS_당월_판매량
CREATE TABLE SULIM_PRDT_IDX_F_1 AS
WITH VW_GR AS (
SELECT
    A.*,
    DECODE(B.PORD_CNT,0,0,ROUND(A.PORD_CNT/B.PORD_CNT,5)) AS GR,
    TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-1),'YYYYMM') AS M1,
    TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-2),'YYYYMM') AS M2,
    TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-3),'YYYYMM') AS M3,
    TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-4),'YYYYMM') AS M4,
    TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-5),'YYYYMM') AS M5,
    TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-6),'YYYYMM') AS M6
FROM
    SULIM_ORD_CNT A,
    SULIM_ORD_CNT B
WHERE 1=1
AND TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-1),'YYYYMM') = B.SALE_YYMM
AND A.SLPART_CD = B.SLPART_CD
AND A.PRDG_CD = B.PRDG_CD
)
, VW_GR_PORD_CNT AS (
SELECT A.*
      ,ROUND((NVL(B1.GR,1)+NVL(B2.GR,1)+NVL(B3.GR,1)+NVL(B4.GR,1)+NVL(B5.GR,1)+NVL(B6.GR,1))/6,5) RCNT_6_AVG_GR
      ,ROUND(B1.PORD_CNT*((NVL(B1.GR,1)+NVL(B2.GR,1)+NVL(B3.GR,1)+NVL(B4.GR,1)+NVL(B5.GR,1)+NVL(B6.GR,1))/6),0) GR_PORD_CNT
  FROM
    VW_GR A,
    VW_GR B1,
    VW_GR B2,
    VW_GR B3,
    VW_GR B4,
    VW_GR B5,
    VW_GR B6
WHERE 1=1
AND A.M1 = B1.SALE_YYMM(+) AND A.SLPART_CD = B1.SLPART_CD(+) AND A.PRDG_CD = B1.PRDG_CD(+)
AND A.M2 = B2.SALE_YYMM(+) AND A.SLPART_CD = B2.SLPART_CD(+) AND A.PRDG_CD = B2.PRDG_CD(+)
AND A.M3 = B3.SALE_YYMM(+) AND A.SLPART_CD = B3.SLPART_CD(+) AND A.PRDG_CD = B3.PRDG_CD(+)
AND A.M4 = B4.SALE_YYMM(+) AND A.SLPART_CD = B4.SLPART_CD(+) AND A.PRDG_CD = B4.PRDG_CD(+)
AND A.M5 = B5.SALE_YYMM(+) AND A.SLPART_CD = B5.SLPART_CD(+) AND A.PRDG_CD = B5.PRDG_CD(+)
AND A.M6 = B6.SALE_YYMM(+) AND A.SLPART_CD = B6.SLPART_CD(+) AND A.PRDG_CD = B6.PRDG_CD(+)
AND B1.PORD_CNT IS NOT NULL
)
SELECT 
    A.SALE_YYMM,
--    A.SLPART_CD,
    SUM(DECODE(A.PRDG_CD,'001',A.PORD_CNT,0)) PORD_CNT_001,
    SUM(DECODE(A.PRDG_CD,'002',A.PORD_CNT,0)) PORD_CNT_002,
    SUM(DECODE(A.PRDG_CD,'004',A.PORD_CNT,0)) PORD_CNT_004,
    SUM(DECODE(A.PRDG_CD,'008',A.PORD_CNT,0)) PORD_CNT_008,
    SUM(DECODE(A.PRDG_CD,'003',A.PORD_CNT,0)) PORD_CNT_003,
    SUM(DECODE(A.PRDG_CD,'005',A.PORD_CNT,0)) PORD_CNT_005,
    SUM(DECODE(A.PRDG_CD,'510',A.PORD_CNT,0)) PORD_CNT_510,

    SUM(DECODE(A.PRDG_CD,'001',A.GR_PORD_CNT,0)) GR_PORD_CNT_001,
    SUM(DECODE(A.PRDG_CD,'002',A.GR_PORD_CNT,0)) GR_PORD_CNT_002,
    SUM(DECODE(A.PRDG_CD,'004',A.GR_PORD_CNT,0)) GR_PORD_CNT_004,
    SUM(DECODE(A.PRDG_CD,'008',A.GR_PORD_CNT,0)) GR_PORD_CNT_008,
    SUM(DECODE(A.PRDG_CD,'003',A.GR_PORD_CNT,0)) GR_PORD_CNT_003,
    SUM(DECODE(A.PRDG_CD,'005',A.GR_PORD_CNT,0)) GR_PORD_CNT_005,
    SUM(DECODE(A.PRDG_CD,'510',A.GR_PORD_CNT,0)) GR_PORD_CNT_510
FROM 
    VW_GR_PORD_CNT A
WHERE 1=1
AND A.SLPART_CD = '2'
GROUP BY
    SALE_YYMM,
    SLPART_CD
ORDER BY
    SALE_YYMM,
    SLPART_CD
;

-- F-2_최근3개월성장률반영_판매량_VS_당월_판매량
CREATE TABLE SULIM_PRDT_IDX_F_2 AS
WITH VW_GR AS (
SELECT
    A.*,
    DECODE(B.PORD_CNT,0,0,ROUND(A.PORD_CNT/B.PORD_CNT,5)) AS GR,
    TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-1),'YYYYMM') AS M1,
    TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-2),'YYYYMM') AS M2,
    TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-3),'YYYYMM') AS M3
FROM
    SULIM_ORD_CNT A,
    SULIM_ORD_CNT B
WHERE 1=1
AND TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-1),'YYYYMM') = B.SALE_YYMM
AND A.SLPART_CD = B.SLPART_CD
AND A.PRDG_CD = B.PRDG_CD
)
, VW_GR_PORD_CNT AS (
SELECT A.*
      ,ROUND((NVL(B1.GR,1)+NVL(B2.GR,1)+NVL(B3.GR,1))/3,5) RCNT_6_AVG_GR
      ,ROUND(B1.PORD_CNT*((NVL(B1.GR,1)+NVL(B2.GR,1))/3),0) GR_PORD_CNT
  FROM
    VW_GR A,
    VW_GR B1,
    VW_GR B2,
    VW_GR B3
WHERE 1=1
AND A.M1 = B1.SALE_YYMM(+) AND A.SLPART_CD = B1.SLPART_CD(+) AND A.PRDG_CD = B1.PRDG_CD(+)
AND A.M2 = B2.SALE_YYMM(+) AND A.SLPART_CD = B2.SLPART_CD(+) AND A.PRDG_CD = B2.PRDG_CD(+)
AND A.M3 = B3.SALE_YYMM(+) AND A.SLPART_CD = B3.SLPART_CD(+) AND A.PRDG_CD = B3.PRDG_CD(+)
AND B1.PORD_CNT IS NOT NULL
)
SELECT 
    A.SALE_YYMM,
--    A.SLPART_CD,
    SUM(DECODE(A.PRDG_CD,'001',A.PORD_CNT,0)) PORD_CNT_001,
    SUM(DECODE(A.PRDG_CD,'002',A.PORD_CNT,0)) PORD_CNT_002,
    SUM(DECODE(A.PRDG_CD,'003',A.PORD_CNT,0)) PORD_CNT_003,
    SUM(DECODE(A.PRDG_CD,'004',A.PORD_CNT,0)) PORD_CNT_004,
    SUM(DECODE(A.PRDG_CD,'007',A.PORD_CNT,0)) PORD_CNT_007,
    SUM(DECODE(A.PRDG_CD,'008',A.PORD_CNT,0)) PORD_CNT_008,
    SUM(DECODE(A.PRDG_CD,'510',A.PORD_CNT,0)) PORD_CNT_510,

    SUM(DECODE(A.PRDG_CD,'001',A.GR_PORD_CNT,0)) GR_PORD_CNT_001,
    SUM(DECODE(A.PRDG_CD,'002',A.GR_PORD_CNT,0)) GR_PORD_CNT_002,
    SUM(DECODE(A.PRDG_CD,'003',A.GR_PORD_CNT,0)) GR_PORD_CNT_003,
    SUM(DECODE(A.PRDG_CD,'004',A.GR_PORD_CNT,0)) GR_PORD_CNT_004,
    SUM(DECODE(A.PRDG_CD,'007',A.GR_PORD_CNT,0)) GR_PORD_CNT_007,
    SUM(DECODE(A.PRDG_CD,'008',A.GR_PORD_CNT,0)) GR_PORD_CNT_008,
    SUM(DECODE(A.PRDG_CD,'510',A.GR_PORD_CNT,0)) GR_PORD_CNT_510
FROM 
    VW_GR_PORD_CNT A
WHERE 1=1
AND A.SLPART_CD = '2'
GROUP BY
    SALE_YYMM
ORDER BY
    SALE_YYMM
;

-- H-1_전월_일시불_VS_당월_일시불
CREATE TABLE SULIM_PRDT_IDX_H_1 AS
WITH VW_SRC AS (
SELECT SALE_YYMM 
      ,SUM(PORD_CNT) AS PORD_CNT
  FROM SULIM_ORD_CNT
 WHERE SLPART_CD = '1'
 GROUP BY
       SALE_YYMM
)
SELECT A.*
      ,B.PORD_CNT AS PORD_CNT_M1
  FROM VW_SRC A
      ,VW_SRC B
 WHERE TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-1),'YYYYMM') = B.SALE_YYMM
;

-- H-2_최근3개월_일시불_VS_당월_일시불
CREATE TABLE SULIM_PRDT_IDX_H_2 AS
WITH VW_SRC AS (
SELECT SALE_YYMM 
      ,SUM(PORD_CNT) AS PORD_CNT
  FROM SULIM_ORD_CNT
 WHERE SLPART_CD = '1'
 GROUP BY
       SALE_YYMM
)
SELECT A.*
      ,ROUND((B1.PORD_CNT+B2.PORD_CNT+B3.PORD_CNT)/3) AS PORD_CNT_M3
  FROM VW_SRC A
      ,VW_SRC B1
      ,VW_SRC B2
      ,VW_SRC B3
 WHERE 1=1
   AND TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-1),'YYYYMM') = B1.SALE_YYMM
   AND TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-2),'YYYYMM') = B2.SALE_YYMM
   AND TO_CHAR(ADD_MONTHS(TO_DATE(A.SALE_YYMM,'YYYYMM'),-3),'YYYYMM') = B3.SALE_YYMM
;

-- I-1_연평균_계절지수반영_VS_당월_판매량
CREATE TABLE SULIM_PRDT_IDX_I_1 AS
WITH VW_SRC AS (
SELECT
    M.*,
    
    ROUND((B1.PORD_CNT+B2.PORD_CNT+B3.PORD_CNT+B4.PORD_CNT+B5.PORD_CNT+B6.PORD_CNT+
           B7.PORD_CNT+B8.PORD_CNT+B9.PORD_CNT+B10.PORD_CNT+B11.PORD_CNT+B12.PORD_CNT)/12) AS LAT_PORD_CNT,

    B1.PORD_CNT AS B1_PORD_CNT,
    B2.PORD_CNT AS B2_PORD_CNT,
    B3.PORD_CNT AS B3_PORD_CNT,
    B4.PORD_CNT AS B4_PORD_CNT,
    B5.PORD_CNT AS B5_PORD_CNT,
    B6.PORD_CNT AS B6_PORD_CNT

FROM
    SULIM_ORD_CNT M,
    SULIM_ORD_CNT B1,
    SULIM_ORD_CNT B2,
    SULIM_ORD_CNT B3,
    SULIM_ORD_CNT B4,
    SULIM_ORD_CNT B5,
    SULIM_ORD_CNT B6,
    SULIM_ORD_CNT B7,
    SULIM_ORD_CNT B8,
    SULIM_ORD_CNT B9,
    SULIM_ORD_CNT B10,
    SULIM_ORD_CNT B11,
    SULIM_ORD_CNT B12
WHERE 1=1
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-1 ),'YYYYMM') = B1.SALE_YYMM  AND M.SLPART_CD = B1.SLPART_CD  AND M.PRDG_CD = B1.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-2 ),'YYYYMM') = B2.SALE_YYMM  AND M.SLPART_CD = B2.SLPART_CD  AND M.PRDG_CD = B2.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-3 ),'YYYYMM') = B3.SALE_YYMM  AND M.SLPART_CD = B3.SLPART_CD  AND M.PRDG_CD = B3.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-4 ),'YYYYMM') = B4.SALE_YYMM  AND M.SLPART_CD = B4.SLPART_CD  AND M.PRDG_CD = B4.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-5 ),'YYYYMM') = B5.SALE_YYMM  AND M.SLPART_CD = B5.SLPART_CD  AND M.PRDG_CD = B5.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-6 ),'YYYYMM') = B6.SALE_YYMM  AND M.SLPART_CD = B6.SLPART_CD  AND M.PRDG_CD = B6.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-7 ),'YYYYMM') = B7.SALE_YYMM  AND M.SLPART_CD = B7.SLPART_CD  AND M.PRDG_CD = B7.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-8 ),'YYYYMM') = B8.SALE_YYMM  AND M.SLPART_CD = B8.SLPART_CD  AND M.PRDG_CD = B8.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-9 ),'YYYYMM') = B9.SALE_YYMM  AND M.SLPART_CD = B9.SLPART_CD  AND M.PRDG_CD = B9.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-10),'YYYYMM') = B10.SALE_YYMM AND M.SLPART_CD = B10.SLPART_CD AND M.PRDG_CD = B10.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-11),'YYYYMM') = B11.SALE_YYMM AND M.SLPART_CD = B11.SLPART_CD AND M.PRDG_CD = B11.PRDG_CD
AND TO_CHAR(ADD_MONTHS(TO_DATE(M.SALE_YYMM,'YYYYMM'),-12),'YYYYMM') = B12.SALE_YYMM AND M.SLPART_CD = B12.SLPART_CD AND M.PRDG_CD = B12.PRDG_CD
)
,VW_SRC2 AS (
SELECT
    SUBSTR(SALE_YYMM,5,2) AS MM,
    PRDG_CD,
    ROUND(SUM(PORD_CNT)/COUNT(1)) AS AVG_MM_PORD_CNT
FROM
    VW_SRC
WHERE 1=1
AND SLPART_CD = '2'
GROUP BY
    SUBSTR(SALE_YYMM,5,2),
    PRDG_CD
)
,VW_MM_IDX AS (
SELECT
    A.*,
    B.TOT_MM_PORD_CNT,
    ROUND(A.AVG_MM_PORD_CNT/B.TOT_MM_PORD_CNT,   5) AS MM_PORD_PCNT,
    ROUND(A.AVG_MM_PORD_CNT/B.TOT_MM_PORD_CNT*12,5) AS MM_IDX
FROM
    VW_SRC2 A,
    (
    SELECT
        PRDG_CD,
        SUM(AVG_MM_PORD_CNT) TOT_MM_PORD_CNT
    FROM
        VW_SRC2
    GROUP BY
        PRDG_CD
    ) B
WHERE 1=1
AND A.PRDG_CD = B.PRDG_CD
AND B.TOT_MM_PORD_CNT <> 0
ORDER BY
    A.PRDG_CD,
    A.MM
)
, VW_REPORT AS (
SELECT
    M.SALE_YYMM,
    M.PRDG_CD,
    M.PORD_CNT,
    ROUND(M.LAT_PORD_CNT*I.MM_IDX) AS SESSON_PORD_CNT,
    M.LAT_PORD_CNT,
    I.MM_IDX
FROM
    VW_SRC M,
    VW_MM_IDX I
WHERE 1=1
AND M.SLPART_CD = '2'
AND SUBSTR(M.SALE_YYMM,5,2) = I.MM
AND M.PRDG_CD = I.PRDG_CD
)
SELECT
    SALE_YYMM,

    SUM(DECODE(PRDG_CD,'001',PORD_CNT,0)) AS PORD_CNT_001,
    SUM(DECODE(PRDG_CD,'002',PORD_CNT,0)) AS PORD_CNT_002,
    SUM(DECODE(PRDG_CD,'004',PORD_CNT,0)) AS PORD_CNT_004,
    SUM(DECODE(PRDG_CD,'008',PORD_CNT,0)) AS PORD_CNT_008,
    SUM(DECODE(PRDG_CD,'003',PORD_CNT,0)) AS PORD_CNT_003,
    SUM(DECODE(PRDG_CD,'005',PORD_CNT,0)) AS PORD_CNT_005,
    SUM(DECODE(PRDG_CD,'510',PORD_CNT,0)) AS PORD_CNT_510,

    SUM(DECODE(PRDG_CD,'001',SESSON_PORD_CNT,0)) AS SESSON_001,
    SUM(DECODE(PRDG_CD,'002',SESSON_PORD_CNT,0)) AS SESSON_002,
    SUM(DECODE(PRDG_CD,'004',SESSON_PORD_CNT,0)) AS SESSON_004,
    SUM(DECODE(PRDG_CD,'008',SESSON_PORD_CNT,0)) AS SESSON_008,
    SUM(DECODE(PRDG_CD,'003',SESSON_PORD_CNT,0)) AS SESSON_003,
    SUM(DECODE(PRDG_CD,'005',SESSON_PORD_CNT,0)) AS SESSON_005,
    SUM(DECODE(PRDG_CD,'510',SESSON_PORD_CNT,0)) AS SESSON_510

FROM
    VW_REPORT
GROUP BY
    SALE_YYMM
ORDER BY
    SALE_YYMM
;