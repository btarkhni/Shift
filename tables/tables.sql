-----------------------------------------------
-- Disctionary Description
-----------------------------------------------

create table SHFT_DICT_DSC
(
  DICT_CODE        NUMBER,
  MASTER_DICT_CODE NUMBER,
  NAME_TECH        VARCHAR2(512),
  NAME             VARCHAR2(512),
  IS_VIEWABLE      NUMBER,
  IS_ALTERABLE     NUMBER,
  IS_EDITABLE      NUMBER,
  DSC              VARCHAR2(4000),
  CONSTRAINTS SHFT_DICT_DSC_pk_DCODE PRIMARY KEY(DICT_CODE)
);

comment on table SHFT_DICT_DSC is 'Described Dictionaries employed in the System';
comment on column SHFT_DICT_DSC.DICT_CODE is 'Dictionary Code. Corresponds to the ++SHFT_DICT.UP++';
comment on column SHFT_DICT_DSC.MASTER_DICT_CODE is 'In case of the hierarchical dependency between Dictionaries - refers ++DIC_CODE++ of the dictionary which is considered as Master for this one.

This means that Codes of this Dictionary (++SHFT_DICT.CODE++) will belong to the particular Code (++SHFT_DICT.MASTER_CODE++) of the Master Dictionary';
comment on column SHFT_DICT_DSC.NAME_TECH is 'Name of the Dictionary - as it is used Internally (English)';
comment on column SHFT_DICT_DSC.NAME is 'Name of the Dictionary - as it is used on UI';
comment on column SHFT_DICT_DSC.IS_VIEWABLE is 'Indicates whether Dictionary is viewable (i.e. authorized User has permit to view this Dictionary Items from UI).

0 - is not, 1 - is';
comment on column SHFT_DICT_DSC.IS_ALTERABLE is 'Indicates whether Dictionary is alterable (i.e. authorized User has permit to view and alter name of this Dictionary Items from UI). NOTE no permit to adddelete exists, i.e. all codes - are stable and can''t be modified from UI

0 - is not, 1 - is';
comment on column SHFT_DICT_DSC.IS_EDITABLE is 'Indicates whether Dictionary is editable (i.e. authorized User has permit to add, delete, update records of this Dictionary from UI)

0 - is not, 1 - is';
comment on column SHFT_DICT_DSC.DSC is 'Free Description making clear Dictionary';

-- Indices

-----------------------------------------------
-- Disctionary table
-----------------------------------------------

create sequence SHFT_DICT_SQ_ID minvalue 1 start with 1 increment by 1;


create table SHFT_DICT
(
  ID            NUMBER,
  UP            NUMBER,
  CODE          NUMBER,
  MASTER_CODE   NUMBER,
  NAME          VARCHAR2(512),
  NAME_TECH     VARCHAR2(512),
  DSC           VARCHAR2(4000),
  ACTIVITY_FLAG NUMBER, 
  CONSTRAINT SHFT_DICT_pk_ID PRIMARY KEY(ID)
);

comment on table SHFT_DICT is 'Dictionary. Contains ++CODE-NAME++ pairs for different Dictionaruies';
comment on column SHFT_DICT.ID is 'Unique identifier for SHFT_DICT, generated from +SHFT_DICT_SQ_ID+ sequence';
comment on column SHFT_DICT.UP is 'Code of the Dictionary. Description of these Dictionaries are in the ++SHFT_DICT_DSC++';
comment on column SHFT_DICT.CODE is 'Code. It is referrenced in the Business tables, though on the UI is visualized corresponding to it ++NAME++';
comment on column SHFT_DICT.MASTER_CODE is 'If This Dictionary this Code belongs to - has Master (see ++SHFT_DICT_DSC.MASTER_DICT_CODE++) 

- here is indicated Master Dictionary Code this Code belongs to Otherwise - NULL';
comment on column SHFT_DICT.NAME is 'Name corresponding to the ++CODE++';
comment on column SHFT_DICT.NAME_TECH is 'Technical Name corresponding to the ++CODE++';
comment on column SHFT_DICT.DSC is 'Free Description is necessary';
comment on column SHFT_DICT.ACTIVITY_FLAG is 'indicates whether this Dictionary Item is Active or Closed:

1 == Active, i.e. this Dictionary Item is used with current processes;

0 == Closed, i.e. this Dictionary Item is not used with current processes, but might be still referrenced with previously done records

