create or replace package PSHFT_EXCLUSION is

  -- Author  : USER
  -- Created : 02.01.2012 16:43:22
  -- Purpose : Manages Operators exclusions


-- Exclusion Type Group - Exclusion with Exclusion Type EXCTYPE_SHIFTTYPE is considered as belonging to it
EXCTYPE_GRP_SHIFTTYPE constant number := 1;
-- Exclusion Type Group - Exclusion with Exclusion Type EXCTYPE_PERIOD or EXCTYPE_DAYOFF is considered as belonging to it
EXCTYPE_GRP_RestDays constant number := 2;


------------------------------------
-- Exclusion Types (see SHFT_OPERATOR_EXC.EXC_TYPE)
------------------------------------
-- Exclusion Types: Operator is Excluded to be assigned to the ANY Shift of particular Shift Type
EXCTYPE_SHIFTTYPE constant number := 1;
-- Exclusion Types: Operator is Excluded to be assigned to the particular Shift
EXCTYPE_SHIFT constant number := 2;
-- Exclusion Types: Operator is Excluded to be assigned to any Shift intersecting with particular Period
EXCTYPE_PERIOD constant number := 3;
-- Exclusion Types: Operator is Excluded to be assigned to any Shift intersecting with particular Day assigned as DayOff
EXCTYPE_DAYOFF constant number := 4;


------------------------------------
-- Operator Exclusion Status
------------------------------------
-- Operator Exclusion Status: Exception is Active (will be applied during shift generation)
OPERATOREXC_STATUS_ACTIVE constant pls_integer := 1;
-- Operator Exclusion Status: Exception is Canceled (will NOT be applied during shift generation)
OPERATOREXC_STATUS_CANCELED constant pls_integer := 10;

TYPE exclusionType is RECORD (
  ID number,
  EXC_TYPE number
);

TYPE exclCursor is REF CURSOR; --  RETURN SHFT_OPERATOR_EXC%ROWTYPE;

TYPE distrDayOffs is REF CURSOR; -- spcial cursor for DayOffs distribution by Days

-- Setup DayOff Exclusion type for particular Operator within particular Procedure
-- #param p_proc_id
-- #param p_operator_id
-- #param p_exc_type Exclusion Type. For this procedure - should be always EXCTYPE_DAYOFF.
-- #param p_assigned_dayoff DayOff date assigned as exclusion
-- #param p_correction_gap number indicates how many days forward (if > 0) or backward (if < 0) may this day off be shifted without violation between-DayOffs distance limitation Rule.
procedure setupExclusion4Operator(p_proc_id number, p_operator_id number, p_exc_type number, p_assigned_dayoff date, p_correction_gap number := 0, p_user_id number := 0);

-- Setup Period (Vacation) Exclusion type for particular Operator within particular Procedure
-- #param p_proc_id
-- #param p_operator_id
-- #param p_exc_type Exclusion Type. For this procedure - should be always EXCTYPE_PERIOD.
-- #param p_period_from Period start date (inclusive)
-- #param p_period_to Period end date (inclusive)
procedure setupExclusion4Operator(p_proc_id number, p_operator_id number, p_exc_type number, p_period_from date, p_period_to date, p_user_id number := 0);


-- Setup ShiftType of Shift Exclusion type for particular Operator within particular Procedure
-- #param p_proc_id
-- #param p_operator_id
-- #param p_exc_type Exclusion Type. For this procedure - should be always:
--        either EXCTYPE_SHIFTTYPE (in which case p_shift_type should be indicated) or
--               EXCTYPE_SHIFT (in which case p_shift_id should be indicated)
-- #param p_shift_type Shift Type which is excluded (used only with p_exc_type = EXCTYPE_SHIFTTYPE)
-- #param p_shift Shift System ID which is excluded (used only with p_exc_type = EXCTYPE_SHIFT)
procedure setupExclusion4Operator(p_proc_id number, p_operator_id number, p_exc_type number, p_shift_type number, p_shift_id number, p_user_id number := 0);


-- Detects if indicated Day is Exclusion Day for indicated Operator and returns its Exclusion Type if it is
-- (i.e. either EXCTYPE_PERIOD or EXCTYPE_DAYOFF) or NULL if Day is not exclusion
-- #param p_operator_user_id Operator's UserID (not dependent on Generation Procedure!) which is checked
-- #p_day Date (if hour-min-sec indicated - truncated to the Day!) checked.
function checkExclusionType4Day(p_operator_user_id number, p_day date) return number;

-- Check if particular day is working day for particular Operator.
-- This actually depends on the Exclusions: Vacation, DayOff type.
-- No other Rules are checked as whole Day may be switched off only because of them.
-- NOTE: a) if day supplied is not covered by Generation Procedure indicated Operator belongs to - Day will be Reported NOT available
--       b) to be sure Day is not available because the same Operator already has been assigned to it -
--       use another version of this method, with additional [p_if_check_assignments] parameter
-- #return 1 = Day is available
--         0 = Day is not available
function checkIfDayIsAvailable(p_operator_id number, p_day date) return number;


