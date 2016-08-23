create or replace package PSHFTUTL_MIGRATION is

  -- Author  : Beso Tarkhnishvili
  -- Created : 04.01.2012 01:27:10
  -- Purpose : Migration from Old (Koba made) Shift Database




  -- Migrate Old (Koba Made) Shift DB to New temporary DB
  -- #param p_date_from 1-st day of the Period to be migrated (inclusive)
  -- #param p_date_to last day of the Period to be migrated (inclusive)
  -- #param p_dsc arbitrary comment which will become comment to the Shift Generation Procedure
  -- #param p_proc_id Generation Procedure ID. If null - Generation Procedure will be generated
  -- #param p_dumpseq Dump Sequence to be assigned. If null - will be generated.
  -- #return System number of the Shift Generation Procedure which has been generated in behalf of this Migration process.
  function migrateOld2NewTmp(p_date_from date, p_date_to date, p_dsc varchar2, p_proc_id number, p_dumpseq number) return number;

  -- Migrates Operators from Old (Koba Made) Shift DB to New temporary DB in behalf of ready Shift Generation Procedure
  procedure migrateOldOpers2NewTmp(p_proc_id number);

  -- Migrate Shifts Generated in New PLSQL Shift Generator application - to Old CCH Shift.
  procedure migrateNewTmp2Old(p_proc_id number);


end PSHFTUTL_MIGRATION;
/
create or replace package body PSHFTUTL_MIGRATION is



-- migrateOld2NewTmp
function migrateOld2NewTmp(p_date_from date, p_date_to date, p_dsc varchar2, p_proc_id number, p_dumpseq number) return number is
/**
declare
  p_date_from date := to_date('01.12.2011', 'dd.mm.yyyy');
  p_date_to date := to_date('08.01.2012', 'dd.mm.yyyy');
  p_dsc varchar2(128) := 'Migration Shift Generation Procedure Koba Shift DB - New Shift DB';
  p_proc_id number := 10;
  p_dumpseq number: = 1;
  v_proc_id number;
begin
  v_proc_id := PSHFTUTL_MIGRATION.migrateOld2NewTmp(p_date_from, p_date_to, p_dsc, p_proc_id, p_dumpseq);
  dbms_output.put_line('v_proc_id = ' || v_proc_id);
end;
*/
  v_proc_id number;
  v_dumpseq number;
  v_operator SHFT_OPERATOR%ROWTYPE;
  cursor crsOperators is
         select * from geo_users_cc@cch u
                where u.status = 'A'
                order by id;
  cursor crsShifts(cp_proc_id number) is
         select * from SHFT_SHIFT sh
                where sysdate between fd and td
                order by sh.shift_start_hour;
  -- more correct would be use GEO_USERS_CC table, but GEO_USERS is super-manifold and result ios the same!
  cursor crsOldUsers2Shift(cp_shift_start_hour date) is
         select u.id user_id, uh.start_day, hh.start_hh, hh.stop_hh
                from GEO_USERS_CC@cch u, SHIFT_HOURS@cch hh, SHIFT_USER_HH_TEMP@cch uh
                where uh.hours_id = hh.id
                      and u.id = uh.user_id
                      and u.status = 'A'
                      and uh.start_day = trunc(cp_shift_start_hour, 'dd')
                      and hh.start_hh = round((cp_shift_start_hour - trunc(cp_shift_start_hour, 'dd'))*24)
                order by u.id;
  cursor crsOldUsersDayOffs(cp_date_from date, cp_date_to date) is
         select user_id, decode(hours_id, 12, PSHFT_EXCLUSION.EXCTYPE_DAYOFF, 13, PSHFT_EXCLUSION.EXCTYPE_PERIOD) exc_type, start_day
                from SHIFT_USER_HH_TEMP@cch
                where hours_id in (12, 13)
                      and start_day between cp_date_from and cp_date_to
                order by start_day, user_id;
