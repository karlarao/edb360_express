@@&&edb360_0g.tkprof.sql
DEF section_id = '2b';
DEF section_name = 'Storage';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Tablespace';
DEF main_table = '&&v_view_prefix.TABLESPACE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.tablespace
 ORDER BY
       ts#
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tablespaces';
DEF main_table = '&&dva_view_prefix.TABLESPACES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.tablespaces
 ORDER BY
       tablespace_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tablespace Groups';
DEF main_table = '&&dva_view_prefix.TABLESPACE_GROUPS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.tablespace_groups
 ORDER BY
       group_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Default Tablespace Use';
DEF main_table = '&&dva_view_prefix.USERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       default_tablespace, COUNT(*)
  FROM &&dva_object_prefix.users
 GROUP BY
       default_tablespace
 ORDER BY
       default_tablespace
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Temporary Tablespace Use';
DEF main_table = '&&dva_view_prefix.USERS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       temporary_tablespace, COUNT(*)
  FROM &&dva_object_prefix.users
 GROUP BY
       temporary_tablespace
 ORDER BY
       temporary_tablespace
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'UNDO Stat';
DEF main_table = '&&gv_view_prefix.UNDOSTAT';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&gv_object_prefix.undostat
]';
END;
/
@@edb360_9a_pre_one.sql


DEF title = 'Tablespace Usage';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
COL pct_used FOR 999990.0;
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
-- fixed by Rodigo Righetti
WITH
files AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       tablespace_name,
       SUM(DECODE(autoextensible, 'YES', maxbytes, bytes)) / POWER(10,9) Max_size_gb,
       SUM( bytes) / POWER(10,9) Size_gb
  FROM &&dva_object_prefix.data_files
 GROUP BY
       tablespace_name
),
segments AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       tablespace_name,
       SUM(bytes) / POWER(10,9) used_gb
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
 GROUP BY
       tablespace_name
),
tablespaces AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       files.tablespace_name,
       ROUND(files.size_gb, 1) size_gb,
       ROUND(segments.used_gb, 1) used_gb,
       ROUND(100 * segments.used_gb / files.size_gb, 1) pct_used,
       ROUND(files.max_size_gb, 1) max_size_gb
  FROM files,
       segments
 WHERE files.size_gb > 0
   AND files.tablespace_name = segments.tablespace_name(+)
 ORDER BY
       files.tablespace_name
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       'Total' tablespace_name,
       SUM(size_gb) size_gb,
       SUM(used_gb) used_gb,
       ROUND(100 * SUM(used_gb) / SUM(size_gb), 1) pct_used,
       sum(max_size_gb) max_size_gb
  FROM tablespaces
)
SELECT tablespace_name,
       size_gb,
       used_gb,
       pct_used,
       max_size_gb
  FROM tablespaces
 UNION ALL
SELECT tablespace_name,
       size_gb,
       used_gb,
       pct_used,
       max_size_gb
  FROM total
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Temp Tablespace Usage';
DEF main_table = '&&gv_view_prefix.TEMP_EXTENT_POOL';
BEGIN
  :sql_text := q'[
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
a.tablespace_name, round(A.AVAIL_SIZE_GB,1) AVAIL_SIZE_GB, 
round(B.TOT_GBBYTES_CACHED,1) TOT_GBBYTES_CACHED , 
round(B.TOT_GBBYTES_USED,1) TOT_GBBYTES_USED,
ROUND(100*(B.TOT_GBBYTES_CACHED/A.AVAIL_SIZE_GB),1) PERC_CACHED,
ROUND(100*(B.TOT_GBBYTES_USED/A.AVAIL_SIZE_GB),1) PERC_USED
FROM
(select  tablespace_name,sum(bytes)/POWER(10,9) AVAIL_SIZE_GB
from &&dva_object_prefix.temp_files
group by tablespace_name) A,
(SELECT tablespace_name, 
SUM(BYTES_CACHED)/POWER(10,9) TOT_GBBYTES_CACHED, 
SUM(BYTES_USED)/POWER(10,9) TOT_GBBYTES_USED
FROM &&gv_object_prefix.temp_extent_pool
GROUP BY  TABLESPACE_NAME) B
where a.tablespace_name=b.tablespace_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tablespace Quotas';
DEF main_table = '&&dva_view_prefix.TS_QUOTAS';
BEGIN
  :sql_text := q'[