function checkIfDayIsAvailableByUser(p_user_operator_id number, p_day date) return number;

-- Checks if DAY is available for this Operator to be assigned to some Shift.
-- DAY may be NOT available if:
-- a) this DAY if DayOff (from Exclusions)
-- b) if Operator has vacation in this DAY (from Exclusions)
-- c) if Operator has been already Assigned to some Shift in this DAY
-- NOTE: a) if day supplied is not covered by Generation Procedure indicated Operator belongs to - Day will be Reported NOT available
-- #param p_operator_id Operator System ID
-- #param p_day Day
-- #param p_if_check_assignments 1 = Check Assignments
--                               0 = Don't check assignments
-- #return 1 - if Day is found to be available for Operator
--         0 - if Day by some Reason (reason is not reported!) is not available
function checkIfDayIsAvailable(p_operator_id number, p_day date, p_if_check_assignments number) return number;


-- Returns Cursor of Days which are available for Operator within week to be assigned to some Shift in it.
-- #param p_week any date within week to represent it
-- #param p_date_before if NOT NULL - checked will be only days of this week AFTER the day (inclusive) this date belongs to
--        if NULL (default) - all days of week will be checked on availability
-- #param p_if_check_assignments 1 (default) = day will be checked on both exclusions (Vacation, DayOff) and whether assignment already done within this day (in which case it is not available)
--        0 = assignments are ignored, only exclusions checked.
function getAvailableDays(p_operator_id number, p_week date, p_date_after date := null, p_if_check_assignments number := 1) return PSHFT_COMMONS1.daysCursor;

-- Return cursor on Operators of indicated Procedure havind DayOffs in indicated Day
-- #param p_proc_id System Id of the Procedure
-- #param p_day Day date
-- #param p_if_last indicates if this DayOff should be last for indicated Procedure or not necessarily.
--     1 = only those Operators having DayOff in this day will be returned whose this DayOff is Last for indicated Procedure
--     0 = any Operator having day off in this day will be returned  regardless is it last or not.
-- #param p_orderby indicates Order in which operators are ordered. following values are meaningful: 
--     0 = Random ordering: order by round(dbms_random.value(1, 10000))
--     1 = order by SHFT_OPERATOR.ORD_NUM (default)
--     2 = order by SHFT_OPERATOR.ID 
--     3 = order by SHFT_OPERATOR.OPERATOR_USER_ID
--     4 = order by SHFT_OPERATOR.OPERATOR_PERSONNAME
function getOperatorsHavingDayOff(p_proc_id number, p_day date, p_if_last number := 0, p_orderby number := 1) return PSHFT_COMMONS1.operatorsCursor;

-- Checks if there are some Exclusions which makes this Shift not available for indicated Operator
-- Checked are following Exclusions: <BR>
-- EXCTYPE_SHIFTTYPE - probably type of the Shift is excluded for indicated Operator<BR>
-- EXCTYPE_SHIFT - probably this very Shift is excluded for indicated Operator<BR>
-- EXCTYPE_PERIOD - probably period of this Shift - intersects with the period of Exclusion<BR>
-- EXCTYPE_DAYOFF - probably period of this Shift - intersects with the DayOff Exclusion<BR>
-- NOTE: about DayOff and Vacations - it is acceptable Shift to have TAILs in the Night of DayOff day!
function checkIfShiftIsAvailable(p_shift_id number, p_operator_id number) return exclusionType;

function checkShiftTypeAvailable(p_operator_id number, p_shift_type number) return boolean;

-- Assigns particular Restriction Group to particular Operator.
-- This assignment leads to the following actions:
-- 1) all existing Exclusions related to the Shift Type (i.e. EXC_TYPE = 1) are removed if any for the indicated Operator 
--    (i.e. within context of the Generation Proceddure this Operator belongs to)
-- 2) new Exclusions of the Shift Type related determined for the Restriction Group (if any) are assigmed to the indicated Operator 
--    (i.e. within context of the Generation Proceddure this Operator belongs to)
-- 3) Restriction Group is setup into the SHFT_OPERATOR.RESTRICT_GRP
-- If particular restriction group already is assigned to the Operator - it is re-assigned following all expressed above actions.
-- #param p_operator_id Id of the Operator
-- #param p_restrgr_code Code of the Restriction Group to be assigned (according Dictionary # PSHFT_DICTS.DCODE_OperRestrictGroup)
procedure assignRestrictionGroup(p_operator_id number, p_restrgr_code number, p_user_id number := 0);


