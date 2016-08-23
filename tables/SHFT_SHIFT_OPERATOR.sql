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

