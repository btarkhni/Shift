-- drop tables
/* NOTE: after generation the statements, they are to be re-arranged to take into account referential integrity: 
         parent tables should be dropped AFTER child ones
select 'drop table ' || table_name || ';' 
       from user_tables 
       where table_name like 'SHFT%'
       order by table_name
**/
drop table SHFT_SHIFT_ASSGNLOG;
drop table SHFT_SHIFT_FAILEDRULELOG;
drop table SHFT_SHIFT_REASSGNLOG;
drop table SHFT_SHIFT_OPERATOR;
drop table SHFT_OPERATOR_EXC;
drop table SHFT_OPERATOR;
drop table SHFT_SHIFT_TYPE;
drop table SHFT_SHIFT;
drop table SHFT_SHIFT_PROC;
drop table SHFT_OPERATOR_RESTRGRP;
drop table SHFT_GROUP;
drop table SHFT_RULE;
drop table SHFT_DICT;
drop table SHFT_DICT_DSC;

-- drop sequences
/*
select 'drop sequence ' || sequence_name || ';' 
       from user_sequences
       where sequence_name like 'SHFT%'
       order by sequence_name       
**/
drop sequence SHFT_DICT_SQ_ID;
drop sequence SHFT_DUMP_SQ_ID;
drop sequence SHFT_OPERATOR_EXC_SQ_ID;
drop sequence SHFT_OPERATOR_SQ_ID;
drop sequence SHFT_SHIFT_ASSGNLOG_SQ_ID;
drop sequence SHFT_SHIFT_CALCLOG_SQ_ID;
drop sequence SHFT_SHIFT_FAILEDRULELOG_SQ_ID;
drop sequence SHFT_SHIFT_OPERATOR_SQ_ID;
drop sequence SHFT_SHIFT_PROC_SQ_ID;
drop sequence SHFT_SHIFT_REASSGNLOG_SQ_ID;
drop sequence SHFT_SHIFT_SQ_ID;
drop sequence SHFT_SHIFT_TYPE_SQ_ID;


-- drop packages
/*
select 'drop package ' || object_name || ';' 
       from user_objects
       where object_type = 'PACKAGE BODY'
             and object_name like 'PSHFT%'
       order by object_name
**/
drop package PSHFT_COMMONS1;
drop package PSHFT_DICTS;
drop package PSHFT_EXCLUSION;
drop package PSHFT_GENERATOR;
drop package PSHFT_OPERATOR;
drop package PSHFT_RULECLC;