-- by berx
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ * from &&dva_object_prefix.ts_quotas
WHERE username NOT IN &&exclusion_list.
and username not in &&exclusion_list2.
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Datafile';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.datafile
 ORDER BY
       file#
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Data Files';
DEF main_table = '&&dva_view_prefix.DATA_FILES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.data_files
 ORDER BY
       file_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Data Files Usage';
DEF main_table = '&&dva_view_prefix.DATA_FILES';
COL pct_used FOR 999990.0;
COL pct_free FOR 999990.0;
BEGIN
  :sql_text := q'[
WITH
alloc AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       tablespace_name,
       COUNT(*) datafiles,
       ROUND(SUM(bytes)/POWER(10,9)) gb
  FROM &&dva_object_prefix.data_files
 GROUP BY
       tablespace_name
),
free AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       tablespace_name,
       ROUND(SUM(bytes)/POWER(10,9)) gb
  FROM &&dva_object_prefix.free_space
 GROUP BY
       tablespace_name
),
tablespaces AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       a.tablespace_name,
       a.datafiles,
       a.gb alloc_gb,
       (a.gb - f.gb) used_gb,
       f.gb free_gb
  FROM alloc a, free f
 WHERE a.tablespace_name = f.tablespace_name
 ORDER BY
       a.tablespace_name
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       SUM(alloc_gb) alloc_gb,
       SUM(used_gb) used_gb,
       SUM(free_gb) free_gb
  FROM tablespaces
)
SELECT v.tablespace_name,
       v.datafiles,
       v.alloc_gb,
       v.used_gb,
       CASE WHEN v.alloc_gb > 0 THEN
       LPAD(TRIM(TO_CHAR(ROUND(100 * v.used_gb / v.alloc_gb, 1), '990.0')), 8)
       END pct_used,
       v.free_gb,
       CASE WHEN v.alloc_gb > 0 THEN
       LPAD(TRIM(TO_CHAR(ROUND(100 * v.free_gb / v.alloc_gb, 1), '990.0')), 8)
       END pct_free
  FROM (
SELECT tablespace_name,
       datafiles,
       alloc_gb,
       used_gb,
       free_gb
  FROM tablespaces
 UNION ALL
SELECT 'Total' tablespace_name,
       TO_NUMBER(NULL) datafiles,
       alloc_gb,
       used_gb,
       free_gb
  FROM total
) v
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tempfile';
DEF main_table = '&&v_view_prefix.TEMPFILE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.tempfile
 ORDER BY
       file#
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Temp Files';
DEF main_table = '&&dva_view_prefix.TEMP_FILES';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.temp_files
 ORDER BY
       file_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'I/O Statistics for DB Files';
DEF main_table = '&&v_view_prefix.IOSTAT_FILE';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.iostat_file
 ORDER BY
       1
]';
END;
/
@@&&skip_10g_script.edb360_9a_pre_one.sql

DEF title = 'Kernel I/O taking long';
DEF main_table = '&&v_view_prefix.KERNEL_IO_OUTLIER';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.kernel_io_outlier
 ORDER BY
       1
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'Log Writer I/O taking long';
DEF main_table = '&&v_view_prefix.LGWRIO_OUTLIER';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.lgwrio_outlier
 ORDER BY
       1
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'I/O taking long';
DEF main_table = '&&v_view_prefix.IO_OUTLIER';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&v_object_prefix.io_outlier
 ORDER BY
       1
]';
END;
/
@@&&skip_10g_script.&&skip_11g_script.edb360_9a_pre_one.sql

DEF title = 'SYSAUX Occupants';
DEF main_table = '&&v_view_prefix.SYSAUX_OCCUPANTS';
BEGIN
  :sql_text := q'[
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       v.*, ROUND(v.space_usage_kbytes / POWER(10,6), 3) space_usage_gbs
  FROM &&v_object_prefix.sysaux_occupants v
 ORDER BY 1
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Database Growth per Month';
DEF main_table = '&&v_view_prefix.DATAFILE';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       TO_CHAR(creation_time, 'YYYY-MM') creation_month,
       ROUND(SUM(bytes)/POWER(10,6)) mb_growth,
       ROUND(SUM(bytes)/POWER(10,9)) gb_growth,
       ROUND(SUM(bytes)/POWER(10,12), 1) tb_growth
  FROM &&v_object_prefix.datafile
 GROUP BY
       TO_CHAR(creation_time, 'YYYY-MM')
 ORDER BY
       TO_CHAR(creation_time, 'YYYY-MM')
]';
END;
/
@@edb360_9a_pre_one.sql
    
