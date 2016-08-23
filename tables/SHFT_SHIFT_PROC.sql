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


