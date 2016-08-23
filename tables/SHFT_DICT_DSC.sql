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