DEF title = 'Largest 200 Objects';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
COL gb FOR 999990.000;
BEGIN
  :sql_text := q'[
WITH schema_object AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       segment_type,
       owner,
       segment_name,
       tablespace_name,
       COUNT(*) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
 GROUP BY
       segment_type,
       owner,
       segment_name,
       tablespace_name
), totals AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes
  FROM schema_object
), top_200_pre AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       ROWNUM rank, v1.*
       FROM (
SELECT so.segment_type,
       so.owner,
       so.segment_name,
       so.tablespace_name,
       so.segments,
       so.extents,
       so.blocks,
       so.bytes,
       ROUND((so.segments / t.segments) * 100, 3) segments_perc,
       ROUND((so.extents / t.extents) * 100, 3) extents_perc,
       ROUND((so.blocks / t.blocks) * 100, 3) blocks_perc,
       ROUND((so.bytes / t.bytes) * 100, 3) bytes_perc
  FROM schema_object so,
       totals t
 ORDER BY
       bytes_perc DESC NULLS LAST
) v1
 WHERE ROWNUM < 201
), top_200 AS (
SELECT p.*,
       (SELECT object_id
          FROM &&dva_object_prefix.objects o
         WHERE o.object_type = p.segment_type
           AND o.owner = p.owner
           AND o.object_name = p.segment_name
           AND o.object_type NOT LIKE '%PARTITION%') object_id,
       (SELECT data_object_id
          FROM &&dva_object_prefix.objects o
         WHERE o.object_type = p.segment_type
           AND o.owner = p.owner
           AND o.object_name = p.segment_name
           AND o.object_type NOT LIKE '%PARTITION%') data_object_id,
       (SELECT SUM(p2.bytes_perc) FROM top_200_pre p2 WHERE p2.rank <= p.rank) bytes_perc_cum
  FROM top_200_pre p
), top_200_totals AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes,
       SUM(segments_perc) segments_perc,
       SUM(extents_perc) extents_perc,
       SUM(blocks_perc) blocks_perc,
       SUM(bytes_perc) bytes_perc
  FROM top_200
), top_100_totals AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes,
       SUM(segments_perc) segments_perc,
       SUM(extents_perc) extents_perc,
       SUM(blocks_perc) blocks_perc,
       SUM(bytes_perc) bytes_perc
  FROM top_200
 WHERE rank < 101
), top_20_totals AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes,
       SUM(segments_perc) segments_perc,
       SUM(extents_perc) extents_perc,
       SUM(blocks_perc) blocks_perc,
       SUM(bytes_perc) bytes_perc
  FROM top_200
 WHERE rank < 21
)
SELECT v.rank,
       v.segment_type,
       v.owner,
       v.segment_name,
       v.object_id,
       v.data_object_id,
       v.tablespace_name,
       CASE
       WHEN v.segment_type LIKE 'INDEX%' THEN
         (SELECT i.table_name
            FROM &&dva_object_prefix.indexes i
           WHERE i.owner = v.owner AND i.index_name = v.segment_name)       
       WHEN v.segment_type LIKE 'LOB%' THEN
         (SELECT l.table_name
            FROM &&dva_object_prefix.lobs l
           WHERE l.owner = v.owner AND l.segment_name = v.segment_name)
       END table_name,
       v.segments,
       v.extents,
       v.blocks,
       v.bytes,
       ROUND(v.bytes / POWER(10,9), 3) gb,
       LPAD(TO_CHAR(v.segments_perc, '990.000'), 7) segments_perc,
       LPAD(TO_CHAR(v.extents_perc, '990.000'), 7) extents_perc,
       LPAD(TO_CHAR(v.blocks_perc, '990.000'), 7) blocks_perc,
       LPAD(TO_CHAR(v.bytes_perc, '990.000'), 7) bytes_perc,
       LPAD(TO_CHAR(v.bytes_perc_cum, '990.000'), 7) perc_cum
  FROM (
SELECT d.rank,
       d.segment_type,
       d.owner,
       d.segment_name,
       d.object_id,
       d.data_object_id,
       d.tablespace_name,
       d.segments,
       d.extents,
       d.blocks,
       d.bytes,
       d.segments_perc,
       d.extents_perc,
       d.blocks_perc,
       d.bytes_perc,
       d.bytes_perc_cum
  FROM top_200 d
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       NULL segment_type,
       NULL owner,
       NULL segment_name,
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       'TOP  20' tablespace_name,
       st.segments,
       st.extents,
       st.blocks,
       st.bytes,
       st.segments_perc,
       st.extents_perc,
       st.blocks_perc,
       st.bytes_perc,
       TO_NUMBER(NULL) bytes_perc_cum
  FROM top_20_totals st
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       NULL segment_type,
       NULL owner,
       NULL segment_name,
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       'TOP 100' tablespace_name,
       st.segments,
       st.extents,
       st.blocks,
       st.bytes,
       st.segments_perc,
       st.extents_perc,
       st.blocks_perc,
       st.bytes_perc,
       TO_NUMBER(NULL) bytes_perc_cum
  FROM top_100_totals st
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       NULL segment_type,
       NULL owner,
       NULL segment_name,
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       'TOP 200' tablespace_name,
       st.segments,
       st.extents,
       st.blocks,
       st.bytes,
       st.segments_perc,
       st.extents_perc,
       st.blocks_perc,
       st.bytes_perc,
       TO_NUMBER(NULL) bytes_perc_cum
  FROM top_200_totals st
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       NULL segment_type,
       NULL owner,
       NULL segment_name,
       TO_NUMBER(NULL),
       TO_NUMBER(NULL),
       'TOTAL' tablespace_name,
       t.segments,
       t.extents,
       t.blocks,
       t.bytes,
       100 segemnts_perc,
       100 extents_perc,
       100 blocks_perc,
       100 bytes_perc,
       TO_NUMBER(NULL) bytes_perc_cum
  FROM totals t) v
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Tables with one extent and no rows';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by David Kurtz
SELECT  /* LEADING(T) USE_NL(S) */ -- removed hint as per Luis Calvo
        t.owner, t.table_name, t.tablespace_name, t.num_rows, t.blocks hwm_blocks, t.last_analyzed, s.blocks seg_blocks
