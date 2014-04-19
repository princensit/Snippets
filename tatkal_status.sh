#!/bin/bash
# @author Prince Raj
# @since 2013-05-12
# @modified 2014-03-16

# add following two lines before outputting data to the web browser from shell script
echo "Content-type: text/html"
echo ""

query_string=`echo $QUERY_STRING`
saveIFS=$IFS
IFS='=&'
param=($query_string)
IFS=$saveIFS

declare -A array
for ((i=0; i<${#param[@]}; i+=2))
do
    array[${param[i]}]=${param[i+1]}
done

# initialize default values
day=`date -d '1 day' +%d`
month=`date +%m`
src="NDLS"
dest="KQR"
checked="none"
train_numbers="12802 12816 12876 12312 12382 12818 22812 22824"
user_agent="Chrome/26.0.1410.63"
other="lccp_class1=SL&lccp_quota=CK&submit=Please+Wait...&lccp_classopt=ZZ&lccp_class2=ZZ&lccp_class3=ZZ&lccp_class4=ZZ&lccp_class5=ZZ&lccp_class6=ZZ&lccp_class7=ZZ"

if [ -n "${array[day]}" ]; then
        day="${array[day]}"
fi

if [ -n "${array[src]}" ]; then
        src="${array[src]}"
fi

if [ -n "${array[dest]}" ]; then
        dest="${array[dest]}"
fi

if [ -n "${array[update]}" ]; then
    if [ "${array[update]}" == "on" ]; then
        checked="checked"
    fi
fi

echo "<HTML>"
echo "<HEAD><STYLE>"
echo "body {font-size:16px;}
label {float:left; padding-right:10px;}
.field {clear:both; text-align:right; line-height:25px;}
.main {float:left;}"
echo "</STYLE></HEAD>"
echo "<TITLE>Tatkal Status</TITLE>"
echo "<BODY>"

echo "Refer: <A HREF=http://www.stationcodes.com target="_blank">http://www.stationcodes.com</A> to know station code."
echo "<BR/><BR/>"
echo "<form action="">
    <div class="main">
        <div class="field">
            <label for="n">Day:</label>
            <input type="text" name="day" placeholder="Day" value="${day}">
        </div>
        <div class="field">
            <label for="ln">Month:</label>
            <input type="text" name="month" placeholder="Month" value="${month}">
        </div>
        <div class="field">
            <label for="a">Source:</label>
            <input type="text" name="src" placeholder="Station Code" value="${src}">
        </div>
        <div class="field">
            <label for="a">Destination:</label>
            <input type="text" name="dest" placeholder="Station Code" value="${dest}">
        </div>
        <div class="field">
            <label for="a">All trains?</label>
            <input type="checkbox" name="update" "${checked}">
        </div>
        <input style=\"clear:left; float: left; margin-top:15px\" type="submit" value="Submit">
    </div>
</form>"

if [ ! -z "${query_string}" ]; then
    # start time
    start=`date +%s`

    echo "<TABLE style=\"clear:both; margin-top:180px\" border=\"1\">"
    echo "<TR>"
    echo "<TH>Train Number</TH>"
    echo "<TH>Train Name</TH>"
    echo "<TH>Date</TH>"
    echo "<TH>Class - SL</TH>"
    echo "<TH>Class -3A</TH>"
    echo "<TH>Source</TH>"
    echo "<TH>Destination</TH>"
    echo "</TR>"

    # fetch train numbers between two station codes
    if echo "on" | grep -i "^${array[update]}$" > /dev/null; then
        train_numbers=`curl -s --data "lccp_src_stncode=${src}&lccp_dstn_stncode=${dest}&lccp_classopt=SL&lccp_day=${day}&lccp_month=${month}&submit2=Get+Trains" http://www.indianrail.gov.in/cgi_bin/inet_srcdest_cgi_date.cgi | grep -Po '<INPUT TYPE=\"RADIO\" NAME=\"lccp_trndtl\" VALUE="\K.?.?.?.?.?' | sort`
    fi

    # fetch tatkal seat availability
    for x in $train_numbers; do
        result=`curl -A ${user_agent} -s --data "lccp_trnno=${x}&lccp_day=${day}&lccp_month=${month}&lccp_srccode=${src}&lccp_dstncode=${dest}&${other}" http://www.indianrail.gov.in/cgi_bin/inet_accavl_cgi.cgi | egrep -m9 "^<TD class=\"table_border_both" | sed -e '3,6d'`
        if [ -n "$result" ]; then
            echo "<TR>"
            echo "$result"
            echo "<TD>${src}</TD>"
            echo "<TD>${dest}</TD>"
            echo "</TR>"
        fi
    done
    echo "</TABLE>"

    # end time
    end=`date +%s`

    # total time
    total_time_taken=`echo "$((end-start))/60" |bc`

    echo "<BR/><BR/>Total response time: $((end-start)) seconds or $total_time_taken minutes"
fi

echo "</BODY></HTML>"
