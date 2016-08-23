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
create or replace package PSHFT_DICTS is

  -- Author  : BESO
  -- Created : 2/20/2013 3:00:24 PM
  -- Purpose : set of methods working with Dictionaries
  

  DCODE_OperRestrictGroup constant number := 24;
  
  
  DICT_ORDERBY_CODE constant number := 1;
  DICT_ORDERBY_NAME constant number := 2;
  DICT_ORDERBY_NAMETECH constant number := 3;
  
  
  -- type of Cursor referencing to the Resultset consisting of Dictionary Items (DIC_DATA) records
  TYPE DictDataCurTyp is ref cursor;
  -- type of Cursor referencing to the Resultset consisting of Dictionaries (DIC) records
  TYPE DictCurTyp is ref cursor;
  
  -- Returns Cursor for the indicated Dictionary items CODE and NAME values (this order), ordered by CODE
  -- Returned are following columns:
  -- CODE == Code of the Item (to be value of the choice on the UI control - ComoBox or List)
  -- NAME == Name of the Item (to be name on the UI control - ComoBox or List)
  -- #param p_dict_code Code of the Dictionary whose Items are of interest
  -- #param p_if_activeonly indicate if only Active Items are to be returned (1) or - ALL ones (0). 
  --        By Default - Active Items are returned only.
  -- #param p_orderby define ORDER BY clause for the ResultSet. Possible values are:
  -- <ul>
  -- <li>{#link DICT_ORDERBY_CODE} Items are ordered according CODE</li>
  -- <li>{#link DICT_ORDERBY_NAME} Items are ordered according NAME </li>
  -- <li>{#link DICT_ORDERBY_NAMETECH} Items are ordered according NAME_TECH </li>
  -- </ul>
  function getDictData(p_dict_code pls_integer, p_if_activeonly pls_integer := 1, p_orderby pls_integer := DICT_ORDERBY_CODE) return DictDataCurTyp;
  
  -- Returns open Cursor providing resultset of Dictionaries, depending on the Dictionary Code requested.
  -- #param p_dict_code indicate which Dictionaries should be present in the Resultset:
  -- if 0 - resultset will consist of ALL existing Dictionaries.
  -- if > 0 - resultset will consist of only 1 Dictonary, namely one having indicated Dictionary Code or 0 if Dictionary with this code - doesn't exist.
  function getDictDsc(p_dict_code pls_integer) return DictCurTyp;
  
  -- re-uses general getDictData(p_dict_code) method for Dictionary #24 (see DCODE_OperRestrictGroup)
  function getDictData_OperRestrGroup return DictDataCurTyp;

  function getNameByCode(p_dict_code number, p_item_code number) return varchar2;


end PSHFT_DICTS;
/
create or replace package body PSHFT_DICTS is

  function getDictData(p_dict_code pls_integer, p_if_activeonly pls_integer, p_orderby pls_integer) return DictDataCurTyp is
    /**
    declare
      p_dict_code pls_integer := 24;
      p_if_activeonly pls_integer := 1;
      p_orderby pls_integer := PSHFT_DICTS.DICT_ORDERBY_CODE;
      curData PSHFT_DICTS.DictDataCurTyp;
      recDict SHFT_DICT%ROWTYPE;
    begin
      curData := PSHFT_DICTS.getDictData(p_dict_code, p_if_activeonly, p_orderby);
      LOOP
        fetch curData into recDict;
        exit when curData%NOTFOUND;
        dbms_output.put_line('CODE = ' || recDict.CODE || ': ' || recDict.NAME);
      end loop;
    end;
    */
    curData DictDataCurTyp;
    v_where varchar2(200) := '';
    v_where_counter pls_integer := 0;
    v_orderby varchar2(200) := ' order by ';
    v_sql varchar2(2000);
  begin
    
    v_sql := 'select * from SHFT_DICT @WHERE @ORDERBY';

    --
    if p_dict_code > 0 then 
      v_where_counter := v_where_counter + 1;
      if v_where_counter > 1 then
        v_where := v_where || ' and ';
      else
        v_where := v_where || ' where ';
      end if;
      v_where := v_where || ' up = ' || p_dict_code;
    end if;  

    --
    if p_if_activeonly = 1 then 
      v_where_counter := v_where_counter + 1;
      if v_where_counter > 1 then
        v_where := v_where || ' and ';
      else
        v_where := v_where || ' where ';
      end if;
      v_where := v_where || ' activity_flag = 1 ';
    end if;  
    
    case p_orderby
      when DICT_ORDERBY_CODE then 
        v_orderby := v_orderby || ' code ';
      when DICT_ORDERBY_NAME then
        v_orderby := v_orderby || ' name ';
      when DICT_ORDERBY_NAMETECH then 
        v_orderby := v_orderby || ' name_tech ';
    end case;
    
    v_sql := replace(v_sql, '@WHERE', v_where);
    v_sql := replace(v_sql, '@ORDERBY', v_orderby);

    open curData for v_sql;
    return curData;
  end getDictData;



  function getDictData_OperrestrGroup return DictDataCurTyp is
  /**
  declare
    crs PSHFT_DICTS.DictDataCurTyp;
    v_code number; 
    v_name varchar2(64);
  begin
    crs := PSHFT_DICTS.getDictData_OperrestrGroup;
    LOOP
      fetch crs into v_code, v_name; 
      exit when crs%NOTFOUND;
    END LOOP;
    CLOSE crs; 
  end;
  */
    curData DictDataCurTyp;
  begin
    curData := getDictData(DCODE_OperRestrictGroup);
    return curData;
  end getDictData_OperrestrGroup;

  -- getNameByCode()
  function getNameByCode(p_dict_code number, p_item_code number) return varchar2 is
    v_name SHFT_DICT.NAME%TYPE;
  begin
    select name into v_name 
           from SHFT_DICT dd
           where dd.up = p_dict_code
                 and dd.code = p_item_code;
    return v_name;
  exception
    when NO_DATA_FOUND then
      return NULL;
  end getNameByCode;

  
  
  function getDictDsc(p_dict_code pls_integer) return DictCurTyp is
  /**
  declare
    p_dict_code pls_integer := 24;
    curDict PSHFT_DICTS.DictCurTyp;
    rcDictDsc SHFT_DICT_DSC%ROWTYPE;
  begin
    curDict := PSHFT_DICTS.getDict(p_dict_code);
    LOOP
      fetch curDict into rcDictDsc;
      exit when curDict%NOTFOUND;
      dbms_output.put_line('DICT_COD = ' || rcDictDsc.DICT_CODE || ': ' || rcDictDsc.DSC);
   end LOOP;
  end;
  */
    curDict DictCurTyp;
    v_sql varchar2(2000) := '';
    v_where varchar2(200) := '';
    v_orderby varchar2(200) := '';
  begin
    v_sql := 'select * from SHFT_DICT_DSC @WHERE @ORDERBY';
    if p_dict_code > 0 then 
      v_where := ' where dict_code = ' || p_dict_code;
    else
      v_orderby := ' order by dict_code';
    end if;  
    v_sql := replace(v_sql, '@WHERE', v_where);
    v_sql := replace(v_sql, '@ORDERBY', v_orderby);
    
    open curDict for v_sql;
    
    return curDict;
    
  end;

end PSHFT_DICTS;
/
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
create or replace package PSHFT_GENERATOR is

  -- Author  : BESO
  -- Created : 12/24/2011 7:02:13 PM
  -- Purpose : Generates SHIFT schedule, based on the:
  -- a) general requirements imposed by CC (Irma Gurgenidze)
  -- b) Conditions applied to the particular Operators (someone can't participate in any shift, some - in night shift, some - has exceptional days etc...)
  -- **********************************************************
  -- General Requirements:
  -- **********************************************************
  -- 1: during the calendar week no more than 40 working hours;
  -- 2: day off should not be a fixed day during the week;
  -- 3: day off should be at 5-th or at 6-th working day, depends on the number of CC Agents in the shift and number of agents who is in the vacation;
  -- 4: cc operator should have all existing shifts during the week (it means not only evening, or not only the morning shift) for example two morning shifts and 3 evening shifts;
  -- 5: during the calendar week CC operator should have at least one 8 hour shift (day shift);
  -- 6: there are the particular CC operator's list who is able to have the night shift.The list of such operators will be provided;
  -- 7: no more than one night shift per month;
  -- 8: after night shift before next working day should pass no less than 24 hour;
  -- 9: between two shifts should pass no less than 12 hours. It means that evening shift should not be followed by the morning shift, f.e. 18:00 - 00:00 and after  comes 09:00 - 17:00 ;
  -- 10: the newcomers who is answering only pre-paid calls are not able to have the following shifts: 08:00;  20:00  and 01:00 - 08:00 -night shift. The list of such operators will be provided.

  -- General solution looks like:
  -- Tables:
  --        SHFT_SHIFT_PROC - contains Shifts Generation Procedure
  --        SHFT_SHIFT - generated Shifts
  --        SHFT_SHIFT_OPERATOR - relation between Shift and Operator.
  --        SHFT_OPERATOR - for each Shift Generation Procedure - list of Operators, participated in it.
  --        SHFT_OPERATOR_EXC - for each Shift Generation Procedure - list of so-called Exceptions which some Operators can have.
  --                            E.g. particular Operator can't participate in Nigh shift etc...
  --        SHFT_DICT_SHIFT - List of existing Shifts (Mornig shift, Day shift, Night shift etc...)
  --        SHFT_DICT - Different Dictionaries serving System
  -- Process:
  --        User Responsible for Shift generation - enters SHFT_OPERATOR_EXCEPTION and SHFT_OPERATOR data (assuming that SHFT_OPERATOR - generated automatically based on particular Permit - UI deal).
  --        Starting hift Generation - System - takes 1-st "Next" Operator and assigns it to 1-st available (taking into account all General Requirements) Shift. Then takes 2-d "Next" etc...
  --        "Next" means some choice procedure when if we have N objects - done N times - it guaranteed will choose all N objects and no any is taken more than 1 time.
  --        The meaning of "Next" is that it may be not correct to run through list of these objects and take ordinally next, but apply some randomization to the choice process to make all objects equally treated.
  --        When Operators' list is done (1-st run) - starts from beginning and makes next Run etc...
  --        Particular Operator is finished be treated with Runs if his Resource is fully used (i.e. he according General Requirement can't be used)
  --        Particular Shift is finished be treated with Runs if it is fully comleted (number of Operators accomplished).

-- Assign procedure (assignOperators2Shifts) mode: both DayOffs are generated and Operators are assigned to Shifts (default mode)
ASSIGN_MODE_FULL constant pls_integer := 1;
-- Assign procedure (assignOperators2Shifts) mode: only DayOffs are generated
ASSIGN_MODE_DAYOFFSonly constant pls_integer := 2;
-- Assign procedure (assignOperators2Shifts) mode: only Operators are assigned to Shifts
ASSIGN_MODE_ASSIGNonly constant pls_integer := 3;


-- value for setupDayOffs, p_steps parameter
DAYOFF_GNR_STEPS_10 constant pls_integer := 10;
DAYOFF_GNR_STEPS_20 constant pls_integer := 20;
DAYOFF_GNR_STEPS_25 constant pls_integer := 25;
DAYOFF_GNR_STEPS_30 constant pls_integer := 30;


PHASE_ASSIGN_NO_OVERCAP constant pls_integer := 1;
PHASE_ASSIGN_OVERCAP constant pls_integer := 2;
PHASE_REASSIGN constant pls_integer := 3;

-- Between 2 next DayOffs for any Operator may pass 4, 5 or 6 Working Days, less is not acceptable, more - is exclusive cases
-- (to reach even DayOffs distribution per week)
DAYOFF_SHIFT_FROM constant number := 4;
DAYOFF_SHIFT_TO constant number := 6;



TYPE generationWeightType is RECORD (
  weight number,
  capacity number,
  shift_id number,
  shift_index number -- Index of the Shift in array-like control structure where all Shifts of Day may be before assignment done
);

TYPE operatorType is RECORD (
  ID number,
  flag_taken boolean := false
);

TYPE operatorsType is TABLE OF operatorType index by BINARY_INTEGER;

TYPE opersType is RECORD (
  counter pls_integer := 0,
  opersNumber pls_integer,
  operators operatorsType
);

-- Type representing SHFT_SHIFT record along with some control structures
TYPE shiftType is RECORD (
    ID NUMBER,
 		SHIFT_START_HOUR DATE,
		SHIFT_END_HOUR DATE,
    SHIFT_HOURS NUMBER,
		SHIFT_TYPE NUMBER,
		SHIFT_CAPACITY NUMBER,
		ASSIGNED_OPERATORS NUMBER,
    OVERCAPACITY_LIMIT NUMBER, -- how many more Operators over SHIFT_CAPACITY may be assigned to the Shift
    CNT_FLAG_AVAILABLE BOOLEAN, -- indicates that for particular Operator this shift is available
    CNT_FLAG_AVAILABLE_BYRULE BOOLEAN,
    CNT_OPER_ID NUMBER, -- Operator in behalf of which this Shift is tried.
    weight number
);

TYPE shiftsType is TABLE OF shiftType index by BINARY_INTEGER;

TYPE dayAssignmentType is RECORD (
  day DATE,
  if_available boolean, -- indicates if this DAY is available for particular Operator
  if_assigned boolean, -- indicates if particular Operator has been assigned within this DAY
  exclusion_type number, -- if if_available = false - Exclusion Type (either PSHFT_EXCLUSION.EXCTYPE_DAYOFF or EXCTYPE_PERIOD)
  shift shiftType -- contains data about Shift Operator was assigned to
);

TYPE daysAssignmentsType is TABLE OF dayAssignmentType index by BINARY_INTEGER;

TYPE restDaysType is TABLE of DATE index by BINARY_INTEGER; -- to keep list of DayOffs.


TYPE assignmentData is RECORD (
  restDays restDaysType, -- List of rest Days (DayOffs and Vacation days).
  restDaysNum pls_integer := 0, -- total number of rest Days.
  -- If Operator took Evening shift at Sun - it is possible part of this Shift - hits next week Mon.
  -- In this case these "tail" hours of Shift started in previous week - are accounted for this one!
  weekBeginnigTailHours number := 0,
  morningShiftsNum pls_integer :=0, -- Number of assigned Morning Type Shifts (PSHFT_COMMONS1.SHIFT_TYPE_MORNING_EARLY and PSHFT_COMMONS1.SHIFT_TYPE_MORNING)
  morningShiftsHours number := 0, -- Number of Hours of assigned Morning Type Shifts
  dayShiftsNum pls_integer :=0, -- Number of assigned Day Type Shifts (PSHFT_COMMONS1.SHIFT_TYPE_DAY)
  dayShiftsHours number := 0, -- Number of Hours of assigned Day Type Shifts
  eveningShiftsNum pls_integer :=0, -- Number of assigned Evening Type Shifts (PSHFT_COMMONS1.SHIFT_TYPE_EVENING, PSHFT_COMMONS1.SHIFT_TYPE_EVENING_LATE)
  eveningShiftsHours number := 0, -- Number of Hours of assigned Evening Type Shifts
  shiftsNum pls_integer := 0, -- Total number of assigned Shifts
  shiftsHours number := 0, -- Total hours of assigned Shifts
  if_night_assigned boolean := false,
  dayAssignments daysAssignmentsType,
  daysNum pls_integer := 0 -- number of days represented in the dayAssignments
);

TYPE dayShiftsType is RECORD (
  morningTypeShiftsNum pls_integer := 0, -- number of available Shifts of Morning Type (8 hours) in this Day
  morningTypeWinner generationWeightType, --
  eveningTypeShiftsNum pls_integer := 0, -- number of available Shifts of Evening Type (6 hours) in this Day
  eveningTypeWinner generationWeightType,
  eveningTypeFirst generationWeightType, -- keep 1-st (1-st available) Evening type available Shift
  nightTypeShiftsNum pls_integer := 0, -- number of available Shifts in this Day
  nightTypeWinner generationWeightType,
  dayShiftsNum pls_integer := 0, -- number of available Shifts in this Day
  dayWinner generationWeightType,
  letovercapacity boolean
);

TYPE dayAssgnStatType is RECORD (
  day DATE := null,
  if_dayoff boolean := false,
  if_prevday_dayoff boolean := false,
  if_day_available boolean := false, -- 1 - availble, 0 - not (may be because it is already assigned to!)
  if_day_already_assigned boolean := false,
  shift_type_already_assigned number := 0,
  shift_id_already_assigned number := 0,
  shift_hours_already_assigned number := 0,

  if_assigned boolean := false,
  assigned_shift_type number := 0,
  assigned_shift_id number := 0,

  shift_night_avl number := 0, -- Number of Night Shifts available to be assigned. 0 - not available
  shift_mornearl_avl number := 0, -- Number of Early Morning
  shift_mornearl_avl_overc number := 0, -- Number of Early Morning
  shift_morn_avl number := 0, -- Number of Morning
  shift_morn_avl_overc number := 0, -- Number of Morning
  shift_day_avl number := 0, -- Number of DAY Shift (13:00) available the way when it Is not Complete (capacity > assigned): 1 or 0
  shift_day_avl_overc number := 0, -- Number of DAY Shift (13:00) available the way when it Is already Complete but OverCapacity is still possible: 1 or 0
  shift_evn_avl number := 0, -- Number of Evening Shifts available the way when it Is not Complete (capacity > assigned): 1 or 0
  shift_evn_avl_overc number := 0, -- Number of Evening Shifts available the way when it Is already Complete but OverCapacity is still possible: 1 or 0
  shift_evnlate_avl number := 0, -- Number of Late Evening Shift (20:00) available the way when it Is not Complete (capacity > assigned): 1 or 0
  shift_evnlate_avl_overc number := 0 -- Number of Late Evening Shift (20:00) available the way when it Is already Complete but OverCapacity is still possible: 1 or 0
);



-- Generates new Shift Generation Procedure. 
-- New procedure should guarantee that following integrity constraints are satisfied:
-- {*} Its Dates (p_date_from, p_date_to) don't intersect with Already generated Procedures dates.
-- {*} Its Start Date (p_date_from) is 1 day after End Date of the Previous Procedure (no gaps constraint) 
-- {*} Dates (p_date_from, p_date_to) - form whole Week, that is - p_date_from is Mon and p_date_to is Sun.
-- #param p_date_from Date since which Shift is Generated
-- #param p_date_to Date till which Shift is generated
-- #param p_dsc Optional Description
-- #param p_user_id System Id of the User responsible for this action
-- #return System Id of the right generated Procedure (SHFT_SHIFT_PROCEDURE.ID)
function generateNewProcedure(p_date_from date, p_date_to date, p_dsc varchar2, p_user_id number) return number;

-- Generates new Shift Generation Procedure.
-- Dates for this procedure - are detected automatically from Previous procedure which is assumed to exist. 
-- If Previous procedure doesn't exist - -1 is returned.
-- #returns System Id of the new Procedure just generated or -1 if previous Procedure doesn't exists
function generateNewProcedure(p_dsc varchar2, p_user_id number) return number;

-- Create Shift Types in context of new Procedure (Procedure ID is indicated in p_proc_id) - as copy of previous Generation Procedure.
-- Net result: SHFT_SHIFT_TYPE contain records for indicated Procedure - exactly with same parameters (Type, Capacity) as in Previous Procedure. 
-- NOTE: COMMITting
-- #param p_proc_id System ID of the Procedure in context of which new Shift types are to be created by this Procedure
-- #param p_user_id System Id of the User in context of which this operation is performed. 
-- #param p_if_commit manage if commit current transaction after execution:
--        0 = DONT commit
--        1 = COMMIT
--        Default: 1
-- #raises PSHFT_COMMONS1.exObjectAlreadyExists if in context of indicated Procedure (p_proc_id) there exists some Shift Types
procedure copyShiftTypesFromPrevProc(p_proc_id number, p_user_id number, p_if_commit number := 1);

-- Updates capacity for particular ShiftType (i.e. SHFT_SHIFT_TYPE.CAAPACITY)
-- Net result: New Version of Shift Type record created with Updated Capacity
-- NOTE: COMMITting
-- #param p_id System Id of the Shift Type (i.e. SHFT_SHIFT_TYPE.ID)
-- #param p_capacity Capacity to be set
-- #raises NO_DATA_FOUND if indicated Shift Type not found
procedure updateShiftTypeCapacity(p_id number, p_capacity number, p_user_id number);


-- Generate Empty Shifts for indicated Shift Generation Procedure.
-- Net result: Empty Shifts are available in the SHFT_SHIFT table
-- NOTE: COMMITting
-- #param p_proc_id Shift Generation Procedure System ID (SHFT_SHIFT_PROC.ID)
-- #param p_user_id System Id of the User in context of which empty Shifts are generated
procedure generateEmptyShifts(p_proc_id number, p_user_id number);

-- Create Operators in context of new Procedure (Procedure ID is indicated in p_proc_id) - as copy of Operators from previous Generation Procedure.
-- Net result: SHFT_OPERATOR table contain records for indicated Procedure - exactly with same parameters (Name, Restriction Group etc...) as in Previous Procedure. 
-- #param p_proc_id System ID of the Procedure in context of which this operation is performed. 
-- #param p_user_id System Id of the User in context of which this operation is performed. 
-- #param p_if_commit manage if commit current transaction after execution:
--        0 = DONT commit
--        1 = COMMIT
--        Default: 1
-- #raises PSHFT_COMMONS1.exObjectAlreadyExists if in context of indicated Procedure (p_proc_id) there exists some Operator
procedure copyOperatorsFromPrevProc(p_proc_id number, p_user_id number, p_if_commit number := 1);

-- Create Operators ShiftType Exclusions in context of new Procedure (Procedure ID is indicated in p_proc_id) - as copy of them from previous Generation Procedure.
-- Net result: SHFT_OPERATOR_EXC table contain records for indicated Procedure - exactly with same parameters as in Previous Procedure. 
-- #param p_proc_id System ID of the Procedure in context of which this operation is performed. 
-- #param p_user_id System Id of the User in context of which this operation is performed. 
-- #param p_if_commit manage if commit current transaction after execution:
--        0 = DONT commit
--        1 = COMMIT
--        Default: 1
-- #raises PSHFT_COMMONS1.exObjectAlreadyExists if in context of indicated Procedure (p_proc_id) there exists some Exclusions of Shift Type 
procedure copyShiftTypeExclFromPrevProc(p_proc_id number, p_user_id number, p_if_commit number := 1);

procedure setupDayOffs(p_proc_id number, p_dayoffs_per_day number, p_user_id number := 0);


-- Generate DayOffs for all Operators participated in indicated Generation Procedure. <BR>
-- Before this setup is done - assumed that Night Shifts are already Assigned in behalf of the indicated Procedure.<BR>
-- In this case - during DayOffs setup for those Operators assigned for Night Shifts (excluding Monday!) - previous Day will be Setup as DayOff!<BR>
-- Besides - One Operator will be chosen such who is eligible for Night Shift for Monday of next week after one this Generation Procedure is for. <BR>
-- For this Operator Sunday will be set up as DayOff. <BR>
-- Other Operators will be assigned with DayOffs based on the simple Following Rule: <BR>
-- For Mon - will be taken: <BR>
-- All Operators having previous week Monday as LAST DayOff +
-- Max possible part of Operators having LAST DayOff in Tuesday (leaving 1 Operator for next Day assignments) +
-- Rest part - Operators having LAST DayOff in Wednesday.
-- Until number of DayOffs reaches value indicated in [p_dayoffs_per_day] parameter.
-- These dayOffs are Setup.
-- For Tue - will be taken: <BR>
-- All Operators having previous week Tuesday as LAST DayOff (Note: those setup for Mon already don't present here - their LAST DayOff is this week MON!)+
-- Max possible part of Operators having LAST DayOff in Wednesday (leaving 1 Operator for next Day assignments) +
-- Rest part - Operators having LAST DayOff in Thursday.
-- Until number of DayOffs reaches value indicated in [p_dayoffs_per_day] parameter.
-- Etc...
-- NOTE: Those Operators in behalf of which DayOffs were setup due to the assigned Night Shifts - are calculated for [p_dayoffs_per_day] parameter limit.
-- @TODO: To guarantee same Operator has not DayOff on the next week - same as he had week before - control that.
--        Code should be more complicated to do that to be guaranteed!
-- @TODO: If Operator is newly Inserted, that is - hadn't participated in previous Procedure - he may be not assigned with DayOff at all during the week.
--        See for example JIRA, SHIFT-27, Step.7.5
-- #param p_proc_id Generation Procedure in behalf of which DayOffs are generated
-- #param p_dayoffs_per_day how many DayOffs are to be generated for each Day
-- #param p_steps indicates How many Steps to do. Possible values are: <BR>
--   DAYOFF_GNR_STEPS_10 = implements Step.10: Setup DayOffs for those Operators who was assigned to Night Shifts for Tue-Sun.<BR>
--   DAYOFF_GNR_STEPS_20 = implements Step.10 and Step.20: Setup DayOffs for several Operators for SUN who may be in Night Shift for next week Mon.<BR>
--   DAYOFF_GNR_STEPS_25 = implements Step.10, Step.20 and Step.25: Setup DayOffs for "New" Operators, i.e. those which were absent as Operators in previous Shift but are present now.<BR>
--   DAYOFF_GNR_STEPS_30 = implements Step.10, Step.20, Step.25 and Step.30: Setup all other Operators DayOffs<BR>
-- #param p_if_miss_prev_steps indicates if miss (not execute) Steps previous to the indicated one. That means that if
--   p_steps = DAYOFF_GNR_STEPS_20 - Step.10 won't be executed,
--   p_steps = DAYOFF_GNR_STEPS_25 - Step.10, Step.20 won't be executed,
--   p_steps = DAYOFF_GNR_STEPS_30 - Step.10, Step.20 and Step.25 won't be executed
--    true = miss
--    false - don't miss
-- #param p_user_id System Id of the User in context of which this action is performing 
procedure setupDayOffs(p_proc_id number, p_dayoffs_per_day number, p_steps number, p_if_miss_prev_steps boolean, p_user_id number);


-- Generate Shift in accordance to all restrictions and rules.
-- For each Operator - duistribute it in proper shifts for its working days.
-- #param p_proc_id Shift Generation Procedure System ID (SHFT_SHIFT_PROC.ID)
-- #param p_mode indicates mode in which Assign procedure is invoked.
--   Possible are following modes:
--   ASSIGN_MODE_FULL
--   ASSIGN_MODE_DAYOFFSonly
--   ASSIGN_MODE_ASSIGNonly
procedure assignOperators2Shifts(p_proc_id number, p_mode number := PSHFT_GENERATOR.ASSIGN_MODE_FULL);


-- Assigns Operators to Night Shifts for ALL days included in the indicated Procedure
-- #param p_proc_id Shift Generation Procedure System ID (SHFT_SHIFT_PROC.ID)
-- #param p_if_randomize indicates whether to choose operators - candidates for Night SShift - in strict or random order:
-- 0 = strict order - ordered by Date they participated in Night Shift last time - 1-st will be considered ones participated longer time ago.
-- By Default
-- 1 = randomize order
procedure assignOperators2NightShifts(p_proc_id number, p_if_randomize pls_integer := 0, p_user_id number := 0);


-- Assigns particular Operator - to particular Shift.
-- #param p_proc_id Shift Generation Procedure System ID (SHFT_SHIFT_PROC.ID)
-- #param p_operator_id Operator System ID - refers SHFT_OPERATOR.ID
-- #param p_shift_id Shift System ID (SHFT_SHIFT.ID)
-- #param p_dumpseq DUMP sequence under which current generation is performed
procedure assignOperator2Shift(p_proc_id number, p_operator_id number, p_shift_id number,
          p_dumpseq number := null,
          p_if_manual number := 0,
          p_dsc varchar2 := '', 
          p_user_id number := 0);

-- Removes existing assignment of indicated Operator to the indicated Shift
-- #param p_proc_id Shift Generation Procedure System ID (SHFT_SHIFT_PROC.ID)
-- #param p_operator_id Operator System ID - refers SHFT_OPERATOR.ID
-- #param p_shift_id Shift System ID (SHFT_SHIFT.ID)
procedure deAssignOperator2Shift(p_proc_id number, p_operator_id number, p_shift_id number);

-- reassign Operators for all days participated in indicated Procedure
-- Reassign means attempt to take some Operator from some the Over-Capacited Shift in some day and
-- assing it to the Not Completed so far Shift within same day.
-- This is possible if ALL rules are calculated Ok for this Operator and Not Complete Shift taking into account that
-- everything else remains unchanged
procedure reassignOperators(p_proc_id number);

-- reassign Operators for indicated day participated in indicated Procedure
procedure reassignOperatorsInDay(p_proc_id number, p_day date);

function generateDumpSeq return number;

-- Mark Procedure that Night Shifts are generated
procedure flagProcedureNightShiftsDone(p_proc_id number, p_user_id number);
-- Mark Procedure that DayOffs are generated
procedure flagProcedureDayOffsDone(p_proc_id number, p_user_id number);
-- Mark Procedure that All other Shifts are generated
procedure flagProcedureAssignsDone(p_proc_id number, p_user_id number);

procedure test;

end PSHFT_GENERATOR;
/
create or replace package body PSHFT_GENERATOR is

-- Indicates globally Debugging levels in which Shift Application will work
-- 0 = Production mode
-- 1 = only assignOperators2Shifts() Loop with takeNextOperator() works
--     and writes console log with dbms_output. Operator choose randomization may be tested this way.
FLAG_DEBUG_MODE constant pls_integer := 0;

GNR_ASSIGNM_METHOD_RANDOM constant pls_integer := 1;

GNR_ASSIGNM_METHOD_SEQUENTIAL constant pls_integer := 2;

-- so far most intellectual way when justice is tried to be delivered.
-- When Generator chooses for Operator among available Shifts within Day - each Shift is assigned weight.
-- The less weight is the higher is Shift priority.
-- Weight is calculated by division of Shift.AssignedOperators to Shift.Capacity.
-- for 2 Shifts having same weights calculated this way higher priority has one having less Capacity.
GNR_ASSIGNM_METHOD_WEIGHTED constant pls_integer := 4;

gnrAssignmMethod pls_integer := GNR_ASSIGNM_METHOD_WEIGHTED;

-- Indicates method configured for Assignment of Operator to the Shift within single Day.
-- Possible values are constants GNR_ASSIGNM_METHOD_...
function getCnf_GNR_AssignmentMethod return pls_integer;

GNR_LET_OVERCAPACITY constant boolean := false;


TRY_MAX_ATTEMPTS constant number := 1;

-- indicates how many Operators who can have Night Shift in next week Mon - assign DayOffs in SUN.
-- Having just 1 Operator prepared this way with DayOff - may be risky as for Next week he could take Vacation and be excluded from Shifts!
CNF_DAYOFF_Sun4NightShift constant pls_integer := 2;

DAYOFF_ALGORITHM_1 constant pls_integer := 1; -- 1-st Minimal (DAYOFF_SHIFT_FROM), 2-d - Maximum (DAYOFF_SHIFT_TO)
DAYOFF_ALGORITHM_2 constant pls_integer := 2; -- Randomly decide use DAYOFF_SHIFT_FROM or DAYOFF_SHIFT_TO
gnrDayOffsMethod pls_integer := DAYOFF_ALGORITHM_2;





-- Control structure, works along with takeNextOperator() function to return next Operator chosen by some randomization.
operatorsRec opersType;


function getNextCalcLogSeq return number;

-- When particular Shift is found Available
procedure logRulesCalcResult(p_proc_id number, p_shift_id number, p_operator_id number, p_day date,
                             p_shift_start_hour date, p_shift_capacity number, p_assigned_operators number, p_dayShifts dayShiftsType, p_assignment assignmentData,
                             p_dumpseq number);

-- When particular Shift is found not Available
procedure logRulesCalcResult(p_proc_id number, p_shift_id number, p_operator_id number, p_day date,
                             p_shift_start_hour date, p_shift_capacity number, p_assigned_operators number, p_dayShifts dayShiftsType, p_assignment assignmentData,
                             p_check_source number, p_check_type number, p_check_source_id number,
                             p_dumpseq number);

procedure logRulesCalcResult(p_proc_id number, p_shift_id number, p_operator_id number, p_day date,
                             p_shift_start_hour date, p_shift_capacity number, p_assigned_operators number, p_dayShifts dayShiftsType, p_assignment assignmentData,
                             p_shiftavailable_flag number, p_check_source number, p_check_type number, p_check_source_id number,
                             p_dumpseq number);

procedure logAssignmentAction(p_proc_id number, p_shift_id number, p_shift_start_hour date,
                             p_shift_capacity number, p_assigned_operators number,
                             p_operator_id number, p_assign_id number, action_result varchar2,
                             p_dumpseq number);

procedure logReassignments(p_proc_id number,
                             p_shift_rcpnt_id number, p_shift_donor_id number,
                             p_operator_id number, p_day date,
                             p_shift_rcpnt_start_hour date,
                             p_shift_donor_capacity number, p_shift_donor_assgn number,
                             p_shift_rcpnt_capacity number, p_shift_rcpnt_assgn number,
                             p_if_check_ok number, p_check_source number, p_check_type number, p_check_source_id number,
                             p_dumpseq number);

-- for indicated Shift Generation Procedure - take next Operator to make particular Operation for him.
-- Possible operations are: Setup-ing DayOffs, Generating Shifts, ???
-- #param p_proc_id refers the SHFT_SHIFT_PROC.ID of the Shift Generation Procedure
-- #return Operator System ID (SHFT_OPERATOR.ID)
function takeNextOperator(p_proc_id number) return number;


-- Generate Empty Shifts for indicated Shift Generation Procedure and particular Day
-- #param p_proc_id System ID of the procedure in ontext of which empty Shifts are to be generated
-- #param p_day Day for which empty Shofta are to be generated (under single procedure there are 7 days - week)
-- #param p_user_id System Id of the User in context of which empty Shifts are generated
procedure generateEmptyShifts(p_proc_id number, p_day date, p_user_id number);


-- Generate DayOffs for all Operators participated in indicated Generation Procedure
-- procedure setupDayOffs(p_proc_id number, p_dumpseq number);

-- for indicated Shift Generation Procedure - setup DayOffs (i.e. rest days) for particular Operator
-- #param p_proc_id Shift Generation Procedure System ID (SHFT_SHIFT_PROC.ID)
-- #param p_operator_id Operator System ID (SHFT_OPERATOR.ID)
-- #param p_dumpseq DUMP sequence under which current generation is performed
-- procedure setupDayOffs4Operator(p_proc_id number, p_operator_id number, p_dumpseq number);

--
function calcDayAssgnStat(p_proc_id number, p_operator_id number, p_day date) return dayAssgnStatType;

-- Generates Shift for particular Operator.
-- During this Operation - is calculated and set-up for the indicated Operator -
-- which days within the Calculation Period will be rest days, in which shifts they will work etc...
-- #param p_proc_id Shift Generation Procedure System ID (SHFT_SHIFT_PROC.ID)
-- #param p_operator_id Operator System ID (SHFT_OPERATOR.ID)
-- #param p_dumpseq DUMP sequence under which current generation is performed
procedure assignOperator2Shifts(p_proc_id number, p_operator_id number, p_dumpseq number);


-- Assigns particular Operator - to some Shift for particular Day.
-- Optimal choice will be done among all Shifts of this Day this Operator is eligible to be assigned to, taking into account all restrictions and rules.
-- #param p_proc_id Shift Generation Procedure System ID (SHFT_SHIFT_PROC.ID)
-- #param p_operator_id Operator System ID - refers SHFT_OPERATOR.ID
-- #param p_day Day for which Operator is to be assigned
-- #param p_assignment Structure providing whole week data (about dayoffs and already assigned shifts) - to let analyze for most optimal distribution within this Day.
-- #param p_letovercapacity indicates Overcapacity mode:
--        true = it is allowed to assign Operator to the Shift whose Capacity is already filled in.
--             How many Operators may be added Over and whether it is possible at all for this Type of Shift - is configured with SHFT_SHIFT_TYPE table
--        false = Operator may be set only to the Shift whose capacity is not filled in yet.
-- #param p_dumpseq DUMP sequence under which current generation is performed
function assignOperator2Day(p_proc_id number, p_operator_id number, p_day date, p_assignment assignmentData, p_letovercapacity boolean, p_dumpseq number) return dayAssignmentType;

-- Sets indicated status for indicated procedure
-- procedure setStatus2Procedure(p_proc_id number, p_status number);

-- Remove assignments (physically Delete it from SHFT_SHIFT_PROCEDURE)
procedure deassignOperator2Shift(p_operator_id number, p_shift_id number);

-- Updates status of the Procedure to the indicated one. 
-- If Status is not correct - nothing is done
-- If Status is already as indicated one - nothing is done
-- New version is created if status is changed
-- #param p_proc_id Procedure System Id
-- #param p_new_status Status value to which it should be changed
-- #param User System Id in context of which this is to be changed
procedure updateProcStatus(p_proc_id number, p_new_status number, p_user_id number);



-- generateNewProcedure()
function generateNewProcedure(p_date_from date, p_date_to date, p_dsc varchar2, p_user_id number) return number is
/**
 declare
   p_date_from date := to_date('09.01.2012', 'dd.mm.yyyy');
   p_date_to date := to_date('15.01.2012', 'dd.mm.yyyy');
   p_dsc varchar2(128) := 'Test generation procedure';
   v_id number;
 begin
   v_id := PSHFT_GENERATOR.generateNewProcedure(p_date_from, p_date_to, p_dsc);
   dbms_output.put_line('id = ' || v_id);
 end;
*/
  v_id number;
  v_last_proc PSHFT_COMMONS1.shiftProcType;
begin
  v_last_proc := PSHFT_COMMONS1.getLastShiftProc;
  select SHFT_SHIFT_PROC_SQ_ID.Nextval into v_id from dual;
  insert into SHFT_SHIFT_PROC (ID, STATUS, PERIOD_FROM, PERIOD_TO, DSC, DUMPSEQ_PREV, USER_ID, FD, TD)
                       values (v_id, PSHFT_COMMONS1.PROC_STATUS_INIT, p_date_from, p_date_to, p_dsc, v_last_proc.DUMPSEQ, p_user_id, sysdate, pshft_commons1.getInfinity);
  return v_id;
end generateNewProcedure;

-- generateNewProcedure()
function generateNewProcedure(p_dsc varchar2, p_user_id number) return number as
  v_last_proc PSHFT_COMMONS1.shiftProcType;
  v_id number;
begin
  v_last_proc := PSHFT_COMMONS1.getLastShiftProc;
--  select * into prevProc from SHFT_SHIFT_PROC
--         where ID = (select max(id) from SHFT_SHIFT_PROC where sysdate between fd and td);
  
  if v_last_proc.id is not NULL then
    -- generate for next week
    v_id := generateNewProcedure(v_last_proc.Period_To + 1, v_last_proc.Period_To + 7, p_dsc, p_user_id);
  else
    -- 
    v_id := -1;
  end if;
  return v_id;
end;

-- generateEmptyShifts()
procedure generateEmptyShifts(p_proc_id number, p_user_id number) is
/**
declare
  p_proc_id number := xx;
begin
  PSHFT_GENERATOR.generateEmptyShifts(p_proc_id);
end;
*/
  shiftProc PSHFT_COMMONS1.shiftProcType;
  v_day date;
begin
  shiftProc := PSHFT_COMMONS1.getShiftProc(p_proc_id);
  for cnt in 1..shiftProc.CLC_DAYS_NUM loop
    v_day := shiftProc.PERIOD_FROM + cnt - 1;
    generateEmptyShifts(p_proc_id, v_day, p_user_id);
  end loop;
  commit;
end generateEmptyShifts;

-- generateEmptyShifts(p_proc_id number, p_day date)
procedure generateEmptyShifts(p_proc_id number, p_day date, p_user_id number) is
  v_day date := trunc(p_day, 'dd');
  v_shift_start date;
  cursor crsShiftTypes is
         select * from SHFT_SHIFT_TYPE
                where status = PSHFT_COMMONS1.SHIFTTP_STATUS_ACTIVE
                      and proc_id = p_proc_id
                      and sysdate between fd and td
                order by hour_start;
  v_sysdate date := sysdate;
begin
  for crs in crsShiftTypes loop
    v_shift_start := v_day + crs.hour_start/24;
    insert into SHFT_SHIFT (ID, PROC_ID, STATUS,
                            SHIFT_START_HOUR, SHIFT_END_HOUR, SHIFTTYPE_ID, 
		                        SHIFT_TYPE, SHIFT_CAPACITY, ASSIGNED_OPERATORS, FD, TD, USER_ID)
                    values (SHFT_SHIFT_SQ_ID.Nextval, p_proc_id, PSHFT_COMMONS1.SHIFT_STATUS_INIT,
                            v_shift_start, v_shift_start + crs.hours/24, crs.ID, 
                            crs.shift_type, crs.capacity, 0, v_sysdate, PSHFT_COMMONS1.getInfinity, p_user_id);
  end loop;
end generateEmptyShifts;


-- setupDayOffs()
procedure setupDayOffs(p_proc_id number, p_dayoffs_per_day number, p_user_id number := 0) as
/**
declare
  p_proc_id number := 85;
  p_dayoffs_per_day number := 10;
  p_user_id number := 0;
begin
  PSHFT_GENERATOR.setupDayOffs(p_proc_id, p_dayoffs_per_day, user_id);
end;
*/
begin
  setupDayOffs(p_proc_id, p_dayoffs_per_day, DAYOFF_GNR_STEPS_30, false, p_user_id);
  commit;
end;  

-- setupDayOffs()
procedure setupDayOffs(p_proc_id number, p_dayoffs_per_day number, p_steps number, p_if_miss_prev_steps boolean, p_user_id number) is
/**
declare
  p_proc_id number := 17;
  p_dayoffs_per_day number := 10;
  p_steps number := PSHFT_GENERATOR.DAYOFF_GNR_STEPS_1;
  p_if_miss_prev_steps boolean := true;
begin
  PSHFT_GENERATOR.setupDayOffs(p_proc_id, p_dayoffs_per_day, p_steps, p_if_miss_prev_steps);
end;
*/
  v_day date;
  v_day_processed date;
  v_week_startday date;
  v_week_lastday date;
  v_last_restday date;
  v_shiftproc PSHFT_COMMONS1.shiftProcType;
  v_prev_shiftproc PSHFT_COMMONS1.shiftProcType;
  v_proc_id number;
  v_operator SHFT_OPERATOR%ROWTYPE;
  v_counter number;
  v_dayoffs_counter number;
  v_dayoffs_last number;
  v_step varchar2(128) := '';
  v_ops_num number := 0;

  v_ops_per_day number := 0;
  v_ops_rest number := 0;
  v_daynum number := 0; -- Fri = 1, Sat = 2, Sun = 3

  -- List of Operators have been assigned already to the Night Shifts
  -- used with Step.10
  cursor crsNightShiftAssgn(cp_proc_id number) is
    select op.operator_user_id, op.id operator_id, op.operator_personname, sh.shift_start_hour
       from SHFT_SHIFT sh, SHFT_OPERATOR op, SHFT_SHIFT_OPERATOR sop
       where sop.proc_id = cp_proc_id
             and sop.operator_id = op.id
             and sop.shift_id = sh.id
             and sh.shift_type = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT
       order by sh.shift_start_hour;
  -- Operators who are Ok to be assigned for Night Shift according to the PSHFT_RULECLC.RULE_NightShiftPerMonth rule.
  -- used with Step.20
  cursor crsNightShiftAvail(cp_proc_id number, cp_day date) is
    select op.operator_user_id,
           op.id operator_id,
           op.operator_personname, 
           assgn.start_max
       from SHFT_OPERATOR op,
            (select op1.operator_user_id, max(sh.shift_start_hour) start_max
                    from SHFT_SHIFT sh,
                         SHFT_OPERATOR op1,
                         SHFT_SHIFT_OPERATOR sop
                    where sop.operator_id = op1.id
                          and sop.shift_id = sh.id
                          and sh.shift_type = 1
                    group by op1.operator_user_id
                         ) assgn
       where op.proc_id = cp_proc_id
             and op.status = PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED
             and op.operator_user_id = assgn.operator_user_id
             and not exists (select * from SHFT_OPERATOR_EXC exc
                                    where exc.exc_type = PSHFT_EXCLUSION.EXCTYPE_SHIFTTYPE
                                          and exc.exc_shift_type = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT
                                          and exc.operator_id = op.id)
             and cp_day > assgn.start_max + PSHFT_RULECLC.DST_BETWEEN_NIGHT_SHIFTS
       order by start_max, round(dbms_random.value(1, 1000));
  -- Operators which are New (appeared in this Procedure 1-st time) - they all need to have DayOff in Fri.
  -- User with Step.25
  cursor crsNewOperators(cp_prev_proc_id number) is
    select count(*) over (partition by status) ops_num, op.* from SHFT_OPERATOR op
           where op.proc_id = p_proc_id
                 and not exists (select * from SHFT_OPERATOR op1
                                    where op1.proc_id = cp_prev_proc_id
                                          and op1.operator_user_id = op.operator_user_id
                                          )
           order by op.operator_user_id;
  -- Operators from particular Procedure having Lasd DayOff in indicated Day.
  -- NOTE: Operators are ORDERed randomly.
  -- used with Step.30
  -- #param cp_proc_id Shift Procedure ID which is previous related to the current one
  -- #param cp_day Calendar day to be processed
  cursor crsHavingLastDayoff(cp_proc_id number, cp_day date) is
    select exc.* from
          (select oe.proc_id, op.id operator_id, op.operator_user_id, op.operator_personname, oe.exc_type, decode(exc_type, PSHFT_EXCLUSION.EXCTYPE_PERIOD, exc_period_to, PSHFT_EXCLUSION.EXCTYPE_DAYOFF, exc_period_from) exc_period_from
             from SHFT_OPERATOR op, SHFT_OPERATOR_EXC oe
             where oe.operator_id = op.id
                   and oe.proc_id = cp_proc_id
                   and oe.exc_type in (PSHFT_EXCLUSION.EXCTYPE_PERIOD, PSHFT_EXCLUSION.EXCTYPE_DAYOFF)) exc
       where  -- Don't generate DayOffs for Operators having vacation on THIS week
             not exists (select * from SHFT_OPERATOR op2, SHFT_OPERATOR_EXC oe2
                                    where oe2.proc_id = p_proc_id
                                          and oe2.operator_id = op2.id
                                          and oe2.exc_type = PSHFT_EXCLUSION.EXCTYPE_PERIOD
                                          and op2.operator_user_id = exc.operator_user_id
                                          )
             and trunc(exc.exc_period_from, 'dd') = trunc(cp_day)
             and exc.exc_period_from = (select max(decode(exc_type, PSHFT_EXCLUSION.EXCTYPE_PERIOD, exc_period_to, PSHFT_EXCLUSION.EXCTYPE_DAYOFF, exc_period_from))
                                              from SHFT_OPERATOR_EXC
                                              where exc_type in (PSHFT_EXCLUSION.EXCTYPE_PERIOD, PSHFT_EXCLUSION.EXCTYPE_DAYOFF)
                                                    and operator_id = exc.operator_id)
             -- Exclude Operators for whom DayOffs have been already generated with new Procedure
             and exc.operator_user_id not in (select op1.operator_user_id
                                                    from SHFT_OPERATOR op1, SHFT_OPERATOR_EXC oe1
                                                    where oe1.exc_type = PSHFT_EXCLUSION.EXCTYPE_DAYOFF
                                                          and op1.id = oe1.operator_id
                                                          and oe1.proc_id > exc.proc_id
                                                          )
       order by round(dbms_random.value(1, 1000));
  -- Log on the screen (dbms_output) DayOff parameters: Operator, Day etc...
  procedure log_exclusion_screen(p_step varchar2, p_operator_user_id number, p_operator_id number, p_day date, p_operator_name varchar2) as
  begin
    dbms_output.put_line('p_step: ' || p_step || ', operator_id = ' || p_operator_id || ', p_day = ' || to_char(p_day, 'dd.mm.yyyy') 
                        || ', p_operator_user_id = ' || p_operator_user_id || ', p_operator_name = ' || p_operator_name);
  end;
begin
  v_shiftproc := PSHFT_COMMONS1.getShiftProc(p_proc_id);

  if v_shiftproc.IF_NIGHTSHIFTS_ASSIGNED != 1 then
     -- Terminate DayOffs Setup - Night Shifts had to be generated before!
     raise PSHFT_COMMONS1.exNightShiftsNotGenerated;
  end if;

  v_step := '10';

  v_prev_shiftproc := PSHFT_COMMONS1.getPreviousShiftProc(p_proc_id);
  v_week_startday := PSHFT_COMMONS1.getWeekStartDate(v_shiftproc.PERIOD_FROM);
  v_week_lastday := v_week_startday + 6; -- this week SUN
  -- Step.10: for Operators assigned for Night Shifts (excluding Monday!) - previous Day will be Setup as DayOff.
  if p_steps = DAYOFF_GNR_STEPS_10 OR NOT p_if_miss_prev_steps then
      for crs in crsNightShiftAssgn(p_proc_id) loop
        v_day := trunc(crs.shift_start_hour, 'dd');
        if v_day != v_week_startday then
           v_day := v_day - 1;

/*           
           if crs.operator_id is null then
             log_exclusion_screen(v_step, crs.operator_user_id, crs.operator_id, v_day, crs.operator_personname);
           end if;
*/           
           pshft_exclusion.setupExclusion4Operator(p_proc_id, crs.operator_id, pshft_exclusion.EXCTYPE_DAYOFF, v_day, 0, p_user_id);
        end if;
      end loop;
  end if;

  v_step := '20';

  -- Step.20: Choose as many as indicated in the CNF_DAYOFF_Sun4NightShift Config parameter
  --         Operators who may be Ok to be assigned to the Next week Monday nigh shift -
  --         and setup for them DayOff for SUN.
  --         Then - distribute for them probably other DayOffs, too.
  if p_steps = DAYOFF_GNR_STEPS_20 OR ((NOT p_if_miss_prev_steps) and p_steps in (DAYOFF_GNR_STEPS_25, DAYOFF_GNR_STEPS_30)) then
    v_counter := 0;
    for crs in crsNightShiftAvail(p_proc_id, v_week_startday+7) loop
       v_last_restday := PSHFT_COMMONS1.getLastRestDay(crs.operator_id);
       if v_last_restday is NULL -- That is - Operator is new for Shift Application
         or v_last_restday < v_week_startday-7 -- This case shan't take plase - violates PSHFT_RULECLC.RULE_DayOff_DistanceBetween Rule
         or v_last_restday = v_week_startday - 1 -- Previous week SUN
         or v_last_restday between v_week_startday-7 and v_week_startday-4 -- Previous week MON-THU
                                                                        THEN

             v_step := '22';

/*             
             if crs.operator_id is null then
                log_exclusion_screen(v_step, crs.operator_user_id, crs.operator_id, v_week_lastday, crs.operator_personname);
             end if;
*/
             
             pshft_exclusion.setupExclusion4Operator(p_proc_id, crs.operator_id, pshft_exclusion.EXCTYPE_DAYOFF, v_week_lastday, 0);
             v_counter := v_counter + 1;

             v_step := '24';

             if v_last_restday is not NULL and v_last_restday != v_week_startday - 1 then
                 -- Now - setup for the same Operator - rest DayOff on this week
                 v_day := v_last_restday + trunc((v_week_lastday-v_last_restday+1)/2);
/*
                 if crs.operator_id is null then
                    log_exclusion_screen(v_step, crs.operator_user_id, crs.operator_id, v_day, crs.operator_personname);
                 end if;
*/
                 pshft_exclusion.setupExclusion4Operator(p_proc_id, crs.operator_id, pshft_exclusion.EXCTYPE_DAYOFF, v_day, 0, p_user_id);
             end if;
       end if;
       if v_counter = CNF_DAYOFF_Sun4NightShift then
         exit;
       end if;
    end loop;
  end if;

  -- Step.25: distribute New Operators (i.e. those which were absent as Operators in previous Shift but are now).
  -- They may hit either Fri, Sat or Sun as a DayOff.
  if p_steps = DAYOFF_GNR_STEPS_25 OR ((NOT p_if_miss_prev_steps) and p_steps in (DAYOFF_GNR_STEPS_30)) then
    v_ops_num := 0;
    v_ops_per_day := 0;
    v_ops_rest := 0;
    v_daynum := 0; -- Fri = 1, Sat = 2, Sun = 3
    v_counter := 0;
    for crs in crsNewOperators(v_prev_shiftproc.ID) loop
      if v_ops_num = 0 then
        v_ops_num := crs.ops_num;
        v_ops_per_day := trunc(v_ops_num/3);
        v_ops_rest := mod(v_ops_num, 3);
        v_daynum := 1;
      end if;
      v_step := '25';
      -- Exclusion add
      v_day := v_week_startday+3+v_daynum;
/*      
      if crs.id is null then
         log_exclusion_screen(v_step, crs.operator_user_id, crs.id, v_day, crs.operator_personname);
      end if;
*/      
      pshft_exclusion.setupExclusion4Operator(p_proc_id, crs.id, pshft_exclusion.EXCTYPE_DAYOFF, v_day, 0, p_user_id);
      v_counter := v_counter + 1;
      if v_counter = v_ops_per_day and v_daynum in (1,2) then
        v_daynum := v_daynum + 1;
        v_counter := 0;
      end if;
    end loop;
  end if;

  -- Step.30: Distribute Other DayOffs - for Other Operators than ones
  if p_steps = DAYOFF_GNR_STEPS_30 then
    -- Go by Week's daya and Setup DayOffs for each Day
    for cnt_day in 1..7 loop
      v_day_processed := v_week_startday + cnt_day - 1;
      -- Start accounting DayOffs number setup for this day.
      -- Some DayOffs are already setup because of Night Shifts.
      v_dayoffs_counter := PSHFT_COMMONS1.getNumberOfDayOffs(v_day_processed);
      -- to this day - should be setup dayoffs for:
      -- a) All those Operators having LAST Day Off at the day: v_day_processed-7
      -- b) Most possible part (leaving 1) of operators having LAST Day Off at the day: v_day_processed-6
      -- c) as many as necessary Operators (to fill in till p_dayoffs_per_day) having Last DayOff at the day: v_day_processed-5
      -- So - go to these Setup Steps:
      -- a) All those Operators having LAST Day Off at the day: v_day_processed-7
      v_proc_id := v_prev_shiftproc.id;
      v_day := v_day_processed-7;
      for crs in crsHavingLastDayoff(v_proc_id, v_day) loop
          
          v_operator := PSHFT_COMMONS1.getOperatorByUserId(p_proc_id, crs.operator_user_id);

          v_step := '32';
          if v_operator.id is NOT null then
            
             v_dayoffs_counter := v_dayoffs_counter + 1;
             
             pshft_exclusion.setupExclusion4Operator(p_proc_id, v_operator.id, pshft_exclusion.EXCTYPE_DAYOFF, v_day_processed, 0, p_user_id);

