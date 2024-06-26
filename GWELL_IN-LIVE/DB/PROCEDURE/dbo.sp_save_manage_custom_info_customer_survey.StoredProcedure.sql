/****** Object:  StoredProcedure [dbo].[sp_save_manage_custom_info_customer_survey]    Script Date: 4/24/2020 12:39:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[sp_save_manage_custom_info_customer_survey]
GO
/****** Object:  StoredProcedure [dbo].[sp_save_manage_custom_info_customer_survey]    Script Date: 4/24/2020 12:39:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_save_manage_custom_info_customer_survey] 
    @i_session_id [sessionid], 
    @i_user_id [userid], 
    @i_client_id [uddt_client_id], 
    @i_locale_id [uddt_locale_id], 
    @i_country_code [uddt_country_code], 
    @i_custom_info_code [uddt_varchar_60], 
    @i_custom_info_ref_no1 [uddt_nvarchar_60], 
    @i_custom_info_ref_no2 [uddt_nvarchar_60], 
    @i_inputparam_header_xml [uddt_nvarchar_max], 
    @i_rec_timestamp [uddt_uid_timestamp], 
    @i_save_mode [uddt_varchar_1], 
	@o_outputparam_detail_xml [uddt_nvarchar_max] OUTPUT, 
    @o_update_status [uddt_varchar_5] OUTPUT, 
	@custom_info_detail [sp_save_manage_custom_info_custom_info_detail] READONLY,
    @errorNo [errorno] OUTPUT
AS
BEGIN
    /*
     * Function to save custom info
     */
    -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON;


    -- The following SQL snippet illustrates (with sample values) assignment of scalar output parameters
    -- returned out of this stored procedure

    -- Use SET | SELECT for assigning values
    /*
    SET 
         @o_update_status = '' /* string */
         @errorNo = ''	/* string */
     */

    /*
     * List of errors associated to this stored procedure. Use the text of the error
     * messages printed below as a guidance to set appropriate error number to @errorNo inside the procedure.
     * E_UP_005 - Update Failure : Record updated by another user. Please Retry the retrieval of the record and update.
     * E_UP_251 - Failed saving Information
     * 
     * Use the following SQL statement to set @errorNo:
     * SET @errorNo = 'One of the error numbers associated to this procedure as per list above'
     */

	 
	declare @p_inputparam_header_xml xml,
			@p_customer_id nvarchar(15),
			@p_customer_location_code nvarchar(15),
			@p_requirement nvarchar(1000),
			@p_additional_information varchar(1000),
			
			@p_custom_info_detail_sl_no tinyint, 
			@p_custom_info_detail_inputparam_detail_xml nvarchar(max),
			@p_custom_info_detail_crud_ind varchar(1),
			@p_custom_info_detail_inputparam_detail_fields xml

	declare @p_inputparam_xml xml,
			@p_channel_id		[uddt_varchar_20], 
			@p_call_ref_no		[uddt_nvarchar_20], 
			@p_wfeventverb_id	[uddt_varchar_60], 
			@p_event_date		[uddt_date], 
			@p_event_hour		[uddt_hour], 
			@p_event_minute		[uddt_minute], 
			@p_from_wf_stage_no tinyint, 
			@p_to_wf_stage_no	tinyint,
			@p_from_wf_status	[uddt_varchar_2], 
			@p_to_wf_status		[uddt_varchar_2], 
			@p_by_employee_id	nvarchar(12),
			@p_to_employee_id_string [uddt_nvarchar_255], 
			@p_reason_code		[uddt_nvarchar_50], 
			@p_comments			[uddt_nvarchar_1000], 
			@p_lattitude_value	[uddt_varchar_10], 
			@p_longitude_value	[uddt_varchar_10], 
			@p_inputparam_xml1	[uddt_nvarchar_max], 
			@p_inputparam_xml2	[uddt_nvarchar_max], 
			@p_inputparam_xml3	[uddt_nvarchar_max], 
			@p_attachment_xml	[uddt_nvarchar_max], 
			@p_rec_tstamp		[uddt_uid_timestamp],	
			@p_save_mode		[uddt_varchar_1],
			@p_retrieve_status	varchar(10)

	
	
	set @errorNo = ''

	create table #input_params_header
	(
	paramname varchar(50) not null,
	paramval varchar(50) null
	)

	set @p_inputparam_header_xml = +CAST(replace(@i_inputparam_header_xml,'\/','/') as XML)

	insert #input_params_header
	(paramname, paramval)
	SELECT nodes.value('local-name(.)', 'varchar(50)'),
			nodes.value('(.)[1]', 'varchar(1000)')
	FROM @p_inputparam_header_xml.nodes('/inputparam/*') AS Tbl(nodes)

	update #input_params_header
	set paramval = null 
	where paramval = 'ALL'
	or paramval = ''

	select @p_channel_id				=	'WEB'
	select @p_call_ref_no				=	paramval 	from #input_params_header	where paramname = 'p_request_ref_no'
	select @p_wfeventverb_id			=	paramval 	from #input_params_header	where paramname = 'p_wfeventverb_id'
	select @p_event_date				=	paramval 	from #input_params_header	where paramname = 'p_event_date'
	select @p_event_hour				=	paramval 	from #input_params_header	where paramname = 'p_event_hour'
	select @p_event_minute				=	paramval 	from #input_params_header	where paramname = 'p_event_minute'
	select @p_from_wf_stage_no 			=	paramval 	from #input_params_header	where paramname = 'p_from_wf_stage_no'
	select @p_to_wf_stage_no			=	paramval 	from #input_params_header	where paramname = 'p_to_wf_stage_no'
	select @p_from_wf_status			=	paramval 	from #input_params_header	where paramname = 'p_from_wf_status'
	select @p_to_wf_status				=	paramval 	from #input_params_header	where paramname = 'p_to_wf_status'
	select @p_to_employee_id_string		=	paramval 	from #input_params_header	where paramname = 'p_to_employee_id_string'
	select @p_reason_code				=	paramval 	from #input_params_header	where paramname = 'p_reason_code'
	select @p_comments					=	paramval 	from #input_params_header	where paramname = 'p_comments'
	select @p_lattitude_value			=	paramval 	from #input_params_header	where paramname = 'p_lattitude_value'
	select @p_longitude_value			=	paramval 	from #input_params_header	where paramname = 'p_longitude_value'
	select @p_inputparam_xml1			=	paramval 	from #input_params_header	where paramname = 'p_attachment_xml'
	select @p_inputparam_xml2			=	paramval 	from #input_params_header	where paramname = 'p_inputparam_xml1'
	select @p_inputparam_xml3			=	paramval 	from #input_params_header	where paramname = 'p_inputparam_xml2'
	select @p_attachment_xml			=	paramval 	from #input_params_header	where paramname = 'p_inputparam_xml3'
	select @p_rec_tstamp				=	paramval 	from #input_params_header	where paramname = 'p_rec_tstamp'
	select @p_save_mode					=	paramval 	from #input_params_header	where paramname = 'p_save_mode'
	select @p_by_employee_id			=	@i_user_id

		
	create table #input_params_custom_info_detail_inputparam_detail_fields
	(
		paramname nvarchar(100) not null,
		paramval nvarchar(500) not null
	)
	
		if @i_save_mode = ''
		 begin
			if exists ( select 1 from ancillary_request_register
							where company_id = @i_client_id
							  and country_code = @i_country_code
							  and request_ref_no = @p_call_ref_no

						) and (@p_wfeventverb_id ='PROGRESSUPDATE')
				begin			

					update ancillary_request_register
					set 
						additional_information = @p_comments

					where company_id = @i_client_id
					  and country_code = @i_country_code
					  and request_ref_no = @p_call_ref_no
			 

		
					/*if @@ROWCOUNT = 0
					begin
						--set @errorNo = 'E_UP_251'
						--raiserror('Failed to update Ancillary register', 15,1)
						--return

					end
	
				end
				else
				begin
					select @errorNo = 'E_UP_251'
					raiserror('Record does not exists', 15,1)
					return
				end		*/
 
		 end
	end

	 if @i_save_mode = 'U'
	 begin

 
		select @p_customer_id = paramval
		from #input_params_header
		where paramname = 'customer_id'

			
		select @p_customer_location_code = paramval
		from #input_params_header
		where paramname = 'customer_location_code'

		select @p_requirement = paramval
		from #input_params_header
		where paramname = 'requirement'

		select @p_additional_information = paramval
		from #input_params_header
		where paramname = 'additional_information'
	
		

		if exists ( select 1 from ancillary_request_register
						where company_id = @i_client_id
						  and country_code = @i_country_code
						  and request_ref_no = @i_custom_info_ref_no1

					)
		begin

			

			update ancillary_request_register
			set 
				requirement = @p_requirement

			where company_id = @i_client_id
			  and country_code = @i_country_code
			  and request_ref_no = @i_custom_info_ref_no1
			 

		
			if @@ROWCOUNT = 0
			begin
				set @errorNo = 'E_UP_251'
				raiserror('Failed to update Ancillary register', 15,1)
				return
			end
	
		end
		else
		begin
			select @errorNo = 'E_UP_251'
			raiserror('Record does not exists', 15,1)
			return
		end		
 
	 end
	 if @i_save_mode = 'W'
	 begin
	
			EXECUTE sp_update_ancillary_request_wfeventverb_status_change
			@i_client_id, 
			@i_country_code ,
			@i_session_id ,
			@i_user_id ,
			@i_locale_id ,
			@p_call_ref_no,
			@p_channel_id ,
			@p_wfeventverb_id,
			@p_event_date ,
			@p_event_hour ,
			@p_event_minute ,
			@p_from_wf_stage_no,
			@p_to_wf_stage_no , 
			@p_from_wf_status , 
			@p_to_wf_status  ,
			@p_by_employee_id ,
			@p_to_employee_id_string ,
			@p_reason_code,
			@p_comments,
			@p_lattitude_value,
			@p_longitude_value,
			@p_inputparam_xml1,
			@p_inputparam_xml2,
			@p_inputparam_xml3,
			@p_attachment_xml,
			@p_rec_tstamp,
			@p_save_mode,
			@o_update_status  OUTPUT,
			@errorNo OUTPUT
	 end

	set @o_update_status = 'SP001'

    SET NOCOUNT OFF;
END