-- for particular Exclusion - sets up Period Start and End Dates to the new values by mean of creation of New Version on the indicated Exclusion Object 
-- It is assumed (but not controlled) that Exclusion is of type compatible with RestDays group (i.e. EXCTYPE_GRP_RestDays)
-- #param p_excl_id Exclusion System ID
-- #param p_date_from Period Start date value
-- #param p_date_to Period End date value
-- #raises NO_DATA_FOUND if indicate Exclusion is not found
procedure editExclusion(p_excl_id number, p_date_from date, p_date_to date, p_user_id number);

-- Removes indicated Exclusion
procedure removeExclusion(p_excl_id number);

-- Returns open cursor to the Resultset which representc Exclusions (i.e. SHFT_SHIFT_EXC.*) for indicated filter
-- #param p_operator_id Operator ID in behalf of which Exclusions are to be returned. 
-- #param p_excl_grp indicates which kind of Exclusions we are interested to see. The possible granularity is higher than in SHFT_OPERATOR_EXC.EXC_TYPE.
--   Possible values are (see Global Constants):
--   EXCL_GRP_ShiftType == Shift Type type exlusions - corresponds SHFT_OPERATOR_EXC.EXC_TYPE = 1
--   EXCL_GRP_RestDays  == Rest Days type exlusions  - corresponds SHFT_OPERATOR_EXC.EXC_TYPE = 3 (vacation), 4 (Day Offs)
-- #param p_excl_type makes granularity of choice indicated by p_excl_grp more narrow, indicating particular SHFT_OPERATOR_EXC.EXC_TYPE we are interested in.
--   Possible values are (see Global Constants): EXCTYPE_...at we need.
--   If it is 0 - only p_excl_grp defines 
function retrieveExclusions(p_operator_id number, p_excl_grp number, p_excl_type number) return exclCursor;

-- Returns open cursor to the Resultset which representc Exclusions (i.e. SHFT_SHIFT_EXC.*) for indicated filter
-- #param p_excl_id Exclusion System ID in behalf of which Exclusions are to be returned. 
function retrieveExclusions(p_excl_id number) return exclCursor;

-- Returns open cursor to the Resultset which represents DayOffs distribution by Days. Resultset consists of 2 attributes: 
--         DAY - date of day (1-st second of the day) 
--         DAYOFFS - number of DayOffs existing for this Day
-- #param p_proc_id System Id of the procedure in behalf of which distribution is required
-- #return open Cursor representing DayOffs distribution
function getDayOffsDistribution(p_proc_id number) return distrDayOffs;

end PSHFT_EXCLUSION;
/
create or replace package body PSHFT_EXCLUSION is

--
procedure setupExclusion4Operator(p_proc_id number, p_operator_id number, p_exc_type number,
                                  p_exc_shift_type number, p_exc_shift number,
                                  p_exc_period_from date, p_exc_period_to date, p_correction_gap number,
                                  p_exc_reason_text varchar2, p_status number, p_user_id number);

-- setupExclusion4Operator()
procedure setupExclusion4Operator(p_proc_id number, p_operator_id number, p_exc_type number, p_assigned_dayoff date, p_correction_gap number, p_user_id number) is
/**
declare
  p_proc_id number := 11;
  p_operator_id number := xx;
  p_assigned_dayoff date := dd
  p_correction_gap number := 0;
begin
  PSHFT_EXCLUSION.setupExclusion4Operator(p_proc_id, p_operator_id, PSHFT_EXCLUSION.EXCTYPE_DAYOFF, p_assigned_dayoff, p_correction_gap);
end;
*/
begin
  setupExclusion4Operator(p_proc_id, p_operator_id, p_exc_type,
                          null, null,
                          p_assigned_dayoff, null, p_correction_gap,
                          null, OPERATOREXC_STATUS_ACTIVE, 
                          p_user_id);
end setupExclusion4Operator;

procedure setupExclusion4Operator(p_proc_id number, p_operator_id number, p_exc_type number, p_period_from date, p_period_to date, p_user_id number) is
/**
declare
  p_proc_id number := 15;
  p_operator_id number := 600;
  p_period_from date := to_date('16.01.2012', 'dd.mm.yyyy');
  p_period_to date := to_date('22.01.2012', 'dd.mm.yyyy');
begin
  PSHFT_EXCLUSION.setupExclusion4Operator(p_proc_id, p_operator_id, PSHFT_EXCLUSION.EXCTYPE_PERIOD, p_period_from, p_period_to);
end;
*/
begin
  setupExclusion4Operator(p_proc_id, p_operator_id, p_exc_type,
                          null, null,
                          p_period_from, p_period_to, null,
                          null, OPERATOREXC_STATUS_ACTIVE, 
                          p_user_id);
end;


procedure setupExclusion4Operator(p_proc_id number, p_operator_id number, p_exc_type number, p_shift_type number, p_shift_id number, p_user_id number) is