--             log_exclusion_screen(v_step, crs.operator_user_id, v_operator.id, v_day_processed, crs.operator_personname);
          end if;

      end loop;
      -- b) Most possible part (leaving 1) of operators having LAST Day Off at the day: v_day_processed-6
      --    - if Day we are setup DayOffs for is not this week SUN!
      --    If it is SUN - then Mon and Tue would share equally!
      if v_dayoffs_counter < p_dayoffs_per_day then
        v_day := v_day_processed-6;
        v_counter := 0;
        if v_day_processed = v_week_lastday then
           -- Processed Day is this week SUN, policy -  Operators having LAST DayOffs in this week Mon and Tue -
           -- share approximately equally in SUN's DayOffs.
           v_dayoffs_last := trunc((p_dayoffs_per_day - v_dayoffs_counter)/2);
           v_proc_id := p_proc_id;
        else
           v_dayoffs_last := PSHFT_COMMONS1.getNumberOfLastDayOffs(v_prev_shiftproc.id, v_day);
           v_proc_id := v_prev_shiftproc.id;
        end if;
        for crs in crsHavingLastDayoff(v_proc_id, v_day) loop

          v_step := '35';

          
          v_counter := v_counter + 1;
          v_operator := PSHFT_COMMONS1.getOperatorByUserId(p_proc_id, crs.operator_user_id);
          
          if v_operator.id is NOT null then
            
             v_dayoffs_counter := v_dayoffs_counter + 1;
             pshft_exclusion.setupExclusion4Operator(p_proc_id, v_operator.id, pshft_exclusion.EXCTYPE_DAYOFF, v_day_processed, 0, p_user_id);
             
             -- log_exclusion_screen(v_step, crs.operator_user_id, v_operator.id, v_day_processed, crs.operator_personname);
          end if;
          
          if v_dayoffs_counter = p_dayoffs_per_day then
            exit;
          end if;
          if v_counter = v_dayoffs_last - 1 then
            -- Leave 1 Operators resource from this day - for Next day DayOffs' setup.
            exit;
          end if;
        end loop;
      end if;
      -- c) as many as necessary Operators (to fill in till p_dayoffs_per_day) having Last DayOff at the day: v_day_processed-5
      if v_dayoffs_counter < p_dayoffs_per_day then
        v_day := v_day_processed-5;
        if cnt_day in (6, 7) then
           -- Processed day is SAT or SUN, this Day - will be MON or TUE, from same Procedure!
           v_proc_id := p_proc_id;
        else
           v_proc_id := v_prev_shiftproc.id;
        end if;
        for crs in crsHavingLastDayoff(v_proc_id, v_day) loop
          
          v_step := '40';

          v_operator := PSHFT_COMMONS1.getOperatorByUserId(p_proc_id, crs.operator_user_id);

          if v_operator.id is NOT null then
            
             v_dayoffs_counter := v_dayoffs_counter + 1;
             
             pshft_exclusion.setupExclusion4Operator(p_proc_id, v_operator.id, pshft_exclusion.EXCTYPE_DAYOFF, v_day_processed, 0, p_user_id);
             
             -- log_exclusion_screen(v_step, crs.operator_user_id, v_operator.id, v_day_processed, crs.operator_personname);
          end if;
          
          if v_dayoffs_counter = p_dayoffs_per_day then
            exit;
          end if;
        end loop;
      end if;

    end loop;
  end if;

  flagProcedureDayOffsDone(p_proc_id, p_user_id);

