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