FROM    &&dva_object_prefix.tables t
,       &&dva_object_prefix.segments s
WHERE   '&&edb360_conf_incl_segments.' = 'Y'
and     t.owner not in &&exclusion_list.
and     t.owner not in &&exclusion_list2.
and     s.segment_type = 'TABLE'
and     t.owner = s.owner
and     t.table_name = s.segment_name
and     t.tablespace_name = s.tablespace_name
and     s.partition_name IS NULL
and     t.segment_created = 'YES'
AND     (       t.num_rows = 0
        OR       t.num_rows IS NULL     
        )
and     s.extents =  1
ORDER BY 1,2
]';
END;
/
BRE ON REPORT;
COMP SUM LAB TOTAL OF hwm_blocks ON REPORT;
COMP SUM LAB TOTAL OF seg_blocks ON REPORT;
@@&&skip_10g_script.edb360_9a_pre_one.sql
CL BRE;
CL COMP;

DEF title = 'Partitions with one extent and no rows';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by David Kurtz
SELECT  /* LEADING(T) USE_NL(S) */ -- removed hint as per Luis Calvo
        t.table_owner, t.table_name, t.partition_name, t.tablespace_name, t.num_rows, t.blocks hwm_blocks, t.last_analyzed, s.blocks seg_blocks
FROM    &&dva_object_prefix.tab_partitions t
,       &&dva_object_prefix.segments s
WHERE   '&&edb360_conf_incl_segments.' = 'Y'
and     t.table_owner not in &&exclusion_list.
and     t.table_owner not in &&exclusion_list2.
and     s.segment_type = 'TABLE PARTITION'
and     t.table_owner = s.owner
and     t.table_name = s.segment_name
and     t.tablespace_name = s.tablespace_name
and     t.partition_name = s.partition_name
and     t.segment_created = 'YES'
AND     (       t.num_rows = 0
        OR       t.num_rows IS NULL     
        )