end setupDayOffs;

/*
-- setupDayOffs()
procedure setupDayOffs(p_proc_id number, p_dumpseq number) is
  c_opers PSHFT_COMMONS1.operatorsCursor;
  v_operator SHFT_OPERATOR%ROWTYPE;
begin
  c_opers := PSHFT_COMMONS1.getOperators(p_proc_id);
  LOOP
    FETCH c_opers into v_operator;
    EXIT when c_opers%NOTFOUND;

    setupDayOffs4Operator(p_proc_id, v_operator.id, p_dumpseq);

  END LOOP;
  CLOSE c_opers;
end setupDayOffs;

-- setupDayOffs4Operator()
procedure setupDayOffs4Operator(p_proc_id number, p_operator_id number, p_dumpseq number) is
  v_last_dayoff date;
  v_assigned_dayoff date;
  v_dayoff_shift number; -- number of days since last dayoff (v_last_dayoff) till new dayoff (v_assigned_dayoff)
  shiftProc PSHFT_COMMONS1.shiftProcType;
  v_correction_gap number;
begin
  --
  shiftProc := PSHFT_COMMONS1.getShiftProc(p_proc_id);

  -- Find out last Day Off operator took
  select max(exc.exc_period_from) into v_last_dayoff
       from SHFT_OPERATOR opr, SHFT_OPERATOR_EXC exc
	     where exc.operator_id = opr.id
             and exc.exc_type = 4 -- DayOff
		         and opr.operator_user_id = (select opr_p.operator_user_id
                                       from SHFT_OPERATOR opr_p
                                       where opr_p.proc_id = p_proc_id and id = p_operator_id);

  v_correction_gap := 0;

  -- This case may take place with New Comers!
  if v_last_dayoff is null then
    v_last_dayoff := shiftProc.PERIOD_FROM - 1;
  end if;

  if gnrDayOffsMethod = DAYOFF_ALGORITHM_2 then
     v_dayoff_shift := round(dbms_random.value(DAYOFF_SHIFT_FROM, DAYOFF_SHIFT_TO));
  elsif gnrDayOffsMethod = DAYOFF_ALGORITHM_1 then
     v_dayoff_shift := DAYOFF_SHIFT_FROM; -- 1-st Shift is minimal possible one
  end if;

  v_assigned_dayoff := v_last_dayoff + v_dayoff_shift;

  if v_assigned_dayoff < shiftProc.PERIOD_FROM then
      -- This may take place if, by some reason - this Operator has no former DayOffs fixed properly.
      -- Example: he had vacation and had no dayoffs.
      -- @TODO: this decision should be re-estimated along with Vera and\or Irma.
      v_assigned_dayoff := shiftProc.PERIOD_FROM;

  else
      v_correction_gap := 1;
  end if;

  -- if Shift generation Procedure period is larger than 1 week (2 weeks or 3 weeks)
  -- there should be next DayOffs as well
  while v_assigned_dayoff between shiftProc.PERIOD_FROM and shiftProc.PERIOD_TO loop

     -- SetUp just calculated DayOff -
    pshft_exclusion.setupExclusion4Operator(p_proc_id, p_operator_id, pshft_exclusion.EXCTYPE_DAYOFF, v_assigned_dayoff, v_correction_gap);

    if gnrDayOffsMethod = DAYOFF_ALGORITHM_2 then
       v_dayoff_shift := round(dbms_random.value(DAYOFF_SHIFT_FROM, DAYOFF_SHIFT_TO));
    elsif gnrDayOffsMethod = DAYOFF_ALGORITHM_1 then
       v_dayoff_shift := DAYOFF_SHIFT_TO; -- 2-d Shift is maximal possible one
    end if;

    v_assigned_dayoff := v_assigned_dayoff + v_dayoff_shift;
    v_correction_gap := 0;
  end loop;
exception
  when NO_DATA_FOUND then
      null;
  when OTHERS then
      null;
end setupDayOffs4Operator;
*/

-- assignOperators2Shifts()
procedure assignOperators2Shifts(p_proc_id number, p_mode number) is
/**
--   ASSIGN_MODE_FULL
--   ASSIGN_MODE_DAYOFFSonly
--   ASSIGN_MODE_ASSIGNonly
declare
  p_proc_id number := xx;
  p_mode number := PSHFT_GENERATOR.ASSIGN_MODE_DAYOFFSonly;
begin
  PSHFT_GENERATOR.assignOperators2Shifts(p_proc_id);
end;
*/
  v_operator_id number;
  v_counter number := 0;
  v_dumpseq number;
  shiftProc PSHFT_COMMONS1.shiftProcType;
begin

  shiftProc := PSHFT_COMMONS1.getShiftProc(p_proc_id);

  if shiftProc.DUMPSEQ is null then

    -- Generate DUMP sequence to be used
    v_dumpseq := generateDumpSeq;
    update SHFT_SHIFT_PROC
           set DUMPSEQ = v_dumpseq
           where id = p_proc_id;
  else
    v_dumpseq := shiftProc.DUMPSEQ;
  end if;

  if p_mode in (ASSIGN_MODE_FULL, ASSIGN_MODE_DAYOFFSonly) then
    -- Control if DayOffs were already Generated
