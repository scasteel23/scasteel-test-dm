SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


--Ashwini 23-Jul-2007

--This funtion is to retrieve the termination date of employees from table:EDW_T_JOB_HIST


CREATE FUNCTION [dbo].[DailyUpdate_fn_Get_Termination_date]
(
	@edw_pers_id as varchar(10)
)
RETURNS varchar(12)  AS  

BEGIN 

	DECLARE @job_end_dt as varchar(12)

	SELECT	@job_end_dt =  JH.job_end_dt
	FROM	Decision_Support_HR.dbo.EDW_T_JOB_HIST JH
				INNER JOIN
			Decision_Support_HR.dbo.EDW_V_JOB_DETL_HIST_1 JDH1

		ON	JDH1.edw_pers_id = JH.edw_pers_id 
	
	WHERE	JDH1.job_detl_coll_cd = 'KM' AND
			JH.job_data_status_desc = 'current' AND
			JH.job_cur_info_ind = 'Y' and 
			JH.edw_pers_id = @edw_pers_id and 
			JH.job_end_dt is not null

ORDER BY JH.job_end_dt 

RETURN @job_end_dt

END

/*

DECLARE @job_end_dt AS varchar(12)
SELECT @job_end_dt = [dbo].[DailyUpdate_fn_Get_Termination_date_1]('76481')
print @job_end_dt

*/
GO
