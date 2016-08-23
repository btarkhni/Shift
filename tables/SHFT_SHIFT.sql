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


