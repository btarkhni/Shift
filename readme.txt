To launch the Code do following Steps: 

1) Create any schema in Oracle
2) apply (Command line mode) Shift_Tables.sql
   Result: all required Project tables are created
3) apply (Command line mode) Shift_Sequences.sql
   Result: all required Project sequences are created
4) apply (Command line mode) Shift_Packages.sql
   Result: all required Project PLSQL packages are created (both interface and body).
5) apply tables_inserts.sql
   Result: Lookup-like tables (stable data) are populated
6) apply tables_export.sql
   Result: several previous Shift Procedures related data are populated
7) launch the code indicated in the launch_code.sql
   Result: may be checked by the SELCT statements indicated in the end of the launch_code.sql