and     s.extents =  1
ORDER BY 1,2,3
]';
END;
/
BRE ON REPORT;
COMP SUM LAB TOTAL OF hwm_blocks ON REPORT;
COMP SUM LAB TOTAL OF seg_blocks ON REPORT;
@@&&skip_10g_script.edb360_9a_pre_one.sql
CL BRE;
CL COMP;

DEF title = 'Subpartitions with one extent and no rows';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- requested by David Kurtz
SELECT  /* LEADING(T) USE_NL(S) */ -- removed hint as per Luis Calvo
        t.table_owner, t.table_name, t.partition_name, t.subpartition_name, t.tablespace_name, t.num_rows, t.blocks hwm_blocks, t.last_analyzed, s.blocks seg_blocks
FROM    &&dva_object_prefix.tab_subpartitions t
,       &&dva_object_prefix.segments s
WHERE   '&&edb360_conf_incl_segments.' = 'Y'
and     t.table_owner not in &&exclusion_list.
and     t.table_owner not in &&exclusion_list2.
and     s.segment_type = 'TABLE SUBPARTITION'
and     t.table_owner = s.owner
and     t.table_name = s.segment_name
and     t.subpartition_name = s.partition_name
and     t.tablespace_name = s.tablespace_name
and     t.segment_created = 'YES'
AND     (       t.num_rows = 0
        OR       t.num_rows IS NULL     
        )
and     s.extents =  1
ORDER BY 1,2,3,4
]';
END;
/
BRE ON REPORT;
COMP SUM LAB TOTAL OF hwm_blocks ON REPORT;
COMP SUM LAB TOTAL OF seg_blocks ON REPORT;
@@&&skip_10g_script.edb360_9a_pre_one.sql
CL BRE;
CL COMP;

DEF title = 'Tables and their indexes larger than 1 GB';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
COL gb FOR 999990.000;
BEGIN
  :sql_text := q'[
WITH
tables AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       segment_name,
       SUM(bytes) bytes,
       COUNT(*) segments
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND segment_type LIKE 'TABLE%'
GROUP BY
       owner,
       segment_name
),
indexes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       segment_name,
       SUM(bytes) bytes,
       COUNT(*) segments
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND segment_type LIKE 'INDEX%'
GROUP BY
       owner,
       segment_name
),
idx_tbl AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       d.table_owner,
       d.table_name,
       SUM(i.bytes) bytes,
       SUM(i.segments) segments
  FROM indexes i,
       &&dva_object_prefix.indexes d
WHERE i.owner = d.owner
  AND i.segment_name = d.index_name
GROUP BY
       d.table_owner,
       d.table_name
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       t.owner,
       t.segment_name table_name,
       (t.bytes + NVL(i.bytes, 0)) bytes,
       t.bytes table_bytes,
       NVL(i.bytes, 0) indexes_bytes,
       (t.segments + NVL(i.segments, 0)) segs,
       t.segments tab_segs,
       NVL(i.segments, 0) idx_segs
  FROM tables t,
       idx_tbl i
WHERE t.owner = i.table_owner(+)
   AND t.segment_name = i.table_name(+)
)
SELECT owner,
       table_name,
       ROUND(bytes / POWER(10,9), 3) total_gb,
       ROUND(table_bytes / POWER(10,9), 3) table_gb,
       ROUND(indexes_bytes / POWER(10,9), 3) indexes_gb,
       segs,
       tab_segs,
       idx_segs
  FROM total
WHERE bytes > POWER(10,9)
ORDER BY
       bytes DESC NULLS LAST
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Indexes larger than their Table';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
COL gb FOR 999990.000;
BEGIN
  :sql_text := q'[
WITH
tables AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       segment_name,
       SUM(bytes) bytes
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND segment_type LIKE 'TABLE%'
GROUP BY
       owner,
       segment_name
),
indexes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       owner,
       segment_name,
       SUM(bytes) bytes
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND segment_type LIKE 'INDEX%'
GROUP BY
       owner,
       segment_name
),
idx_tbl AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       d.table_owner,
       d.table_name,
       d.owner,
       d.index_name,
       SUM(i.bytes) bytes
  FROM indexes i,
       &&dva_object_prefix.indexes d
