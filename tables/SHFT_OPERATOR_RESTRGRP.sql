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