--    setupDayOffs(p_proc_id, v_dumpseq);
    COMMIT;
  end if;


  if p_mode in (ASSIGN_MODE_FULL, ASSIGN_MODE_ASSIGNonly) then
      -- setStatus2Procedure(p_proc_id, PSHFT_COMMONS1.PROC_STATUS_UNDERPROC);
      COMMIT;
      while true loop
        v_counter := v_counter + 1;
        v_operator_id := takeNextOperator(p_proc_id);
        if v_operator_id is null then
          exit;
        end if;
        if v_counter >= 55 then -- Just for DEBUG purposes
          NULL;
        end if;
        if FLAG_DEBUG_MODE != 1 then
           assignOperator2Shifts(p_proc_id, v_operator_id, v_dumpseq);
        else
           dbms_output.put_line(v_counter || ', ' || v_operator_id);
        end if;
        update SHFT_OPERATOR op
               set ORD_NUM = v_counter
               where ID = v_operator_id;
        COMMIT;
      end loop;
      -- After 1-st Run - should be done analyzis of what is left Undone.
      -- Among these things are:
      -- 1. Shifts which aren't Completed well, i.e. Shift whose Capacity exceeds actually assigned Operators number: SHFT_SHIFT.SHIFT_CAPACITY > SHFT_SHIFT.ASSIGNED_OPERATORS
      -- 2. Operators which couldn't be assigned to any Shift within Day which is to be Working day for him.
      -- setStatus2Procedure(p_proc_id, PSHFT_COMMONS1.PROC_STATUS_FINISHED);
      COMMIT;
  end if;

end assignOperators2Shifts;

/*
-- assignOperator2Shifts()
procedure assignOperator2Shifts(p_proc_id number, p_operator_id number, p_dumpseq number) is
  v_cnt_try number;
  v_cnt_day number;
  v_day date;
  c_dayoffs PSHFT_COMMONS1.daysCursor;
  v_dayoffs_cnt number := 0;
  shiftProcRec PSHFT_COMMONS1.shiftProcType;
  dayAssign dayAssignmentType;
  assignment assignmentData;
  v_assign_index number := 0;
  v_letovercapacity boolean := false;
begin
  shiftProcRec := PSHFT_COMMONS1.getShiftProc(p_proc_id);

  assignment.morningShiftsHours := 0;
  assignment.eveningShiftsHours := 0;
  assignment.shiftsHours := 0;

  assignment.weekBeginnigTailHours := PSHFT_COMMONS1.calcTailHoursFromPreviousWeek(p_operator_id, shiftProcRec.PERIOD_FROM);


  -- NOTE: DayOffs are calculated separately at once for all Operators!
  -- after this Step - DayOff days should be set for this Operator
  --(they will be fixed in the SHFT_OPERATOR_EXC, with DAY Off type)
  -- NOTE: Day Offs should be generated using ARBITRARY assumtion, just - hitting the Rules: RULE_DayOff_DistanceBetween
  --   setupDayOffs4Operator(p_proc_id, p_operator_id, p_dumpseq);

  c_dayoffs := PSHFT_COMMONS1.getDayOffs(p_operator_id);
  LOOP
    FETCH c_dayoffs into v_day;
    EXIT when c_dayoffs%NOTFOUND;

    v_dayoffs_cnt := v_dayoffs_cnt + 1;
    assignment.restDays(v_dayoffs_cnt) := v_day;

  END LOOP;
  CLOSE c_dayoffs;

  assignment.restDaysNum := v_dayoffs_cnt;


  for v_cnt_try in 1..2 loop
     if v_cnt_try = 1 then
       assignment.daysNum := 0;
     else
       -- Check if Operator have problem with one of Day, namely, which is his Working Day but he, by some reason got no assignment in it.
       -- In this case - next (2-d) assignment roundtrip will be taken, now - with Shifts Overcapacity allowed.
       -- This is most probable case why assignment took no place!
       v_letovercapacity := true;
     end if;
     for v_cnt_day in 1..shiftProcRec.CLC_DAYS_NUM loop

       v_day := shiftProcRec.PERIOD_FROM + v_cnt_day - 1;
       if v_cnt_try = 1
          or (v_cnt_try = 2
              and assignment.dayAssignments(v_cnt_day).if_available
              and NOT assignment.dayAssignments(v_cnt_day).if_assigned) then

               dayAssign := assignOperator2Day(p_proc_id, p_operator_id, v_day, assignment, v_letovercapacity, p_dumpseq);

               assignment.dayAssignments(v_cnt_day) := dayAssign;
               if dayAssign.if_assigned then
                  assignment.shiftsNum := assignment.shiftsNum + 1;
                  assignment.shiftsHours := assignment.shiftsHours + dayAssign.shift.SHIFT_HOURS;
                  if dayAssign.shift.shift_type in (PSHFT_COMMONS1.SHIFT_TYPE_MORNING_EARLY, PSHFT_COMMONS1.SHIFT_TYPE_MORNING) then
                      assignment.morningShiftsNum := assignment.morningShiftsNum + 1;
                      assignment.morningShiftsHours :=  assignment.morningShiftsHours + dayAssign.shift.SHIFT_HOURS;
                   -- NOTE: 1-st time - to not harm former algorythm (not enough time to change) - DAY - calculate along with evening!
--                 elsif dayAssign.shift.shift_type = PSHFT_COMMONS1.SHIFT_TYPE_DAY then
--                      assignment.dayShiftsNum := assignment.dayShiftsNum + 1;
--                      assignment.dayShiftsHours :=  assignment.dayShiftsHours + dayAssign.shift.SHIFT_HOURS;
                  elsif dayAssign.shift.shift_type in (PSHFT_COMMONS1.SHIFT_TYPE_DAY, PSHFT_COMMONS1.SHIFT_TYPE_EVENING, PSHFT_COMMONS1.SHIFT_TYPE_EVENING_LATE) then
                      assignment.eveningShiftsNum := assignment.eveningShiftsNum + 1;
                      assignment.eveningShiftsHours := assignment.eveningShiftsHours + dayAssign.shift.SHIFT_HOURS;
                  elsif dayAssign.shift.shift_type = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT then
                      assignment.if_night_assigned := true;
                  end if;
               end if;

       end if;
       if v_cnt_try = 1 then
          assignment.daysNum := v_cnt_day;
       end if;

     end loop; -- v_cnt_day in 1..shiftProcRec.CLC_DAYS_NUM loop

  end loop; -- v_cnt_try in 1..2 loop

end assignOperator2Shifts;
**/
-- assignOperator2Shifts()
procedure assignOperator2Shifts(p_proc_id number, p_operator_id number, p_dumpseq number) is
  pr_hoursWeekTail number;
	pr_if_avl_night boolean;
	pr_if_avl_morning_early boolean;
	pr_if_avl_evening_late boolean;
  pr_dayoffs number;

  already_assigned_days number := 0;
  already_assigned_hours number := 0;
  if_night_already_assigned boolean := false;
  if_night_assigned boolean := false;

  TYPE daysAssignType is TABLE of dayAssgnStatType index by BINARY_INTEGER;
  daysAssign daysAssignType;
  dayAssgnStat dayAssgnStatType;
  dayAssgnWeekStat dayAssgnStatType;

  v_res number;
  v_shift_id number;


  c_dayoffs PSHFT_COMMONS1.daysCursor;
  v_dayoffs_cnt number := 0;
  v_cnt_day number;
  v_day date;

  shiftProcRec PSHFT_COMMONS1.shiftProcType;
  -- Accumulates figures provided with dayAssgnStatType structure transferred to parameter -
  -- into the Week Statistic - purpose dayAssgnStatType structure - [dayAssgnWeekStat]
  procedure accumulateStat(dayAssgnStat dayAssgnStatType) is
  begin
    dayAssgnWeekStat.shift_night_avl := dayAssgnWeekStat.shift_night_avl + dayAssgnStat.shift_night_avl;
    dayAssgnWeekStat.shift_mornearl_avl := dayAssgnWeekStat.shift_mornearl_avl + dayAssgnStat.shift_mornearl_avl;
    dayAssgnWeekStat.shift_mornearl_avl_overc := dayAssgnWeekStat.shift_mornearl_avl_overc + dayAssgnStat.shift_mornearl_avl_overc;
    dayAssgnWeekStat.shift_morn_avl := dayAssgnWeekStat.shift_morn_avl + dayAssgnStat.shift_morn_avl;
    dayAssgnWeekStat.shift_morn_avl_overc := dayAssgnWeekStat.shift_morn_avl_overc + dayAssgnStat.shift_morn_avl_overc;
    dayAssgnWeekStat.shift_day_avl := dayAssgnWeekStat.shift_day_avl + dayAssgnStat.shift_day_avl;
    dayAssgnWeekStat.shift_day_avl_overc := dayAssgnWeekStat.shift_day_avl_overc + dayAssgnStat.shift_day_avl_overc;
    dayAssgnWeekStat.shift_evn_avl := dayAssgnWeekStat.shift_evn_avl + dayAssgnStat.shift_evn_avl;
    dayAssgnWeekStat.shift_evn_avl_overc := dayAssgnWeekStat.shift_evn_avl_overc + dayAssgnStat.shift_evn_avl_overc;
    dayAssgnWeekStat.shift_evnlate_avl := dayAssgnWeekStat.shift_evnlate_avl + dayAssgnStat.shift_evnlate_avl;
    dayAssgnWeekStat.shift_evnlate_avl_overc := dayAssgnWeekStat.shift_evnlate_avl_overc + dayAssgnStat.shift_evnlate_avl_overc;
  end;
begin
   shiftProcRec := PSHFT_COMMONS1.getShiftProc(p_proc_id);

   -- Step.10: Calculate Days Statistics
   for v_cnt_day in 1..shiftProcRec.CLC_DAYS_NUM loop
     v_day := shiftProcRec.PERIOD_FROM + v_cnt_day - 1;
     dayAssgnStat := calcDayAssgnStat(p_proc_id, p_operator_id, v_day);
     daysAssign(v_cnt_day) := dayAssgnStat;
     -- Accumulate
     accumulateStat(dayAssgnStat);
     if dayAssgnStat.if_day_already_assigned then
       already_assigned_days := already_assigned_days + 1;
       if dayAssgnStat.shift_type_already_assigned = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT then
          if_night_already_assigned := true;
       end if;
     end if;

   end loop;

   -- Step.20: See Previous week Hours Tail (either 0, 1 or 2)
   pr_hoursWeekTail := PSHFT_COMMONS1.calcTailHoursFromPreviousWeek(p_operator_id, shiftProcRec.PERIOD_FROM);

   -- Step.25: See if Night Shift, Early Morning, Late Evening Shifs are available
   pr_if_avl_night := PSHFT_EXCLUSION.checkShiftTypeAvailable(p_operator_id => p_operator_id,
                                           p_shift_type => PSHFT_COMMONS1.SHIFT_TYPE_NIGHT);
   pr_if_avl_morning_early := PSHFT_EXCLUSION.checkShiftTypeAvailable(p_operator_id => p_operator_id,
                                           p_shift_type => PSHFT_COMMONS1.SHIFT_TYPE_MORNING_EARLY);
   pr_if_avl_evening_late := PSHFT_EXCLUSION.checkShiftTypeAvailable(p_operator_id => p_operator_id,
                                           p_shift_type => PSHFT_COMMONS1.SHIFT_TYPE_EVENING_LATE);

   -- Step.30: See how many DayOffs has Operator within this week
   pr_dayoffs := PSHFT_COMMONS1.getNumberOfDayOffs(p_operator_id);


   -- Step.40: Analyse collected information about the week and decide on Assignment
   if if_night_already_assigned then
     if_night_assigned := true;
   end if;
   for v_cnt_day in 1..shiftProcRec.CLC_DAYS_NUM loop
      -- Step.40.1: See if Night Shift will be assigned
      if pr_if_avl_night and NOT if_night_assigned
             and daysAssign(v_cnt_day).if_prevday_dayoff and daysAssign(v_cnt_day).shift_night_avl > 0 then
           -- Now for this Day Night Shift - should be calculated
           select id into v_shift_id
                  from SHFT_SHIFT sh
                  where sh.shift_type = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT
                       and trunc(sh.shift_start_hour, 'dd') = daysAssign(v_cnt_day).day;
           v_res := PSHFT_RULECLC.calculateSingleRuleNum(p_shift_id => v_shift_id,
                                             p_operator_id => p_operator_id,
                                             p_rule => PSHFT_RULECLC.RULE_NightShiftPerMonth,
                                             p_accountOnlyPast => true);
           if v_res = 1 then
             -- Night Shift - will be assigned!!
             if_night_assigned := true;
             daysAssign(v_cnt_day).if_assigned := true;
             daysAssign(v_cnt_day).assigned_shift_type := PSHFT_COMMONS1.SHIFT_TYPE_NIGHT;
             daysAssign(v_cnt_day).assigned_shift_id := v_shift_id;
           end if;
      end if;
   end loop;


   if pr_dayoffs = 2 then
      -- RULE: Not consider for such Operators 13:00 (Day type) Shift
      -- Possible are Schemas: S0 = 1*8 + 4*6 = 32 hours
      --                       S1 = 2*8 + 3*6 = 34 hours,
      --                       S2 = 2*8 + 7 + 2*6 = 35 hours,
      --                       S3 = 3*8 + 2*6 = 36 hours,
      --                       S4 = 3*8 + 6 + 7 = 37 hours.
      if NOT if_night_assigned then
        -- Schemas S1 or S3 employed, decide between them
        null;
      else
        -- Schemas S2 or S4 employed, decide between them
        null;
      end if;
   elsif pr_dayoffs = 1 then
      null;
   end if;




   for v_cnt_day in 1..shiftProcRec.CLC_DAYS_NUM loop


     v_day := shiftProcRec.PERIOD_FROM + v_cnt_day - 1;

   end loop; -- v_cnt_day in 1..shiftProcRec.CLC_DAYS_NUM loop



end assignOperator2Shifts;

--
procedure assignOperators2NightShifts(p_proc_id number, p_if_randomize pls_integer, p_user_id number) is
/**
declare
  p_proc_id number := 36;
begin
  PSHFT_GENERATOR.assignOperators2NightShifts(p_proc_id);
end;
*/
  p_days2assign number := 7; -- Number of days of week to assign (starting from Mon)
  v_shiftproc PSHFT_COMMONS1.shiftProcType;
  v_shiftproc_prev PSHFT_COMMONS1.shiftProcType;
  v_day date;
  v_day_lastrest date;
  v_shift_id number;
  v_if_available number;
  if_assigned boolean;
  v_opers_num number;
  v_operator SHFT_OPERATOR%ROWTYPE;
  v_sysdate date := sysdate;
  v_nightshift_distane pls_integer;
  cursor crsOpers(cp_proc_id number, cp_day date, cp_nightshift_disctance number) is
    select op.operator_user_id,
           op.id operator_id,
           assgn.start_max
       from SHFT_OPERATOR op,
            -- For each OPERATOR_USER_ID gives last Night Shift date it was assigned to (if any)
            (select op1.operator_user_id, nvl(max(sh.shift_start_hour), to_date('01.01.2012', 'dd.mm.yyyy')) start_max
                    from SHFT_SHIFT sh,
                         SHFT_OPERATOR op1,
                         SHFT_SHIFT_OPERATOR sop
                    where sop.operator_id(+) = op1.id
                          and sop.shift_id = sh.id(+)
                          and sh.shift_type(+) = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT
                    group by op1.operator_user_id
                         ) assgn
       where op.proc_id = cp_proc_id
             and op.status = PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED
             and op.operator_user_id = assgn.operator_user_id
             -- i.e. this Operator is authorized for Night Shift assignments
             and not exists (select * from SHFT_OPERATOR_EXC exc
                                    where exc.exc_type = PSHFT_EXCLUSION.EXCTYPE_SHIFTTYPE
                                          and exc.exc_shift_type = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT
                                          and exc.operator_id = op.id)
             -- i.e. this Operator has no vacation at the day of this Night Shift
             and not exists (select * from SHFT_OPERATOR op2, SHFT_OPERATOR_EXC exc
                                    where exc.exc_type = PSHFT_EXCLUSION.EXCTYPE_PERIOD
                                          and cp_day between exc.exc_period_from-1 and exc.exc_period_to+1
                                          and exc.operator_id = op2.id
                                          and op2.operator_user_id = op.operator_user_id)
             -- take into account - Distance between Night Shifts restriction
             and cp_day > assgn.start_max + cp_nightshift_disctance
       order by decode(p_if_randomize, 0, start_max, 1, v_sysdate + dbms_random.value);
begin
  v_shiftproc := PSHFT_COMMONS1.getShiftProc(p_proc_id);
  v_shiftproc_prev := PSHFT_COMMONS1.getPreviousShiftProc(p_proc_id);
  for cnt in 1..7 loop
     if cnt > p_days2assign then
       exit;
     end if;
     v_day := v_shiftproc.PERIOD_FROM + cnt - 1;
     select id into v_shift_id
        from SHFT_SHIFT sh
        where sh.proc_id = p_proc_id
             and sh.shift_start_hour between v_day and v_day + 1 - PSHFT_COMMONS1.ONE_SECOND
             and sh.shift_type = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT;
     -- See if this Night Shift has been already assigned - bypass it:
     v_opers_num := PSHFT_COMMONS1.getAssignedOperatorsNum(v_shift_id);
     if v_opers_num > 0 then
         continue;
     end if;
     if_assigned := false;
     -- Assignment Algorithm works in 3 runs:
     -- 1-st run = follow Strict restrictions regarding both "Between Night Shifts distance" (30 days) and "Between DayOffs distance" (4, 5, 6 working days) rules (see PSHFT_RULECLC.RULE_NightShiftPerMonth, PSHFT_RULECLC.RULE_DayOff_DistanceBetween)
     -- 2-d run = (if 1-st run fails for this Night Shift) - relax "Between Night Shifts distance" rule, letting less distance (indicated in new constant PSHFT_RULECLC.DST_BETWEEN_NIGHT_SHIFTS_RELAX).
     -- 3-d run = (if 2-d run fails for this Night Shift) - relax "Between DayOffs distance" rule, letting 3 working days be accepted.
     for lvl in 1..3 loop -- 1-st level - strict control of PSHFT_RULECLC.RULE_DayOff_DistanceBetween, 2-d level - let 1 working day less than minimal allowed - if no resource.
         if lvl = 1 then
             v_nightshift_distane := PSHFT_RULECLC.DST_BETWEEN_NIGHT_SHIFTS;
         elsif lvl in (2, 3) then
             v_nightshift_distane := PSHFT_RULECLC.DST_BETWEEN_NIGHT_SHIFTS_RELAX;
         end if;
         for crs in crsOpers(p_proc_id, v_day, v_nightshift_distane) loop
             if cnt = 1 then
                 -- We are working for Mon.
                 -- Previous day was Sun, belonging to the previous week, in behalf of wich Generation Procedure has been already paseed formerly.
                 -- We need to be sure Operator we are handling - had DayOff in this Sun.
                 -- If not so - he can't bne assigned due to the PSHFT_RULECLC.RULE_HoursBetweenShifts Rule violation!
                 v_operator := PSHFT_COMMONS1.getOperatorByUserId(p_proc_id => v_shiftproc_prev.id,
                                                                  p_user_id => crs.operator_user_id);
                 v_if_available := PSHFT_EXCLUSION.checkIfDayIsAvailable(p_operator_id => v_operator.id, p_day => (v_day-1));
                 if v_if_available = 0 then
                       -- i.e. previous day, Sun - was DayOff in previous Generation Procedure.
                       -- This Operator may be assigned to MON Night Shift then.
                       if_assigned := true;
                 end if;
             else
                 -- Be sure Rule PSHFT_RULECLC.RULE_HoursBetweenShifts is not violated.
                 -- Actually this check has no much sense, as previous Day should be DayOff and this Operators is not assigned any Shift yet!
                 -- Why I am doing that? Alvays Ok (1) will be here!
                 v_if_available := PSHFT_RULECLC.calculateSingleRuleNum(p_shift_id => v_shift_id, p_operator_id => crs.operator_id, p_rule => PSHFT_RULECLC.RULE_HoursBetweenShifts);
                 if v_if_available = 1 then
                   if_assigned := true;
                 end if;
                 if if_assigned then
                   -- Now check if Rule PSHFT_RULECLC.RULE_DayOff_DistanceBetween is not violated for day previous to this one.
                   -- Only then this Operator may be assigned to this day Night Shift.
                   v_day_lastrest := PSHFT_RULECLC.calcDstBetweenDayOffsRule(p_operator_id => crs.operator_id, p_day => v_day-1);
                   if v_day_lastrest is NOT NULL then
                      if (lvl in (1, 2) and PSHFT_EXCLUSION.checkExclusionType4Day(crs.operator_user_id, v_day_lastrest) != PSHFT_EXCLUSION.EXCTYPE_PERIOD)
                         OR (lvl = 3 AND v_day_lastrest != (v_day-1) - PSHFT_GENERATOR.DAYOFF_SHIFT_FROM) -- That is allow 1 working days less than minimal allowed PSHFT_GENERATOR.DAYOFF_SHIFT_FROM
                                                                                                               THEN
                         if_assigned := false;
                      end if;
                   end if;
                 end if;
             end if;
             if if_assigned then
                 PSHFT_GENERATOR.assignOperator2Shift(p_proc_id => p_proc_id,
                                                  p_operator_id => crs.operator_id,
                                                  p_shift_id => v_shift_id,
                                                  p_dumpseq => v_shiftproc.DUMPSEQ, 
                                                  p_user_id => p_user_id);
                 exit;
             end if;
         end loop; -- for crs
         if if_assigned then
             exit;
         end if;
     end loop; -- for mode in 1..2 loop
  end loop;
  
  flagProcedureNightShiftsDone(p_proc_id, p_user_id);
  COMMIT;