begin
  -- Step.01: Generate Migration Procedure or work under indicated one
  if p_proc_id is not null then
    -- @TODO protection is to be done against:
    -- a) accidential using of existing real other Procedure
    -- b) inconsistency with Procedure Sequence (to notr allow indicated Proc ID be more than Sequence nextval).
    begin
      select id into v_proc_id from SHFT_SHIFT_PROC where id = p_proc_id;
      update SHFT_SHIFT_PROC
             set PERIOD_FROM = p_date_from,
                 PERIOD_TO = p_date_to,
                 DSC = p_dsc
             where id = v_proc_id
                   and sysdate between fd and td;
    exception
      WHEN NO_DATA_FOUND then
        raise PSHFT_COMMONS1.exProcedureNotExists;
    end;
  else
    v_proc_id := PSHFT_GENERATOR.generateNewProcedure(p_date_from, p_date_to, p_dsc,0);
  end if;

  -- Determine Dump Seq.
  if p_dumpseq is not null then
    v_dumpseq := p_dumpseq;
  else
    v_dumpseq := PSHFT_GENERATOR.generateDumpSeq;
  end if;
  update SHFT_SHIFT_PROC
      set DUMPSEQ = v_dumpseq
      where id = v_proc_id;

  -- Step.02: Migrate Operators
  migrateOldOpers2NewTmp(v_proc_id);
  -- Step.03: Generate empty Shifts for the period 01-Dec-2011 - 08-Jan-2011
  PSHFT_GENERATOR.generateEmptyShifts(v_proc_id, 0);
  -- Step.04: Assign Operators to the Shifts
  for crsSh in crsShifts(v_proc_id) loop
    for crsOUs in crsOldUsers2Shift(crsSh.shift_start_hour) loop
      v_operator := PSHFT_COMMONS1.getOperatorByUserId(v_proc_id, crsOUs.user_id);
      -- Assign this Operator to the Shift
      PSHFT_GENERATOR.assignOperator2Shift(v_proc_id, v_operator.id, crsSh.id, v_dumpseq);
    end loop;
  end loop;

  -- Step.05: Update SHFT_SHIFT with used DUMPSEQ
  update SHFT_SHIFT
         set DUMPSEQ = v_dumpseq
         where proc_id = v_proc_id;

  -- Step.06: SetUp Exclusions - for DayOffs and Vacations
  for crs in crsOldUsersDayOffs(p_date_from, p_date_to) loop
    v_operator := PSHFT_COMMONS1.getOperatorByUserId(v_proc_id, crs.user_id);
    if crs.exc_type = PSHFT_EXCLUSION.EXCTYPE_DAYOFF then
       PSHFT_EXCLUSION.setupExclusion4Operator(v_proc_id, v_operator.id, crs.exc_type, crs.start_day, v_dumpseq);
    elsif crs.exc_type = PSHFT_EXCLUSION.EXCTYPE_PERIOD then
       PSHFT_EXCLUSION.setupExclusion4Operator(v_proc_id, v_operator.id, crs.exc_type, crs.start_day, crs.start_day);
    end if;
  end loop;

  return v_proc_id;

end migrateOld2NewTmp;

-- migrateOldOpers2NewTmp
procedure migrateOldOpers2NewTmp(p_proc_id number) is
  cursor crsOperators is
         select * from geo_users_cc@cch u
                where u.status = 'A'
                order by id;
  v_sysdate date := sysdate;
begin
  for crs in crsOperators loop
     insert into SHFT_OPERATOR (ID, PROC_ID, OPERATOR_USER_ID, OPERATOR_USERNAME, OPERATOR_PERSONNAME, STATUS, FD, TD, USER_ID)
                     values (SHFT_OPERATOR_SQ_ID.Nextval, p_proc_id, crs.id, crs.username, crs.fname || ' ' || crs.lname, PSHFT_COMMONS1.OPERATOR_STATUS_ASSIGNED, v_sysdate, PSHFT_COMMONS1.getInfinity, 0);
  end loop;
end migrateOldOpers2NewTmp;

