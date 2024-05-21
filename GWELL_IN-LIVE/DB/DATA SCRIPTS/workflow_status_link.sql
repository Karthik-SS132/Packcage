declare @p_company_id varchar(20), @p_country_code varchar(5)

select @p_company_id = 'gwell'

select @p_country_code = 'in'


delete from workflow_status_link where company_id = 'gwell' and country_code = 'in'  and transaction_type_code = 'ANCILLARY' and request_category = 'CS'

insert workflow_status_link (company_id, country_code, transaction_type_code, request_category, request_type, from_workflow_stage, from_status, to_workflow_stage, to_status,lcl_value,ucl_value, last_update_id) 
select 'gwell', 'in', 'ANCILLARY', 'CS', 'ALL', 1, 'AC', 2, 'CL','NA','NA', 'system'

insert workflow_status_link (company_id, country_code, transaction_type_code, request_category, request_type, from_workflow_stage, from_status, to_workflow_stage, to_status,lcl_value,ucl_value, last_update_id) 
select 'gwell', 'in', 'ANCILLARY', 'CS', 'ALL', 1, 'NR', 1, 'NR','NA','NA', 'system'

insert workflow_status_link (company_id, country_code, transaction_type_code, request_category, request_type, from_workflow_stage, from_status, to_workflow_stage, to_status,lcl_value,ucl_value, last_update_id) 
select 'gwell', 'in', 'ANCILLARY', 'CS', 'ALL', 1, 'O', 1, 'NR','NA','NA', 'system'

