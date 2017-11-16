-- add seq to one_spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&spool_filename.' one_spool_filename FROM DUAL;

-- display
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SET TERM ON;
SPO &&edb360_log..txt APP;
PRO &&hh_mm_ss. &&section_id. "&&one_spool_filename._line_chart.html"
SPO OFF;
SET TERM OFF;

-- update main report
SPO &&edb360_main_report..html APP;
PRO <a href="&&one_spool_filename._line_chart.html">line</a>
SPO OFF;

-- get time t0
EXEC :get_time_t0 := DBMS_UTILITY.get_time;

-- header
SPO &&one_spool_filename._line_chart.html;
@@edb360_0d_html_header.sql
PRO <!-- &&one_spool_filename._line_chart.html $ -->

-- chart header
PRO    &&edb360_conf_google_charts.
PRO    <script type="text/javascript">
PRO      google.load("visualization", "1", {packages:["corechart"]});
PRO      google.setOnLoadCallback(drawChart);
PRO      function drawChart() {
PRO        var data = google.visualization.arrayToDataTable([

-- body
SET SERVEROUT ON;
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
DECLARE
  cur SYS_REFCURSOR;
  l_snap_id NUMBER;
  l_begin_time VARCHAR2(32);
  l_end_time VARCHAR2(32);
  l_col_01 NUMBER;
  l_col_02 NUMBER;
  l_line VARCHAR2(1000);
  l_sql_text VARCHAR2(32767);
BEGIN
  EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''&&edb360_date_format.''';
  l_line := '[''Date''';
  IF '&&tit_01.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_01.'''; 
  END IF;
  IF '&&tit_02.' IS NOT NULL THEN
    l_line := l_line||', ''&&tit_02.'''; 
  END IF;
  l_line := l_line||']';
  DBMS_OUTPUT.PUT_LINE(l_line);
  --OPEN cur FOR :sql_text;
  l_sql_text := DBMS_LOB.SUBSTR(:sql_text); -- needed for 10g
  OPEN cur FOR l_sql_text; -- needed for 10g
  LOOP
    FETCH cur INTO l_snap_id, l_begin_time, l_end_time,
    l_col_01, l_col_02;
    EXIT WHEN cur%NOTFOUND;
    IF l_col_01 IS NOT NULL AND l_col_02 IS NOT NULL THEN
      l_line := ', [new Date('||SUBSTR(l_end_time,1,4)||','||
      (TO_NUMBER(SUBSTR(l_end_time,6,2)) - 1)||','||
      SUBSTR(l_end_time,9,2)||','||
      SUBSTR(l_end_time,12,2)||','||
      SUBSTR(l_end_time,15,2)||','||
      NVL(SUBSTR(l_end_time,18,2),'0')||
      ')';
      IF '&&tit_01.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_01; 
      END IF;
      IF '&&tit_02.' IS NOT NULL THEN
        l_line := l_line||', '||l_col_02; 
      END IF;
      l_line := l_line||']';
      DBMS_OUTPUT.PUT_LINE(l_line);
    END IF;
  END LOOP;
  CLOSE cur;
END;
/
SET SERVEROUT OFF;

-- line chart footer
PRO        ]);;
PRO        
PRO        var options = {
PRO          chartArea:{left:120, top:80, width:'70%', height:'70%'},
PRO          backgroundColor: {fill: '#fcfcf0', stroke: '#336699', strokeWidth: 1},
PRO          explorer: {actions: ['dragToZoom', 'rightClickToReset'], maxZoomIn: 0.01},
PRO          series: { 0: {targetAxisIndex: 0}, 1: {targetAxisIndex: 1} },
PRO          vAxes: { 0: {title: '&&vaxis1.', titleTextStyle: {fontSize: 16, bold: false}}, 1: {title: '&&vaxis2.', titleTextStyle: {fontSize: 16, bold: false}}},
PRO          vAxes: { 0: {textStyle: {color: 'royalblue'}, title: '&&vaxis1.', titleTextStyle: {color: 'royalblue', fontSize: 16, bold: false}}, 
PRO                   1: {textStyle: {color: 'red'},       title: '&&vaxis2.', titleTextStyle: {color: 'red',       fontSize: 16, bold: false}}},
PRO          title: '&&section_id..&&report_sequence.. &&title.&&title_suffix.',
PRO          titleTextStyle: {fontSize: 18, bold: false},
PRO          focusTarget: 'category',
PRO          legend: {position: 'right', textStyle: {fontSize: 14}},
PRO          tooltip: {textStyle: {fontSize: 14}},
PRO          hAxis: {title: '&&haxis.', gridlines: {count: -1}, titleTextStyle: {fontSize: 16, bold: false}}
PRO        };
PRO
PRO        var chart = new google.visualization.&&chartype.(document.getElementById('linechart'));
PRO        chart.draw(data, options);
PRO      }
PRO    </script>
PRO  </head>
PRO  <body>
PRO
PRO<h1> &&edb360_conf_all_pages_icon. &&section_id..&&report_sequence.. &&title. <em>(&&main_table.)</em> &&edb360_conf_all_pages_logo. </h1>
PRO
PRO <br />
PRO &&abstract.
PRO &&abstract2.
PRO <br />
PRO
PRO    <div id="linechart" class="google-chart"></div>
PRO

-- footer
PRO <br />
PRO <font class="n">Notes:<br />1) drag to zoom, and right click to reset<br />2) up to &&history_days. days of awr history were considered</font>
PRO <font class="n"><br />3) &&foot.</font>
PRO <pre>
SET LIN 80;
DESC &&main_table.
SET HEA OFF;
SET LIN 32767;
PRINT sql_text_display;
SET HEA ON;
--PRO &&row_count. rows selected.
PRO &&row_num. rows selected.
PRO </pre>

@@edb360_0e_html_footer.sql
SPO OFF;

-- get time t1
EXEC :get_time_t1 := DBMS_UTILITY.get_time;

-- update log2
SET HEA OFF;
SPO &&edb360_log2..txt APP;
SELECT TO_CHAR(SYSDATE, '&&edb360_date_format.')||' , '||
       TO_CHAR((:get_time_t1 - :get_time_t0)/100, '999,999,990.00')||'s , rows:'||
       --:row_count||' , &&section_id., &&main_table., &&edb360_prev_sql_id., -1, &&title_no_spaces., html , &&one_spool_filename._line_chart.html'
       '&&row_num., &&section_id., &&main_table., &&edb360_prev_sql_id., -1, &&title_no_spaces., line , &&one_spool_filename._line_chart.html'
  FROM DUAL
/
SPO OFF;
SET HEA ON;

-- zip
HOS zip -m &&edb360_zip_filename. &&one_spool_filename._line_chart.html >> &&edb360_log3..txt