If Dictionary Item is [deleted] or [closed] (synonyms), this attribute is switched from 1 to 0';

-- Indices
create index SHFT_DICT_I_UPID on SHFT_DICT (UP, CODE);


-----------------------------------------------
-- Group table
-----------------------------------------------


create table SHFT_GROUP 
(
  ID NUMBER, 
  GROUP_NAME VARCHAR2(128), 
  DSC VARCHAR2(4000), 
  CONSTRAINT SHFT_GROUP_pk_ID PRIMARY KEY(ID)
);



-- Indices


-----------------------------------------------
-- Rule table
-----------------------------------------------

create table SHFT_RULE
(
  ID        NUMBER,
  CODE 		NUMBER, 
  RULE_TYPE NUMBER,
  RULE_NAME VARCHAR2(128),
  DSC       VARCHAR2(4000), 
  CONSTRAINT SHFT_RULE_pk_ID PRIMARY KEY(ID)
);

comment on table SHFT_RULE is 'Lists all Rules applicable to the shift calculation';
comment on column SHFT_RULE.ID is 'Unique ID, generated from the sequence SHFT_RULE_SQ_ID';
comment on column SHFT_RULE.CODE is 'Code assigned to this Rule';
comment on column SHFT_RULE.RULE_TYPE is 'Indicates whether this Rule is blocker or Checker. Values are:

1 == Blocker Rule - is calculated when Operator is tried to be assigned to the particular Shift, while

2 == Checker Rule - is calculated when all Operators are already distributed

';
comment on column SHFT_RULE.RULE_NAME is 'Name of the Rule';
comment on column SHFT_RULE.DSC is 'Detailed Description of the Rule';

-----------------------------------------------
-- Restirction Group table
-----------------------------------------------



create table SHFT_OPERATOR_RESTRGRP
(
  GRP_CODE   NUMBER,
  SHIFT_TYPE NUMBER, 
  CONSTRAINT SHFT_OPERATOR_RESTRGRP_pk PRIMARY KEY (GRP_CODE, SHIFT_TYPE)
);


comment on table SHFT_OPERATOR_RESTRGRP is 'represents operator Restriction Group mapping on the Shift Type which are bared for this Group,

i.e. Operator assigned to this restriction Group - will be excluded from participating in those Shift Types which are mapped to the Group here.

If no Shift Type is mapped - that means this operator is allowed to participate in ANY Shift Type';

comment on column SHFT_OPERATOR_RESTRGRP.GRP_CODE is 'Code of Operator Restriction Group - see Dictionary #24';
comment on column SHFT_OPERATOR_RESTRGRP.SHIFT_TYPE is 'Code of Shift Type - Dictionary #26 - barred for this Group';


-- Indices


-----------------------------------------------
-- Shift Procedure table
-----------------------------------------------

create sequence SHFT_SHIFT_PROC_SQ_ID minvalue 1 start with 1 increment by 1;

create sequence SHFT_DUMP_SQ_ID minvalue 1 start with 1 increment by 1;

create table SHFT_SHIFT_PROC
(
  ID                      NUMBER,
  STATUS                  NUMBER,
  PERIOD_FROM             DATE,
  PERIOD_TO               DATE,
  GROUP_ID		  	      NUMBER,
  DSC                     VARCHAR2(4000),
  DUMPSEQ                 NUMBER,
  DUMPSEQ_PREV            NUMBER,
  IF_NIGHTSHIFTS_ASSIGNED NUMBER,
  IF_DAYOFFS_GENERATED    NUMBER,
  IF_OPERATORS_ASSIGNED   NUMBER, 
  USER_ID		  		  NUMBER,
  FD                      DATE,
  TD                      DATE,
  CONSTRAINT SHFT_SHIFT_PROC_pk_IDFD PRIMARY KEY(ID, FD), 
  CONSTRAINT SHFT_SHIFT_PROC_fk_GRPID FOREIGN KEY(GROUP_ID) REFERENCES SHFT_GROUP(ID)
);

-- Indices
create index SHFT_SHIFT_PROC_I_GRPID on SHFT_SHIFT_PROC(GROUP_ID);


-----------------------------------------------
-- Shift Type table
-----------------------------------------------

create sequence SHFT_SHIFT_TYPE_SQ_ID minvalue 1 start with 1 increment by 1;