begin
  setupExclusion4Operator(p_proc_id, p_operator_id, p_exc_type,
                          p_shift_type, p_shift_id,
                          null, null, null,
                          null, OPERATOREXC_STATUS_ACTIVE, 
                          p_user_id);
end;

-- setupExclusion4Operator()
procedure setupExclusion4Operator(p_proc_id number, p_operator_id number, p_exc_type number,
                                  p_exc_shift_type number, p_exc_shift number,
                                  p_exc_period_from date, p_exc_period_to date, p_correction_gap number,
                                  p_exc_reason_text varchar2, p_status number, 
                                  p_user_id number) is
  v_id number;
  v_shiftProc PSHFT_COMMONS1.shiftProcType;
begin
  v_shiftProc := PSHFT_COMMONS1.getShiftProc(p_proc_id);
  select shft_operator_exc_sq_id.nextval into v_id from dual;
  insert into SHFT_OPERATOR_EXC (ID, PROC_ID,	OPERATOR_ID, EXC_TYPE,
                                 EXC_SHIFT_TYPE, EXC_SHIFT,
		                             EXC_PERIOD_FROM, EXC_PERIOD_TO, EXC_REASON_TEXT, STATUS, USER_ID, FD, TD, DUMPSEQ, CORRECTION_GAP)
                         values (v_id, p_proc_id, p_operator_id, p_exc_type,
                                 p_exc_shift_type, p_exc_shift,
                                 p_exc_period_from, p_exc_period_to, p_exc_reason_text, p_status, p_user_id, sysdate, PSHFT_COMMONS1.getInfinity, v_shiftProc.DUMPSEQ, p_correction_gap);
end setupExclusion4Operator;


function checkExclusionType4Day(p_operator_user_id number, p_day date) return number is
/**
declare
  p_operator_user_id number := 1234;
  p_day date := to_date('26.06.2012', 'dd.mm.yyyy');
  v_exc_type number;
begin
  v_exc_type := PSHFT_EXCLUSION.checkExclusionType4Day(p_operator_user_id, p_day);
  dbms_output.put_line('v_exc_type = ' || v_exc_type);
end;
*/
  v_cnt number;
  v_ret_exc_type number := NULL;
begin
   select count(*) into v_cnt
         from SHFT_OPERATOR op, SHFT_OPERATOR_EXC oe
         where op.operator_user_id = p_operator_user_id
               and oe.operator_id = op.id
               and oe.exc_type = EXCTYPE_PERIOD
               and trunc(p_day, 'dd') between oe.exc_period_from and oe.exc_period_to
               and sysdate between op.fd and op.td
               and sysdate between oe.fd and oe.td;
   if v_cnt > 0 then
     v_ret_exc_type := EXCTYPE_PERIOD;
   end if;

   if v_ret_exc_type is null then
       select count(*) into v_cnt
         from SHFT_OPERATOR op, SHFT_OPERATOR_EXC oe
         where op.operator_user_id = p_operator_user_id
               and oe.operator_id = op.id
               and oe.exc_type = EXCTYPE_DAYOFF
               and oe.exc_period_from = trunc(p_day, 'dd')
               and sysdate between op.fd and op.td
               and sysdate between oe.fd and oe.td;
       if v_cnt > 0 then
         v_ret_exc_type := EXCTYPE_DAYOFF;
       end if;
   end if;

   return v_ret_exc_type;

end;

-- checkIfDayIsAvailable()
function checkIfDayIsAvailable(p_operator_id number, p_day date) return number is
/**
declare
  p_operator_id number := 580;
  p_day date := to_date('15-Dec-2011', 'dd.mm.yyyy');
  v_ret number;
begin
  v_ret := PSHFT_EXCLUSION.checkIfDayIsAvailable(p_operator_id, p_day);
  dbms_output.put_line('ret = ' || v_ret);
end;
*/

  v_proc PSHFT_COMMONS1.shiftProcType;
  v_id number;
  v_ret number := 1;
  cursor crsExc(cp_oper_id number, cp_day date) is
     select * from SHFT_OPERATOR_EXC oe
          where oe.operator_id = cp_oper_id
                and ((oe.exc_type = EXCTYPE_DAYOFF
                              and oe.exc_period_from = trunc(cp_day, 'dd'))
                     OR
                     (oe.exc_type = EXCTYPE_PERIOD
                              and trunc(cp_day, 'dd') between oe.exc_period_from and oe.exc_period_to)
                     )
                and sysdate between oe.fd and oe.td;
begin

  -- Check date supplied if from Generation Procedure period
  v_proc := PSHFT_COMMONS1.getShiftProcByOperator(p_operator_id);
  if v_proc.id is not null then
     if NOT (p_day between v_proc.PERIOD_FROM and v_proc.PERIOD_TO) then
       v_ret := 0;
     end if;
  else
    v_ret := 0;
  end if;

  if v_ret = 1 then
      for crs in crsExc(p_operator_id, p_day) loop
        v_ret := 0;
        exit;
      end loop;
  end if;
  return v_ret;
