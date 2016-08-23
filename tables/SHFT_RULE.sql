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

