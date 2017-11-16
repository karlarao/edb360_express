-- requested by matthew.d.walden
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&common_edb360_prefix._&&section_id._&&report_sequence._report_auto_tuning_task' one_spool_filename FROM DUAL;
SET PAGES 0;
SPO &&one_spool_filename..txt
SELECT DBMS_SQLTUNE.REPORT_AUTO_TUNING_TASK FROM DUAL;
SPO OFF
SET PAGES &&def_max_rows.; 
HOS zip -m &&edb360_zip_filename. &&one_spool_filename..txt >> &&edb360_log3..txt
-- update main report
SPO &&edb360_main_report..html APP;
PRO <li title="DBMS_SQLTUNE.REPORT_AUTO_TUNING_TASK">Report Auto Tuning Task
PRO <a href="&&one_spool_filename..txt">txt</a>
PRO </li>
SPO OFF;
HOS zip &&edb360_zip_filename. &&edb360_main_report..html >> &&edb360_log3..txt
-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;