end checkIfDayIsAvailable;

function checkIfDayIsAvailableByUser(p_user_operator_id number, p_day date) return number is
  v_operator SHFT_OPERATOR%ROWTYPE;
  v_shiftproc PSHFT_COMMONS1.shiftProcType;
  if_available number;
begin
  v_shiftproc := PSHFT_COMMONS1.getShiftProc(p_day);
  v_operator := PSHFT_COMMONS1.getOperatorByUserId(v_shiftproc.id, p_user_operator_id);
  if_available := checkIfDayIsAvailable(v_operator.id, p_day);
  return if_available;
end;


-- checkIfDayIsAvailable
function checkIfDayIsAvailable(p_operator_id number, p_day date, p_if_check_assignments number) return number is
  v_ret number;
  v_shift SHFT_SHIFT%ROWTYPE;
begin

  v_ret := checkIfDayIsAvailable(p_operator_id, p_day);
  if v_ret = 1 and p_if_check_assignments = 1 then
    -- Now check if Operator has been already assigned.
    v_shift := PSHFT_COMMONS1.getAssignedShift(p_operator_id, p_day);
    if v_shift.id is not null then
       v_ret := 0;
    end if;
  end if;

  return v_ret;

end checkIfDayIsAvailable;


-- getAvailableDays
function getAvailableDays(p_operator_id number, p_week date, p_date_after date, p_if_check_assignments number) return PSHFT_COMMONS1.daysCursor is
/**
declare
  p_operator_id number := 580;
  p_week date := to_date('09.01.2012', 'dd.mm.yyyy');
  c_days PSHFT_COMMONS1.daysCursor;
  v_day date;
begin
  c_days := PSHFT_EXCLUSION.getAvailableDays(p_operator_id, p_week);
  LOOP
    FETCH c_days into v_day;
    EXIT when c_days%NOTFOUND;

    dbms_output.put_line('day: ' || v_day);
  END LOOP;

  CLOSE c_days;
end;
*/
  v_date_from date;
  v_week_startday date;
  v_week_lastsecond date;
  c_days PSHFT_COMMONS1.daysCursor;
  v_day date;
begin

  v_week_startday := PSHFT_COMMONS1.getWeekStartDate(p_week);
  v_week_lastsecond := v_week_startday + 7 - PSHFT_COMMONS1.ONE_SECOND;

  if p_date_after is null then
     v_date_from := v_week_startday;
  else
     v_date_from := trunc(p_date_after, 'dd');
  end if;

  OPEN c_days for
    select * from (

          select trunc(sh.shift_start_hour, 'dd') day
             from SHFT_SHIFT sh
             where sh.status != PSHFT_COMMONS1.SHIFT_STATUS_CANCELED
                   and sh.shift_start_hour between v_date_from and v_week_lastsecond
                   and sysdate between fd and td
             group by trunc(sh.shift_start_hour, 'dd')

          ) where checkIfDayIsAvailable(p_operator_id, day, p_if_check_assignments) = 1
            order by day;

  return c_days;

end getAvailableDays;

-- getOperatorsHavingDayOff()
function getOperatorsHavingDayOff(p_proc_id number, p_day date, p_if_last number, p_orderby number) return PSHFT_COMMONS1.operatorsCursor is
/**
declare
  p_proc_id number := 15;
  p_day date := to_date('09.01.2012', 'dd.mm.yyyy');
  c_opers PSHFT_COMMONS1.operatorsCursor;
  v_operator SHFT_OPERATOR%ROWTYPE;
begin
  c_opers := getOperatorsHavingDayOff(p_proc_id, p_day);
  LOOP
    FETCH c_opers into v_operator;
    EXIT when c_opers%NOTFOUND;

    dbms_output.put_line('id = ' || v_operator.id);
  END LOOP;
  CLOSE c_opers;
end;
*/
  c_opers PSHFT_COMMONS1.operatorsCursor;
