
declare
-- This code does following: 
-- 1) takes indicated Shift Procedure (#323) which has been prepared Last for B2C (Business 2 Customer in contrast with B2B - Business 2 Business) Shift Group and close it.
--    According to the Shift application business flow - next week Shift may be generated only if previous one is "closed".
--    This changes just STATUS of the procedure.
-- 2) new procedure is generated
-- 3) so called Shift Types are copied from previous Procedure to the new one
-- 4) empty Shifts are generated for the new Procedure
-- 5) Operators (in this case B2C Operators) are copied from previous Procedure to the new one.
-- 6) so called Shift types Exclusions (i.e. in which Shifts particular Operator(s) are restricted to participate) for Operators are copied from previous Procedure to the new one
  p_proc_id constant number := 323; -- 
  v_proc pshft_commons1.shiftProcType;
  v_proc_id number; 
begin
  v_proc := pshft_commons1.getShiftProc(p_proc_id);
  pshft_generator.flagProcedureAssignsDone(p_proc_id => p_proc_id, p_user_id => 0);
  v_proc_id := pshft_generator.generateNewProcedure('Generation procedure for ' || to_char(v_proc.PERIOD_TO+1, 'mm/dd/yyyy') || ' - ' || to_char(v_proc.PERIOD_TO+7, 'mm/dd/yyyy'), 0, v_proc.group_id);
  pshft_generator.copyShiftTypesFromPrevProc(p_proc_id => v_proc_id, p_user_id => 0, p_if_commit => 0);
  pshft_generator.generateEmptyShifts(p_proc_id => v_proc_id, p_user_id => 0);
  pshft_generator.copyOperatorsFromPrevProc(p_proc_id => v_proc_id, p_user_id => 0, p_if_commit => 0);
  pshft_generator.copyShiftTypeExclFromPrevProc(p_proc_id => v_proc_id, p_user_id => 0, p_if_commit => 0);
  dbms_output.put_line('Procedure: ' || p_proc_id || ' has been closed; Procedure: ' || v_proc_id || ' has been generated');
end; 


-- See Last Procedure generated (normaly should be #325 - from oracle sequence), Previous Procedure (#323) - closed (STATUS = 9)
select * from SHFT_SHIFT_PROC
       order by id desc, fd
-- Look at the copied Shift Types 
select * from SHFT_SHIFT_TYPE st
       where proc_id = 325
       order by st.HOUR_START
-- Look at the just generated Empty Shifts 
select * from SHFT_SHIFT       
       where proc_id = 325
-- look at the copied Operators
select * from SHFT_OPERATOR 
       where proc_id = 325
       order by ORD_NUM
-- look at the copied Operators Shift Types exclusions
select * from SHFT_OPERATOR_EXC 
       where proc_id = 325
       order by ID
