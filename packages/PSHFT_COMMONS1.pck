create or replace package PSHFT_COMMONS1 is

  -- Author  : Beso Tarkhnishvili
  -- Created : 03.01.2012 00:19:32
  -- Purpose : Some common constants, types, simple read-only methods

ONE_SECOND constant number := 1/86400;

------------------------------------
-- Shift Generation Procedure STATUS (Dictionary #2)
------------------------------------
-- Shift Generation Procedure STATUS: Initialized
PROC_STATUS_INIT constant pls_integer := 1;

-- Shift Generation Procedure STATUS: Night Shifts are Assigned
PROC_STATUS_NightShiftsAsigned constant pls_integer := 2;
-- PROC_STATUS_READY constant pls_integer := 2;

-- Shift Generation Procedure STATUS: DayOffs setup
PROC_STATUS_DayOffsSetup constant pls_integer := 3;
-- Shift Generation Procedure STATUS: Under Processing
-- PROC_STATUS_UNDERPROC constant pls_integer := 3;

-- Shift Generation Procedure STATUS: Finished (i.e. successfully generated)
PROC_STATUS_FINISHED constant pls_integer := 9;
-- Shift Generation Procedure STATUS: Canceled (canceled by Admin)
PROC_STATUS_CANCELED constant pls_integer := 10;

------------------------------------
-- Shift STATUS (Dictionary #6)
------------------------------------
-- Shift STATUS: Initialized
SHIFT_STATUS_INIT constant pls_integer := 1;
-- Shift STATUS: Ready to be Generated
SHIFT_STATUS_READY constant pls_integer := 2;
-- Shift STATUS: Under Processing
SHIFT_STATUS_UNDERPROC constant pls_integer := 3;
-- Shift STATUS: Finished (i.e. successfully generated)
SHIFT_STATUS_FINISHED constant pls_integer := 4;
-- Shift STATUS: Canceled (canceled by Admin)
SHIFT_STATUS_CANCELED constant pls_integer := 10;


------------------------------------
-- ShiftType STATUS (Dictionary #30)
------------------------------------
--
SHIFTTP_STATUS_ACTIVE constant pls_integer := 1;
--
SHIFTTP_STATUS_CANCELED constant pls_integer := 10;

------------------------------------
-- Operator STATUS (Dictionary #14)
------------------------------------
-- Operator STATUS: Assigned to Shift Generation
OPERATOR_STATUS_ASSIGNED constant pls_integer := 1;
-- Operator STATUS: Canceled from Shift Generation
OPERATOR_STATUS_CANCELED constant pls_integer := 10;

------------------------------------
-- Shift-Operator Link STATUS (Dictionary #10)
------------------------------------
-- Operator STATUS: Assigned to Shift Generation
SHIFTOPERATOR_STATUS_ASSIGNED constant pls_integer := 1;
-- Operator STATUS: Canceled from Shift Generation
SHIFTOPERATOR_STATUS_CANCELED constant pls_integer := 10;

------------------------------------
-- Shift Type (Dictionary #26)
------------------------------------
      -- Shift Type: Morning (8 hour)
--      SHIFT_TYPE_MORNING constant pls_integer := 1;
      -- Shift Type: Day (8 hour)
--      SHIFT_TYPE_DAY constant pls_integer := 2;
      -- Shift Type: Evening (6 hour)
--      SHIFT_TYPE_EVENING constant pls_integer := 3;
      -- Shift Type: Night (7 hour)
--      SHIFT_TYPE_NIGHT constant pls_integer := 4;


-- Shift Type: Night (01:00 - 7 hour)
SHIFT_TYPE_NIGHT constant pls_integer := 1;
-- Shift Type: Early Morning (08:00 - 8-hour)
SHIFT_TYPE_MORNING_EARLY constant pls_integer := 2;
-- Shift Type: Morning (09:00, 10:00 - 8-hour)
SHIFT_TYPE_MORNING constant pls_integer := 3;
-- Shift Type: Day (13:00 - 6 hour)
SHIFT_TYPE_DAY constant pls_integer := 4;
-- Shift Type: Evening (17:00, 18:00, 19:00 - 6 hour)
SHIFT_TYPE_EVENING constant pls_integer := 5;
-- Shift Type: Late Evening (20:00 - 6 hour)
SHIFT_TYPE_EVENING_LATE constant pls_integer := 6;






TYPE shiftProcType is RECORD (
  ID NUMBER,
  PERIOD_FROM DATE,
  PERIOD_TO DATE,
  DUMPSEQ NUMBER,
  DUMPSEQ_PREV NUMBER,
  CLC_DAYS_NUM NUMBER,
  IF_NIGHTSHIFTS_ASSIGNED NUMBER,
	IF_DAYOFFS_GENERATED NUMBER,
	IF_OPERATORS_ASSIGNED NUMBER
);

TYPE assignedShiftsCursor is REF CURSOR;

TYPE shiftsCursor is REF CURSOR;


TYPE operatorsCursor is REF CURSOR;

TYPE daysCursor is REF CURSOR;

exObjectAlreadyExists exception; 

exObjectUsed exception;

exProcedureNotExists exception;
exNightShiftsNotGenerated exception;

exOperatorNotExists exception;
exRestrictionGrpNotExists exception; 

  -- Return Operator record by Operator user ID i behalf of particular Generation Procedure
  -- #param p_proc_id Shift Generation Procedure System ID
  -- #param p_user_id User ID
  function getOperatorByUserId(p_proc_id number, p_user_id number) return SHFT_OPERATOR%ROWTYPE;


  -- Return Operator record by Operator user ID i behalf of particular Generation Procedure
  -- #param p_proc_id Shift Generation Procedure System ID
  -- #param p_user_id User ID
  function getOperatorIdByUserId(p_proc_id number, p_user_id number) return number;


  -- For indicated Operator - return its UserId
  function getUserIdbByOperator(p_operator_id number) return number;

  -- For indicated Generation Procedure - minimal duration of Shifts (from SHFT_SHIFT_TYPE).
  function getShiftMinHours(p_proc_id number) return number;

  -- Gets most recent previous (relative to the indicated Shift) Shift which had been assigned to the indicated Operator
  -- #param p_operator_id System ID of the Operator
  -- #param p_shift_id System ID of the Shift
  function getPreviousShift(p_operator_id number, p_shift_id number) return SHFT_SHIFT%ROWTYPE;

  -- Most close Previous Shift End Hour
  -- #return if this Previous Shift is found - its End Date, if not - NULL
  function getPreviousShiftEndHour(p_operator_id number, p_shift_id number) return date;

  -- Gets most recent previous (relative to the indicated Shift) Shift of indicated Type which had been assigned to the indicated Operator
  -- #param p_operator_id System ID of the Operator
  -- #param p_shift_id System ID of the Shift
  -- #param p_shift_type Type of the Shift we are interested in
  function getPreviousShift(p_operator_id number, p_shift_id number, p_shift_type number) return SHFT_SHIFT%ROWTYPE;


  -- Gets most close next (relative to the indicated Shift) Shift which had been assigned to the indicated Operator
  -- #param p_operator_id System ID of the Operator
  -- #param p_shift_id System ID of the Shift
  function getNextShift(p_operator_id number, p_shift_id number) return SHFT_SHIFT%ROWTYPE;

  -- Gets most recent next (relative to the indicated Shift) Shift of indicated Type which had been assigned to the indicated Operator
  -- #param p_operator_id System ID of the Operator
  -- #param p_shift_id System ID of the Shift
  -- #param p_shift_type Type of the Shift we are interested in
  function getNextShift(p_operator_id number, p_shift_id number, p_shift_type number) return SHFT_SHIFT%ROWTYPE;


  -- Gets whole Shift record for indicated Shift
  -- #param p_shift_id System ID of the Shift
  function getShift(p_shift_id number) return SHFT_SHIFT%ROWTYPE;

  -- Gets Shift System ID for Shift existing fro indicated Day and started at indicated hour
  function getShiftId(p_shift_start_hour number, p_day date) return number;

  -- Shows if particular Operator has been assigned to Particular Shift
  -- #return 1 - if this Operator is assigned to thie Shift, 0 - otherwise
  function ifAssigned2Shift(p_operator_id number, p_shift_id number) return number;

  -- Gets Shift indicated Operator is Assigned to within indicated Day (i.e. Shift Start date within day)
  -- NOTE: similar function exists by Operator User ID - see getAssignedShiftByUserId()
  -- If no Shift is assigned within this Day - return.id is null
  function getAssignedShift(p_operator_id number, p_day date) return SHFT_SHIFT%ROWTYPE;

  -- return open Cursor to the recordset representingoperators (SHFT_OPERATOR) being assigned to the indicated Shift.
  -- Operators are ordered according SHFT_OPERATOR.ORD_NUM
  -- #param p_shift_id System Id of the Shift 
  function getAssignedOperators4Shift(p_shift_id number) return operatorsCursor;
  
  -- Gets number of Operators assigned for indicated Shift
  function getAssignedOperatorsNum(p_shift_id number) return number;

  -- Gets Shift indicated User is Assigned to within indicated Day (i.e. Shift Start date within day)
  -- NOTE: similar function exists by Operator ID - see getAssignedShift()
  -- If no Shift is assigned within this Day - return.id is null
  -- #param p_user_id Uperator User ID whose assigned Shift is required
  function getAssignedShiftByUserId(p_user_id number, p_day date) return SHFT_SHIFT%ROWTYPE;

  -- return Cursor to all Assigned Shifts for indicated Operator resided within indicated period
  function getAssignedShifts(p_operator_id number, p_date_from date, p_date_to date) return assignedShiftsCursor;

  -- Returns number of Shifts this Operator is assigned to within the Procedure it belongs to
  -- #param p_operator_id System Id of the Operator (i.e. SHFT_OPERATOR.ID)
  function getAssignedShiftsNum4Operator(p_operator_id number) return number;

  -- in behalf to the indicated Procedure and indicated Day - return Cursor to the Shifts which aren't complete (i.e. whose Capacity is not filled in fully)
  -- The order is according Fixing priority, that is: weight ASSIGNED_OPERATOR/SHIFT_CAPACITY is minimal - 1-st
  function getNotCompleteShifts(p_proc_id number, p_day date) return shiftsCursor;

  -- in behalf to the indicated Procedure and indicated Day - return Cursor to the Shifts which are assigned Over capacity
  -- The order is according Fixing priority, that is: ASSIGNED_OPERATOR max - 1-st
  function getOverCapacityShifts(p_proc_id number, p_day date) return shiftsCursor;


  -- For indicated Operator and Week - calculate number of already assigned hours
  -- #param p_date fixes week, Hours will be calculated for week indicated date belongs to (i.e. this date may be any moment of week, effect will be the same!)
  -- #param p_date_before will be calculated assignments for only those Days which are before the day this date belongs to, INCLUDING very this day.
  --        if this date is NULL (default) - whole week's assignments will be handled.
  function calculateAssignedHoursInWeek(p_operator_id number, p_date date, p_date_before date := null) return number;

  -- How many hours from previous week SUN assigned Shift - hit this week (for 19:00 and 20:: shifts!)
  -- #param p_date this week any date
  function calcTailHoursFromPreviousWeek(p_operator_id number, p_date date) return number;

  -- Gets structure representing indicated Generation Procedure
  function getShiftProc(p_proc_id number) return shiftProcType;

  -- Gets System Id of the Procedure which is right previous to indicated one
  function getPreviousShiftProcId(p_proc_id number) return number;

  -- Gets structure representing Generation Procedure which is direct previous one relative to the indicated
  function getPreviousShiftProc(p_proc_id number) return shiftProcType;

  -- Get Last existing in the System Procedure System Id which is not canceled. 
  function getLastShiftProcId return number;
  
  -- Last Generation Procedure existin in System is returned
  function getLastShiftProc return shiftProcType;

  -- for indicated Procedure - return particular Date of the Next Procedure period (either From or To part of period) particular Date. 
  -- Note: Period is calculated based on the Period of indicated procedure, based on the Default and Supported assumption that next procedure always starts from next day after previous one and keeps 7 days (1 week). 
  -- #param p_proc_id Procedure System Id
  -- #param p_period_code which date of the Next Procedure Period (From-To) to return: 1 = From, 2 = To
  function getNextShiftProcPeriod(p_proc_id number, p_period_code number) return date;


  -- For indicated Operator - get record describing Shift Procedure this Operator is belonging to
  function getShiftProcByOperator(p_operator_id number) return shiftProcType;

  -- For indicated Day - get record describing Shift Procedure this Day is belonging to
  function getShiftProc(p_day date) return shiftProcType;


  -- Return cursor on Operators participating in indicated Generation Procedure
  function getOperators(p_proc_id number) return operatorsCursor;


  -- For indicated Date - return date which is its Week 1-st day (1-st second)
  function getWeekStartDate(p_date date) return date;
  

  -- For indicated Day - returns Week Day, assuming Mon == 1, Tue = 2, ..., Sun = 7
  function getWeekDay(p_day date) return pls_integer;

  -- for indicated Operator - gets number of DayOffs setup for him within Generation Procedure it belongs to.
  function getNumberOfDayOffs(p_operator_id number) return number;

  -- for indicated Day - gets number of DayOffs setup for it
  function getNumberOfDayOffs(p_day date) return number;

  -- for indicated Day - gets number of Operators having LAST DayOffs setup for this day.
  -- All Operators are considered within particular Generation Procedure
  function getNumberOfLastDayOffs(p_proc_id number, p_day date) return number;

  -- Returns LAST Day which was Rest Day for indicated Operator - due either DayOff or Vacation
  function getLastRestDay(p_operator_id number) return date;

  -- Returns closest DayOff indicated Operator had at day before indicated one.
  -- NULL - if there is no DayOff found
  function getPreviousDayOff(p_operator_userid number, p_day date) return date;

  -- Returns all DayOffs found for this Operator within the period of Generation Procedure it is belonging to
  -- Resultset contains only column of DATE type.
  function getDayOffs(p_operator_id number) return daysCursor;

  -- Returns all DayOffs found for the Operator's User ID within the indicated period
  -- Resultset contains only column of DATE type.
  -- @TODO: Not Implemented Yet
  function getDayOffs(p_operator_user_id number, p_date_from date, p_date_to date) return daysCursor;


  -- Returns all Vacations found for this Operator within the period of Generation Procedure it is belonging to
  -- Resultset contains 2 columns with Period Dates of DATE type.
  function getVacations(p_operator_id number) return daysCursor;

  -- Wrapper of some randomization algorythm.
  function getRandomNumber(num_start pls_integer, num_end pls_integer) return pls_integer;

  function getInfinity return date;

end PSHFT_COMMONS1;
/
create or replace package body PSHFT_COMMONS1 is

DATE_INFINITY constant date := to_date('01.01.3000', 'dd.mm.yyyy');


-- getOperatorByUserId
function getOperatorByUserId(p_proc_id number, p_user_id number) return SHFT_OPERATOR%ROWTYPE is
  v_operator SHFT_OPERATOR%ROWTYPE;
begin
  select * into v_operator
         from SHFT_OPERATOR sop
         where sop.proc_id = p_proc_id and sop.operator_user_id = p_user_id
               and sysdate between fd and td;
  return v_operator;
exception
  when NO_DATA_FOUND then
    v_operator.id := null;
    return v_operator;
  when others then
    v_operator.id := null;
    return v_operator;
end getOperatorByUserId;

-- getOperatorIdByUserId
function getOperatorIdByUserId(p_proc_id number, p_user_id number) return number as
  v_operator SHFT_OPERATOR%ROWTYPE;
begin
  v_operator := getOperatorByUserId(p_proc_id, p_user_id);
  return v_operator.id;
end getOperatorIdByUserId;


-- getUserIdbByOperator
function getUserIdbByOperator(p_operator_id number) return number is
  v_user_id number;
begin
  select op.operator_user_id into v_user_id
         from SHFT_OPERATOR op
         where op.id = p_operator_id
               and sysdate between fd and td;
  return v_user_id;
exception
  WHEN NO_DATA_FOUND then
     return null;
end getUserIdbByOperator;

-- getShiftMinHours
function getShiftMinHours(p_proc_id number) return number is
  v_min_hour number;
begin
  select min(st.hours) into v_min_hour from SHFT_SHIFT_TYPE st
         where st.proc_id = p_proc_id
               and st.hours > 0
               and st.status = SHIFTTP_STATUS_ACTIVE
               and sysdate between fd and td;
  return v_min_hour;
end getShiftMinHours;

-- getPreviousShift
function getPreviousShift(p_operator_id number, p_shift_id number) return SHFT_SHIFT%ROWTYPE is
/**
declare
  p_operator_id number := 589;
  p_shift_id number := 2047;
  v_prev_shift SHFT_SHIFT%ROWTYPE;
begin
  v_prev_shift := PSHFT_COMMONS1.getPreviousShift(p_operator_id, p_shift_id);
  dbms_output.put_line('shift_id = ' || v_prev_shift.id || ', shift_start_hour = ' || to_char(v_prev_shift.SHIFT_START_HOUR, 'dd.mm.yyyy hh24'));
end;
*/
  v_shift SHFT_SHIFT%ROWTYPE;
begin
  v_shift := getPreviousShift(p_operator_id, p_shift_id, 0);
  return v_shift;
end getPreviousShift;

-- getPreviousShiftEndHour
function getPreviousShiftEndHour(p_operator_id number, p_shift_id number) return date is
  v_shift SHFT_SHIFT%ROWTYPE;
begin
  v_shift := getPreviousShift(p_operator_id, p_shift_id);
  if v_shift.id is not null then
     return v_shift.shift_end_hour;
  end if;

  return null;

end getPreviousShiftEndHour;


-- getPreviousShift
function getPreviousShift(p_operator_id number, p_shift_id number, p_shift_type number) return SHFT_SHIFT%ROWTYPE is
  v_date date;
  v_user_id number;
  v_shift SHFT_SHIFT%ROWTYPE;
begin

   select sh.shift_start_hour into v_date
          from SHFT_SHIFT sh
          where sh.id = p_shift_id
                and sysdate between fd and td;


   select op.operator_user_id into v_user_id
          from SHFT_OPERATOR op
          where op.id = p_operator_id
                and sysdate between fd and td;

   select sh.* into v_shift
      from SHFT_SHIFT sh
      where sh.id = (select max(sh1.id)
                       from SHFT_SHIFT sh1,
                            SHFT_OPERATOR op,
                            SHFT_SHIFT_OPERATOR shop
                       where shop.operator_id = op.id
                             and shop.shift_id = sh1.id
                             and op.operator_user_id = v_user_id
                             and sh1.shift_start_hour < v_date
                             and sh1.shift_type = decode(p_shift_type, 0, sh1.shift_type, p_shift_type)
                             and shop.STATUS = PSHFT_COMMONS1.SHIFTOPERATOR_STATUS_ASSIGNED
                             and sysdate between sh1.fd and sh1.td
                             and sysdate between op.fd and op.td
                             and sysdate between shop.fd and shop.td)
            and sysdate between fd and td;

   return v_shift;

exception
  when NO_DATA_FOUND then
    v_shift.id := null;
    return v_shift;
end getPreviousShift;

-- getNextShift
function getNextShift(p_operator_id number, p_shift_id number) return SHFT_SHIFT%ROWTYPE is
  v_shift SHFT_SHIFT%ROWTYPE;
begin
  v_shift := getNextShift(p_operator_id, p_shift_id, 0);
  return v_shift;
end getNextShift;

-- getNextShift
function getNextShift(p_operator_id number, p_shift_id number, p_shift_type number) return SHFT_SHIFT%ROWTYPE is
  v_date date;
  v_user_id number;
  v_shift SHFT_SHIFT%ROWTYPE;
begin

   select sh.shift_start_hour into v_date
          from SHFT_SHIFT sh
          where sh.id = p_shift_id
                and sysdate between fd and td;


   select op.operator_user_id into v_user_id
          from SHFT_OPERATOR op
          where op.id = p_operator_id
                and sysdate between fd and td;

   select sh.* into v_shift
      from SHFT_SHIFT sh
      where sh.id = (select min(sh1.id)
                       from SHFT_SHIFT sh1,
                            SHFT_OPERATOR op,
                            SHFT_SHIFT_OPERATOR shop
                       where shop.operator_id = op.id
                             and shop.shift_id = sh1.id
                             and op.operator_user_id = v_user_id
                             and sh1.shift_start_hour > v_date
                             and sh1.shift_type = decode(p_shift_type, 0, sh1.shift_type, p_shift_type)
                             and shop.STATUS = PSHFT_COMMONS1.SHIFTOPERATOR_STATUS_ASSIGNED
                             and sysdate between sh1.fd and sh1.td
                             and sysdate between op.fd and op.td
                             and sysdate between shop.fd and shop.td
                             )
            and sysdate between fd and td;
                             

   return v_shift;

exception
  when NO_DATA_FOUND then
    v_shift.id := null;
    return v_shift;
end getNextShift;



-- getShift
function getShift(p_shift_id number) return SHFT_SHIFT%ROWTYPE is
  v_shift SHFT_SHIFT%ROWTYPE;
begin

   select * into v_shift
          from SHFT_SHIFT sh
          where sh.id = p_shift_id
                and sysdate between fd and td;

   return v_shift;

exception
  when NO_DATA_FOUND then
    v_shift.id := null;
    return v_shift;
end getShift;

-- getShiftId
function getShiftId(p_shift_start_hour number, p_day date) return number is
  v_shift_id number;
begin
  select id into v_shift_id
         from SHFT_SHIFT sh
         where sh.shift_start_hour = trunc(p_day, 'dd') + p_shift_start_hour/24
               and sysdate between fd and td;
  return v_shift_id;
exception
  when NO_DATA_FOUND then
    return null;
end getShiftId;

-- ifAssigned2Shift
function ifAssigned2Shift(p_operator_id number, p_shift_id number) return number is
  if_assigned number := 0;
begin
  select count(*) into if_assigned
         from SHFT_SHIFT_OPERATOR sop
         where sop.operator_id = p_operator_id and sop.shift_id = p_shift_id
               and sysdate between fd and td;
  return if_assigned;
end ifAssigned2Shift;

-- getAssignedShift
function getAssignedShift(p_operator_id number, p_day date) return SHFT_SHIFT%ROWTYPE is
/**
declare
  p_operator_id number := oo;
  p_day date := to_date('10.01.2012', 'dd.mm.yyyy');
  v_shift SHFT_SHIFT%ROWTYPE;
begin
  v_shift := PSHFT_COMMONS1.getAssignedShift(p_operator_id, p_day);
  dbms_output.put_line('v_shift.ID = ' || v_shift.ID);
end;
*/
  v_counter number := 0;
  v_shift SHFT_SHIFT%ROWTYPE;
  c_cursor PSHFT_COMMONS1.assignedShiftsCursor;
begin
/*
  select sh.* into v_shift
         from SHFT_SHIFT sh, SHFT_SHIFT_OPERATOR sop
         where sop.shift_id = sh.id
               and sop.operator_id = p_operator_id
               and sh.shift_start_hour between trunc(p_day, 'dd') and trunc(p_day, 'dd') + 1 - PSHFT_COMMONS1.ONE_SECOND
               and sop.status = PSHFT_COMMONS1.SHIFTOPERATOR_STATUS_ASSIGNED
               and sh.status != PSHFT_COMMONS1.SHIFT_STATUS_CANCELED;
*/
  c_cursor := PSHFT_COMMONS1.getAssignedShifts(p_operator_id,
                                               trunc(p_day, 'dd'),
                                               trunc(p_day, 'dd') + 1 - PSHFT_COMMONS1.ONE_SECOND);
  -- sees Always only, 1-st record
  LOOP
    FETCH c_cursor INTO  v_shift;
    EXIT when c_cursor%NOTFOUND;

    -- Should be placed after [EXIT when c_cursor%NOTFOUND;]!
    v_counter := v_counter + 1;
    EXIT;
  END LOOP;

  CLOSE c_cursor;

  if v_counter = 0 then
    v_shift.id := null;
  end if;

  return v_shift;

end getAssignedShift;

-- getAssignedOperators4Shift()
function getAssignedOperators4Shift(p_shift_id number) return operatorsCursor is
  c_opers PSHFT_COMMONS1.operatorsCursor;
begin
  open c_opers for
    select * from SHFT_OPERATOR op
       where id in 
           (select sop.operator_id 
              from SHFT_SHIFT_OPERATOR sop
                 where sop.shift_id = p_shift_id
                      and status = PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED
                      and sysdate between fd and td)
          and sysdate between fd and td
       order by op.ord_num;
  return c_opers;
end;

-- getAssignedShiftByUserId
function getAssignedShiftByUserId(p_user_id number, p_day date) return SHFT_SHIFT%ROWTYPE is
/**
-- to choose proper User ID:
  select sh.id, op.operator_user_id, sh.shift_start_hour
         from SHFT_SHIFT sh, SHFT_OPERATOR op, SHFT_SHIFT_OPERATOR sop
         where sop.shift_id = sh.id
               and sop.operator_id = op.id
               and sh.shift_start_hour between to_date('03.01.2012', 'dd.mm.yyyy') and
                                               to_date('04.01.2012', 'dd.mm.yyyy')
declare
  p_user_id number := ;
  p_day date := to_date('03.01.2012', 'dd.mm.yyyy');
  v_shift SHFT_SHIFT%ROWTYPE;
begin
  v_shift := getAssignedShiftByUserId(p_user_id, p_day);
  dbms_output.put_line('shift_id = ' || v_shift.id);
end;
*/
  v_shift SHFT_SHIFT%ROWTYPE;
  v_date_from date;
  v_date_to date;
begin
  v_date_from  := trunc(p_day, 'dd');
  v_date_to := v_date_from + 1 - PSHFT_COMMONS1.ONE_SECOND;
  select sh.* into v_shift
         from SHFT_SHIFT sh, SHFT_OPERATOR op, SHFT_SHIFT_OPERATOR sop
         where sop.shift_id = sh.id
               and sop.operator_id = op.id
               and op.operator_user_id = p_user_id
               and sh.shift_start_hour between v_date_from and v_date_to
               and sysdate between sh.fd and sh.td
               and sysdate between op.fd and op.td
               and sysdate between sop.fd and sop.td;

  return v_shift;
exception
  when others then
    v_shift.id := null;
    return v_shift;
end getAssignedShiftByUserId;


-- getAssignedShifts
function getAssignedShifts(p_operator_id number, p_date_from date, p_date_to date) return assignedShiftsCursor is
  c_cursor PSHFT_COMMONS1.assignedShiftsCursor;
/**
declare
  p_operator_id number := op;
  p_date_from date := to_date('11.01.2012', 'dd.mm.yyyy');
  p_date_to date := to_date('12.01.2012', 'dd.mm.yyyy');
  v_cursor PSHFT_COMMONS1.assignedShiftsCursor;
  v_shift SHFT_SHIFT%ROWTYPE;
begin
  v_cursor := PSHFT_COMMONS1.getAssignedShifts(p_operator_id, p_date_from, p_date_to);
  LOOP
    FETCH v_cursor INTO  v_shift;
    EXIT WHEN c_cursor%NOTFOUND;
    DBMS_OUTPUT.put_line('v_shift.id = ' || v_shift.id);
  END LOOP;
end;
*/
begin
  open c_cursor for
     select sh.*
         from SHFT_SHIFT sh, SHFT_SHIFT_OPERATOR sop
         where sop.shift_id = sh.id
               and sop.operator_id = p_operator_id
               and sh.shift_start_hour between p_date_from and p_date_to
               and sop.status = PSHFT_COMMONS1.SHIFTOPERATOR_STATUS_ASSIGNED
               and sh.status != PSHFT_COMMONS1.SHIFT_STATUS_CANCELED
               and sysdate between sh.fd and sh.td
               and sysdate between sop.fd and sop.td
          order by sh.shift_start_hour;

  return c_cursor;
end getAssignedShifts;

-- getAssignedShiftsNum4Operator(..)
function getAssignedShiftsNum4Operator(p_operator_id number) return number as
  v_num pls_integer;
begin
  select count(*) into v_num from SHFT_SHIFT_OPERATOR sop
         where sop.operator_id = p_operator_id
               and sysdate between fd and td
               and status = SHIFTOPERATOR_STATUS_ASSIGNED;
  return v_num;
end;


function getAssignedOperatorsNum(p_shift_id number)  return number is
/**
declare
  p_shift_id number := 2611;
  v_num number;
begin
  v_num := PSHFT_COMMONS1.getAssignedOperatorsNum(p_shift_id);
  dbms_output.put_line(v_num);
end;
*/
  v_num number;
begin
  select count(*) into v_num
         from SHFT_SHIFT_OPERATOR sop
         where sop.shift_id = p_shift_id
               and sop.status = PSHFT_COMMONS1.SHIFTOPERATOR_STATUS_ASSIGNED
               and sysdate between fd and td;
  return v_num;
end;


-- getNotCompleteShifts
function getNotCompleteShifts(p_proc_id number, p_day date) return shiftsCursor is
/**
declare
  p_proc_id number := 15;
  p_day date := to_date('22.01.2012', 'dd.mm.yyyy');
  c_shifts PSHFT_COMMONS1.shiftsCursor;
  v_shift SHFT_SHIFT%ROWTYPE;
begin
  c_shifts := PSHFT_COMMONS1.getNotCompleteShifts(p_proc_id, p_day);
  LOOP
    FETCH c_shifts into v_shift;
    EXIT WHEN c_shifts%NOTFOUND;

    dbms_output.put_line(to_char(v_shift.shift_start_hour, 'dd.mm.yyyy hh24') || ': capacity = ' || v_shift.shift_capacity || ', assigned = ' || v_shift.assigned_operators);

  END LOOP;
  CLOSE c_shifts;
end;
*/
  v_date_from date := trunc(p_day, 'dd');
  v_date_to date := trunc(p_day, 'dd') + 1 - ONE_SECOND;
  c_cursor shiftsCursor;
begin

  open c_cursor for
     select sh.*
         from SHFT_SHIFT sh
         where sh.proc_id = p_proc_id
               and sh.shift_start_hour between v_date_from and v_date_to
               and sh.status != PSHFT_COMMONS1.SHIFT_STATUS_CANCELED
               and sh.shift_capacity > nvl(sh.assigned_operators, 0)
               and sysdate between fd and td
          order by nvl(sh.assigned_operators, 0)/sh.shift_capacity ASC, sh.id;

  return c_cursor;

end getNotCompleteShifts;

-- getOverCapacityShifts
function getOverCapacityShifts(p_proc_id number, p_day date) return shiftsCursor is
/**
declare
  p_proc_id number := 15;
  p_day date := to_date('22.01.2012', 'dd.mm.yyyy');
  c_shifts PSHFT_COMMONS1.shiftsCursor;
  v_shift SHFT_SHIFT%ROWTYPE;
begin
  c_shifts := PSHFT_COMMONS1.getOverCapacityShifts(p_proc_id, p_day);
  LOOP
    FETCH c_shifts into v_shift;
    EXIT WHEN c_shifts%NOTFOUND;

    dbms_output.put_line(to_char(v_shift.shift_start_hour, 'dd.mm.yyyy hh24') || ': capacity = ' || v_shift.shift_capacity || ', assigned = ' || v_shift.assigned_operators);

  END LOOP;
  CLOSE c_shifts;
end;
*/
  v_date_from date := trunc(p_day, 'dd');
  v_date_to date := trunc(p_day, 'dd') + 1 - ONE_SECOND;
  c_cursor shiftsCursor;
begin

  open c_cursor for
     select sh.*
         from SHFT_SHIFT sh
         where sh.proc_id = p_proc_id
               and sh.shift_start_hour between v_date_from and v_date_to
               and sh.status != PSHFT_COMMONS1.SHIFT_STATUS_CANCELED
               and sh.shift_capacity < sh.assigned_operators
               and sysdate between fd and td
          order by assigned_operators DESC, sh.id;

  return c_cursor;
end getOverCapacityShifts;


-- calculateAssignedHoursInWeek
function calculateAssignedHoursInWeek(p_operator_id number, p_date date, p_date_before date) return number is
/**
declare
  p_operator_id number := 966;
  p_date date := to_date('10.01.2012', 'dd.mm.yyyy');
  p_date_before date := to_date('14.01.2012', 'dd.mm.yyyy');
  v_hours number;
begin
  v_hours := PSHFT_COMMONS1.calculateAssignedHoursInWeek(p_operator_id, p_date, p_date_before);
  dbms_output.put_line('v_hours = ' || v_hours);
end;
*/
  v_hours number := 0;
  v_hour number;
  v_week_startday date;
  v_week_lastsecond date;
  v_date_from date;
  v_date_to date;
  v_shift_start_hour date;
  v_shift_end_hour date;
  v_prev_shift_end date;
  v_tail_hours number;
  v_first_shift_id number;
  v_shift SHFT_SHIFT%ROWTYPE;
  c_cursor PSHFT_COMMONS1.assignedShiftsCursor;
  v_counter number := 0;
begin

  v_week_startday := getWeekStartDate(p_date);

  v_date_from := v_week_startday;

  if p_date_before is not null then
    v_date_to := trunc(p_date_before, 'dd') + 1 - PSHFT_COMMONS1.ONE_SECOND;
  else
    v_date_to := v_week_startday + 7 - PSHFT_COMMONS1.ONE_SECOND;
  end if;

  c_cursor := PSHFT_COMMONS1.getAssignedShifts(p_operator_id,
                                               v_date_from,
                                               v_date_to);

  LOOP

    FETCH c_cursor into v_shift;

    EXIT WHEN c_cursor%NOTFOUND;

    v_counter := v_counter + 1;

    if v_counter = 1 then
       v_first_shift_id := v_shift.id;
    end if;
    v_shift_start_hour := v_shift.shift_start_hour;
    v_shift_end_hour := v_shift.shift_end_hour;
    if v_week_lastsecond < v_shift_end_hour then
      v_hour := (v_week_lastsecond + PSHFT_COMMONS1.ONE_SECOND - v_shift_start_hour)*24;
    else
      v_hour := (v_shift_end_hour - v_shift_start_hour)*24;
    end if;
    v_hours := v_hours + v_hour;
  END LOOP;

  CLOSE c_cursor;

  -- Now - see - if some other Shift assigned to the User of this Operator
  -- (as it may be from other Generation Procedure, in which case Operator instances will be different!) -
  -- not from this, but from the end of previous week - have tail here.
  -- In this case - that  tail should be counted in this week hours!
  v_tail_hours := calcTailHoursFromPreviousWeek(p_operator_id, p_date);
  v_hours := v_hours + v_tail_hours;

--  v_prev_shift_end := PSHFT_COMMONS1.getPreviousShiftEndHour(p_operator_id, v_first_shift_id);

--  if v_prev_shift_end > v_week_startday then
--     v_hours := v_hours + (v_prev_shift_end - v_week_startday)*24;
--  end if;

  return v_hours;


end calculateAssignedHoursInWeek;

-- calcTailHoursFromPreviousWeek
function calcTailHoursFromPreviousWeek(p_operator_id number, p_date date) return number is
/**
-- To see cases to test well:
-- TestCase.01: Has Tail
  select sh.id, op.operator_user_id, sh.shift_end_hour, op0.id operator_id
         from SHFT_SHIFT sh, SHFT_OPERATOR op, SHFT_SHIFT_OPERATOR sop, SHFT_OPERATOR op0
         where sop.shift_id = sh.id
               and sop.operator_id = op.id
               and op0.operator_user_id = op.operator_user_id and op.proc_id = 10 and op0.proc_id = 11
               and to_date('02.01.2012', 'dd.mm.yyyy') between sh.shift_start_hour and sh.shift_end_hour - 1/86400
-- TestCase.02: Has NO Tail
  select sh.id, op.operator_user_id, sh.shift_end_hour, op0.id operator_id
         from SHFT_SHIFT sh, SHFT_OPERATOR op, SHFT_SHIFT_OPERATOR sop, SHFT_OPERATOR op0
         where sop.shift_id = sh.id
               and sop.operator_id = op.id
               and op0.operator_user_id = op.operator_user_id and op.proc_id = 10 and op0.proc_id = 11
               and sh.shift_start_hour between to_date('01.01.2012', 'dd.mm.yyyy') and to_date('02.01.2012', 'dd.mm.yyyy')
               and sh.shift_end_hour < to_date('02.01.2012', 'dd.mm.yyyy')
declare
  p_operator_id number := nn;
  p_date date := to_date('08.01.2012', 'dd.mm.yyyy');
  v_hours number;
begin
  v_hours := PSHFT_COMMONS1.calcTailHoursFromPreviousWeek(p_operator_id, p_date);
  dbms_output.put_line('hours = ' || v_hours);
end;
*/
  v_week_prevday date;
  v_week_firstday date;
  v_shift SHFT_SHIFT%ROWTYPE;
  v_user_id number;
  v_tail_hours number := 0;
begin
  v_user_id := getUserIdbByOperator(p_operator_id);
  v_week_firstday := getWeekStartDate(p_date);
  v_week_prevday := v_week_firstday-1;

  v_shift := getAssignedShiftByUserId(v_user_id, v_week_prevday);

  if v_shift.id is null then
    -- that is - this User had no any Shift at Sun, so - no tails are possible :)
    v_tail_hours := 0;
  elsif v_shift.shift_end_hour > v_week_firstday then
    v_tail_hours := (v_shift.shift_end_hour - v_week_firstday)*24;
  else
    v_tail_hours := 0;
  end if;

  return v_tail_hours;

end calcTailHoursFromPreviousWeek;


-- getShiftProc
function getShiftProc(p_proc_id number) return shiftProcType is
/**
declare
  p_proc_id number := xx;
  shiftProc PSHFT_COMMONS.shiftProcType;
begin
  shiftProc := PSHFT_COMMONS.getShiftProc(p_proc_id);
  dbms_output.put_line('PERIOD_FROM = ' || shiftProc.PERIOD_FROM || ', PERIOD_TO = ' || shiftProc.PERIOD_TO || ', CLC_DAYS_NUM = ' || shiftProc.CLC_DAYS_NUM);
end;
*/

  shiftProc shiftProcType;
begin
  select sp.id, sp.period_from, sp.period_to, sp.dumpseq, sp.dumpseq_prev, sp.if_nightshifts_assigned, sp.if_dayoffs_generated, sp.if_operators_assigned
    into shiftProc.ID, shiftProc.PERIOD_FROM, shiftProc.PERIOD_TO, shiftProc.DUMPSEQ, shiftProc.DUMPSEQ_PREV, shiftProc.IF_NIGHTSHIFTS_ASSIGNED, shiftProc.IF_DAYOFFS_GENERATED, shiftProc.IF_OPERATORS_ASSIGNED
      from SHFT_SHIFT_PROC sp
      where sp.id = p_proc_id
            and sysdate between fd and td;
  shiftProc.CLC_DAYS_NUM := trunc(shiftProc.PERIOD_TO, 'dd') - trunc(shiftProc.PERIOD_FROM, 'dd') + 1;
  return shiftProc;
exception
  when others then
    shiftProc.ID := null;
    return shiftProc;
end;

-- getPreviousShiftProcId(...)
function getPreviousShiftProcId(p_proc_id number) return number is
  v_prev_id number;
begin
  select id into v_prev_id
         from SHFT_SHIFT_PROC sp
         where sp.id = (select max(id)
                               from SHFT_SHIFT_PROC
                               where id < p_proc_id
                                     and sysdate between fd and td
                                     and status != PROC_STATUS_CANCELED)
               and sysdate between fd and td;
  return v_prev_id;
end;

-- getPreviousShiftProc
function getPreviousShiftProc(p_proc_id number) return shiftProcType is
/**
declare
  p_proc_id number := 12;
  shiftProc PSHFT_COMMONS1.shiftProcType;
begin
  shiftProc := PSHFT_COMMONS1.getPreviousShiftProc(p_proc_id);
  dbms_output.put_line('Procedure id = ' || shiftProc.ID || ', DUMPSEQ = ' || shiftProc.DUMPSEQ || ', DUMPSEQ_PREV = ' || shiftProc.DUMPSEQ_PREV);
end;
*/
  v_prev_id number;
  shiftProc shiftProcType;
begin
  v_prev_id := getPreviousShiftProcId(p_proc_id);
  shiftProc := getShiftProc(v_prev_id);
  return shiftProc;
exception
  when NO_DATA_FOUND then
    shiftProc.id := null;
    return shiftProc;
end getPreviousShiftProc;

-- getLastShiftProcId
function getLastShiftProcId return number is 
  v_last_id number;
begin
  select id into v_last_id
         from SHFT_SHIFT_PROC sp
         where sp.id = (select max(id)
                               from SHFT_SHIFT_PROC
                               where sysdate between fd and td
                                     and status != PROC_STATUS_CANCELED)
               and sysdate between fd and td;
  return v_last_id;
exception
  when NO_DATA_FOUND then
    return null;
end getLastShiftProcId;

-- getLastShiftProc
function getLastShiftProc return shiftProcType is
/**
declare
  shiftProc PSHFT_COMMONS1.shiftProcType;
begin
  shiftProc := PSHFT_COMMONS1.getLastShiftProc;
  dbms_output.put_line('Procedure id = ' || shiftProc.ID);
end;
*/
  v_last_id number;
  shiftProc shiftProcType;
begin
  v_last_id := getLastShiftProcId;
  if v_last_id is NULL then
    shiftProc.id := null;
  else    
    shiftProc := getShiftProc(v_last_id);
  end if;
  return shiftProc;
exception
  when NO_DATA_FOUND then
    shiftProc.id := null;
    return shiftProc;
end getLastShiftProc;

-- getNextShiftProcPeriod()
function getNextShiftProcPeriod(p_proc_id number, p_period_code number) return date is
/**
declare
  p_proc_id number := 90;
  p_period_code number := 1;
  v_date_from date;
  v_date_to date;
begin
  v_date_from := PSHFT_COMMONS1.getNextShiftProcPeriod(p_proc_id, 1);
  v_date_to := PSHFT_COMMONS1.getNextShiftProcPeriod(p_proc_id, 2);
  dbms_output.put_line('DateFrom = ' || v_date_from || ', DateTo = ' || v_date_to);
end;
*/
  v_proc shiftProcType;
  v_date date; 
begin
  v_proc := getShiftProc(p_proc_id);
  if v_proc.ID is not NULL then
    if p_period_code = 1 then
       v_date := v_proc.PERIOD_TO + 1;
    elsif p_period_code = 2 then
       v_date := v_proc.PERIOD_TO + 7;
    end if;
  else
    v_date := NULL;
  end if;
  return v_date;
end getNextShiftProcPeriod;


-- getShiftProcByOperator
function getShiftProcByOperator(p_operator_id number) return shiftProcType is
  v_proc_id number;
  shiftProc shiftProcType;
begin
  select proc_id into v_proc_id
         from SHFT_OPERATOR op
         where op.id = p_operator_id
               and sysdate between fd and td;
  shiftProc := getShiftProc(v_proc_id);
  return shiftProc;
exception
  when others then
    shiftProc.ID := null;
    return shiftProc;
end getShiftProcByOperator;

-- getShiftProc()
function getShiftProc(p_day date) return shiftProcType is
  v_proc_id number;
  shiftProc shiftProcType;
begin
  select id into v_proc_id
         from SHFT_SHIFT_PROC sp
         where p_day between sp.period_from and sp.period_to
               and sysdate between fd and td;
  shiftProc := getShiftProc(v_proc_id);
  return shiftProc;
exception
  when others then
    shiftProc.ID := null;
    return shiftProc;
end getShiftProc;

-- getOperators()
function getOperators(p_proc_id number) return operatorsCursor is
  c_opers PSHFT_COMMONS1.operatorsCursor;
begin
  open c_opers for
       select * from SHFT_OPERATOR op
                where proc_id = p_proc_id
                      and status = PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED
                      and sysdate between fd and td
                order by op.id;
  return c_opers;
end getOperators;

-- getWeekStartDate
function getWeekStartDate(p_date date) return date is
/** Tested - OK!
declare
  p_date date := to_date('02.01.2012', 'dd.mm.yyyy');
  v_date date;
  v_week_date date;
begin
  for cnt in 1..7 loop
    v_date := p_date + cnt - 1;
    v_week_date := PSHFT_COMMONS1.getWeekStartDate(v_date);
    dbms_output.put_line('Original Date = ' || to_char(v_date, 'dd.mm.yyyy: DAY') || ', Week Start Day = ' || to_char(v_week_date, 'dd.mm.yyyy: DAY'));
  end loop;
end;
*/
  v_week_date date;
  v_oracle_week_day number; -- for Oracle Sun = 1, Mon = 2, ..., Sat = 7
  v_days2add number;
begin
  v_oracle_week_day := to_number(to_char(p_date, 'd'));
  if v_oracle_week_day = 1 then
     v_days2add := -1;
  else
     v_days2add := 0;
  end if;
  v_week_date := p_date + v_days2add;
  v_week_date := trunc(v_week_date, 'day')+1;
  return v_week_date;
end getWeekStartDate;


-- getWeekDay
function getWeekDay(p_day date) return pls_integer is
  v_day pls_integer;
begin
  v_day := to_number(to_char(p_day, 'D'));
  if v_day = 1 then
     v_day := 7;
  else
     v_day := v_day - 1;
  end if;
  return v_day;
end getWeekDay;


-- getNumberOfDayOffs()
function getNumberOfDayOffs(p_operator_id number) return number is
  v_dayoffs number;
begin
  select count(*) into v_dayoffs
            from SHFT_OPERATOR_EXC oe
            where oe.exc_type = 4
                  and oe.operator_id = p_operator_id
                  and sysdate between fd and td;
  return v_dayoffs;
end getNumberOfDayOffs;

-- getNumberOfDayOffs()
function getNumberOfDayOffs(p_day date) return number is
  v_dayoffs number;
begin
  select count(*) into v_dayoffs
            from SHFT_OPERATOR_EXC oe
            where oe.exc_type = 4
                  and trunc(oe.exc_period_from, 'dd') = trunc(p_day, 'dd')
                  and sysdate between fd and td;
  return v_dayoffs;
end getNumberOfDayOffs;

-- getNumberOfLastDayOffs()
function getNumberOfLastDayOffs(p_proc_id number, p_day date) return number is
/**
declare
  p_proc_id number := 16;
  p_day date := to_date('26.01.2012', 'dd.mm.yyyy');
  v_dayoffs number;
begin
  v_dayoffs := PSHFT_COMMONS1.getNumberOfLastDayOffs(p_proc_id, p_day);
  dbms_output.put_line(v_dayoffs);
end;
*/
  v_dayoffs number;
begin
  select count(*) into v_dayoffs
       from SHFT_OPERATOR op, SHFT_OPERATOR_EXC oe
       where oe.operator_id = op.id
             and oe.proc_id = p_proc_id
             and oe.exc_type = 4
             and trunc(oe.exc_period_from, 'dd') = trunc(p_day, 'dd')
             and oe.exc_period_from = (select max(exc_period_from)
                                              from SHFT_OPERATOR op1, SHFT_OPERATOR_EXC oe1
                                              where oe1.exc_type = oe.exc_type
                                                    and oe1.operator_id = op1.id
                                                    and op1.operator_user_id = op.operator_user_id
                                                    and sysdate between op1.fd and op1.td
                                                    and sysdate between oe1.fd and oe1.td)
             and sysdate between op.fd and op.td
             and sysdate between oe.fd and oe.td;
  return v_dayoffs;
end getNumberOfLastDayOffs;

-- getLastRestDay
function getLastRestDay(p_operator_id number) return date is
/**
-- To find Rest Days:
select * from SHFT_OPERATOR_EXC oe
       where oe.proc_id = 16
             and oe.exc_type = 3; -- 4 - DayOff

declare
  p_operator_id number := xx;
  v_last_restday date;
begin
  v_last_restday := PSHFT_COMMONS1.getLastRestDay(p_operator_id);
  dbms_output.put_line(v_last_restday);
end;
*/
  v_operator_user_id number;
  v_last_restday date;
begin
  v_operator_user_id := PSHFT_COMMONS1.getUserIdbByOperator(p_operator_id);
  select max(decode(oe.exc_type, PSHFT_EXCLUSION.EXCTYPE_PERIOD, oe.exc_period_to, PSHFT_EXCLUSION.EXCTYPE_DAYOFF, oe.exc_period_from)) into v_last_restday
         from SHFT_OPERATOR op, SHFT_OPERATOR_EXC oe
         where oe.operator_id = op.id
               and op.operator_user_id = v_operator_user_id
               and oe.exc_type in (PSHFT_EXCLUSION.EXCTYPE_PERIOD, PSHFT_EXCLUSION.EXCTYPE_DAYOFF)
               and oe.status = PSHFT_EXCLUSION.OPERATOREXC_STATUS_ACTIVE
               and op.status = PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED
               and sysdate between op.fd and op.td
               and sysdate between oe.fd and oe.td;
  return v_last_restday;
end getLastRestDay;

-- getPreviousDayOff()
function getPreviousDayOff(p_operator_userid number, p_day date) return date is
/**
declare
  p_operator_userid number := 1248;
  p_day date := to_date('05.02.2012', 'dd.mm.yyyy');
  v_dayoff date;
begin
  v_dayoff := PSHFT_COMMONS1.getPreviousDayOff(p_operator_userid, p_day);
  dbms_output.put_line(v_dayoff);
end;
*/
  v_dayoff date;
begin
   select max(exc_period_from) into v_dayoff
      from SHFT_OPERATOR_EXC oe, SHFT_OPERATOR op
      where op.operator_user_id = p_operator_userid
            and op.id = oe.operator_id
            and oe.exc_type = PSHFT_EXCLUSION.EXCTYPE_DAYOFF
            and oe.exc_period_from < trunc(p_day, 'dd')
            and sysdate between op.fd and op.td
            and sysdate between oe.fd and oe.td;
   return v_dayoff;

exception
   when NO_DATA_FOUND then return null;
end getPreviousDayOff;

-- Returns all DayOffs found for this Operator within the period of Generation Procedure it is belonging to
-- Resultset contains only column of DATE type.
function getDayOffs(p_operator_id number) return daysCursor is
/**
declare
  c_dayoffs PSHFT_COMMONS1.daysCursor;
  p_operator_id number := 622;
  v_day date;
  v_dayoffs_cnt number := 0;
begin
  c_dayoffs := PSHFT_COMMONS1.getDayOffs(p_operator_id);
  LOOP
    FETCH c_dayoffs into v_day;
    EXIT when c_dayoffs%NOTFOUND;

    v_dayoffs_cnt := v_dayoffs_cnt + 1;
    dbms_output.put_line(v_dayoffs_cnt || ': v_day = ' || v_day);
  END LOOP;
  CLOSE c_dayoffs;
end;
*/
  c_days daysCursor;
begin
  open c_days for
     select oe.exc_period_from
            from SHFT_OPERATOR_EXC oe
            where oe.exc_type = 4
                  and oe.operator_id = p_operator_id
                  and sysdate between fd and td
            order by oe.exc_period_from;
  return c_days;
end getDayOffs;

-- Returns all DayOffs found for the Operator's User ID within the indicated period
-- Resultset contains only column of DATE type.
function getDayOffs(p_operator_user_id number, p_date_from date, p_date_to date) return daysCursor is
begin
  null;
end;

-- getVacations
function getVacations(p_operator_id number) return daysCursor is
  c_days daysCursor;
begin
  open c_days for
     select oe.exc_period_from, oe.exc_period_to
            from SHFT_OPERATOR_EXC oe
            where oe.exc_type = 3
                  and oe.operator_id = p_operator_id
                  and sysdate between fd and td
            order by oe.exc_period_from;
  return c_days;
end getVacations;

-- getRandomNumber(
function getRandomNumber(num_start pls_integer, num_end pls_integer) return pls_integer is
  v_int pls_integer;
begin

  v_int := round(dbms_random.value(num_start, num_end));

  return v_int;

end;

function getInfinity return date as
begin
  return DATE_INFINITY;
end;  

end PSHFT_COMMONS1;
/
