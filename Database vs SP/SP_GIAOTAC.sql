USE [CHUNGKHOAN]
GO
/****** Object:  StoredProcedure [dbo].[SP_GIAOTAC]    Script Date: 10/19/2019 10:18:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[SP_GIAOTAC]
@minsup float,
@isinc int
as
BEGIN

select MACP,COUNT(NGAY) as sup into #DSMACP_Sup from LSGIA WHERE (@isinc =1 and GIAMOCUA < GIADONGCUA) or (@isinc =0 and GIAMOCUA > GIADONGCUA) group by MACP
DECLARE @SUP float 
DECLARE @cnt int
 
SET @SUP  =(@minsup * (select COUNT(DISTINCT (NGAY)) FROM LSGIA))/100.0

SELECT DISTINCT(MACP) INTO #DSMACP FROM #DSMACP_Sup 
   WHERE SUP >= @SUP ORDER BY (MACP)

SET @cnt = (SELECT COUNT(DISTINCT(MACP)) FROM #DSMACP) 
if(@cnt = 0)
BEGIN
return 0
END

DECLARE @PivotColumnHeader varchar(max)
SET @PivotColumnHeader = ''
SELECT @PivotColumnHeader += RTRIM(MACP) + ',' FROM #DSMACP
SET @PivotColumnHeader = SUBSTRING(@PivotColumnHeader,1,LEN(@PivotColumnHeader)-1)
 
SELECT NGAY,MACP into #LSGIA from LSGIA WHERE (@isinc =1 and GIAMOCUA < GIADONGCUA) or (@isinc =0 and GIAMOCUA > GIADONGCUA)

DECLARE @PivotTable varchar(MAX)
SET @PivotTable = 'SELECT * FROM #LSGIA Pivot( COUNT(MACP) for MACP in ('+ @PivotColumnHeader +')) as PivotTable'
PRINT (@PivotTable)
execute(@PivotTable)
DROP table #LSGIA
end