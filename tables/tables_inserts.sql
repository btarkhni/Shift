----------------------------
-- SHFT_DICT
----------------------------
-- 2: Generation Procedure Status
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 2, 1, null, 'initial', 'initial', 'Procedure just was generated, some standard initial data loaded (e.g. Operators, Shift Types, Shift Type Exclusions for operators - copied from previous Procedure)', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 2, 2, null, 'night shifts done', 'night shifts done', 'Night Shifts assignment has been done', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 2, 3, null, 'dayoffs done', 'dayoffs done', 'Day Offs setup has been done', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 2, 9, null, 'finished', 'finished', 'Procedure just was marked as finished. Only then - next Procedure (for next period) is eligible to be generated and processed.', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 2, 10, null, 'canceled', 'canceled', 'Procedure just was canceled', 1);


-- 14: Operator STATUS: SHFT_OPERATOR.STATUS
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 14, 1, null, 'ACTIVE', 'ACTIVE', 'Assigned to Shift Generation', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 14, 2, null, 'SUSPENDED', 'SUSPENED', 'Suspended - temporarily', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 14, 10, null, 'CANCELED', 'CANCELED', 'Canceled - permanently removed', 1);
	
-- 16: Operator STATUS in Pool: SHFT_OPERATOR_POOL.STATUS
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 16, 1, null, 'ACTIVE', 'ACTIVE', 'Assigned to Shift Generation', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 16, 2, null, 'SUSPENDED', 'SUSPENED', 'Suspended - temporarily', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 16, 10, null, 'CANCELED', 'CANCELED', 'Canceled - permanently removed', 1);

	
-- 18: Exception Type
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 18, 1, null, 'ShiftType', 'ShiftType', 'Operator Excluded to be assigned to the ANY Shift of particular Shift Type', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 18, 2, null, 'Shift', 'Shift', 'Operator Excluded to be assigned to the particular Shift', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 18, 3, null, 'Period', 'Period', 'Operator Excluded to be assigned to the any Shift which hits (intersects) particular Period', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 18, 4, null, 'DayOff', 'DayOff', 'Day Off', 1);

-- 24: Operator Restriction Group
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 24, 1, null, 'Regular', 'Regular', 'regular Operators, who can work in ANY Shift without exclusions', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 24, 2, null, 'Novice', 'Novice', 'Novice Operators, who are barred to work in Early Morning, Late Evening and Night Shifts', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 24, 3, null, 'no Night', 'no Night', 'Operators, who are barred to work in Night Shifts', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 24, 4, null, 'no Early Morning', 'no Early Morning', 'Operators, who are barred to work in Early Morning', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 24, 5, null, 'no Early Morning & Late Evening', 'no Early Morning & Late Evening', 'Operators, who are barred to work in Early Morning & Late Evening', 1);

-- 26: Shift Type
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 26, 1, null, 'Night', 'Night', '01:00', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 26, 2, null, 'Early Morning', 'Early Morning', '08:00', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 26, 3, null, 'Morning', 'Morning', '09:00, 10:00', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 26, 4, null, 'Day', 'Day', '13:00', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 26, 5, null, 'Evening', 'Evening', '17:00, 18:00, 19:00', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
    values (SHFT_DICT_SQ_ID.nextval, 26, 6, null, 'Late Evening', 'Late Evening', '20:00', 1);