begin
  if p_if_last = 1 then
     open c_opers for
          select op.* from SHFT_OPERATOR op
                where id in (select operator_id
                                from SHFT_OPERATOR_EXC oe
                                where oe.proc_id = p_proc_id
                                      and oe.exc_type = EXCTYPE_DAYOFF
                                      and oe.exc_period_from = trunc(p_day, 'dd')
                                      and oe.status = OPERATOREXC_STATUS_ACTIVE
                                      and not exists (select * from SHFT_OPERATOR_EXC
                                                         where exc_type = 4
                                                               and proc_id = oe.proc_id
                                                               and operator_id = oe.operator_id
                                                               and exc_period_from > oe.exc_period_from
                                                               and status = OPERATOREXC_STATUS_ACTIVE
                                                               and sysdate between fd and td)
                                      and sysdate between fd and td
                              )
                       and sysdate between fd and td
                       and op.status = PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED
                order by decode(p_orderby, 0, round(dbms_random.value(1, 10000)), 1, ORD_NUM, 2, ID, 3, OPERATOR_USER_ID, 4, OPERATOR_PERSONNAME);
  else
     open c_opers for
          select op.* from SHFT_OPERATOR op
                where id in (select operator_id
                                from SHFT_OPERATOR_EXC oe
                                where oe.proc_id = p_proc_id
                                      and oe.exc_type = EXCTYPE_DAYOFF
                                      and oe.exc_period_from = trunc(p_day, 'dd')
                                      and oe.status = OPERATOREXC_STATUS_ACTIVE
                                      and sysdate between fd and td)
                       and sysdate between fd and td
                       and op.status = PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED
                order by decode(p_orderby, 0, round(dbms_random.value(1, 10000)), 1, ORD_NUM, 2, ID, 3, OPERATOR_USER_ID, 4, OPERATOR_PERSONNAME);
  end if;
  return c_opers;
end getOperatorsHavingDayOff;




-- checkIfShiftIsAvailable
function checkIfShiftIsAvailable(p_shift_id number, p_operator_id number) return exclusionType is
/**
declare
  p_shift_id number := ss;
  p_operator_id number := oo;
  v_excl exclusionType;
begin
  v_excl := PSHFT_EXCLUSION.checkIfShiftIsAvailable(p_shift_id, p_operator_id);
  dbms_output('Excl Type = ' || v_excl.EXC_TYPE || ', ' Exc ID = ' || v_excl.ID);
end;
*/
  v_shift SHFT_SHIFT%ROWTYPE;
  v_excl exclusionType;
  v_period_from date;
  v_period_to date;
  cursor crsExc(cp_oper_id number, cp_proc_id number) is
     select * from SHFT_OPERATOR_EXC oe
          where oe.operator_id = cp_oper_id
                and oe.proc_id = cp_proc_id
                and sysdate between fd and td;
  if_excluded boolean := false;
begin
  v_shift := PSHFT_COMMONS1.getShift(p_shift_id);
  for crs in crsExc(p_operator_id, v_shift.proc_id) loop

    if crs.exc_type = EXCTYPE_SHIFTTYPE then
        if crs.exc_shift_type = v_shift.shift_type then
          if_excluded := true;
        end if;
    elsif crs.exc_type = EXCTYPE_SHIFT then
        if crs.exc_shift = v_shift.id then
          if_excluded := true;
        end if;
    elsif crs.exc_type = EXCTYPE_PERIOD OR crs.exc_type = EXCTYPE_DAYOFF then
        v_period_from := crs.exc_period_from;
        if crs.exc_type = EXCTYPE_PERIOD then
          v_period_to := crs.exc_period_to;
        else
          v_period_to := trunc(crs.exc_period_from, 'dd') + 1 - PSHFT_COMMONS1.ONE_SECOND;
        end if;
        -- There was additional condition to period intersection: OR v_period_from between v_shift.shift_start_hour and v_shift.shift_end_hour
        -- But after consultations with Vera - was consirmed that it is acceptable when Evening Shifts leave their Tails in the next DayOff night:
        -- 20:00- Shift - 2 hours, 19:00- Shift - 1 hour.
        -- Until Shift Application becomes more flexible (DRULLS :)?) - more late evening shifts should be prohibited.
        if v_shift.shift_start_hour between v_period_from and v_period_to then
           if_excluded := true;
        end if;
    end if;
    if if_excluded then
      v_excl.ID := crs.id;
      v_excl.EXC_TYPE := crs.exc_type;
      exit;
    end if;
  end loop;
  if NOT if_excluded then
    v_excl.ID := null;
  end if;
  return v_excl;
end checkIfShiftIsAvailable;

-- checkShiftTypeAvailable()
function checkShiftTypeAvailable(p_operator_id number, p_shift_type number) return boolean is
  v_result boolean;
  v_count number;
begin
  select count(*) into v_count
         from SHFT_OPERATOR_EXC oe
         where oe.operator_id = p_operator_id
               and oe.exc_type = EXCTYPE_SHIFTTYPE
               and oe.Status = OPERATOREXC_STATUS_ACTIVE
               and oe.exc_shift_type = p_shift_type
               and sysdate between fd and td;
  if v_count > 0 then
    v_result := false;
  else
    v_result := true;
  end if;

  return v_result;

end checkShiftTypeAvailable;

