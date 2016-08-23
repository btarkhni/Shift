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