end;




-- reassignOperators()
procedure reassignOperators(p_proc_id number) is
  v_procedure PSHFT_COMMONS1.shiftProcType;
  v_days_num number;
  v_day date;
begin
  v_procedure := PSHFT_COMMONS1.getShiftProc(p_proc_id);
  for cnt in 1..v_procedure.CLC_DAYS_NUM loop
    v_day := v_procedure.PERIOD_FROM + cnt - 1;
    PSHFT_GENERATOR.reassignOperatorsInDay(p_proc_id, v_day);
  end loop;
end reassignOperators;

-- reassignOperatorsInDay()
procedure reassignOperatorsInDay(p_proc_id number, p_day date) is
/**
declare
  p_proc_id number := 15;
  p_day date := to_date('22.01.2012', 'dd.mm.yyyy');
begin
  PSHFT_GENERATOR.reassignOperatorsInDay(p_proc_id, p_day);
end;
*/
  c_notcomplete PSHFT_COMMONS1.shiftsCursor;
  c_overcap PSHFT_COMMONS1.shiftsCursor;
  v_shift_notcomplete SHFT_SHIFT%ROWTYPE;
  v_shift_donor SHFT_SHIFT%ROWTYPE;

  v_if_check_ok number;

  v_diff number; -- keeps number of assignments to be done until particular Incomplete Shift is complete (i.e. SHIFT_CAPACITY - ASSIGNED_OPERATORS)
  v_assgn_counter number; -- accumulates number of successful re-assignments - to control it not come more than v_diff.


  checkResult PSHFT_RULECLC.checkType;

  v_dsc varchar2(512);

  cursor crsAssgn(cp_shift_id number) is
         select * from SHFT_SHIFT_OPERATOR sop
                where sop.shift_id = cp_shift_id
                order by sop.operator_id;

  v_shiftProc PSHFT_COMMONS1.shiftProcType;

begin

  v_shiftProc := PSHFT_COMMONS1.getShiftProc(p_proc_id);

  c_notcomplete := PSHFT_COMMONS1.getNotCompleteShifts(p_proc_id, p_day);
  LOOP
      FETCH c_notcomplete into v_shift_notcomplete;
      EXIT WHEN c_notcomplete%NOTFOUND;

      v_diff := v_shift_notcomplete.Shift_Capacity - v_shift_notcomplete.Assigned_Operators;

      v_assgn_counter := 0;
      c_overcap := PSHFT_COMMONS1.getOverCapacityShifts(p_proc_id, p_day);
      LOOP
          FETCH c_overcap into v_shift_donor;
          EXIT WHEN c_overcap%NOTFOUND;

          for crs in crsAssgn(v_shift_donor.id) loop
             checkResult := PSHFT_RULECLC.calculateAllRules(p_shift_id => v_shift_notcomplete.id, p_operator_id => crs.operator_id,
                                                            p_accountOnlyPast => false, p_ignore_sameday => true);
             if checkResult.if_ok then
                 -- URA!!! anu VASHA!!! ReAssign now
                 -- 1-st - remove former assignment
                 deassignOperator2Shift(crs.operator_id, v_shift_donor.id);
                 v_dsc := 'REASSIGNMENT: ' || v_shift_donor.id || '->' || v_shift_notcomplete.id;
                 -- now - make new assignment. Note: fix in DSC
                 assignOperator2Shift(p_proc_id => p_proc_id,
                                      p_operator_id => crs.operator_id,
                                      p_shift_id => v_shift_notcomplete.id,
                                      p_dumpseq => v_shiftProc.DUMPSEQ,
                                      p_if_manual => 0,
                                      p_dsc => v_dsc
                                      );
                 v_assgn_counter := v_assgn_counter + 1;

                 logReassignments(p_proc_id,
                             p_shift_rcpnt_id => v_shift_notcomplete.id, p_shift_donor_id => v_shift_donor.id,
                             p_operator_id => crs.operator_id, p_day => p_day,
                             p_shift_rcpnt_start_hour => v_shift_notcomplete.shift_start_hour,
                             p_shift_donor_capacity => v_shift_donor.shift_capacity, p_shift_donor_assgn =>v_shift_donor.assigned_operators,
                             p_shift_rcpnt_capacity => v_shift_notcomplete.shift_capacity, p_shift_rcpnt_assgn => v_shift_notcomplete.assigned_operators,
                             p_if_check_ok => 1, p_check_source => null, p_check_type => null, p_check_source_id => null,
                             p_dumpseq => v_shiftProc.DUMPSEQ);

                 if v_assgn_counter = v_diff then
                   exit; -- Thanks, no more Donor assignments required. Deal Done
                 end if;

             else
                 logReassignments(p_proc_id,
                             p_shift_rcpnt_id => v_shift_notcomplete.id, p_shift_donor_id => v_shift_donor.id,
                             p_operator_id => crs.operator_id, p_day => p_day,
                             p_shift_rcpnt_start_hour => v_shift_notcomplete.shift_start_hour,
                             p_shift_donor_capacity => v_shift_donor.shift_capacity, p_shift_donor_assgn =>v_shift_donor.assigned_operators,
                             p_shift_rcpnt_capacity => v_shift_notcomplete.shift_capacity, p_shift_rcpnt_assgn => v_shift_notcomplete.assigned_operators,
                             p_if_check_ok => 0, p_check_source => checkResult.check_source, p_check_type => checkResult.check_type, p_check_source_id => checkResult.id,
                             p_dumpseq => v_shiftProc.DUMPSEQ);
             end if;

          end loop;

          if v_assgn_counter = v_diff then
             exit; -- Thanks, no more Donor assignments required. Deal Done
          end if;

      END LOOP;
      CLOSE c_overcap;

  END LOOP;
  CLOSE c_notcomplete;
end reassignOperatorsInDay;

-- assignOperator2Day()
function assignOperator2Day(p_proc_id number, p_operator_id number, p_day date,
                            p_assignment assignmentData, p_letovercapacity boolean,
                            p_dumpseq number) return dayAssignmentType is

  dayShifts dayShiftsType;

  --------
  shifts shiftsType;

  v_shift shiftType;
  --------


  --------
  dayAssgn dayAssignmentType;

  -- will keep type of Shift: 1 - Morning, 2 - Evening.
  v_shiftType2choose pls_integer := 0;

  v_index pls_integer := 0;
  v_counter number;
  v_hit_index number;
  v_ret number;
  v_ret_rule PSHFT_RULECLC.checkType;
  v_if_assigned boolean := false;
  v_assigned_shift_id number := null;
  v_assigned_shift_ind number := null;
  v_calclog_seq number;

  cursor crsShifts(cp_day date) is
         select * from SHFT_SHIFT sh
                where sh.proc_id = p_proc_id
                      and sh.shift_start_hour between trunc(cp_day, 'dd') and trunc(cp_day, 'dd') + 1 - PSHFT_COMMONS1.ONE_SECOND
                      and sh.status in (PSHFT_COMMONS1.SHIFT_STATUS_READY, PSHFT_COMMONS1.SHIFT_STATUS_UNDERPROC)
                      and sysdate between fd and td
                order by sh.shift_start_hour;

  v_assgn_method pls_integer;
  v_weight number; if_change boolean;

  v_if_can_go boolean;
  v_deal number;
begin

  dayShifts.letovercapacity := p_letovercapacity;

  -- 1-st of all - make sure this day is available for Operator as a whole.
  v_ret := PSHFT_EXCLUSION.checkIfDayIsAvailable(p_operator_id, p_day, 1);

  v_assgn_method := getCnf_GNR_AssignmentMethod;

  if v_ret != 1 then
     dayAssgn.if_available := false;
     return dayAssgn;
  else
     dayAssgn.if_available := true;
  end if;

  -- Day is available.
  -- Construct structure of all Shifts where each is marked if it is available or not
  for crs in crsShifts(p_day) loop
    v_index := v_index + 1;
    shifts(v_index).ID := crs.id;
    shifts(v_index).SHIFT_START_HOUR := crs.SHIFT_START_HOUR;
    shifts(v_index).SHIFT_END_HOUR := crs.SHIFT_END_HOUR;
    shifts(v_index).SHIFT_HOURS := (crs.SHIFT_END_HOUR - crs.SHIFT_START_HOUR)*24;
    shifts(v_index).SHIFT_TYPE := crs.SHIFT_TYPE;
    shifts(v_index).SHIFT_CAPACITY := crs.SHIFT_CAPACITY;
    shifts(v_index).ASSIGNED_OPERATORS := crs.ASSIGNED_OPERATORS;
    shifts(v_index).OVERCAPACITY_LIMIT := crs.OVERCAPACITY_LIMIT;
    shifts(v_index).CNT_FLAG_AVAILABLE  := false;
    shifts(v_index).CNT_FLAG_AVAILABLE_BYRULE := FALSE;
    shifts(v_index).CNT_OPER_ID := p_operator_id;
    v_ret_rule := PSHFT_RULECLC.calculateAllRules(crs.id, p_operator_id);
    if v_ret_rule.if_ok then
      shifts(v_index).CNT_FLAG_AVAILABLE_BYRULE := TRUE;
      if ((NOT p_letovercapacity) and (shifts(v_index).SHIFT_CAPACITY > shifts(v_index).ASSIGNED_OPERATORS))