WHERE i.owner = d.owner
   AND i.segment_name = d.index_name
GROUP BY
       d.table_owner,
       d.table_name,
       d.owner,
       d.index_name
),
total AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       t.owner table_owner,
       t.segment_name table_name,
       t.bytes t_bytes,
       i.owner index_owner,
       i.index_name,
       i.bytes i_bytes
  FROM tables t,
       idx_tbl i
WHERE t.owner = i.table_owner
   AND t.segment_name = i.table_name
   AND i.bytes > t.bytes
   AND t.bytes > POWER(10,7) /* 10M */
)
SELECT table_owner,
       table_name,
       ROUND(t_bytes / POWER(10,9), 3) table_gb,
       index_owner,
       index_name,
       ROUND(i_bytes / POWER(10,9), 3) index_gb,
       ROUND((i_bytes - t_bytes) / POWER(10,9), 3) dif_gb,
       ROUND(100 * (i_bytes - t_bytes) / t_bytes, 1) dif_perc
  FROM total
ORDER BY
      table_owner,
       table_name,
       index_owner,
       index_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Candidate Tables for Partitioning';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
   owner, table_name, blocks, block_size, 
   round(blocks * block_size / POWER(10,6)) mb, 
   num_rows, avg_row_len, degree, sample_size, last_analyzed
from 
   &&dva_object_prefix.tables, 
   &&dva_object_prefix.tablespaces
where
   &&dva_object_prefix.tablespaces.tablespace_name = &&dva_object_prefix.tables.tablespace_name and
   (blocks * block_size / POWER(10,6)) >= POWER(10,3) and
   partitioned = 'NO' and
   owner not in &&exclusion_list. and
   owner not in &&exclusion_list2.
order by owner, (blocks * block_size / POWER(10,6)) desc
]';
END;
/
--@@edb360_9a_pre_one.sql (redundant with "Largest 200 Objects")

DEF title = 'Temporary Segments in Permanent Tablespaces';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- http://askdba.org/weblog/2009/07/cleanup-temporary-segments-in-permanent-tablespace/
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
tablespace_name, owner, segment_name,
round(sum(bytes/POWER(10,6))) mega_bytes 
from &&dva_object_prefix.segments
where '&&edb360_conf_incl_segments.' = 'Y'
and segment_type = 'TEMPORARY' 
group by tablespace_name, owner, segment_name
having round(sum(bytes/POWER(10,6))) > 0
order by tablespace_name, owner, segment_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Segments in Reserved Tablespaces';
DEF main_table = '&&dva_view_prefix.SEGMENTS';
BEGIN
  :sql_text := q'[
-- provided by Simon Pane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       s.owner, s.segment_type, s.tablespace_name, COUNT(1) segments
  FROM &&dva_object_prefix.segments s
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND s.owner NOT IN ('SYS','SYSTEM','OUTLN','AURORA$JIS$UTILITY$','OSE$HTTP$ADMIN','ORACACHE','ORDSYS',
                       'CTXSYS','DBSNMP','DMSYS','EXFSYS','MDSYS','OLAPSYS','SYSMAN','TSMSYS','WMSYS','XDB')
   AND s.tablespace_name IN ('SYSTEM','SYSAUX','TEMP','TEMPORARY','RBS','ROLLBACK','ROLLBACKS','RBSEGS')
   AND s.tablespace_name NOT IN (SELECT tablespace_name
                                   FROM &&dva_object_prefix.tablespaces
                                  WHERE contents IN ('UNDO','TEMPORARY')
                                )
and s.owner not in &&exclusion_list.
and s.owner not in &&exclusion_list2.
 GROUP BY s.owner, s.segment_type, s.tablespace_name
 ORDER BY 1,2,3
]';
END;
/
BRE ON REPORT;
COMP SUM LAB TOTAL OF segments ON REPORT;
@@edb360_9a_pre_one.sql
CL BRE;
CL COMP;

DEF title = 'Segment Shrink Recommendations';
DEF main_table = 'DBMS_SPACE';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
       *
FROM TABLE(dbms_space.asa_recommendations())
Where segment_owner not in &&exclusion_list. and
   segment_owner not in &&exclusion_list2.
