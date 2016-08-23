create or replace package PSHFT_OPERATOR is

  -- Author  : BESO
  -- Created : 4/3/2013 5:28:38 PM
  -- Purpose : Contains set of procedures managing Operators - before they are processed in context of Shift generation.
  

-- Updates Operator's Personal ID.
-- NOTE: Update is performed in context of Current Procedure (indicated Operator ID belongs to).
-- If this context is Last existing Procedure - then - its value will be propagated to the next Procedures that will be generated then, too!
procedure editPersonalId(p_operator_id number, p_personal_id varchar2);

-- Randomization is required to treat all Operators JUST between different Procedures. 
-- Only if Operators will be randomized and thus invoked in random order with each new generation Procedure - 
-- any algorithm involved in process may without doubt pick up next Operator for processing not thinking if any unwilling 
-- tendency be applied to this particular Operator. 
-- Say, algorithm may try to complete Early Morning Shifts as early as possible. 
-- If no randomization is applied - always same Operators will participate in Early Morning shifts, 
-- while other (picked up last) - won't. 
-- Such treatment is NOT JUST and will be soon objected by Operators treated this way.
-- Net result: SHFT_OPERATOR.ORD_NUM columns are UPDATEd for Last versions of all active Operators under indicated Procedure, 
--             i.e. no New version is generated!
-- Transaction: COMMITting
-- #param p_proc_id System Id of the procedure to which Randomization is applying
procedure randomizeOperators(p_proc_id number);

-- Removes indicated Operator from the Procedure it belongs to. 
-- Removal operation is possible ONLY if this particular Operator doesn't participate in any Shift Assignments within this procedure.
-- Otherwise - Exception is raised.
-- Net Result: Closed Version (TD = Sysdate) is created with STATUS = PSHFT_COMMONS1.OPERATOR_STATUS_CANCELED
-- #param p_operator_id System Id of the Operator (i.e. SHFT_OPERATOR.ID)
-- #param p_user_id System Id of the User in context of which remove is performed
-- #raises PSHFT_COMMONS1.exObjectUsed if indicated Operator is assigned to any Shift within this Procedure
-- #raises NO_DATA_FOUND - if indicated Operator doesn't exist 
procedure removeOperatorFromProcedure(p_operator_id number, p_user_id number);

end PSHFT_OPERATOR;
/
create or replace package body PSHFT_OPERATOR is


-- editPersonalId
procedure editPersonalId(p_operator_id number, p_personal_id varchar2) as
begin
  update SHFT_OPERATOR op
         set op.operator_personalid = p_personal_id
         where op.id = p_operator_id
               and sysdate between fd and td;
end editPersonalId;


-- randomizeOperators
procedure randomizeOperators(p_proc_id number) as
/**
declare
  p_proc_id number := xxx;
begin
  PSHFT_OPERATOR.randomizeOperators(p_proc_id);
end;
*/
  cursor crsOpers(cp_proc_id number) is    
      select rownum, d.* from (
         select op.*, op.rowid, dbms_random.value(1, 10) ord
              from SHFT_OPERATOR op
              where proc_id = cp_proc_id
                    and sysdate between fd and td
                    and status = PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED
              order by ord
      ) d; 
begin
  for crs in crsOpers(p_proc_id) loop
    update SHFT_OPERATOR op
           set op.ord_num = crs.rownum
           where rowid = crs.rowid
                 and proc_id = p_proc_id;
  end loop; 
  commit;
end;

-- removeOperatorFromProcedure(..)
procedure removeOperatorFromProcedure(p_operator_id number, p_user_id number) is
  v_num number;
  v_oper SHFT_OPERATOR%ROWTYPE;
  v_rowid rowid;
  v_sysdate date := sysdate;
begin
  v_num := PSHFT_COMMONS1.getAssignedShiftsNum4Operator(p_operator_id);
  if v_num > 0 then
    raise PSHFT_COMMONS1.exObjectUsed;
  end if;
  
  select rowid into v_rowid from SHFT_OPERATOR
         where id = p_operator_id and sysdate between fd and td;
         
  update SHFT_OPERATOR op 
         set op.td = v_sysdate, 
             op.status = PSHFT_COMMONS1.OPERATOR_STATUS_CANCELED,
             op.user_id = p_user_id
         where rowid = v_rowid;
         
end;


end PSHFT_OPERATOR;
/