--          OR (p_letovercapacity and (shifts(v_index).SHIFT_CAPACITY + shifts(v_index).OVERCAPACITY_LIMIT) > shifts(v_index).ASSIGNED_OPERATORS) THEN
          OR (p_letovercapacity and shifts(v_index).OVERCAPACITY_LIMIT > 0) THEN

         v_weight := nvl(crs.ASSIGNED_OPERATORS, 0)/crs.SHIFT_CAPACITY;

         if_change := false;
         if dayShifts.dayShiftsNum = 0 then
           if_change := true;
         else
           if v_weight < dayShifts.dayWinner.weight then
              if_change := true;
           elsif v_weight = dayShifts.dayWinner.weight then
              if NOT p_letovercapacity then
                 if crs.SHIFT_CAPACITY < dayShifts.dayWinner.capacity then
                    if_change := true;
                 end if;
              else
                 if crs.SHIFT_CAPACITY > dayShifts.dayWinner.capacity then
                    if_change := true;
                 end if;
              end if;
           end if;
         end if;
         if if_change then
           dayShifts.dayWinner.shift_index := v_index;
           dayShifts.dayWinner.shift_id := crs.id;
           dayShifts.dayWinner.weight := v_weight;
           dayShifts.dayWinner.capacity := crs.SHIFT_CAPACITY;
         end if;
         if NOT p_letovercapacity then
           if crs.SHIFT_TYPE in (PSHFT_COMMONS1.SHIFT_TYPE_MORNING_EARLY, PSHFT_COMMONS1.SHIFT_TYPE_MORNING, PSHFT_COMMONS1.SHIFT_TYPE_DAY) then
               if_change := false;
               if dayShifts.morningTypeShiftsNum = 0 then
                 if_change := true;
               else
                 if v_weight < dayShifts.morningTypeWinner.weight then
                    if_change := true;
                 elsif v_weight = dayShifts.morningTypeWinner.weight then
                    if crs.SHIFT_CAPACITY < dayShifts.morningTypeWinner.capacity then
                       if_change := true;
                    end if;
                 end if;
               end if;
               if if_change then
                 dayShifts.morningTypeWinner.shift_index := v_index;
                 dayShifts.morningTypeWinner.shift_id := crs.id;
                 dayShifts.morningTypeWinner.weight := v_weight;
                 dayShifts.morningTypeWinner.capacity := crs.SHIFT_CAPACITY;
               end if;
               dayShifts.morningTypeShiftsNum := dayShifts.morningTypeShiftsNum + 1;
           elsif crs.SHIFT_TYPE in (PSHFT_COMMONS1.SHIFT_TYPE_EVENING, PSHFT_COMMONS1.SHIFT_TYPE_EVENING_LATE) then
               if_change := false;
               if dayShifts.eveningTypeShiftsNum = 0 then
                 if_change := true;
                 dayShifts.eveningTypeFirst.shift_index := v_index;
                 dayShifts.eveningTypeFirst.shift_id := crs.id;
               else
                 if v_weight < dayShifts.eveningTypeWinner.weight then
                    if_change := true;
                 elsif v_weight = dayShifts.eveningTypeWinner.weight then
                    if crs.SHIFT_CAPACITY < dayShifts.eveningTypeWinner.capacity then
                       if_change := true;
                    end if;
                 end if;
               end if;
               if if_change then
                 dayShifts.eveningTypeWinner.shift_index := v_index;
                 dayShifts.eveningTypeWinner.shift_id := crs.id;
                 dayShifts.eveningTypeWinner.weight := v_weight;
                 dayShifts.eveningTypeWinner.capacity := crs.SHIFT_CAPACITY;
               end if;
               dayShifts.eveningTypeShiftsNum := dayShifts.eveningTypeShiftsNum + 1;
           elsif crs.SHIFT_TYPE = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT then
               if_change := false;
               if dayShifts.nightTypeShiftsNum = 0 then
                 if_change := true;
               else
                 if v_weight < dayShifts.nightTypeWinner.weight then
                    if_change := true;
                 elsif v_weight = dayShifts.nightTypeWinner.weight then
                    if crs.SHIFT_CAPACITY < dayShifts.nightTypeWinner.capacity then
                       if_change := true;
                    end if;
                 end if;
               end if;
               if if_change then
                 dayShifts.nightTypeWinner.shift_index := v_index;
                 dayShifts.nightTypeWinner.shift_id := crs.id;
                 dayShifts.nightTypeWinner.weight := v_weight;
                 dayShifts.nightTypeWinner.capacity := crs.SHIFT_CAPACITY;
               end if;
               dayShifts.nightTypeShiftsNum := dayShifts.nightTypeShiftsNum + 1;
           end if;
         end if;
         dayShifts.dayShiftsNum := dayShifts.dayShiftsNum + 1;

         shifts(v_index).CNT_FLAG_AVAILABLE := true;
         shifts(v_index).weight := v_weight;
      end if;
      logRulesCalcResult(p_proc_id, crs.id, p_operator_id, p_day, crs.SHIFT_START_HOUR, crs.SHIFT_CAPACITY, crs.ASSIGNED_OPERATORS, dayShifts, p_assignment, p_dumpseq);
    else
      logRulesCalcResult(p_proc_id, crs.id, p_operator_id, p_day, crs.SHIFT_START_HOUR, crs.SHIFT_CAPACITY, crs.ASSIGNED_OPERATORS, dayShifts, p_assignment,
                                                           v_ret_rule.check_source, v_ret_rule.check_type, v_ret_rule.id, p_dumpseq);
    end if;
  end loop;

  -- Now - assign Operator to the 1-st available Shift.
  -- Shift is available if it is allowed for Operator and its capacity is not filled in with already assigned Operators.
  -- Among several available Shifts - choice is doing depending on assignment methog configured.
  -- For Random and Sequential methods - choice is to be done now, for Weighted method - it is already done.
  if v_assgn_method in (GNR_ASSIGNM_METHOD_RANDOM, GNR_ASSIGNM_METHOD_SEQUENTIAL) then
      if v_assgn_method = GNR_ASSIGNM_METHOD_RANDOM then
          v_hit_index := round(dbms_random.value(1, dayShifts.dayShiftsNum));
      elsif v_assgn_method = GNR_ASSIGNM_METHOD_SEQUENTIAL then
          v_hit_index := 1;
      end if;
      v_counter := 0;
      for cnt in 1..v_index loop
        if shifts(cnt).CNT_FLAG_AVAILABLE and shifts(cnt).SHIFT_CAPACITY + shifts(cnt).OVERCAPACITY_LIMIT > shifts(cnt).ASSIGNED_OPERATORS then
           v_counter := v_counter + 1;
           if v_counter = v_hit_index then
              v_if_assigned := true;
              v_assigned_shift_id := shifts(cnt).ID;
              v_assigned_shift_ind := cnt;
              exit;
           end if;
        end if;
      end loop;
   elsif v_assgn_method = GNR_ASSIGNM_METHOD_WEIGHTED and not p_letovercapacity then

      -- Analysis of whole week Data to try to choose among all available Shifts - optimal taking into account
      -- goals:
      -- a) satisfy RULE_AllShiftsParticipate rule - during week Operator should participate at least in 1 Morning-Day Shift and at least in 1 Evening.
      -- b) avoid failing RULE_WeekHours rule - when in the end-of-week any Shift will lead breaking this Rule!

      if dayShifts.nightTypeShiftsNum > 0 then
        -- Highest priority
        if p_assignment.restDaysNum = 1 -- more than 1 rest day per week - is rare case and decided (by me) to use such Operator in other shifts
                         and p_assignment.morningShiftsNum < 2 -- to avoid breaking PSHFT_COMMONS1.RULE_WeekHours rule
                                                       then
           v_if_assigned := true;
           v_assigned_shift_id := dayShifts.nightTypeWinner.shift_id;
           v_assigned_shift_ind := dayShifts.nightTypeWinner.shift_index;

        end if;

      end if;
      if NOT v_if_assigned then
        -- Now - Night Shift is not considered more
        -- 1-st of all - try to satisfy rule RULE_AllShiftsParticipate ASAP.
        -- That means - if we have Evening type but not Morning assigned so far - take Morning (if available)
        -- and vise-versa.
        if p_assignment.eveningShiftsNum = 0 and p_assignment.morningShiftsNum > 0
                                            and dayShifts.eveningTypeShiftsNum > 0 then
           -- Evening assigments will be taken, after that rule RULE_AllShiftsParticipate is satisfie uuff..
           v_if_assigned := true;
           v_assigned_shift_id := dayShifts.eveningTypeWinner.shift_id;
           v_assigned_shift_ind := dayShifts.eveningTypeWinner.shift_index;
        elsif p_assignment.morningShiftsNum = 0 and p_assignment.eveningShiftsNum > 0
                                            and dayShifts.morningTypeShiftsNum > 0 then
           -- Day assigments will be taken, after that rule RULE_AllShiftsParticipate is satisfie uuff..
           v_if_assigned := true;
           v_assigned_shift_id := dayShifts.morningTypeWinner.shift_id;
           v_assigned_shift_ind := dayShifts.morningTypeWinner.shift_index;
        else

           -- Fix one Risk, namely: when we are in the beginning, that is - have no yet been assigned nor to Day nor to Evening Shifts -
           -- if chosen will be late Evening Shift - it will block opportunity to choose Day shifts on Next week - due to the Distance between Shifts restriction.
           -- But on the contrary - choosing 1-st Day shifts - on the next day we can hit both Days and Evening Shifts!
           if p_assignment.morningShiftsNum = 0 then
              if dayShifts.morningTypeShiftsNum > 0 then
                 -- In the Beginning - Start from Day Shift if it is available (may be Not available due to Distance between Shifts Rule)
                  v_if_assigned := true;
                  v_assigned_shift_id := dayShifts.morningTypeWinner.shift_id;
                  v_assigned_shift_ind := dayShifts.morningTypeWinner.shift_index;
               elsif dayShifts.eveningTypeShiftsNum > 0 then
                  v_if_assigned := true;
                  v_assigned_shift_id := dayShifts.eveningTypeFirst.shift_id;
                  v_assigned_shift_ind := dayShifts.eveningTypeFirst.shift_index;
               end if;
           elsif dayShifts.morningTypeShiftsNum > 0 and dayShifts.eveningTypeShiftsNum > 0 then
               -- Our responsibility on care for rule RULE_AllShiftsParticipate is undertook for this DAY if we are here!
               -- if no any, Evening or Day shift was assigned so far - for this rule it doesn't matter which one will be chosen 1-st!
               -- NOW - 1-st of all - see if I have possibility take BOTH Day and Evening type Shifts.
               -- IF so - then decision will be taken randomly

                 -- Now - take care on RULE_WeekHours rule
                 -- Ok. going to the Evening shift - no any problems (6 hous).
                 -- SO - WE CAN safely assign Evening Type shifts
                 -- NOW - decide if we can safely assign Day Type shifts (8 hour Day shifts - may create problems)
                 v_if_can_go := false;
                 if p_assignment.restDaysNum > 2 then
                   -- Definitely no problems: 4*8 = 32, no any week-start tail hours may create problems!
                   v_if_can_go := true;
                 elsif p_assignment.restDaysNum = 2 then
                   -- week-start tail hours may create problems (otherwise if there aren't tails - all days might be 8 hours: 5:8 = 40)
                   if p_assignment.weekBeginnigTailHours = 0 then
                      v_if_can_go := true;
                   elsif (p_assignment.weekBeginnigTailHours + p_assignment.shiftsHours +
                         (7-p_assignment.morningShiftsNum-p_assignment.restDaysNum)*8) <= PSHFT_RULECLC.WEEKS_HOURS then
                      v_if_can_go := true;
                   else
                      v_if_can_go := FALSE;
                   end if;
                 elsif p_assignment.restDaysNum = 1 then
                   -- Having 1 8 hour Shift definitely has no problem: 8 + 6*4 + 7 = 39
                   if p_assignment.morningShiftsNum = 0 then
                      v_if_can_go := true;
                   elsif p_assignment.morningShiftsNum = 1 and p_assignment.if_night_assigned then
                      -- as: 2*8 + 7 + 3*6 = 23+18 = 41
                      v_if_can_go := false;
                   elsif p_assignment.morningShiftsNum = 1 and NOT p_assignment.if_night_assigned and p_assignment.weekBeginnigTailHours = 0 then
                      -- 2*8 + 4*16 = 40
                      v_if_can_go := true;
                   else
                      v_if_can_go := FALSE;
                   end if;
                 end if;
                 if v_if_can_go then
                    --- DEAL
                    -- decide where to come to Day or Evening 1-st time
                    v_deal := PSHFT_COMMONS1.getRandomNumber(1, 2);
                    if v_deal = 1 then
                        v_if_assigned := true;
                        v_assigned_shift_id := dayShifts.morningTypeWinner.shift_id;
                        v_assigned_shift_ind := dayShifts.morningTypeWinner.shift_index;
                     else
                        v_if_assigned := true;
                        v_assigned_shift_id := dayShifts.eveningTypeWinner.shift_id;
                        v_assigned_shift_ind := dayShifts.eveningTypeWinner.shift_index;
                     end if;
                 else
                    v_if_assigned := true;
                    v_assigned_shift_id := dayShifts.eveningTypeWinner.shift_id;
                    v_assigned_shift_ind := dayShifts.eveningTypeWinner.shift_index;
                 end if;
           elsif dayShifts.morningTypeShiftsNum > 0 then
                  v_if_assigned := true;
                  v_assigned_shift_id := dayShifts.morningTypeWinner.shift_id;
                  v_assigned_shift_ind := dayShifts.morningTypeWinner.shift_index;
           elsif dayShifts.eveningTypeShiftsNum > 0 then
                  v_if_assigned := true;
                  v_assigned_shift_id := dayShifts.eveningTypeWinner.shift_id;
                  v_assigned_shift_ind := dayShifts.eveningTypeWinner.shift_index;
           end if;
        end if;
      end if;
   end if;

  -- Here we are if no any Shift was found to be available for this Operator - most probably due to the Capacity overflow.
  -- Now - take 1-st (not Night) Shift where Capacity is filled and assign to it
  if p_letovercapacity then
    if dayShifts.dayWinner.shift_id is not null then
        v_if_assigned := true;
        v_assigned_shift_id := dayShifts.dayWinner.shift_id;
        v_assigned_shift_ind := dayShifts.dayWinner.shift_index;
    end if;
  end if;

  if v_if_assigned then
    assignOperator2Shift(p_proc_id, p_operator_id, v_assigned_shift_id, p_dumpseq);
    v_shift := shifts(v_assigned_shift_ind);
    dayAssgn.if_assigned := true;
  else
    dayAssgn.if_assigned := false;
    v_shift.id := null;
  end if;

  dayAssgn.shift := v_shift;

  return dayAssgn;

end assignOperator2Day;


-- assignOperator2Shift()
procedure assignOperator2Shift(p_proc_id number, p_operator_id number, p_shift_id number,
                               p_dumpseq number,
                               p_if_manual number := 0,
                               p_dsc varchar2, 
                               p_user_id number) is
/**
declare
  p_proc_id number := 15;
  p_operator_id number := 995;
  p_shift_id number := 2476;
  p_dumpseq number := 10;
begin
  PSHFT_GENERATOR.assignOperator2Shift(p_proc_id, p_operator_id, p_shift_id, p_dumpseq);
end;
*/
  v_assigned_operators number;
  v_shift_start_hour date;
  v_shift_capacity number;
  v_assign_id number;
  v_seq number;
  v_sysdate date := sysdate;
  v_result varchar2(16);
  if_ok boolean := true;
begin
  begin
    select id into v_assign_id
           from SHFT_SHIFT_OPERATOR sop
           where sop.shift_id = p_shift_id and sop.operator_id = p_operator_id
                 and sysdate between fd and td;
    if_ok := false;
    v_result := 'DUPL';
  exception
    when no_data_found then
        v_result := 'OK';
  end;
  if if_ok then
     select SHFT_SHIFT_OPERATOR_SQ_ID.Nextval into v_assign_id from dual;
     insert into SHFT_SHIFT_OPERATOR (ID, PROC_ID, SHIFT_ID, OPERATOR_ID, STATUS, FD, TD, DUMPSEQ, IF_MANUAL, DSC, USER_ID)
                           values (v_assign_id, p_proc_id, p_shift_id, p_operator_id, PSHFT_COMMONS1.SHIFTOPERATOR_STATUS_ASSIGNED, v_sysdate, PSHFT_COMMONS1.getInfinity, p_dumpseq, p_if_manual, p_dsc, p_user_id);
     select nvl(sh.assigned_operators,0) + 1, sh.shift_start_hour, sh.shift_capacity into v_assigned_operators, v_shift_start_hour, v_shift_capacity
         from SHFT_SHIFT sh
         where sh.id = p_shift_id
               and sysdate between fd and td;
     update SHFT_SHIFT sh
         set sh.assigned_operators = v_assigned_operators
         where sh.id = p_shift_id
               and sysdate between fd and td;
  end if;
  logAssignmentAction(p_proc_id, p_shift_id, v_shift_start_hour, v_shift_capacity, v_assigned_operators,
                                 p_operator_id, v_assign_id, v_result, p_dumpseq);
  COMMIT;
end assignOperator2Shift;

-- deAssignOperator2Shift
procedure deAssignOperator2Shift(p_proc_id number, p_operator_id number, p_shift_id number) as
begin
  
  delete from SHFT_SHIFT_OPERATOR sop
         where sop.proc_id = p_proc_id
               and sop.operator_id = p_operator_id
               and sop.shift_id = p_shift_id;
  if SQL%FOUND then
    UPDATE SHFT_SHIFT sh
           set sh.assigned_operators = sh.assigned_operators - 1
           where sh.id = p_shift_id;
  end if;
  COMMIT;
end deAssignOperator2Shift;

-- deassignOperator2Shift
procedure deassignOperator2Shift(p_operator_id number, p_shift_id number) is
  v_assgn_id number;
begin
  select id into v_assgn_id
         from SHFT_SHIFT_OPERATOR sop
         where sop.operator_id = p_operator_id
               and sop.shift_id = p_shift_id
               and sop.status = PSHFT_COMMONS1.SHIFTOPERATOR_STATUS_ASSIGNED
               and sysdate between fd and td;
  if v_assgn_id is not null then
     delete from SHFT_SHIFT_OPERATOR sop
            where ID = v_assgn_id;
     update SHFT_SHIFT sh
            set sh.assigned_operators = nvl(sh.assigned_operators,0) - decode(sh.assigned_operators, null, 0, 0, 0, 1)
            where id = p_shift_id
                  and sysdate between fd and td;
  end if;

end deassignOperator2Shift;

-- calcDayAssgnStat()
function calcDayAssgnStat(p_proc_id number, p_operator_id number, p_day date) return dayAssgnStatType is
  dayAssgnStat dayAssgnStatType;
  v_is_available number;
  v_shift SHFT_SHIFT%ROWTYPE;
  v_shiftProc PSHFT_COMMONS1.shiftProcType;
  v_prevShiftProc PSHFT_COMMONS1.shiftProcType;
  v_operator_id number;
  v_user_id number;
  v_operator SHFT_OPERATOR%ROWTYPE;
begin

  dayAssgnStat.day := p_day;

  v_shiftProc := PSHFT_COMMONS1.getShiftProc(p_proc_id);

  v_is_available := PSHFT_EXCLUSION.checkIfDayIsAvailable(p_operator_id => p_operator_id,
                                                                 p_day => p_day,
                                                                 p_if_check_assignments => 1);
  if v_is_available = 1 then
     dayAssgnStat.if_day_available := true;
  else
     dayAssgnStat.if_day_available := false;
  end if;

  -- See if this day is DayOff or not.
  v_is_available := PSHFT_EXCLUSION.checkIfDayIsAvailable(p_operator_id => p_operator_id,
                                                                 p_day => p_day);
  if v_is_available = 1 then
     dayAssgnStat.if_dayoff := true;
  else
     dayAssgnStat.if_dayoff := false;
  end if;

  -- See if Previous Day was DayOff for this Operator.
  -- Previous Day migh be from previous generation
  if p_day > v_shiftProc.PERIOD_FROM then
    v_operator_id := p_operator_id;
  else
    v_prevShiftProc := PSHFT_COMMONS1.getPreviousShiftProc(p_proc_id => p_proc_id);
    v_user_id := PSHFT_COMMONS1.getUserIdbByOperator(p_operator_id);
    v_operator := PSHFT_COMMONS1.getOperatorByUserId(p_proc_id => p_proc_id, p_user_id => v_user_id);
    v_operator_id := v_operator.id;
  end if;
  v_is_available := PSHFT_EXCLUSION.checkIfDayIsAvailable(p_operator_id => v_operator_id,
                                                                 p_day => p_day-1);
  if v_is_available = 1 then
     dayAssgnStat.if_prevday_dayoff := true;
  else
     dayAssgnStat.if_prevday_dayoff := false;
  end if;


  v_shift := PSHFT_COMMONS1.getAssignedShift(p_operator_id => p_operator_id, p_day => p_day);
  if v_shift.id is NOT NULL then
    dayAssgnStat.if_day_already_assigned := true;
    dayAssgnStat.shift_type_already_assigned := v_shift.shift_type;
    dayAssgnStat.shift_id_already_assigned := v_shift.id;
    dayAssgnStat.shift_hours_already_assigned := (v_shift.shift_end_hour - v_shift.shift_start_hour)*24;
  else
    dayAssgnStat.if_day_already_assigned := false;
  end if;

  return dayAssgnStat;

end calcDayAssgnStat;


/*
-- setStatus2Procedure
procedure setStatus2Procedure(p_proc_id number, p_status number) is
begin
  update SHFT_SHIFT_PROC
         set status = p_status
         where id = p_proc_id
               and sysdate between fd and td;
end setStatus2Procedure;
*/

-- takeNextOperator()
function takeNextOperator(p_proc_id number) return number is
  v_index pls_integer;
  v_counter pls_integer;
  cursor crsOpers is
         select * from SHFT_OPERATOR op
                where op.proc_id = p_proc_id
                      and op.status = PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED
                      and sysdate between fd and td
                order by id;
begin
  if operatorsRec.counter = 0 then
    v_index := 0;
    for crs in crsOpers loop
      v_index := v_index + 1;
      operatorsRec.operators(v_index).id := crs.id;
      operatorsRec.operators(v_index).flag_taken := false;
    end loop;
    operatorsRec.opersNumber := v_index;
    operatorsRec.counter := 0;
  elsif operatorsRec.counter = operatorsRec.opersNumber then
    -- All Operators are taken, no more to be processed.
    operatorsRec.counter := 0; -- Prepare Control structure for next Use.
    return null;
  end if;
--  v_index := round(dbms_random.value(operatorsRec.counter + 1, operatorsRec.opersNumber));
  v_index := round(dbms_random.value(1, operatorsRec.opersNumber-operatorsRec.counter));
  v_counter := 0;
  for cnt in 1..operatorsRec.opersNumber loop
    if NOT operatorsRec.operators(cnt).flag_taken then
      v_counter := v_counter + 1;
      if v_counter = v_index then
        operatorsRec.counter := operatorsRec.counter + 1;
        operatorsRec.operators(cnt).flag_taken := true;
        return operatorsRec.operators(cnt).id;
      end if;
    end if;
  end loop;
  return null;
end takeNextOperator;

-- generateDumpSeq
function generateDumpSeq return number is
  v_dumpseq number;
begin
  select SHFT_DUMP_SQ_ID.NEXTVAL into v_dumpseq from dual;

  return v_dumpseq;
end generateDumpSeq;

-- getNextCalcLogSeq
function getNextCalcLogSeq return number is
  v_seq number;
begin
  select SHFT_SHIFT_CALCLOG_SQ_ID.Nextval into v_seq from dual;
  return v_seq;
end getNextCalcLogSeq;

-- logRulesCalcResult(...) - Ok availability
procedure logRulesCalcResult(p_proc_id number, p_shift_id number, p_operator_id number, p_day date,
                             p_shift_start_hour date, p_shift_capacity number, p_assigned_operators number, p_dayShifts dayShiftsType, p_assignment assignmentData,
                             p_dumpseq number) is
begin
  logRulesCalcResult(p_proc_id, p_shift_id, p_operator_id, p_day,
                             p_shift_start_hour, p_shift_capacity, p_assigned_operators, p_dayShifts,p_assignment,
                             1, null, null, null,
                             p_dumpseq);
end logRulesCalcResult;

-- logRulesCalcResult(...) - failed availability
procedure logRulesCalcResult(p_proc_id number, p_shift_id number, p_operator_id number, p_day date,
                             p_shift_start_hour date, p_shift_capacity number, p_assigned_operators number, p_dayShifts dayShiftsType, p_assignment assignmentData,
                             p_check_source number, p_check_type number, p_check_source_id number,
                             p_dumpseq number) is
/**
declare
  p_proc_id number := 15;
  p_shift_id number :=
begin
end;
*/
begin
  logRulesCalcResult(p_proc_id, p_shift_id, p_operator_id, p_day,
                     p_shift_start_hour, p_shift_capacity, p_assigned_operators, p_dayShifts, p_assignment,
                     0, p_check_source, p_check_type, p_check_source_id,
                     p_dumpseq);
end logRulesCalcResult;

-- logRulesCalcResult(...)
procedure logRulesCalcResult(p_proc_id number, p_shift_id number, p_operator_id number, p_day date,
                             p_shift_start_hour date, p_shift_capacity number, p_assigned_operators number, p_dayShifts dayShiftsType, p_assignment assignmentData,
                             p_shiftavailable_flag number, p_check_source number, p_check_type number, p_check_source_id number,
                             p_dumpseq number) is
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_seq number;
  if_night_assigned number;
  if_overcapacity number;
begin
  v_seq := getNextCalcLogSeq;
  if p_assignment.if_night_assigned then
    if_night_assigned := 1;
  else
    if_night_assigned := 0;
  end if;

  if p_dayShifts.letovercapacity then
    if_overcapacity := 1;
  else
    if_overcapacity := 0;
  end if;


  insert into SHFT_SHIFT_FAILEDRULELOG (ID, PROC_ID, SHIFT_ID, OPERATOR_ID, CALC_DAY,
                                       SHIFT_START_HOUR, SHIFT_CAPACITY, ASSIGNED_OPERATORS,
                                       FLAG_SHIFT_AVAILABLE, CHECK_SOURCE, CHECK_TYPE, CHECK_SOURCE_ID,
                                       SEQ, ACTION_DATE,
                                       L_DAY_TYP_SHFT_NUM, L_EVN_TYP_SHFT_NUM, L_NGT_TYP_SHFT_NUM, L_DAY_SHFT_NUM, L_OVERCAPACITY_MODE,
			                                 G_REST_DAYS_NUM, G_WEEK_TAIL_HOURS,
                                       G_MORN_SHFT_NUM, G_MORN_SHFT_HOUR,
			                                 G_DAY_SHFT_NUM, G_DAY_SHFT_HOUR,
			                                 G_EVN_SHFT_NUM, G_EVN_SHFT_HOUR,
			                                 G_SHFT_NUM, G_SHFT_HOUR,
			                                 G_NIGHT_ASSGNED,
			                                 G_DAYS_NUM,
                                       DUMPSEQ)
                               values (SHFT_SHIFT_FAILEDRULELOG_SQ_ID.Nextval, p_proc_id, p_shift_id, p_operator_id, p_day,
                                       p_shift_start_hour, p_shift_capacity, p_assigned_operators,
                                       p_shiftavailable_flag, p_check_source, p_check_type, p_check_source_id,
                                       v_seq, sysdate,
                                       p_dayShifts.morningTypeShiftsNum, p_dayShifts.eveningTypeShiftsNum, p_dayShifts.nightTypeShiftsNum, p_dayShifts.dayShiftsNum, if_overcapacity,
                                       p_assignment.restDaysNum, p_assignment.weekBeginnigTailHours,
                                       p_assignment.morningShiftsNum, p_assignment.morningShiftsHours,
                                       p_assignment.dayShiftsNum, p_assignment.dayShiftsHours,
                                       p_assignment.eveningShiftsNum, p_assignment.eveningShiftsHours,
                                       p_assignment.shiftsNum, p_assignment.shiftsHours,
                                       if_night_assigned,
                                       p_assignment.daysNum,
                                       p_dumpseq);
  commit;
end logRulesCalcResult;

procedure logAssignmentAction(p_proc_id number, p_shift_id number, p_shift_start_hour date,
                              p_shift_capacity number, p_assigned_operators number, p_operator_id number, p_assign_id number, action_result varchar2,
                              p_dumpseq number) is
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_seq number;
begin
  v_seq := getNextCalcLogSeq;
  insert into SHFT_SHIFT_ASSGNLOG (ID, PROC_ID, SHIFT_ID, SHIFT_START_HOUR, SHIFT_CAPACITY, ASSIGNED_OPERATORS, OPERATOR_ID, OPERATOR_ASSIGN_ID, SEQ, ACTION_DATE, ACTION_RESULT, DUMPSEQ)
                           values (SHFT_SHIFT_ASSGNLOG_SQ_ID.Nextval, p_proc_id, p_shift_id, p_shift_start_hour, p_shift_capacity, p_assigned_operators, p_operator_id, p_assign_id, v_seq, sysdate, action_result, p_dumpseq);
  commit;
end logAssignmentAction;

-- logReassignments
procedure logReassignments(p_proc_id number,
                             p_shift_rcpnt_id number, p_shift_donor_id number,
                             p_operator_id number, p_day date,
                             p_shift_rcpnt_start_hour date,
                             p_shift_donor_capacity number, p_shift_donor_assgn number,
                             p_shift_rcpnt_capacity number, p_shift_rcpnt_assgn number,
                             p_if_check_ok number, p_check_source number, p_check_type number, p_check_source_id number,
                             p_dumpseq number) is
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_seq number;
begin
  v_seq := getNextCalcLogSeq;
  insert into SHFT_SHIFT_REASSGNLOG(ID, PROC_ID,
                      SHIFT_RCPNT_ID, SHIFT_DONOR_ID,
                      OPERATOR_ID, DAY2PROC,
                      SHIFT_START_HOUR,
                      SHIFT_DONOR_CAPACITY, SHIFT_DONOR_ASSGN,
                      SHIFT_RCPNT_CAPACITY, SHIFT_RCPNT_ASSGN,
                      CHECK_IF_OK, CHECK_SOURCE, CHECK_TYPE, CHECK_SOURCE_ID,
                      DUMPSEQ,
                      SEQ, ACTION_DATE)
               values (SHFT_SHIFT_REASSGNLOG_SQ_ID.Nextval, p_proc_id,
                       p_shift_rcpnt_id, p_shift_donor_id,
                       p_operator_id, p_day,
                       p_shift_rcpnt_start_hour,
                       p_shift_donor_capacity, p_shift_donor_assgn,
                       p_shift_rcpnt_capacity, p_shift_rcpnt_assgn,
                       p_if_check_ok, p_check_source, p_check_type, p_check_source_id,
                       p_dumpseq,
                       v_seq, sysdate);
  COMMIT;
end logReassignments;

-- getCnf_GNR_AssignmentMethod
function getCnf_GNR_AssignmentMethod return pls_integer is
begin
  return gnrAssignmMethod;
end getCnf_GNR_AssignmentMethod;



-- flagProcedureNightShiftsDone()
procedure flagProcedureNightShiftsDone(p_proc_id number, p_user_id number) is
begin
   updateProcStatus(p_proc_id, PSHFT_COMMONS1.PROC_STATUS_NightShiftsAsigned, p_user_id);
   update SHFT_SHIFT_PROC sp
          set sp.if_nightshifts_assigned = 1 
          where sp.id = p_proc_id
                and sysdate between fd and td;
end flagProcedureNightShiftsDone;
-- flagProcedureDayOffsDone()
procedure flagProcedureDayOffsDone(p_proc_id number, p_user_id number) is
begin
   updateProcStatus(p_proc_id, PSHFT_COMMONS1.PROC_STATUS_DayOffsSetup, p_user_id);
   update SHFT_SHIFT_PROC sp
          set sp.if_dayoffs_generated = 1
          where sp.id = p_proc_id
                and sysdate between fd and td;
end flagProcedureDayOffsDone;

-- flagProcedureAssignsDone()
procedure flagProcedureAssignsDone(p_proc_id number, p_user_id number) is
begin
   updateProcStatus(p_proc_id, PSHFT_COMMONS1.PROC_STATUS_FINISHED, p_user_id);
   update SHFT_SHIFT_PROC sp
          set sp.if_operators_assigned = 1
          where sp.id = p_proc_id
                and sysdate between fd and td;
end flagProcedureAssignsDone;


procedure test is
begin
  dbms_output.put_line('kuku');
end;

-- copyShiftTypesFromPrevProc()
procedure copyShiftTypesFromPrevProc(p_proc_id number, p_user_id number, p_if_commit number) as 
/**
declare
  p_proc_id number := 85;
  p_user_id number := 0;
begin
  PSHFT_GENERATOR.copyShiftTypesFromPrevProc(p_proc_id, p_user_id);
end;
*/
  p_shiftproc_this PSHFT_COMMONS1.shiftProcType;
  p_shiftproc_prev PSHFT_COMMONS1.shiftProcType;
  cursor crsShiftTp(cp_proc_id number) is 
         select * from SHFT_SHIFT_TYPE st
                where st.proc_id = cp_proc_id
                      and st.status = PSHFT_COMMONS1.SHIFTTP_STATUS_ACTIVE
                      and sysdate between fd and td;
  v_sysdate date := sysdate; 
  v_counter number; 
begin

  p_shiftproc_this := PSHFT_COMMONS1.getShiftProc(p_proc_id);
  if p_shiftproc_this.ID is null or p_shiftproc_this.ID != p_proc_id then
    raise PSHFT_COMMONS1.exProcedureNotExists;
  end if;

  select count(*) into v_counter 
         from SHFT_SHIFT_TYPE st 
         where st.proc_id = p_proc_id
               and sysdate between fd and td;
  
  if v_counter > 0 then
    raise PSHFT_COMMONS1.exObjectAlreadyExists;
  end if;

  p_shiftproc_prev := PSHFT_COMMONS1.getPreviousShiftProc(p_proc_id);
  
  if p_shiftproc_prev.ID is null or p_shiftproc_prev.id <= 0 then
    raise PSHFT_COMMONS1.exProcedureNotExists;
  end if;
  
  for crs in crsShiftTp(p_shiftproc_prev.id) loop
    select shft_shift_type_sq_id.nextval into crs.ID from dual;
    crs.proc_id := p_proc_id;
    crs.user_id := p_user_id;
    crs.fd := v_sysdate;
    crs.td := PSHFT_COMMONS1.getInfinity;
    insert into SHFT_SHIFT_TYPE values crs;
  end loop;
  
  if p_if_commit = 1 then
     commit;
  end if;
end;

-- updateShiftTypeCapacity()
procedure updateShiftTypeCapacity(p_id number, p_capacity number, p_user_id number) as
/**
declare
  p_id number := 671;
  p_capacity number := 5;
  p_user_id number := 0;
begin
  PSHFT_GENERATOR.updateShiftTypeCapacity(p_id, p_capacity, p_user_id);
end;
*/
  v_capacity number; 
  v_rowid ROWID;
  v_shifttype SHFT_SHIFT_TYPE%ROWTYPE;
  v_sysdate date := sysdate;
begin
  select rowid into v_rowid from SHFT_SHIFT_TYPE st 
                  where st.ID = p_id
                        and sysdate between fd and td;
  select * into v_shifttype from SHFT_SHIFT_TYPE st 
                  where rowid = v_rowid;
  if v_shifttype.capacity != p_capacity and p_capacity > 0 then 
    v_shifttype.capacity := p_capacity;
    v_shifttype.user_id := p_user_id;
    v_shifttype.fd := v_sysdate;
    v_shifttype.td := PSHFT_COMMONS1.getInfinity;
    update SHFT_SHIFT_TYPE st
           set st.td = v_sysdate - PSHFT_COMMONS1.ONE_SECOND
           where rowid = v_rowid;
    insert into SHFT_SHIFT_TYPE values v_shifttype;
    -- update dependent Shifts' capacities
    update SHFT_SHIFT sh
           set sh.shift_capacity = p_capacity
           where sh.shifttype_id = p_id;
           
  end if;
  commit;
end;

-- Updates status of the Procedure to the indicated one. 
-- If Status is not correct - nothing is done
-- If Status is already as indicated one - nothing is done
-- New version is created if status is changed
-- #param p_proc_id Procedure System Id
-- #param p_new_status Status value to which it should be changed
-- #param User System Id in context of which this is to be changed
procedure updateProcStatus(p_proc_id number, p_new_status number, p_user_id number) as
  v_rowid ROWID;
  v_proctype SHFT_SHIFT_PROC%ROWTYPE;
  v_sysdate date := sysdate;
begin
  select rowid into v_rowid from SHFT_SHIFT_PROC sp 
                  where sp.ID = p_proc_id
                        and sysdate between fd and td;
  select * into v_proctype from SHFT_SHIFT_PROC sp 
                  where rowid = v_rowid;
  if v_proctype.status != p_new_status then 
    v_proctype.status := p_new_status;
    v_proctype.user_id := p_user_id;
    v_proctype.fd := v_sysdate;
    v_proctype.td := PSHFT_COMMONS1.getInfinity;
    update SHFT_SHIFT_PROC sp
           set sp.td = v_sysdate - PSHFT_COMMONS1.ONE_SECOND
           where rowid = v_rowid;
    insert into SHFT_SHIFT_PROC values v_proctype;
           
  end if;
end;  

-- copyOperatorsFromPrevProc()
procedure copyOperatorsFromPrevProc(p_proc_id number, p_user_id number, p_if_commit number) as
/**
declare
  p_proc_id number := xxx;
  p_user_id number := 0;
begin
  PSHFT_GENERATOR.copyOperatorsFromPrevProc(p_proc_id, p_user_id);
end;
*/
  p_shiftproc_prev PSHFT_COMMONS1.shiftProcType;
  cursor crsOperators(cp_proc_id number) is 
         select * from SHFT_OPERATOR op
                where op.proc_id = cp_proc_id
                      and op.status = PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED
                      and sysdate between fd and td;
  v_sysdate date := sysdate;
  v_counter number; 
begin
  select count(*) into v_counter from SHFT_OPERATOR op
         where op.proc_id = p_proc_id 
               and sysdate between fd and td;
  if v_counter > 0 then
     raise PSHFT_COMMONS1.exObjectAlreadyExists;
  end if;
  p_shiftproc_prev := PSHFT_COMMONS1.getPreviousShiftProc(p_proc_id);
  for crs in crsOperators(p_shiftproc_prev.id) loop
    select shft_operator_sq_id.nextval into crs.ID from dual;
    crs.proc_id := p_proc_id;
    crs.fd := v_sysdate; 
    crs.td := PSHFT_COMMONS1.getInfinity;
    crs.user_id := p_user_id;
    insert into SHFT_OPERATOR values crs;
  end loop;
  PSHFT_OPERATOR.randomizeOperators(p_proc_id);
  
  -- Copy Shift Type exclusions.
  copyShiftTypeExclFromPrevProc(p_proc_id, p_user_id, 0);
  
  if p_if_commit = 1 then
     commit;
  end if;
end;

-- copyShiftTypeExclFromPrevProc()
procedure copyShiftTypeExclFromPrevProc(p_proc_id number, p_user_id number, p_if_commit number) as
/**
declare
  p_proc_id number := xxx;
  p_user_id number := 0;
begin
  PSHFT_GENERATOR.copyShiftTypeExclFromPrevProc(p_proc_id, p_user_id);
end;
*/
  p_shiftproc_prev PSHFT_COMMONS1.shiftProcType;
  cursor crsExcl(cp_proc_id number) is 
         select * from SHFT_OPERATOR_EXC oe
                where oe.proc_id = cp_proc_id
                      and oe.exc_type = PSHFT_EXCLUSION.EXCTYPE_SHIFTTYPE
                      and oe.status = PSHFT_EXCLUSION.OPERATOREXC_STATUS_ACTIVE
                      -- Part below is for case when particular Operator having Shift type Exclusion in previous Procedure - is deleted from Current Procedure (see Step.04.2)
                      and exists (select * from SHFT_OPERATOR op 
                                         where op.proc_id = p_proc_id 
                                               and op.operator_user_id = (select operator_user_id from SHFT_OPERATOR 
                                                                                 where proc_id = cp_proc_id
                                                                                       and id = oe.operator_id
                                                                                       and sysdate between fd and td)
                                               and sysdate between fd and td
                                         )
                      and sysdate between fd and td;
  v_operator SHFT_OPERATOR%ROWTYPE;
begin
  p_shiftproc_prev := PSHFT_COMMONS1.getPreviousShiftProc(p_proc_id);
  for crs in crsExcl(p_shiftproc_prev.id) loop
     select * into v_operator from SHFT_OPERATOR op
            where id = crs.operator_id
                  and sysdate between fd and td;
     v_operator := PSHFT_COMMONS1.getOperatorByUserId(p_proc_id => p_proc_id, 
                                                      p_user_id => v_operator.operator_user_id);
     PSHFT_EXCLUSION.setupExclusion4Operator(p_proc_id => p_proc_id, 
                                             p_operator_id => v_operator.ID, 
                                             p_exc_type => PSHFT_EXCLUSION.EXCTYPE_SHIFTTYPE, 
                                             p_shift_type => crs.exc_shift_type, 
                                             p_shift_id => null, p_user_id => p_user_id);
                                             
  end loop;
  
  if p_if_commit = 1 then
     commit;
  end if;
end;

end PSHFT_GENERATOR;
/
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
create or replace package PSHFT_RULECLC is

  -- Author  : BESO
  -- Created : 12/30/2011 1:54:18 AM
  -- Purpose : Responsible on calculation of the Rules

  -- 1: during the calendar week no more than 40 working hours;
  -- 2: day off should not be a fixed day during the week;
  -- 3: day off should be at 5-th or at 6-th working day, depends on the number of CC Agents in the shift and number of agents who is in the vacation;
  -- 4: cc operator should have all existing shifts during the week (it means not only evening, or not only the morning shift) for example two morning shifts and 3 evening shifts;
  -- 5: during the calendar week CC operator should have at least one 8 hour shift (day shift);
  -- 6: there are the particular CC operator's list who is able to have the night shift.The list of such operators will be provided;
  -- 7: no more than one night shift per month;
  -- 8: after night shift before next working day should pass no less than 24 hour;
  -- 9: between two shifts should pass no less than 12 hours. It means that evening shift should not be followed by the morning shift, f.e. 18:00 - 00:00 and after  comes 09:00 - 17:00 ;
  -- 10: the newcomers who is answering only pre-paid calls are not able to have the following shifts: 08:00;  20:00  and 01:00 - 08:00 -night shift. The list of such operators will be provided.

WEEKS_HOURS constant number := 40;

-- Minimal allowed Distance between end of Night Shift and start of next Shift for same Operator in hours
DST_BETWEN_SHIFTS_Night constant number := 24;
-- Minimal allowed Distance between end of Regular (not Night) Shift and start of next Shift for same Operator in hours
DST_BETWEN_SHIFTS_Regular constant number := 12;

-- Minimal allowed Distance between 2 next Night Shifts for same Operator in days
DST_BETWEEN_NIGHT_SHIFTS constant number := 30;
DST_BETWEEN_NIGHT_SHIFTS_RELAX constant number := 25;



-- 1: during the calendar week no more than 40 working hours;
RULE_WeekHours constant number := 1;
RULE_DayOff_DistanceBetween constant number := 3;
RULE_AllShiftsParticipate constant number := 4;
RULE_NightShiftPerMonth constant number := 7;
RULE_HoursBetweenShifts constant number := 9;
RULE_NewComersRestriction constant number := 10;

TYPE checkType is RECORD (
  if_ok boolean,
  -- 1 == Exclusion, 2 == Rule
  check_source number,
  -- if check_source = 1 (Exclusion) here is SHFT_OPERATOR_EXC.EXC_TYPE
  -- if check_source = 2 (Rule) here is Rule Code
  check_type number,
  -- if check_source = 1 (Exclusion) here is SHFT_OPERATOR_EXC.ID  checked
  -- if check_source = 2 (Rule) here is SHFT_SHIFT.ID checked
  id number
);


-- Chesks if indicated Day may be DayOff for indicated Operator:
-- Rule RULE_DayOff_DistanceBetween.
-- #return NULL - If indicated Day may be DayOff for indicated Operator, <BR>
--    previous DayOff date which is in conflict with this day accordnig RULE_DayOff_DistanceBetween rule.
function calcDstBetweenDayOffsRule(p_operator_id number, p_day date, p_accountOnlyPast boolean := false) return date;


-- Wrapper for calculateAllRules which returns simple number
-- #return 1 = indicated Shift if available for Operator
--         0 = indicated Shift if not available for Operator
function calculateAllRulesPoor(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean := false, p_ignore_sameday boolean := false) return number;


-- Caluclates all Rules in behalf of particular Operator and regarding particular Shift
-- #param p_accountOnlyPast indicates whether take into account only previous relative to the indicated one Shifts or all surrounding Shifts when calculate Rules
-- true = only Past Shifts participate in Rule calculation
-- false = whole existing environment except assignment in the very same day where checked Shift exists - participate.
-- #return 1 - if indicated Shift is available for indicated Operator.
function calculateAllRules(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean := false, p_ignore_sameday boolean := false) return checkType;


-- Caluclates particular Rule in behalf of particular Operator and regarding particular Shift
-- #param p_rule identifies particular Rule. Possible values are constants RULE_....
function calculateSingleRule(p_shift_id number, p_operator_id number, p_rule number, p_accountOnlyPast boolean := false, p_ignore_sameday boolean := false) return SHFT_SHIFT%ROWTYPE;


-- #return 1 if Rule is Ok, 0 - if it is violated
function calculateSingleRuleNum(p_shift_id number, p_operator_id number, p_rule number, p_accountOnlyPast boolean := false, p_ignore_sameday boolean := false) return number;




end PSHFT_RULECLC;
/
create or replace package body PSHFT_RULECLC is


-- regulates whether Calculate RULE_WeekHours
FLAG_RULE_WeekHours constant boolean := true;
FLAG_RULE_AllShiftsParticipate constant boolean := false;


-- Checks if rule RULE_HoursBetweenShifts won't break if indicated Operator will be assigned to the indicated Shift.
-- There are 2 kind of this rule:
-- a) After Night shift till any next Shift should pass not less than DST_BETWEN_SHIFTS_Night hours
-- b) After not Night shift till any next Shift should pass not less than DST_BETWEN_SHIFTS_Regular hours
function calcDstBetweenShiftsRule(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean := false, p_ignore_sameday boolean := false) return SHFT_SHIFT%ROWTYPE;