order by reclaimable_space desc
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Objects in Recycle Bin';
DEF main_table = '&&dva_view_prefix.RECYCLEBIN';
BEGIN
  :sql_text := q'[
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM &&dva_object_prefix.recyclebin
 WHERE owner NOT IN &&exclusion_list.
   AND owner NOT IN &&exclusion_list2.
 ORDER BY
       owner,
       object_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Consumers of Recycle Bin';
DEF main_table = '&&dva_view_prefix.RECYCLEBIN';
BEGIN
  :sql_text := q'[
-- requested by Dimas Chbane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       ROUND(SUM(r.space * t.block_size) / POWER(10,6)) mb_space,
       r.owner
  FROM &&dva_object_prefix.recyclebin r,
       &&dva_object_prefix.tablespaces t
 WHERE r.ts_name = t.tablespace_name
 GROUP BY
       r.owner
HAVING ROUND(SUM(r.space * t.block_size) / POWER(10,6)) > 0
 ORDER BY
       1 DESC, 2
]';
END;
/
@@edb360_9a_pre_one.sql
   
DEF title = 'Tables with excessive wasted space';
DEF main_table = '&&dva_view_prefix.TABLES';
BEGIN
  :sql_text := q'[
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ 
   (round(blocks * block_size / POWER(10,6))) - 
      (round(num_rows * avg_row_len * (1+(pct_free/100)) * decode (compression,'ENABLED',0.50,1.00) / POWER(10,6))) over_allocated_mb,
   owner, table_name, blocks, block_size, pct_free,
   round(blocks * block_size / POWER(10,6)) actual_mb,
   round(num_rows * avg_row_len * (1+(pct_free/100)) * decode (compression,'ENABLED',0.50,1.00) / POWER(10,6)) estimate_mb,
   num_rows, avg_row_len, degree, compression, sample_size, to_char(last_analyzed,'MM/DD/RRRR') last_analyzed
from
   &&dva_object_prefix.tables,
   &&dva_object_prefix.tablespaces
where
   &&dva_object_prefix.tablespaces.tablespace_name = &&dva_object_prefix.tables.tablespace_name and
   (blocks * block_size / POWER(10,6)) >= 100 and -- actual_mb 
   abs(round(blocks * block_size / POWER(10,6)) - round(num_rows * avg_row_len * (1+(pct_free/100)) * decode (compression,'ENABLED',0.50,1.00) / POWER(10,6))) / 
      (round(blocks * block_size / POWER(10,6))) >= 0.25 and
   owner not in &&exclusion_list. and
   owner not in &&exclusion_list2.
order by 
   1 desc,
   owner, table_name
]';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Indexes with actual size greater than estimated';
DEF abstract = 'Actual and Estimated sizes for Indexes.<br />';
DEF main_table = '&&dva_view_prefix.INDEXES';
VAR random1 VARCHAR2(30);
VAR random2 VARCHAR2(30);
EXEC :random1 := DBMS_RANDOM.string('A', 30);
EXEC :random2 := DBMS_RANDOM.string('X', 30);
COL random1 NEW_V random1 FOR A30;
COL random2 NEW_V random2 FOR A30;
SELECT :random1 random1, :random2 random2 FROM DUAL;
DELETE plan_table WHERE statement_id IN (:random1, :random2);
SET SERVEROUT ON;
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
-- log
SPO &&edb360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO &&title.
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
DECLARE
  sql_text CLOB;