create table SHFT_SHIFT_TYPE
(
  ID                  NUMBER,
  SHIFT_TYPE          NUMBER,
  HOUR_START          NUMBER,
  HOURS               NUMBER,
  CAPACITY            NUMBER,
  STATUS              NUMBER,
  USER_ID             NUMBER,
  USERNAME            VARCHAR2(128),
  PERSONNAME          VARCHAR2(128),
  DSC                 VARCHAR2(4000),
  FD                  DATE,
  TD                  DATE,
  PROC_ID             NUMBER,
  IF_LET_OVERCAPACITY NUMBER,
  OVERCAPACITY_LIMIT  NUMBER,
  CONSTRAINT SHFT_SHIFT_TYPE_pk_IDFD PRIMARY KEY(ID, FD) 
);

comment on table SHFT_SHIFT_TYPE is 'Describes different Shift types

Supports Versioning';
comment on column SHFT_SHIFT_TYPE.ID is 'Unique ID, generated by sequence +SHFT_SHIFT_TYPE_SQ_ID+';
comment on column SHFT_SHIFT_TYPE.SHIFT_TYPE is 'Type of the Shift Type. So far - exists following Types:

1 = 8 hour morning shift

2 = 8 hour day shift

3 = 6 hour evening shift

4 = 7 hour night shift

Note, there may be several Shifts of each Type!

See Dictionary #26';
comment on column SHFT_SHIFT_TYPE.HOUR_START is 'Shift Type start Hour';
comment on column SHFT_SHIFT_TYPE.HOURS is 'Number of Hours in the Shift';
comment on column SHFT_SHIFT_TYPE.CAPACITY is 'Shift Type Capacity, i.e. number of Operators should be assigned to the Shift';
comment on column SHFT_SHIFT_TYPE.STATUS is 'Status of the Shift Type. Possible values are:

1 = Active (used with Generations

10 = Canceled (not used with Generations

See Dictionary #30';

-- Indices
create index SHFT_SHIFT_TYPE_I_PROCID on SHFT_SHIFT_TYPE (PROC_ID);


-----------------------------------------------
-- Procedure Operator table
-----------------------------------------------

create sequence SHFT_OPERATOR_SQ_ID minvalue 1 start with 1 increment by 1;


create table SHFT_OPERATOR
(
  ID                  NUMBER,
  PROC_ID             NUMBER,
  OPERATOR_USER_ID    NUMBER,
  OPERATOR_USERNAME   VARCHAR2(128),
  OPERATOR_PERSONNAME VARCHAR2(128),
  STATUS              NUMBER,
  GNR_RUN_COUNTER     NUMBER,
  GNR_STATUS          NUMBER,
  USER_ID             NUMBER,
  USERNAME            VARCHAR2(128),
  PERSONNAME          VARCHAR2(128),
  DSC                 VARCHAR2(4000),
  FD                  DATE,
  TD                  DATE,
  DUMPSEQ             NUMBER,
  ORD_NUM             NUMBER, 
  OPERATOR_PERSONALID VARCHAR2(64),
  RESTRICT_GRP        NUMBER,
  GROUP_ID            NUMBER,
  CONSTRAINT SHFT_OPERATOR_pk_ID_FD PRIMARY KEY (ID, FD), 
  CONSTRAINT SHFT_OPERATOR_fk_GRPID FOREIGN KEY(GROUP_ID) REFERENCES SHFT_GROUP(ID)
);
comment on table SHFT_OPERATOR is 'for each Shift Generation Procedure - list of Operators, participated in it.

Supports Versioning';
comment on column SHFT_OPERATOR.ID is 'Unique ID, generated by sequence +SHFT_OPERATOR_SQ_ID+';
comment on column SHFT_OPERATOR.PROC_ID is 'System ID of the Shift Generation Procedure with which it is done - refers +SHFT_SHIFT_PROC.ID+';
comment on column SHFT_OPERATOR.OPERATOR_USER_ID is 'User ID of the Operator involved in Shift generation';
comment on column SHFT_OPERATOR.OPERATOR_USERNAME is 'UserName of the Operator involved in Shift generation';
comment on column SHFT_OPERATOR.OPERATOR_PERSONNAME is 'PersonName of the Operator involved in Shift generation';
comment on column SHFT_OPERATOR.STATUS is 'Status of the Operator. Possible values are:

1 == Assigned to Shift Generation

2 == SUSPENDED, i.e. temporarily does not participate in SHIFT

10 == Canceled from Shift generation

See Dictionary #14';
comment on column SHFT_OPERATOR.USER_ID is 'User ID - who is responsible for this Step';
comment on column SHFT_OPERATOR.USERNAME is 'User Name - who is responsible for this Step';
comment on column SHFT_OPERATOR.PERSONNAME is 'Person Name - who is responsible for this Step';
comment on column SHFT_OPERATOR.DSC is 'Arbitrary Comment';
comment on column SHFT_OPERATOR.FD is 'Validity period start';
comment on column SHFT_OPERATOR.TD is 'Validity period end';
comment on column SHFT_OPERATOR.ORD_NUM is 'Used during generation of the Procedure - to ensure randomization of Operators: for each new Procedure - Operators participated in it are randomly ordered, which sequential order number is put to this column.
  
This way - we may be sure that treatment of Operators through different procedure is managed in JUST manner and can sequentially 1-by-1 treat Operators by any algorithm in order of increasing of this ORD_NUM value.';
comment on column SHFT_OPERATOR.OPERATOR_PERSONALID is 'Personal number (11-digit) of the Operator which is main identifier of the Operator';
comment on column SHFT_OPERATOR.RESTRICT_GRP is 'Restrict Group (Dictionary #24) this Operator belongs to';
comment on column SHFT_OPERATOR.GROUP_ID is 'System ID of the Group this Operator belongs to. Is reference to the SHFT_GROUP.ID';

-- Indices
create index SHFT_OPERATOR_IPROC on SHFT_OPERATOR (PROC_ID);
create index SHFT_OPERATOR_IUID on SHFT_OPERATOR (OPERATOR_USER_ID);
create index SHFT_OPERATOR_GRID on SHFT_OPERATOR (GROUP_ID);


-----------------------------------------------
-- Operator Exclusion table
-----------------------------------------------

create sequence SHFT_OPERATOR_EXC_SQ_ID minvalue 1 start with 1 increment by 1;

create table SHFT_OPERATOR_EXC
(
  ID              NUMBER,
  PROC_ID         NUMBER,
  OPERATOR_ID     NUMBER,
  EXC_TYPE        NUMBER,
  EXC_SHIFT_TYPE  NUMBER,
  EXC_SHIFT       NUMBER,
  EXC_PERIOD_FROM DATE,
  EXC_PERIOD_TO   DATE,
  EXC_REASON_TEXT VARCHAR2(1000),
  STATUS          NUMBER,
  USER_ID         NUMBER,
  USERNAME        VARCHAR2(128),
  PERSONNAME      VARCHAR2(128),
  DSC             VARCHAR2(4000),
  FD              DATE,
  TD              DATE,
  DUMPSEQ         NUMBER,
  CORRECTION_GAP  NUMBER, 
  CONSTRAINTS SHFT_OPERATOR_EXC_pk_IDFD PRIMARY KEY(ID, FD)
);


comment on table SHFT_OPERATOR_EXC is 'for each Shift Generation Procedure - list of so-called Exceptions which some Operators can have.

E.g. particular Operator can NOT participate in Nigh shift etc...

Supports Versioning';
comment on column SHFT_OPERATOR_EXC.ID is 'Unique ID, generated by sequence +SHFT_OPERATOR_EXC_SQ_ID+';
comment on column SHFT_OPERATOR_EXC.PROC_ID is 'System ID of the Shift Generation Procedure with which it is done - refers +SHFT_SHIFT_PROC.ID+';
comment on column SHFT_OPERATOR_EXC.OPERATOR_ID is 'System ID of the Operator, refers +SHFT_OPERATOR.ID+';
comment on column SHFT_OPERATOR_EXC.EXC_TYPE is 'Exception type applied to this Operator. Following values are possible:

1 = Excluded to be assigned to the ANY Shift of particular Shift Type. For this Exception Shift Type is indicated in the +EXC_SHIFT_TYPE+

2 = Excluded to be assigned to the particular Shift. For this Exception Shift is indicated in the +EXC_SHIFT+

3 = Excluded to be assigned to the any Shift which hits particular Period. For this Exception Period is indicated in the +EXC_PERIOD_FROM+ and +EXC_PERIOD_TO+

See Dictionary #18';
comment on column SHFT_OPERATOR_EXC.EXC_SHIFT_TYPE is 'Shift Type - see +SHFT_SHIFT_TYPE.TYPE+.

Used along with +EXC_TYPE = 1+';
comment on column SHFT_OPERATOR_EXC.EXC_SHIFT is 'System ID of the Shift this Operator is excluded from - refers +SHFT_SHIFT.ID+.

Used along with +EXC_TYPE = 2+';
comment on column SHFT_OPERATOR_EXC.EXC_PERIOD_FROM is 'Start of the Period Operator is excluded from, that is - Operator will be excluded from ANY Shift which is Intersected with this Period. See as well +EXC_PERIOD_TO+

Used along with +EXC_TYPE = 3+';
comment on column SHFT_OPERATOR_EXC.EXC_PERIOD_TO is 'Start of the Period Operator is excluded from, that is - Operator will be excluded from ANY Shift which is Intersected with this Period. See as well +EXC_PERIOD_FROM+

Used along with +EXC_TYPE = 3+';
comment on column SHFT_OPERATOR_EXC.EXC_REASON_TEXT is 'Exception reason - so far - free text';
comment on column SHFT_OPERATOR_EXC.STATUS is 'Status of the Exception. Possible Values are:

1 == Exception is Active (will be applied during shift generation)

10 = Canceled (will NOT be applied during shift generation)

See Dictionary #22';
comment on column SHFT_OPERATOR_EXC.USER_ID is 'User ID - who is responsible for this Step';
comment on column SHFT_OPERATOR_EXC.USERNAME is 'User Name - who is responsible for this Step';
comment on column SHFT_OPERATOR_EXC.PERSONNAME is 'Person Name - who is responsible for this Step';
comment on column SHFT_OPERATOR_EXC.DSC is 'Arbitrary Comment';
comment on column SHFT_OPERATOR_EXC.FD is 'Validity period start';
comment on column SHFT_OPERATOR_EXC.TD is 'Validity period end';

-- Indices
create index SHFT_OPERATOR_EXC_I_OPID on SHFT_OPERATOR_EXC (OPERATOR_ID);
create index SHFT_OPERATOR_EXC_I_PROPID on SHFT_OPERATOR_EXC (PROC_ID, OPERATOR_ID);


-----------------------------------------------
-- Shift table
-----------------------------------------------

create sequence SHFT_SHIFT_SQ_ID minvalue 1 start with 1 increment by 1;


create table SHFT_SHIFT
(
  ID                 NUMBER,
  PROC_ID            NUMBER,
  SHIFTTYPE_ID		 NUMBER, 
  STATUS             NUMBER,
  SHIFT_START_HOUR   DATE,
  SHIFT_END_HOUR     DATE,
  SHIFT_TYPE         NUMBER,
  SHIFT_CAPACITY     NUMBER,
  ASSIGNED_OPERATORS NUMBER,
  USER_ID            NUMBER,
  USERNAME           VARCHAR2(128),
  PERSONNAME         VARCHAR2(128),
  DSC                VARCHAR2(4000),
  FD                 DATE,
  TD                 DATE,
  DUMPSEQ            NUMBER,
  OVERCAPACITY_LIMIT NUMBER, 
  CONSTRAINT SHFT_SHIFT_pk_IDFD PRIMARY KEY(ID, FD)
);

comment on table SHFT_SHIFT is 'Contains particular Shifts to be generated or generated or ...

Supports Versioning';
comment on column SHFT_SHIFT.ID is 'Unique ID, generated from sequence +SHFT_SHIFT_SQ_ID+';
comment on column SHFT_SHIFT.PROC_ID is 'System ID of the Shift Generation Procedure with which it is done - refers +SHFT_SHIFT_PROC.ID+';
comment on column SHFT_SHIFT.SHIFTTYPE_ID is 'References System ID of the Shift Type based on which this Shift has been generated - refers +SHFT_SHIFT_TYPE.ID+';
comment on column SHFT_SHIFT.STATUS is 'Status of the Shift (actually follows +SHFT_SHIFT_PROC.STATUS+):

1 = Initialized (Data preparation stage)

2 = Ready (Procedure is marked intentionally, only after that Generation may be started)

3 = Under Processing (when Generation started and until it is finished or Canceled)

4 = Finished (when Generation is Finished)

10 = Canceled (when Generation is Canceled)

See Dictionary #6';
comment on column SHFT_SHIFT.SHIFT_START_HOUR is 'Date when this Shift is started';
comment on column SHFT_SHIFT.SHIFT_END_HOUR is 'Date when this Shift is finished';
comment on column SHFT_SHIFT.SHIFT_TYPE is 'Type of the Shift - refers +SHFT_SHIFT_TYPE.TYPE+';
comment on column SHFT_SHIFT.SHIFT_CAPACITY is 'Number of Operators should be assigned to the Shift';
comment on column SHFT_SHIFT.ASSIGNED_OPERATORS is 'Number of Operators actually assigned to this Shift';
comment on column SHFT_SHIFT.USER_ID is 'User ID - who is responsible for this Step';
comment on column SHFT_SHIFT.USERNAME is 'User Name - who is responsible for this Step';
comment on column SHFT_SHIFT.PERSONNAME is 'Person Name - who is responsible for this Step';
comment on column SHFT_SHIFT.DSC is 'Arbitrary Comment';
comment on column SHFT_SHIFT.FD is 'Validity period start';
comment on column SHFT_SHIFT.TD is 'Validity period end';

-- Indices
create index SHFT_SHIFT_I_PRC on SHFT_SHIFT (PROC_ID, ID);
create index SHFT_SHIFT_I_STH on SHFT_SHIFT (SHIFT_START_HOUR);


-----------------------------------------------
-- Operator assignment to Shift table
-----------------------------------------------

create sequence SHFT_SHIFT_OPERATOR_SQ_ID minvalue 1 start with 1 increment by 1;


create table SHFT_SHIFT_OPERATOR
(
  ID          NUMBER,
  SHIFT_ID    NUMBER,
  OPERATOR_ID NUMBER,
  STATUS      NUMBER,
  USER_ID     NUMBER,
  USERNAME    VARCHAR2(128),
  PERSONNAME  VARCHAR2(128),
  DSC         VARCHAR2(4000),
  FD          DATE,
  TD          DATE,
  PROC_ID     NUMBER,
  DUMPSEQ     NUMBER,
  IF_MANUAL   NUMBER, 
  IF_STABLE   NUMBER, 
  CONSTRAINT SHFT_SHIFT_OPERATOR_pk_IDFD PRIMARY KEY(ID, FD)
);

comment on table SHFT_SHIFT_OPERATOR is 'relation between Shift and Operator assigned to it.

Supports Versioning';
comment on column SHFT_SHIFT_OPERATOR.ID is 'Unique ID generated from sequence +SHFT_SHIFT_OPERATOR_SQ_ID+';
comment on column SHFT_SHIFT_OPERATOR.SHIFT_ID is 'System ID of the Shift, refers +SHFT_SHIFT.ID+';
comment on column SHFT_SHIFT_OPERATOR.OPERATOR_ID is 'System ID of the Operator, refers +SHFT_OPERATOR.ID+';
comment on column SHFT_SHIFT_OPERATOR.STATUS is 'Status of the link. Possible values are:

1 = Assigned - Operator is assigned to Shift

10 = Canceled - Operator assignment is Canceled.

See Dictionary #10';
comment on column SHFT_SHIFT_OPERATOR.USER_ID is 'User ID - who is responsible for this Step';
comment on column SHFT_SHIFT_OPERATOR.USERNAME is 'User Name - who is responsible for this Step';
comment on column SHFT_SHIFT_OPERATOR.PERSONNAME is 'Person Name - who is responsible for this Step';
comment on column SHFT_SHIFT_OPERATOR.DSC is 'Arbitrary Comment';
comment on column SHFT_SHIFT_OPERATOR.FD is 'Validity period start';
comment on column SHFT_SHIFT_OPERATOR.TD is 'Validity period end';
comment on column SHFT_SHIFT_OPERATOR.IF_STABLE is 'Indicates whether THIS Assignment is STABLE in terms that it should survive rolling back Automated Assignments and stay on the scene when Candidate Assignments are done during Automated Assignment process.
  
1 = STABLE

0 = Not STABLE';


-- Indices  
create index SHFT_SHIFT_OPERATOR_I_OPID on SHFT_SHIFT_OPERATOR (OPERATOR_ID);
create index SHFT_SHIFT_OPERATOR_I_SHID on SHFT_SHIFT_OPERATOR (SHIFT_ID);

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

-----------------------------------------------
-- Assignment action Log
-----------------------------------------------

create sequence SHFT_SHIFT_ASSGNLOG_SQ_ID minvalue 1 start with 1 increment by 1;

create table SHFT_SHIFT_ASSGNLOG
(
  ID                 NUMBER,
  PROC_ID            NUMBER,
  SHIFT_ID           NUMBER,
  SHIFT_START_HOUR   DATE,
  SHIFT_CAPACITY     NUMBER,
  ASSIGNED_OPERATORS NUMBER,
  OPERATOR_ID        NUMBER,
  OPERATOR_ASSIGN_ID NUMBER,
  SEQ                NUMBER,
  ACTION_DATE        DATE,
  ACTION_RESULT      VARCHAR2(512),
  DUMPSEQ            NUMBER,
  PHASE              NUMBER, 
  CONSTRAINT SHFT_SHIFT_ASSGNLOG_pk_ID PRIMARY KEY(ID)
);

comment on table SHFT_SHIFT_ASSGNLOG is 'Keeps Log of the updates of SHFT_SHIFT.ASSIGNED_OPERATORS during calculation';
comment on column SHFT_SHIFT_ASSGNLOG.ID is 'Uniques ID for record, generated from sequence +SHFT_SHIFT_ASSGNLOG_SQ_ID+';
comment on column SHFT_SHIFT_ASSGNLOG.PROC_ID is 'Shiift Generation Procedure System ID, references +SHFT_SHIFT_PROC.ID+';
comment on column SHFT_SHIFT_ASSGNLOG.SHIFT_ID is 'Shift System ID, references +SHFT_SHIFT.ID+ of the Shift in behalf of whose update this Log record is generated';
comment on column SHFT_SHIFT_ASSGNLOG.SHIFT_START_HOUR is 'same as +SHFT_SHIFT.SHIFT_START_HOUR+';
comment on column SHFT_SHIFT_ASSGNLOG.SHIFT_CAPACITY is 'same as +SHFT_SHIFT.SHIFT_CAPACITY+';
comment on column SHFT_SHIFT_ASSGNLOG.ASSIGNED_OPERATORS is 'New value of the +SHFT_SHIFT.ASSIGNED_OPERATORS+ after update';
comment on column SHFT_SHIFT_ASSGNLOG.OPERATOR_ID is 'System ID of the Operator whose assignment to this Shift led to the update of the +SHFT_SHIFT.ASSIGNED_OPERATORS+. References +SHFT_OPERATOR.ID+';
comment on column SHFT_SHIFT_ASSGNLOG.OPERATOR_ASSIGN_ID is 'System ID of the Operator-Shift link which fixes Operator assignment to this Shift. References +SHFT_SHIFT_OPERATOR.ID+';
comment on column SHFT_SHIFT_ASSGNLOG.SEQ is 'Calculation Sequence Log which has common source (generated from the same Sequence) for:

+SHFT_SHIFT_ASSGNLOG.SEQ+, +SHFT_SHIFT_FAILEDRULELOG.SEQ+.

Generated from the Sequence: +SHFT_SHIFT_CALCLOG_SQ_ID+';

-- Indices
create unique index SHFT_SHIFT_ASSGNLOG_I_SEQ on SHFT_SHIFT_ASSGNLOG(SEQ);


-----------------------------------------------
-- Re-Assignment action Log
-----------------------------------------------

create sequence SHFT_SHIFT_REASSGNLOG_SQ_ID minvalue 1 start with 1 increment by 1;

create table SHFT_SHIFT_REASSGNLOG
(
  ID                   NUMBER,
  PROC_ID              NUMBER,
  SHIFT_RCPNT_ID       NUMBER,
  SHIFT_DONOR_ID       NUMBER,
  OPERATOR_ID          NUMBER,
  DAY2PROC             DATE,
  SHIFT_START_HOUR     DATE,
  SHIFT_DONOR_CAPACITY NUMBER,
  SHIFT_DONOR_ASSGN    NUMBER,
  SHIFT_RCPNT_CAPACITY NUMBER,
  SHIFT_RCPNT_ASSGN    NUMBER,
  CHECK_IF_OK          NUMBER,
  CHECK_SOURCE         NUMBER,
  CHECK_TYPE           NUMBER,
  CHECK_SOURCE_ID      NUMBER,
  DUMPSEQ              NUMBER,
  SEQ                  NUMBER,
  ACTION_DATE          DATE, 
  CONSTRAINT SHFT_SHIFT_REASSGNLOG_pk_ID PRIMARY KEY(ID)
);


-- Indices
create unique index SHFT_SHIFT_REASSGNLOG_I_SEQ on SHFT_SHIFT_REASSGNLOG(SEQ);