-- Checks if rule RULE_WeekHours won't break if indicated Operator will be assigned to the indicated Shift.
-- Actually it is Ok if only 1 Morning or Day shift is chosen within week (it is only 8 hour shift)!
-- #return If Shift is found acceptable in terms of Week Number of working hours - POSITIVE calculated estimation of Working hours per week returned as if this Shift is assigned.
--     If, though Shift is found NOT acceptable in terms of Week Number of working hours - NEGATIVE calculated estimation of Working hours per week returned as if this Shift is assigned.
function calcWorkHoursPerWeek(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean := false, p_ignore_sameday boolean := false) return number;


-- Checks if rule RULE_NightShiftPerMonth won't break if indicated Operator will be assigned to the indicated Shift.
-- #return if other Shift is found which breaks this rule for indicated in p_shift_id Shift - this found Shift Record is returned.
--     If no breaking Shift is found - empty structure with return.id is null will be returned
function calcNightShiftPerMonth(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean := false, p_ignore_sameday boolean := false) return SHFT_SHIFT%ROWTYPE;

-- Checks if rule RULE_AllShiftsParticipate is Ok so far.
-- Rule will be found failed if indicated Shift is last, all others are assigned already in week and totally - it fail,
-- that is - either all Shifts will be completed from Morning and day type shifts or from Evening ones.
-- If Rule is found to be failed - returned if whole Shift record related to the indicated Shift System ID - p_shift_id.
-- If Rule is Ok - returned is record with return.id is NULL.
function calcAllShiftsParticipate(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean := false, p_ignore_sameday boolean := false) return SHFT_SHIFT%ROWTYPE;

-- calculateAllRulesPoor
function calculateAllRulesPoor(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean, p_ignore_sameday boolean) return number is
/**
declare
  p_shift_id number := ss;
  p_operator_id number := oo;
  v_ret number;
begin
  v_ret := PSHFT_RULECLC.calculateAllRulesPoor(p_shift_id, p_operator_id);
  dbms_output.put_line(v_ret);
end;
*/
  v_ret number;
  v_retinner checkType;
begin
  v_retinner := calculateAllRules(p_shift_id, p_operator_id, p_accountOnlyPast, p_ignore_sameday);
  if v_retinner.if_ok then
    v_ret := 1;
  else
    v_ret := 0;
  end if;
  return v_ret;
end calculateAllRulesPoor;

-- calculateAllRules
function calculateAllRules(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean, p_ignore_sameday boolean) return checkType is
/**
declare
  p_shift_id number := 2047;
  p_operator_id number := 589;
  v_ret PSHFT_RULECLC.checkType;
begin
  v_ret := PSHFT_RULECLC.calculateAllRules(p_shift_id, p_operator_id);
  if v_ret.if_ok then
    dbms_output.put_line('OK');
  else
    dbms_output.put_line('FAILURE, check_source = ' || v_ret.check_source
                                   || ', check_type = ' || v_ret.check_type || ', id = ' || v_ret.id);
  end if;
end;
*/
  if_rule_ok boolean := true;
  v_failed_rule_id number;
  v_excl PSHFT_EXCLUSION.exclusionType;
  v_ret_shift SHFT_SHIFT%ROWTYPE;
  v_ret_num number;
  v_ret checkType;
begin

  v_ret.if_ok := true;

  -- RULE_HoursBetweenShifts Rule calculation
  if v_ret.if_ok then
    v_ret_shift := calcDstBetweenShiftsRule(p_shift_id, p_operator_id, p_accountOnlyPast, p_ignore_sameday);
    if v_ret_shift.id is not null then
      v_ret.if_ok := false;
      v_ret.check_source := 2;
      v_ret.check_type := RULE_HoursBetweenShifts;
      v_ret.id := v_ret_shift.id;
    end if;
  end if;

  -- RULE_WeekHours Rule calculation
  if v_ret.if_ok and FLAG_RULE_WeekHours then
    v_ret_num := calcWorkHoursPerWeek(p_shift_id, p_operator_id, p_accountOnlyPast, p_ignore_sameday);
    if v_ret_num < 0 then
      v_ret.if_ok := false;
      v_ret.check_source := 2;
      v_ret.check_type := RULE_WeekHours;
      v_ret.id := v_ret_num;
    end if;
  end if;

  -- RULE_NightShiftPerMonth
  if v_ret.if_ok then
    v_ret_shift := calcNightShiftPerMonth(p_shift_id, p_operator_id, p_accountOnlyPast, p_ignore_sameday);
    if v_ret_shift.id is not null then
      v_ret.if_ok := false;
      v_ret.check_source := 2;
      v_ret.check_type := RULE_NightShiftPerMonth;
      v_ret.id := v_ret_shift.id;
    end if;
  end if;

  -- RULE_AllShiftsParticipate
  if v_ret.if_ok and FLAG_RULE_AllShiftsParticipate then
    v_ret_shift := calcAllShiftsParticipate(p_shift_id, p_operator_id, p_accountOnlyPast, p_ignore_sameday);
    if v_ret_shift.id is not null then
      v_ret.if_ok := false;
      v_ret.check_source := 2;
      v_ret.check_type := RULE_AllShiftsParticipate;
      v_ret.id := v_ret_shift.id;
    end if;
  end if;


  -- Exclusions calculation
  if v_ret.if_ok then
    v_excl := PSHFT_EXCLUSION.checkIfShiftIsAvailable(p_shift_id, p_operator_id);
    if v_excl.id is not null then
      v_ret.if_ok := false;
      v_ret.check_source := 1;
      v_ret.check_type := v_excl.EXC_TYPE;
      v_ret.id := v_excl.ID;
    end if;
  end if;


  return v_ret;

end calculateAllRules;

-- calcDstBetweenDayOffsRule()
function calcDstBetweenDayOffsRule(p_operator_id number, p_day date, p_accountOnlyPast boolean := false) return date is
/**
-- To find out Operator having DayOffs to test on
select oe.operator_id, oe.exc_period_from
       from SHFT_OPERATOR_EXC oe
       where oe.proc_id = 16
             and oe.exc_type = 4
       order by oe.operator_id, oe.exc_period_from
-- To find out Operator having Vacation to test on
select oe.operator_id, oe.exc_period_from, oe.exc_period_to
       from SHFT_OPERATOR_EXC oe
       where oe.proc_id = 16
             and oe.exc_type = 3
       order by oe.operator_id, oe.exc_period_from

declare
  p_operator_id number := 978;-- 1025; -- 29.01.2012
  p_day date := to_date('04.02.2012', 'dd.mm.yyyy');
  v_day date;
begin
  v_day := PSHFT_RULECLC.calcDstBetweenDayOffsRule(p_operator_id, p_day);
  dbms_output.put_line(v_day);
end;
*/
  v_last_restday date;
  v_diff number;