-- migrateNewTmp2Old
procedure migrateNewTmp2Old(p_proc_id number) is
/**
declare
  p_proc_id number := 11;
begin
  PSHFTUTL_MIGRATION.migrateNewTmp2Old(p_proc_id);
end;
*/
  c_assigned_shifts PSHFT_COMMONS1.assignedShiftsCursor;
  c_days PSHFT_COMMONS1.daysCursor;
  v_dayoff date;
  v_vacation_from date; v_vacation_to date;
  v_vacation_days number;
  v_shift SHFT_SHIFT%ROWTYPE;
  v_proc PSHFT_COMMONS1.shiftProcType;
  v_date_from date;
  v_date_to date;
  v_id number;
  v_hour number;
  v_hour_id number;
  v_cch_dayoff_code number := 12; -- SHIFT_HOURS.ID
  v_cch_vacation_code number := 13; -- SHIFT_HOURS.ID
  cursor crsOperators(cp_proc_id number) is
         select * from SHFT_OPERATOR op
                where op.proc_id = cp_proc_id
                      and sysdate between fd and td
                order by op.operator_user_id;

begin
  v_proc := PSHFT_COMMONS1.getShiftProc(p_proc_id);
  -- to exclude Night Shift in 09-Jan (already assigned by Koba)
  v_date_from := v_proc.PERIOD_FROM;
  -- to include whole last day's shifts
  v_date_to := v_proc.PERIOD_TO + 1;
  -- Step.01: this Date is required to let them choose Generated period from Viewer (for convinience, not critical)
  insert into SHIFT_FD@cch (FD) values (v_proc.PERIOD_TO);

  FOR crs in crsOperators(p_proc_id) loop
     -- Step.1: Import Assigned Shifts
     c_assigned_shifts := PSHFT_COMMONS1.getAssignedShifts(crs.id, v_date_from, v_date_to);
     LOOP
       FETCH c_assigned_shifts into v_shift;
       EXIT when c_assigned_shifts%NOTFOUND;

       v_hour := to_number(to_char(v_shift.shift_start_hour, 'hh24'));

       select id into v_hour_id
              from SHIFT_HOURS@cch
              where start_hh = v_hour;

       select seq_shift_user_hh_id.nextval@cch into v_id from dual;

       insert into SHIFT_USER_HH_TEMP@cch (ID, USER_ID, HOURS_ID, START_DAY)
            values (v_id, crs.operator_user_id, v_hour_id, trunc(v_shift.shift_start_hour, 'dd'));
     END LOOP;

     CLOSE c_assigned_shifts;

     -- Step.2: Import DayOffs
     c_days := PSHFT_COMMONS1.getDayOffs(crs.id);
     LOOP
       FETCH c_days into v_dayoff;
       EXIT when c_days%NOTFOUND;


       select seq_shift_user_hh_id.nextval@cch into v_id from dual;

       insert into SHIFT_USER_HH_TEMP@cch (ID, USER_ID, HOURS_ID, START_DAY)
            values (v_id, crs.operator_user_id, v_cch_dayoff_code, v_dayoff);

     END LOOP;

     CLOSE c_days;

     -- Step.3: Install Vacation
     c_days := PSHFT_COMMONS1.getVacations(crs.id);
     LOOP
       FETCH c_days into v_vacation_from, v_vacation_to;
       EXIT when c_days%NOTFOUND;


       v_vacation_days := v_vacation_to - v_vacation_from + 1;
       for cnt in 1..v_vacation_days loop
           select seq_shift_user_hh_id.nextval@cch into v_id from dual;

           insert into SHIFT_USER_HH_TEMP@cch (ID, USER_ID, HOURS_ID, START_DAY)
                values (v_id, crs.operator_user_id, v_cch_vacation_code, v_vacation_from + cnt - 1);
       end loop;


     END LOOP;

     CLOSE c_days;


  END LOOP;



end migrateNewTmp2Old;



end PSHFTUTL_MIGRATION;
/