-- 40: Rules
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
    values (SHFT_DICT_SQ_ID.nextval, 40, 1, null, 'Working Hours per Week', 'Working Hours per Week', 'working Hours within week (in sum no more than...)', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
    values (SHFT_DICT_SQ_ID.nextval, 40, 4, null, 'All Shift Types Per Week', 'All Shift Types Per Week', 'Operator should have within week at least 1 Moring-Day and at least 1 Evening Shift', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
    values (SHFT_DICT_SQ_ID.nextval, 40, 7, null, 'Night Shifts per Month', 'Night Shifts per Month', 'Night hifts per month calculation', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
    values (SHFT_DICT_SQ_ID.nextval, 40, 9, null, 'Hours between Shifts', 'Hours between Shifts', 'Hours between Shifts - not less than...', 1);

-- ????
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 39, 1, null, 'Exclusion', 'Exclusion', 'Exclusion', 1);
insert into SHFT_DICT (ID, UP, CODE, MASTER_CODE, NAME, NAME_TECH, DSC, ACTIVITY_FLAG)
	values (SHFT_DICT_SQ_ID.nextval, 39, 2, null, 'Rule', 'Rule', 'Rule', 1);

----------------------------
-- SHFT_DICT_DSC
----------------------------
insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (2, null, 'Shift Generation Procedure STATUS', 'Shift Generation Procedure STATUS', 1, 0, 0, 'Shift Generation Procedure STATUS (see SHFT_SHIFT_PROC.STATUS)');
insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (6, null, 'Shift STATUS', 'Shift STATUS', 1, 0, 0, 'Shift STATUS (see SHFT_SHIFT.STATUS)');
insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (10, null, 'Shift-Operator link Status', 'Shift-Operator link Status', 1, 0, 0, 'Shift-Operator link Status (see SHFT_SHIFT_OPERATOR.STATUS)');
insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (14, null, 'Operator Status', 'Operator Status', 1, 0, 0, 'Operator Status (see SHFT_OPERATOR.STATUS)');

-- see SHIFT-292
insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (16, null, 'Operator Status (POOL)', 'Operator Status (POOL)', 1, 0, 0, 'Operator Status in POOL (see SHFT_OPERATOR_POOL.STATUS)');

insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (18, null, 'Exception Type', 'Exception Type', 1, 0, 0, 'Exception Type (see SHFT_OPERATOR_EXC.EXC_TYPE)');
insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (22, null, 'Exception Status', 'Exception Status', 1, 0, 0, 'Exception Status (see SHFT_OPERATOR_EXC.STATUS)');
insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (24, null, 'Operator Restriction Group', 'Operator Restriction Group', 1, 0, 0, 'Regular, Novice, No Night');
insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (26, null, 'Shift Type', 'Shift Type', 1, 0, 0, 'Shift Type (see SHFT_SHIFT_TYPE.SHIFT_TYPE)');
insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (30, null, 'Shift Type Status', 'Shift Type Status', 1, 0, 0, 'Shift Type Status(see SHFT_SHIFT_TYPE.STATUS)');
insert into SHFT_DICT_DSC (DICT_CODE, MASTER_DICT_CODE, NAME_TECH, NAME, IS_VIEWABLE, IS_ALTERABLE, IS_EDITABLE, DSC)
	values (40, null, 'Rules', 'Rules', 1, 0, 0, 'Rules');


----------------------------
-- SHFT_OPERATOR_RESTRGRP
----------------------------
-- Novice
insert into SHFT_OPERATOR_RESTRGRP (GRP_CODE, SHIFT_TYPE) values (2, 1);
insert into SHFT_OPERATOR_RESTRGRP (GRP_CODE, SHIFT_TYPE) values (2, 2);
insert into SHFT_OPERATOR_RESTRGRP (GRP_CODE, SHIFT_TYPE) values (2, 6);
-- no Night
insert into SHFT_OPERATOR_RESTRGRP (GRP_CODE, SHIFT_TYPE) values (3, 1);
-- no Early Morning
insert into SHFT_OPERATOR_RESTRGRP (GRP_CODE, SHIFT_TYPE) values (4, 2);
-- no Early Morning & Late Evening
insert into SHFT_OPERATOR_RESTRGRP (GRP_CODE, SHIFT_TYPE) values (5, 2);
insert into SHFT_OPERATOR_RESTRGRP (GRP_CODE, SHIFT_TYPE) values (5, 6);