begin
  v_last_restday := PSHFT_COMMONS1.getLastRestDay(p_operator_id);
  if v_last_restday is NOT NULL then
    v_diff := trunc(p_day, 'dd') - trunc(v_last_restday, 'dd')-1;
    if v_diff between PSHFT_GENERATOR.DAYOFF_SHIFT_FROM and PSHFT_GENERATOR.DAYOFF_SHIFT_TO then
       v_last_restday := NULL;
    end if;
  end if;

  return v_last_restday;

end calcDstBetweenDayOffsRule;


-- calcDstBetweenShiftsRule
function calcDstBetweenShiftsRule(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean, p_ignore_sameday boolean) return SHFT_SHIFT%ROWTYPE is
/**
-- Catch Violations of PSHFT_RULECLC.RULE_HoursBetweenShifts in Shift generations
select * from (
   select sh1.shift_type, sh1.shift_end_hour, sh2.shift_start_hour, (sh2.shift_start_hour - sh1.shift_end_hour)*24 hours_dist, sho2.shift_id, sho2.operator_id
       from SHFT_SHIFT sh1, SHFT_OPERATOR op1, SHFT_SHIFT_OPERATOR sho1, SHFT_SHIFT sh2, SHFT_OPERATOR op2, SHFT_SHIFT_OPERATOR sho2
       where sho2.proc_id = 11
             and sho2.shift_id = sh2.id
             and sho2.operator_id = op2.id
             and sho1.shift_id = sh1.id
             and sho1.operator_id = op1.id
             and op1.operator_user_id = op2.operator_user_id
             and sho1.shift_id = (select max(shift_id) from SHFT_OPERATOR opp, SHFT_SHIFT_OPERATOR shop
                                                 where shop.operator_id = opp.id
                                                       and opp.operator_user_id = op2.operator_user_id
                                                       and shop.shift_id < sho2.shift_id)
  ) where decode(shift_type, 4, 24, 12) > hours_dist
       and shift_type = 4
*/
  v_prev_shift SHFT_SHIFT%ROWTYPE;
  v_next_shift SHFT_SHIFT%ROWTYPE;
  v_shift SHFT_SHIFT%ROWTYPE;
  v_distance_hours number;
begin
  v_prev_shift := PSHFT_COMMONS1.getPreviousShift(p_operator_id, p_shift_id);
  v_shift := PSHFT_COMMONS1.getShift(p_shift_id);
  if p_ignore_sameday and trunc(v_shift.shift_start_hour, 'dd') = trunc(v_prev_shift.shift_start_hour, 'dd') then
    v_prev_shift := PSHFT_COMMONS1.getPreviousShift(p_operator_id, v_prev_shift.id);
  end if;

  if v_prev_shift.id is not null then
    -- Rule: RULE_HoursBetweenShifts
    if v_prev_shift.shift_type = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT then
      v_distance_hours := DST_BETWEN_SHIFTS_Night;
    else
      v_distance_hours := DST_BETWEN_SHIFTS_Regular;
    end if;
    if v_shift.shift_start_hour >= v_prev_shift.shift_end_hour + v_distance_hours/24 then
      v_prev_shift.id := null;
    end if;
  end if;
  -- Don't check Next Shif if Previous Shift check hit Rule
  if v_prev_shift.id is null and NOT p_accountOnlyPast then
    v_next_shift := PSHFT_COMMONS1.getNextShift(p_operator_id, p_shift_id);
    if p_ignore_sameday and trunc(v_shift.shift_start_hour, 'dd') = trunc(v_next_shift.shift_start_hour, 'dd') then
       v_next_shift := PSHFT_COMMONS1.getNextShift(p_operator_id, v_next_shift.id);
    end if;
    -- Previous Shift check hit NO Rule,check Next Shift
    if v_next_shift.id is not null then
      -- Rule: RULE_HoursBetweenShifts
      if v_shift.shift_type = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT then
        v_distance_hours := DST_BETWEN_SHIFTS_Night;
      else
        v_distance_hours := DST_BETWEN_SHIFTS_Regular;
      end if;
      if v_next_shift.shift_start_hour >= v_shift.shift_end_hour + v_distance_hours/24 then
        v_next_shift.id := null;
      end if;
    end if;
  end if;
  if v_prev_shift.id is not null then
    return v_prev_shift;
  elsif v_next_shift.id is not null and NOT p_accountOnlyPast then
    return v_next_shift;
  end if;

  return v_prev_shift;

end calcDstBetweenShiftsRule;

-- calcWorkHoursPerWeek()
-- Recent implementation takes into account that Restriction of no more than 40 working hours per week
-- won't be violated in case if Operator takes 1 or 2 Morning or Early Morning Shifts (each 8 hour) per week:
-- 1*8 + 5*6 = 38, 2*8 + 4*6 = 40 (Evening shifts are 6 hour). But there may be 2 DayOffs in week or part of week may be Vacation,
-- in which case - with 2 DayOffs: 5*8 = 40, so - no restriction on Day Shifts in this case!
-- @TODO: This calculation may be fully automized: based on the known DayOffs,
-- So far Assigned Shifts and known different type Shifts durations.
-- Normal Implementation which makes no any assumption on particular Shift types (like Morning) may be as following:
-- a) Make sum of: WeekStartTailHours and all already assigned (but not of the same day whose Shift we are checking) in this week Shifts' hours
-- b) Make number of Days which this Operator should be assigned to but not assigned yet (again except of the day of this Shift we aere checking)
--    For these days - calculate most less expensive Hours (6 Hour)
-- c) take very this (checked) Shift Hour
-- All these ingredients should be less than WEEKS_HOURS.
function calcWorkHoursPerWeek(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean, p_ignore_sameday boolean) return number is
/**
-- Catch Violations of PSHFT_RULECLC.RULE_NightShiftPerMonth in Shift generations
*/
  v_shift SHFT_SHIFT%ROWTYPE;
  v_shift_assigned SHFT_SHIFT%ROWTYPE;
  v_week_firstday date;
  v_hours number;
  v_hours_in_shift number;
  v_hours_assigned number;
  v_min_shift_hour number;
  v_counter number := 0;
  c_cursor PSHFT_COMMONS1.assignedShiftsCursor;
  v_ret SHFT_SHIFT%ROWTYPE;
  c_available_days PSHFT_COMMONS1.daysCursor;
  v_day date;
  v_day_counter number := 0;
  v_date_before date;
begin
  -- Here will accumulate Hours to check then over limit (WEEKS_HOURS)
  v_hours := 0;

  v_shift := PSHFT_COMMONS1.getShift(p_shift_id);

  v_hours_in_shift := (v_shift.shift_end_hour - v_shift.shift_start_hour)*24;
  v_week_firstday := PSHFT_COMMONS1.getWeekStartDate(v_shift.shift_start_hour);

  v_hours := v_hours + v_hours_in_shift;

  -- How many hours have been already assigned to this Operator within this week,
  -- taking into account - probably existing Tail hours (i.e. from Previous week last day Shift same User had been assigned to which has hours in this week)
  if p_accountOnlyPast then
    -- Assigned hours will be calculated for 1-st days of week, including this day
    v_date_before := v_shift.shift_start_hour;
  else
    -- Assigned hours will be calculated for whole week's assignments
    v_date_before := null;
  end if;
  v_hours_assigned := PSHFT_COMMONS1.calculateAssignedHoursInWeek(p_operator_id, v_week_firstday, v_date_before);

  if p_ignore_sameday then
      -- Now see - if this Operator has been assigned to some Shift within very same day checked Shift belongs to -
      -- hours of this Shift are to be excluded from ones calculated in [v_hours_assigned].
      -- Matter is that we may check another Shift to re-assign Operator to it within same day.
      v_shift_assigned := PSHFT_COMMONS1.getAssignedShift(p_operator_id, v_shift.shift_start_hour);
      if v_shift_assigned.id is NOT null then
        -- Exclude this assigned shift hours.
        v_hours := v_hours + v_hours_assigned - (v_shift_assigned.SHIFT_END_HOUR - v_shift_assigned.SHIFT_START_HOUR)*24;
      else
        v_hours := v_hours + v_hours_assigned;
      end if;
  else
      v_hours := v_hours + v_hours_assigned;
  end if;

  -- Now see days within this week which are available but not assigned yet.
  -- Estimate these days resource as their possible share in Week work hours, taking minimal possible Shift duration
  if p_accountOnlyPast then
    c_available_days := PSHFT_EXCLUSION.getAvailableDays(p_operator_id, v_week_firstday, v_shift.shift_start_hour, 0);
  else
    c_available_days := PSHFT_EXCLUSION.getAvailableDays(p_operator_id, v_week_firstday);
  end if;
  LOOP
    FETCH c_available_days into v_day;
    EXIT when c_available_days%NOTFOUND;

    -- Exclude the day in which checked Shift exists - if it is among available days
    if trunc(v_day, 'dd') != trunc(v_shift.shift_start_hour, 'dd') then
       v_day_counter := v_day_counter + 1;
    end if;

  END LOOP;
  CLOSE c_available_days;

  v_min_shift_hour := PSHFT_COMMONS1.getShiftMinHours(v_shift.proc_id);

  v_hours := v_hours + v_min_shift_hour*v_day_counter;

  -- And now at last - if accumulated hours exceed limit - verdict is negative, otherwise - Ok!
  if v_hours > WEEKS_HOURS then
    v_hours := - v_hours;
  end if;

  return v_hours;

end calcWorkHoursPerWeek;

-- calcNightShiftPerMonth
function calcNightShiftPerMonth(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean, p_ignore_sameday boolean) return SHFT_SHIFT%ROWTYPE is
/**
-- Catch Violations of PSHFT_RULECLC.RULE_NightShiftPerMonth in Shift generations
select * from (
   select sh1.shift_type, sh1.shift_start_hour shift_start_hour_prev, sh2.shift_start_hour shift_start_hour_now, (sh2.shift_start_hour - sh1.shift_end_hour) days_dist
       from SHFT_SHIFT sh1, SHFT_OPERATOR op1, SHFT_SHIFT_OPERATOR sho1, SHFT_SHIFT sh2, SHFT_OPERATOR op2, SHFT_SHIFT_OPERATOR sho2
       where sho2.proc_id = 11
             and sho2.shift_id = sh2.id
             and sho2.operator_id = op2.id
             and sh2.shift_type = 4 -- Night Shift
             and sho1.shift_id = sh1.id
             and sho1.operator_id = op1.id
             and op1.operator_user_id = op2.operator_user_id
             and sho1.shift_id = (select max(shift_id) from SHFT_SHIFT shp, SHFT_OPERATOR opp, SHFT_SHIFT_OPERATOR shop
                                                 where shop.operator_id = opp.id
                                                       and shop.shift_id = shp.id
                                                       and shp.shift_type = sh2.shift_type
                                                       and opp.operator_user_id = op2.operator_user_id
                                                       and shop.shift_id < sho2.shift_id)
  ) where days_dist < 30
*/
  v_shift SHFT_SHIFT%ROWTYPE;
  v_shift_prev SHFT_SHIFT%ROWTYPE;
  v_shift_next SHFT_SHIFT%ROWTYPE;
begin
  v_shift_prev.id := null;
  v_shift_next.id := null;
  v_shift := PSHFT_COMMONS1.getShift(p_shift_id);
  if v_shift.shift_type = PSHFT_COMMONS1.SHIFT_TYPE_NIGHT then
     v_shift_prev := PSHFT_COMMONS1.getPreviousShift(p_operator_id, p_shift_id, PSHFT_COMMONS1.SHIFT_TYPE_NIGHT);
     if v_shift_prev.id is not null then
       if v_shift.shift_start_hour > v_shift_prev.shift_end_hour + DST_BETWEEN_NIGHT_SHIFTS then
          v_shift_prev.id := null;
       end if;
     end if;
     if v_shift_prev.id is null and NOT p_accountOnlyPast then
        v_shift_next := PSHFT_COMMONS1.getNextShift(p_operator_id, p_shift_id, PSHFT_COMMONS1.SHIFT_TYPE_NIGHT);
        if v_shift_next.id is not null then
          if v_shift_next.shift_start_hour > v_shift.shift_end_hour + DST_BETWEEN_NIGHT_SHIFTS then
             v_shift_next.id := null;
          end if;
        end if;
     end if;
  end if;

  if v_shift_prev.id is not null then
     return v_shift_prev;
  elsif  v_shift_next.id is not null and NOT p_accountOnlyPast then
     return v_shift_next;
  end if;

  return v_shift_prev;

end;

-- calcAllShiftsParticipate
function calcAllShiftsParticipate(p_shift_id number, p_operator_id number, p_accountOnlyPast boolean, p_ignore_sameday boolean) return SHFT_SHIFT%ROWTYPE is
  v_week_fisrtday date;
  v_shift SHFT_SHIFT%ROWTYPE;
  v_shift_assigned SHFT_SHIFT%ROWTYPE;
  v_counter number;
  v_count_shtype_day number := 0;
  v_count_shtype_evening number := 0;
  if_day_among_assigned boolean := false;
  if_exist_otheravailable_day boolean := false;
  c_cursor PSHFT_COMMONS1.assignedShiftsCursor;
  c_days PSHFT_COMMONS1.daysCursor;
  v_day date;
begin
  v_shift := PSHFT_COMMONS1.getShift(p_shift_id);

  v_week_fisrtday := PSHFT_COMMONS1.getWeekStartDate(v_shift.shift_start_hour);

  c_cursor := PSHFT_COMMONS1.getAssignedShifts(p_operator_id,
                                                 v_week_fisrtday,
                                                 v_week_fisrtday+7-PSHFT_COMMONS1.ONE_SECOND);
  LOOP
     FETCH c_cursor into v_shift_assigned;
     EXIT WHEN c_cursor%NOTFOUND;

     if trunc(v_shift_assigned.shift_start_hour, 'dd') = trunc(v_shift.shift_start_hour, 'dd') then
       if_day_among_assigned := true;
     end if;

     if v_shift_assigned.shift_type in (PSHFT_COMMONS1.SHIFT_TYPE_MORNING,
                                        PSHFT_COMMONS1.SHIFT_TYPE_MORNING_EARLY,
                                        PSHFT_COMMONS1.SHIFT_TYPE_DAY) then

        v_count_shtype_day := v_count_shtype_day + 1;

     elsif v_shift_assigned.shift_type in (PSHFT_COMMONS1.SHIFT_TYPE_EVENING,
                                        PSHFT_COMMONS1.SHIFT_TYPE_EVENING_LATE) then

        v_count_shtype_evening := v_count_shtype_evening + 1;

     end if;

  END LOOP;
  CLOSE c_cursor;


  if NOT if_day_among_assigned then
    if v_shift.shift_type in (PSHFT_COMMONS1.SHIFT_TYPE_MORNING,
                              PSHFT_COMMONS1.SHIFT_TYPE_MORNING_EARLY,
                              PSHFT_COMMONS1.SHIFT_TYPE_DAY) then
       v_count_shtype_day := v_count_shtype_day + 1;

     elsif v_shift.shift_type in (PSHFT_COMMONS1.SHIFT_TYPE_EVENING,
                               PSHFT_COMMONS1.SHIFT_TYPE_EVENING_LATE) then

        v_count_shtype_evening := v_count_shtype_evening + 1;

     end if;
   end if;

   v_counter := 0;
   c_days := PSHFT_EXCLUSION.getAvailableDays(p_operator_id, v_shift.shift_start_hour);
   LOOP
      FETCH c_days into v_day;
      EXIT when c_days%NOTFOUND;

      if trunc(v_day, 'dd') != trunc(v_shift.shift_start_hour, 'dd') then
         if_exist_otheravailable_day := true;
         exit;
      end if;
   end LOOP;

   CLOSE c_days;


   if (v_count_shtype_day = 0 or v_count_shtype_evening = 0) and
                                 NOT if_exist_otheravailable_day  then
     return v_shift;

   end if;

   v_shift.id := null;

   return v_shift;

end;


-- calculateSingleRule()
function calculateSingleRule(p_shift_id number, p_operator_id number, p_rule number, p_accountOnlyPast boolean, p_ignore_sameday boolean) return SHFT_SHIFT%ROWTYPE is
/**
-- CASE.1: Check RULE_HoursBetweenShifts rule
-- *********************************************
-- To find out proper Shift-Operator to test this rule:
-- TestCase.01: take Operator having Night Shift and then - Shift which is a) closer than 24 hours, b) - farther than 24 hours:
-- a) FAIL: next Shift closer than 24 hours after Night shift
select sho.shift_id, sh.shift_start_hour, sh.shift_end_hour, sho.operator_id, sh2.id shift_id_far, sh2.shift_start_hour shift_start_hour_far
       from SHFT_SHIFT sh2, SHFT_SHIFT sh, SHFT_SHIFT_OPERATOR sho
       where sh.proc_id = 11 and sh2.proc_id = sh.proc_id
             and sho.shift_id = sh.id
             and sh.shift_type = 4
             and sh2.shift_start_hour between sh.shift_end_hour + 17/24 and sh.shift_end_hour + 17/24
       order by sh.id, sho.operator_id
-- b) EDGE case: next Shift start date (08:00) exactly 24 hours after end of Night shift
select sho.shift_id, sh.shift_start_hour, sh.shift_end_hour, sho.operator_id, sh2.id shift_id_far, sh2.shift_start_hour shift_start_hour_far
       from SHFT_SHIFT sh2, SHFT_SHIFT sh, SHFT_SHIFT_OPERATOR sho
       where sh.proc_id = 11 and sh2.proc_id = sh.proc_id
             and sho.shift_id = sh.id
             and sh.shift_type = 4
             and sh2.shift_start_hour between sh.shift_end_hour + 24/24 and sh.shift_end_hour + 24/24
       order by sh.id, sho.operator_id
-- c) OK case: next Shift start date (09:00) exactly 24 hours after end of Night shift
select sho.shift_id, sh.shift_start_hour, sh.shift_end_hour, sho.operator_id, sh2.id shift_id_far, sh2.shift_start_hour shift_start_hour_far
       from SHFT_SHIFT sh2, SHFT_SHIFT sh, SHFT_SHIFT_OPERATOR sho
       where sh.proc_id = 11 and sh2.proc_id = sh.proc_id
             and sho.shift_id = sh.id
             and sh.shift_type = 4
             and sh2.shift_start_hour between sh.shift_end_hour + 25/24 and sh.shift_end_hour + 25/24
       order by sh.id, sho.operator_id
-- TestCase.02: take Operator having Day Shift and then - Shift which is a) closer than 12 hours, b) - farther than 12 hours
declare
  p_shift_id number := ss;
  p_operator_id number := oo;
  p_rule number := PSHFT_RULECLC.RULE_HoursBetweenShifts;
  v_ret SHFT_SHIFT%ROWTYPE;
begin
  v_ret := PSHFT_RULECLC.calculateSingleRule(p_shift_id, p_operator_id, p_rule);
  dbms_output.put_line('v_ret.id = ' || v_ret.id || ', v_ret.shift_end_hour = ' || v_ret.shift_end_hour);
end;
-- CASE.2: Check RULE_AllShiftsParticipate rule
declare
  p_shift_id number := 1305;
  p_operator_id number := 580;
  p_rule number := PSHFT_RULECLC.RULE_AllShiftsParticipate;
  v_ret SHFT_SHIFT%ROWTYPE;
begin
  v_ret := PSHFT_RULECLC.calculateSingleRule(p_shift_id, p_operator_id, p_rule);
  dbms_output.put_line('v_ret.id = ' || v_ret.id || ', v_ret.shift_end_hour = ' || v_ret.shift_end_hour);
end;
-- *********************************************
*/
  v_ret SHFT_SHIFT%ROWTYPE;
  v_ret_num number;
begin
  case p_rule
    when RULE_WeekHours then
      v_ret_num := calcWorkHoursPerWeek(p_shift_id, p_operator_id, p_accountOnlyPast, p_ignore_sameday);
      v_ret.id := v_ret_num;
    when RULE_NightShiftPerMonth then
      v_ret := calcNightShiftPerMonth(p_shift_id, p_operator_id, p_accountOnlyPast, p_ignore_sameday);
    when RULE_HoursBetweenShifts then
      v_ret := calcDstBetweenShiftsRule(p_shift_id, p_operator_id, p_accountOnlyPast, p_ignore_sameday);
    when RULE_AllShiftsParticipate then
      v_ret := calcAllShiftsParticipate(p_shift_id, p_operator_id, p_accountOnlyPast, p_ignore_sameday);
    when RULE_NewComersRestriction then
      null;
  end case;
  return v_ret;
end calculateSingleRule;

-- calculateSingleRuleNum
function calculateSingleRuleNum(p_shift_id number, p_operator_id number, p_rule number, p_accountOnlyPast boolean := false, p_ignore_sameday boolean := false) return number is
  v_ret SHFT_SHIFT%ROWTYPE;
  v_res number;
begin
  v_ret := calculateSingleRule(p_shift_id, p_operator_id, p_rule, p_accountOnlyPast, p_ignore_sameday);
  if v_ret.id is null then
    v_res := 1;
  else
    v_res := 0;
  end if;
  return v_res;
end calculateSingleRuleNum;


end PSHFT_RULECLC;
/