-- assignRestrictionGroup()
procedure assignRestrictionGroup(p_operator_id number, p_restrgr_code number, p_user_id number) is
/**
declare
  p_operator_id number := xx;
  p_restrgrp number := yy;
  p_user_id number := 0
begin
  PSHFT_EXCLUSION.assignRestrictionGroup(p_operator_id, p_restrgr, p_user_id);
end;
*/
  v_counter number; 
  v_proc_id number; 
  cursor crsRestrGrp(cp_restrgrp_code number) is 
         select * from SHFT_OPERATOR_RESTRGRP org 
                where org.grp_code = cp_restrgrp_code
                order by org.shift_type;
begin
  -- Step.0: detect both Operator and Restriction Group code are correct (i.e. exist)
  -- a) check Operator
  begin
    select proc_id into v_proc_id 
           from SHFT_OPERATOR op 
           where op.id = p_operator_id
                 and sysdate between fd and td;
  exception
    when NO_DATA_FOUND then
       raise PSHFT_COMMONS1.exOperatorNotExists;
  end;
  -- a) check Restriction Group
  select count(*) into v_counter from SHFT_DICT dd 
         where dd.up = PSHFT_DICTS.DCODE_OperRestrictGroup
               and dd.code = p_restrgr_code;
  if v_counter = 0 then
    raise PSHFT_COMMONS1.exRestrictionGrpNotExists;
  end if;
  
  -- Step.1: delete all existing Exclusions of type Shift Type for indicated Operator
  delete from SHFT_OPERATOR_EXC oe
         where oe.operator_id = p_operator_id
               and oe.exc_type = EXCTYPE_SHIFTTYPE
               and sysdate between fd and td;
  
  -- Step.2: assign Exclusions of Shift Type type expressed by indicated Restriction Group
  for crs in crsRestrGrp(p_restrgr_code) loop
    setupExclusion4Operator(v_proc_id, p_operator_id, EXCTYPE_SHIFTTYPE, crs.shift_type, null, p_user_id);
  end loop;
  
  -- Step.3: setup indicated Restriction Group into the SHFT_OPERATOR.RESTRICT_GRP
  update SHFT_OPERATOR
         set RESTRICT_GRP = p_restrgr_code 
         where id = p_operator_id
               and sysdate between fd and td;
  commit;
end assignRestrictionGroup;

-- editExclusion()
procedure editExclusion(p_excl_id number, p_date_from date, p_date_to date, p_user_id number) as
/**
declare
  p_excl_id number := 4408;
  p_date_from date := to_date('10.01.2012', 'dd.mm.yyyy');
  p_date_to date := to_date('11.01.2012', 'dd.mm.yyyy');
begin
  PSHFT_EXCLUSION.editExclusion(p_excl_id, p_date_from, p_date_to);
end;
*/
  obj SHFT_OPERATOR_EXC%ROWTYPE;
  v_rowid rowid;
  v_sysdate date;
  if_update boolean := false;
begin
  select rowid into v_rowid from SHFT_OPERATOR_EXC oe
         where oe.id = p_excl_id
               and sysdate between fd and td;
  select * into obj from SHFT_OPERATOR_EXC
         where rowid = v_rowid;
  if obj.Exc_Type = EXCTYPE_DAYOFF or obj.Exc_Type = EXCTYPE_PERIOD then 
    if obj.exc_period_from is not NULL AND obj.exc_period_from != p_date_from then
      if_update := true;
    end if;  
  end if;
  if NOT if_update AND obj.Exc_Type = EXCTYPE_PERIOD then
    if obj.exc_period_to is not NULL AND obj.exc_period_to != p_date_to then
      if_update := true;
    end if;  
  end if;
  
  if if_update then
    v_sysdate := sysdate;
    obj.exc_period_from := p_date_from;
    if obj.Exc_Type = EXCTYPE_PERIOD then 
      obj.exc_period_to := p_date_to;
    end if;
    obj.FD := v_sysdate; 
    obj.TD := PSHFT_COMMONS1.getInfinity;
    obj.user_id := p_user_id;
    insert into SHFT_OPERATOR_EXC values obj;
    update SHFT_OPERATOR_EXC oe
           set TD = v_sysdate - PSHFT_COMMONS1.ONE_SECOND
           where oe.rowid = v_rowid;
  end if;
end editExclusion;

-- removeExclusion()
procedure removeExclusion(p_excl_id number) as
begin
  delete from SHFT_OPERATOR_EXC oe
         where oe.id = p_excl_id;
end removeExclusion;


