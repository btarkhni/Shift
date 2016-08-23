-----------------------------------------------
-- Failed Rules Log
-----------------------------------------------

create sequence SHFT_SHIFT_FAILEDRULELOG_SQ_ID minvalue 1 start with 1 increment by 1;

create sequence SHFT_SHIFT_CALCLOG_SQ_ID minvalue 1 start with 1 increment by 1;

create table SHFT_SHIFT_FAILEDRULELOG
(
  ID                   NUMBER,
  PROC_ID              NUMBER,
  SHIFT_ID             NUMBER,
  OPERATOR_ID          NUMBER,
  CALC_DAY             DATE,
  FLAG_SHIFT_AVAILABLE NUMBER,
  CHECK_SOURCE         NUMBER,
  CHECK_TYPE           NUMBER,
  CHECK_SOURCE_ID      NUMBER,
  SEQ                  NUMBER,
  ACTION_DATE          DATE,
  SHIFT_START_HOUR     DATE,
  SHIFT_CAPACITY       NUMBER,
  ASSIGNED_OPERATORS   NUMBER,
  L_DAY_TYP_SHFT_NUM   NUMBER,
  L_EVN_TYP_SHFT_NUM   NUMBER,
  L_NGT_TYP_SHFT_NUM   NUMBER,
  L_DAY_SHFT_NUM       NUMBER,
  G_REST_DAYS_NUM      NUMBER,
  G_WEEK_TAIL_HOURS    NUMBER,
  G_DAY_SHFT_NUM       NUMBER,
  G_DAY_SHFT_HOUR      NUMBER,
  G_EVN_SHFT_NUM       NUMBER,
  G_EVN_SHFT_HOUR      NUMBER,
  G_SHFT_NUM           NUMBER,
  G_SHFT_HOUR          NUMBER,
  G_NIGHT_ASSGNED      NUMBER,
  G_DAYS_NUM           NUMBER,
  L_OVERCAPACITY_MODE  NUMBER,
  DUMPSEQ              NUMBER,
  G_MORN_SHFT_NUM      NUMBER,
  G_MORN_SHFT_HOUR     NUMBER,
  PHASE                NUMBER, 
  CONSTRAINT SHFT_SHIFT_FAILEDRULELOG_pk_ID PRIMARY KEY(ID)
);

comment on table SHFT_SHIFT_FAILEDRULELOG is 'Keeps log of failed Checking of Rules - return of the PSHFT_RULECALC.calculateAllRules()';
comment on column SHFT_SHIFT_FAILEDRULELOG.ID is 'Uniques ID for record, generated from sequence +SHFT_SHIFT_FAILEDRULELOG_SQ_ID+';
comment on column SHFT_SHIFT_FAILEDRULELOG.PROC_ID is 'Shiift Generation Procedure System ID, references +SHFT_SHIFT_PROC.ID+';
comment on column SHFT_SHIFT_FAILEDRULELOG.SHIFT_ID is 'Shift System ID, references +SHFT_SHIFT.ID+ of the Shift in behalf of which this Log record is generated';
comment on column SHFT_SHIFT_FAILEDRULELOG.OPERATOR_ID is 'System ID of the Operator whose Rule calculation has failed. References +SHFT_OPERATOR.ID+';
comment on column SHFT_SHIFT_FAILEDRULELOG.CALC_DAY is 'Day in behalf of which calculaton is doing';
comment on column SHFT_SHIFT_FAILEDRULELOG.FLAG_SHIFT_AVAILABLE is 'Indicates if in result of calculation - this particular Shift is found available for Operator:

1 = Available,

0 = Not Available, in which case - detailed reason is provided in the fields: +CHECK_SOURCE+, +CHECK_TYPE+, +CHECK_SOURCE_ID+';
comment on column SHFT_SHIFT_FAILEDRULELOG.CHECK_SOURCE is 'Indicates whether PSHFT_RULECALC.calculateAllRules() calculation has failed on the Exclusion calculation or Rule calculation:

1 = Exclusion calculation

2 = Rule calculation';
comment on column SHFT_SHIFT_FAILEDRULELOG.CHECK_TYPE is 'if +CHECK_SOURCE+ = 1 (Exclusion) - here is type of Exclusion which hit (SHFT_OPERATOR_EXC.EXC_TYPE),

if +CHECK_SOURCE+ = 2 (Rule) - here is Rule code which failed. Possible Rule codes are:

9 == Hours between Shifts

1 == working Hours within week (in sum no more than...)

7 == Night hifts per month calculation';
comment on column SHFT_SHIFT_FAILEDRULELOG.CHECK_SOURCE_ID is 'if +CHECK_SOURCE+ = 1 (Exclusion) - here is SHFT_OPERATOR_EXC.ID of exclusion which hit

if +CHECK_SOURCE+ = 2 (Rule) - here is SHFT_SHIFT.ID checked for this Rule';
comment on column SHFT_SHIFT_FAILEDRULELOG.SEQ is 'Calculation Sequence Log which has common source (generated from the same Sequence) for:

+SHFT_SHIFT_ASSGNLOG.SEQ+, +SHFT_SHIFT_OPERATOR.SEQ+, +SHFT_SHIFT_FAILEDRULELOG.SEQ+.

Generated from the Sequence: +SHFT_SHIFT_CALCLOG_SQ_ID+';

-- Indices
create unique index SHFT_SHIFT_FAILEDRULELOG_I_SEQ on SHFT_SHIFT_FAILEDRULELOG(SEQ);