BEGIN
  IF '&&edb360_conf_incl_metadata.' = 'Y' /*AND '&&db_version.' < '11.2.0.3'*/ AND '&&db_version.' >= '11.2.0.4' THEN -- avoids DBMS_METADATA.GET_DDL: Query Against SYS.KU$_INDEX_VIEW Is Slow In 11.2.0.3 as per 1459841.1
    FOR i IN (SELECT idx.owner, idx.index_name
                FROM &&dva_object_prefix.indexes idx,
                     &&dva_object_prefix.tables tbl
               WHERE idx.owner NOT IN &&exclusion_list. -- exclude non-application schemas
                 AND idx.owner NOT IN &&exclusion_list2. -- exclude more non-application schemas
                 AND idx.index_type IN ('NORMAL', 'FUNCTION-BASED NORMAL', 'BITMAP', 'NORMAL/REV') -- exclude domain and lob
                 AND idx.status != 'UNUSABLE' -- only valid indexes
                 AND idx.temporary = 'N'
                 AND tbl.owner = idx.table_owner
                 AND tbl.table_name = idx.table_name
                 AND tbl.last_analyzed IS NOT NULL -- only tables with statistics
                 AND tbl.num_rows > 0 -- only tables with rows as per statistics
                 AND tbl.blocks > 128 -- skip small tables
                 AND tbl.temporary = 'N')
    LOOP
      BEGIN
        sql_text :=  'EXPLAIN PLAN SET STATEMENT_ID = '''||:random1||''' FOR '||REPLACE(DBMS_METADATA.get_ddl('INDEX', i.index_name, i.owner), CHR(10), ' ');
        -- cbo estimates index size based on explain plan for create index ddl
        EXECUTE IMMEDIATE sql_text;
        -- index owner and name do not fit on statement_id, thus using object_owner and object_name, using statement_id as processing state
        DELETE plan_table WHERE statement_id = :random1 AND (other_xml IS NULL OR NVL(DBMS_LOB.instr(other_xml, 'index_size'), 0) = 0);
        UPDATE plan_table SET object_owner = i.owner, object_name = i.index_name, statement_id = :random2 WHERE statement_id = :random1;
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE(i.owner||'.'||i.index_name||': '||SQLERRM);
          DBMS_OUTPUT.PUT_LINE(DBMS_LOB.substr(sql_text));
      END;
    END LOOP;
  ELSE
    DBMS_OUTPUT.PUT_LINE('*** skip on &&db_version. as per MOS 1459841.1');
  END IF;
END;
/
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
SPO OFF;
SET SERVEROUT OFF;

BEGIN
  :sql_text := q'[
-- from estimate_index_size.sql
-- http://carlos-sierra.net/2014/07/18/free-script-to-very-quickly-and-cheaply-estimate-the-size-of-an-index-if-it-were-to-be-rebuilt/
WITH 
indexes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       pt.object_owner, 
       pt.object_name,
       TO_NUMBER(EXTRACTVALUE(VALUE(d), '/info')) estimated_bytes
  FROM plan_table pt,
       TABLE(XMLSEQUENCE(EXTRACT(XMLTYPE(pt.other_xml), '/other_xml/info'))) d
 WHERE pt.statement_id = '&&random2.'
   AND pt.other_xml IS NOT NULL -- redundant
   AND DBMS_LOB.instr(pt.other_xml, 'index_size') > 0 -- redundant
   AND EXTRACTVALUE(VALUE(d), '/info/@type') = 'index_size' -- grab index_size type
),
segments AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       owner, segment_name, SUM(bytes) actual_bytes
  FROM &&dva_object_prefix.segments
 WHERE '&&edb360_conf_incl_segments.' = 'Y'
   AND owner NOT IN &&exclusion_list. -- exclude non-application schemas
   AND owner NOT IN &&exclusion_list2. -- exclude more non-application schemas
   AND segment_type LIKE 'INDEX%'
HAVING SUM(bytes) > POWER(10,6) -- only indexes with actual size > 1 MB
 GROUP BY
       owner,
       segment_name
),
list_bytes AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       (s.actual_bytes - i.estimated_bytes) actual_minus_estimated,
       s.actual_bytes,
       i.estimated_bytes,
       i.object_owner,
       i.object_name
  FROM indexes i,
       segments s
 WHERE i.estimated_bytes > POWER(10,6) -- only indexes with estimated size > 1 MB
   AND s.owner(+) = i.object_owner
   AND s.segment_name(+) = i.object_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       ROUND(actual_minus_estimated / POWER(10,6)) actual_minus_estimated,
       ROUND(actual_bytes / POWER(10,6)) actual_mb,
       ROUND(estimated_bytes / POWER(10,6)) estimated_mb,
       object_owner owner,
       object_name index_name
  FROM list_bytes
 WHERE actual_minus_estimated > POWER(10,6) -- only differences > 1 MB
 ORDER BY
       1 DESC,
       object_owner,
       object_name
]';
END;
/
@@edb360_9a_pre_one.sql
DELETE plan_table WHERE statement_id IN (:random1, :random2);

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
