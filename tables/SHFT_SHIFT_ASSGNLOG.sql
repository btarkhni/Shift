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


