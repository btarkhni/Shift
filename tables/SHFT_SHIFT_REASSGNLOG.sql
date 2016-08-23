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