-- retrieveExclusions(...)
function retrieveExclusions(p_operator_id number, p_excl_grp number, p_excl_type number) return exclCursor is
/**
declare
  p_operator_id number; 
  p_excl_grp number; 
  p_excl_type number;
  v_curs PSHFT_EXCLUSION.exclCursor;
  rec SHFT_OPERATOR_EXC%ROWTYPE;
begin
  v_curs := PSHFT_EXCLUSION.retrieveExclusions(p_operator_id, p_excl_grp, p_excl_type);
  loop
    fetch v_curs into rec;
    exit when v_curs%notfound;
    dbms_output.put_line('id = ' || rec.ID || ', exc_type = ' || rec.EXC_TYPE);
  end loop;
end;
*/
  c_excl exclCursor;
  v_sql varchar2(2000) := 'select * from SHFT_OPERATOR_EXC ex 
                                  WHERE operator_id = @operId
                                        @whereCond
                                        and sysdate between fd and td
                                  Order By @orderBy'; 
  v_sqlstr_where varchar2(500) := '';
  if_where boolean := false;
  v_sqlstr_orderby varchar2(500);
begin
  if p_excl_type > 0 then 
    v_sqlstr_where := 'EXC_TYPE = ' || p_excl_type;
    if p_excl_type = EXCTYPE_SHIFTTYPE then
        v_sqlstr_orderby := 'EXC_SHIFT_TYPE';
    elsif p_excl_type in (EXCTYPE_PERIOD, EXCTYPE_DAYOFF) then
        v_sqlstr_orderby := 'EXC_PERIOD_FROM';
    else
        v_sqlstr_orderby := 'ID';
    end if;
    if_where := true;
  else
    if p_excl_grp in (EXCTYPE_GRP_SHIFTTYPE, EXCTYPE_GRP_RestDays) then
      case p_excl_grp
        when EXCTYPE_GRP_SHIFTTYPE then
             v_sqlstr_where := 'EXC_TYPE = ' || EXCTYPE_SHIFTTYPE;
             if_where := true;
             v_sqlstr_orderby := 'EXC_SHIFT_TYPE';
        when EXCTYPE_GRP_RestDays then
             v_sqlstr_where := 'EXC_TYPE in (' || EXCTYPE_PERIOD || ', ' || EXCTYPE_DAYOFF || ')';
             if_where := true;
             v_sqlstr_orderby := 'EXC_PERIOD_FROM';
      end case;
    else
      v_sqlstr_orderby := 'ID';
    end if;
  end if;
  if if_where then
    v_sqlstr_where := ' and ' || v_sqlstr_where;
  end if;
  
  v_sql := replace(v_sql, '@operId', p_operator_id);
  v_sql := replace(v_sql, '@whereCond', v_sqlstr_where);
  v_sql := replace(v_sql, '@orderBy', v_sqlstr_orderby);
     
  open c_excl for v_sql;
  
  return c_excl;
  
end retrieveExclusions;  

-- retrieveExclusions(p_excl_id)
function retrieveExclusions(p_excl_id number) return exclCursor as
/**
declare
  p_excl_id number := xxx; 
  v_curs PSHFT_EXCLUSION.exclCursor;
  rec SHFT_OPERATOR_EXC%ROWTYPE;
begin
  v_curs := PSHFT_EXCLUSION.retrieveExclusions(p_excl_id);
  loop
    fetch v_curs into rec;
    exit when v_curs%notfound;
    dbms_output.put_line('id = ' || rec.ID || ', exc_type = ' || rec.EXC_TYPE);
  end loop;
end;
*/
  v_sql varchar2(2000) := 'select * from SHFT_OPERATOR_EXC ex 
                                  WHERE id = @id and sysdate between fd and td';
  c_excl exclCursor;
begin
    
  v_sql := replace(v_sql, '@id', p_excl_id);
  open c_excl for v_sql;
  
  return c_excl;
    
end;

-- getDayOffsDistribution()
function getDayOffsDistribution(p_proc_id number) return distrDayOffs as
/**
declare
  TYPE recDistr is RECORD (
    day DATE, 
    dayoffs number
  );
  c_dayoffs PSHFT_EXCLUSION.distrDayOffs;
  p_proc_id number := 93;
  v_distr recDistr;
begin
  c_dayoffs := PSHFT_EXCLUSION.getDayOffsDistribution(p_proc_id);
  LOOP
    FETCH c_dayoffs into v_distr;
    EXIT when c_dayoffs%NOTFOUND;
    dbms_output.put_line(to_char(v_distr.day, 'dd.mm.yyyy') || ':   ' || v_distr.dayoffs);
  END LOOP;
  CLOSE c_dayoffs;
end;
*/
  c_distrib distrDayOffs;
begin
  open c_distrib for 
         select trunc(oe.exc_period_from, 'dd'), count(*) cases
             from SHFT_OPERATOR_EXC oe
             where oe.exc_type = 4
                   and oe.proc_id = p_proc_id
                   and sysdate between fd and td
                   and oe.operator_id > 0 -- to bypass bug when DayOffs are generated sometimes with NULL in operator_id
             group by trunc(oe.exc_period_from, 'dd')
             order by 1;
       
  return c_distrib;
  
end getDayOffsDistribution;


end PSHFT_EXCLUSION;
/
