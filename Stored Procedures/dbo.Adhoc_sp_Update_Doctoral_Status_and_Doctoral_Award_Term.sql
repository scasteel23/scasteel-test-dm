SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 8/22/2017
CREATE PROC [dbo].[Adhoc_sp_Update_Doctoral_Status_and_Doctoral_Award_Term]
AS
	WITH awardrecords AS
	(
		--SELECT rta.edw_pers_id, 
		--		rta.pers_lname, rta.pers_fname, rta.pers_mname, 
		--		deg.grad_term_cd, deg.grad_term_desc, deg.grad_acad_yr_desc, 
		--		deg.deg_dept_name, deg.deg_acad_pgm_name, deg.deg_cd, deg.deg_name,
		--		year(deg.grad_dt) grad_year
		--FROM Decision_Support.dbo.edw_v_pers_hist_rta_dir rta 
		--	INNER JOIN Decision_Support.dbo.edw_t_student_ah_deg_hist deg
		--	ON rta.edw_pers_id = deg.edw_pers_id  and 
		--		rta.pers_cur_info_ind = 'y'
		SELECT deg.EDW_PERS_ID
				,deg.grad_term_cd, deg.grad_term_desc, deg.grad_acad_yr_desc
				,deg.deg_dept_name, deg.deg_acad_pgm_name
				,year(deg.grad_dt) grad_year
			
		FROM Decision_Support.dbo.edw_t_student_ah_deg_hist deg
		WHERE 	deg.deg_level_cd = '1G'
			AND deg.deg_cd = 'PHD'
			AND deg.admin_coll_cd = 'ks' 
			AND deg.coll_cd='km'
			AND deg.deg_status_cd = 'aw' 		
	)


	UPDATE Faculty_Staff_Holder.dbo.Facstaff_Basic
	SET Doctoral_Flag=2
		,Doctoral_Award_Term_CD=grad_term_cd
		,Doctoral_Department_ID =
			CASE WHEN aw.deg_dept_name LIKE '%Bus%' THEN 1
				WHEN aw.deg_dept_name LIKE '%Fin%' THEN 2
				WHEN aw.deg_dept_name LIKE '%Acc%' THEN 3 END			 
	FROM awardrecords aw, Faculty_Staff_Holder.dbo.Facstaff_Basic fb
	WHERE aw.EDW_PERS_ID=fb.EDW_PERS_ID
			AND ISNULL(fb.Doctoral_Department_ID,'') <> ''
			AND (ISNULL(fb.Doctoral_Award_Term_CD,'') = '' OR fb.Doctoral_Flag = 3)


	--Select fb.facstaff_id, fb.last_name, fb.first_name, fb.Doctoral_Flag
	--		,aw.grad_term_cd
	--		,CASE WHEN aw.deg_dept_name LIKE '%Bus%' THEN 1
	--			WHEN aw.deg_dept_name LIKE '%Fin%' THEN 2
	--			WHEN aw.deg_dept_name LIKE '%Acc%' THEN 3 END as grad_Department_id
	--		,fb.Doctoral_Department_ID
	--FROM awardrecords aw, Faculty_Staff_Holder.dbo.Facstaff_Basic fb
	--WHERE aw.EDW_PERS_ID=fb.EDW_PERS_ID
	--		AND ISNULL(fb.Doctoral_Department_ID,'') <> ''
	--		AND (ISNULL(fb.Doctoral_Award_Term_CD,'') = '' OR fb.Doctoral_Flag = 3)


--select fb.facstaff_id, fb.last_name, fb.first_name, fb.Doctoral_Flag, fb.Doctoral_Department_ID,fb.Doctoral_Award_Term_CD
--FROM Faculty_Staff_Holder.dbo.Facstaff_Basic fb
--where (ISNULL(fb.Doctoral_Award_Term_CD,'') = '' OR fb.Doctoral_Flag = 3)




		
GO
