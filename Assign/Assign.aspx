<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Assign.aspx.cs" Inherits="Assign_Assign" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" dir="rtl">
<head runat="server">
    <title>סידור עבודה</title>
    <style>
        table
        {
            table-layout: fixed;
        }
        .shiftTitle
        {
            text-align: center;
            background-color: silver !important;
            border: solid 1px gray;
            -webkit-print-color-adjust: exact;
        }
        .tdTitle
        {
            border: solid 1px gray;
            text-align: center;
            border-radius: 10px;
            font-size: 14px;
            font-weight: bold;
            font-family: Sans-Serif;
        }
        .shiftWorker
        {
            vertical-align: top;
            height: 180px;
            border: solid 1px gray;
            font-size: 12px;
            font-family: Sans-Serif;
        }
        .menuaWorker
        {
            vertical-align: top;
            height: 100px;
            border: solid 1px gray;
            font-size: 12px;
            font-family: Sans-Serif;
        }
        
        .spJobSign
        {
            padding: 1px;
            background-color: yellow !important;
            -webkit-print-color-adjust: exact;
            float: right;
            width: 28%;
            text-align: right;
            border: solid 1px gray;
            height: 17px;
        }
        
        
        .spContainer
        {
            padding: 1px;
            border: solid 1px gray;
            font-size: 14px;
            float: right;
            font-family: Sans-Serif;
            width: 67%;
            height: 17px;
        }
        
        .spName
        {
            float: right;
            text-align: right;
        }
        
        .addHours
        {
            font-family: Sans-Serif;
            font-weight: bold;
            float: left;
            direction: ltr;
        }
        
        
        .spToran
        {
            background-color: orange !important;
            -webkit-print-color-adjust: exact;
        }
        
        .area
        {
            text-align: center;
            font-size: 26px;
            font-weight: bold;
            text-decoration: underline;
        }
        
        
        .NoZakay
        {
            background: #11F359 !important;
        }


        .mikratitle
        {
         background:#B2A1C7 !important; 
        }
        
        .tblMikra
        {
          font-size:12px;
          font-family:Arial;  
          border:solid 1px gray; 
        }

        .tdright
        {
           width:30%; 
           font-weight:bold;
           background:#F6E8FF;
        }
        
        .tdleft
        {
            width:70%; 
              background:#F6E8FF;
        }


    </style>
    <script type="text/javascript" src="../assets/js/lib/jquery-1.11.min.js"></script>
    <script type="text/javascript">


        //  background: #7FFF00 ;

        $.extend({
            getUrlVars: function () {
                var vars = [], hash;
                var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
                for (var i = 0; i < hashes.length; i++) {
                    hash = hashes[i].split('=');
                    vars.push(hash[0]);
                    vars[hash[0]] = hash[1];
                }
                return vars;
            },
            getUrlVar: function (name) {
                return $.getUrlVars()[name];
            }
        });

        var block = 0;

        var SearchDate = "08.05.2016";
        var OrgUnitCode = "20000059";
        var SourceSearchDate = "";
        $(document).ready(function () {



            //            var someDate = new Date(2016,04,25);

            //            alert(someDate.getMonth() + 1);


            //            var numberOfDaysToAdd = 7;
            //            someDate.setDate(someDate.getDate() + numberOfDaysToAdd);
            //           


            //            var result = new Date(2016, 05, 25);
            //          
            //          
            //            // alert(result.getDate());



            //            var newDate = new Date(result.setTime(result.getTime() + 7 * 86400000));

            // alert(newDate);

            // result.setDate(result.getDate() + 7);




            OrgUnitCode = $.getUrlVars().OrgUnitCode;
            SearchDate = $.getUrlVars().SearchDate;
            SourceSearchDate = SearchDate;

            $(".area").text(GetAreaName(OrgUnitCode));
            InitData();



        });


        function ConvertHebrewDateToJSDATE(HebrewDate, adddays, format) {


            var day = HebrewDate.substring(0, 2);
            var month = HebrewDate.substring(3, 5);
            var year = HebrewDate.substring(6, 10);




            // יש לשים לב להוריד אחד בחודשים
            var result = new Date(year, eval(month) - 1, day);

            if (adddays) {
                result.setDate(result.getDate() + adddays);
            }


            if (format == "Heb") {

                var curr_date = result.getDate();

                // פה בשליפה להוסיף 1
                var curr_month = result.getMonth() + 1;
                var curr_year = result.getFullYear();

                if (curr_date < 10) {
                    curr_date = '0' + curr_date
                }
                if (curr_month < 10) {
                    curr_month = '0' + curr_month
                }


                return curr_date + "." + curr_month + "." + curr_year;

            }


            return result;

            //alert(year);

            //  alert()


        }

        function InitData() {

            var WorkSchedule = Ajax("Assign_GetSymbolShiftWS", "Date=" + SearchDate);

            var mydata = Ajax("Assign_GetAssignmentForPortal", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode);
            var PrevShiftDate = "";
            var PrevShiftCode = "";

            var CurrentShiftCode = "";


            var Day = 0;

            $("#trSiftDate").html("");
            $("[id^='shift']").html("");


            for (var i = 0; i < mydata.length; i++) {

                if (PrevShiftDate != mydata[i].ShiftDate) {
                    PrevShiftDate = mydata[i].ShiftDate;
                    var CurrentDay = getDayInWeekString(mydata[i].DayInWeek);
                    $("#trSiftDate").append("<td class='tdTitle'>" + CurrentDay + "   " + PrevShiftDate + "</tb>");
                    Day = Day + 1;
                }


                CurrentShiftCode = mydata[i].ShiftCode

                var addClass = "";
                var NoZakay = "";
                if (mydata[i].IsToranHerum == "1") {
                    addClass = "spToran";
                }

                // חיווי להסעות להוריד את הלא זכאים
                if (CurrentShiftCode != mydata[i].Borrow
                    && mydata[i].IsAsterisk == "0"
                    && mydata[i].SourceAssignmentId != "0"
                    && mydata[i].EmpNo > 0) {

                    NoZakay = " NoZakay ";
                }




                var FullName = (mydata[i].FullName) ? mydata[i].FullName : "&nbsp;";
                var AddedHours = (mydata[i].AddedHours != 0 && mydata[i].AddedHours) ? mydata[i].AddedHours : "";
                var IsSpecial = (mydata[i].IsSpecial == "1") ? " ק " : "";
                var IsCapsula = (mydata[i].IsCapsula == "1") ? "#BA55D3 " : "";

                var Symbol = mydata[i].Symbol;
                var Asterik = "";
                if (Symbol.indexOf('*') != -1) {
                    Symbol = Symbol.replace('*', "");
                    Symbol = Symbol + "<img style='padding:2px' src='../assets/images/dark-asterisk.png' height='8px' />";

                }





                var TextAppend = "<div  class='spJobSign " + NoZakay + "'>" + Symbol + "</div>"
                    + "<div style='background:" + IsCapsula + "'  class='spContainer " + addClass + "'>"
                    + "<span class='spName'>" + FullName + "</span>"
                    + "<span class='addHours'>" + IsSpecial + AddedHours + "</span>"
                    + "</div>";


                $("#shift" + CurrentShiftCode + Day).append(TextAppend + "<br>");

                var WorkSchedular = getRightSchedular(WorkSchedule, mydata[i].ShiftDate);


                // var WorkSchedular = WorkSchedule.filter(x => x.ShiftDate == mydata[i].ShiftDate);
                //צחי
                $("#boker" + CurrentShiftCode + Day).text("(" + WorkSchedular[0].WorkScheduleRuleCode + ")");

                $("#tza" + CurrentShiftCode + Day).text("(" + WorkSchedular[1].WorkScheduleRuleCode + ")");

                $("#erev" + CurrentShiftCode + Day).text("(" + WorkSchedular[2].WorkScheduleRuleCode + ")");

            }

        }

        function getRightSchedular(WorkSchedule, ShiftDate) {
            var res = [];

            for (var i = 0; i < WorkSchedule.length; i++) {

                if (WorkSchedule[i].ShiftDate == ShiftDate) {

                    res.push(WorkSchedule[i]);

                }
            }

            return res;


        }




        function GetAreaName(OrgUnit) {
            if (OrgUnit == "20000058") return "אזור א'";
            if (OrgUnit == "20000059") return "אזור ב'";
            if (OrgUnit == "20000060") return "FCC";
            if (OrgUnit == "20000301") return "אלקילציה";
            if (OrgUnit == "20000055") return "תנועות דלק";
            if (OrgUnit == "20000016") return "כיבוי";
            if (OrgUnit == "20000057") return "ניפוק";
            if (OrgUnit == "20000017") return "מעבדה";
            if (OrgUnit == "20000011") return "בטחון";
            if (OrgUnit == "20000018") return "מפקחים";




        }

        function Ajax(sp, params) {
            var json = "";
            $.ajax({

                type: "POST",
                url: "../WebService.asmx/" + sp,

                data: params,
                async: false,
                dataType: "json",
                success: function (data) {
                    json = data;
                },

                error: function (request, status, error) {
                    json = (error);
                }

            });
            return json;

        }

        function getDayInWeekString(day) {

            if (day == "1") return "יום א'";
            if (day == "2") return "יום ב'";
            if (day == 3) return "יום ג'";
            if (day == 4) return "יום ד'";
            if (day == 5) return "יום ה'";
            if (day == 6) return "יום שישי";
            if (day == 7) return "יום שבת";



        }

        function NextPrevWeek(Dir) {

            if ((Dir == "prev" && block == -1) || (Dir == "next" && block == 1)) {

                alert(" לא ניתן לצפות בטווח תאריכים זה! ");

                return;

            }


            if (Dir == "prev") {
                SearchDate = ConvertHebrewDateToJSDATE(SearchDate, -7, "Heb");


                block -= 1;
            }

            if (Dir == "next") {

                SearchDate = ConvertHebrewDateToJSDATE(SearchDate, 7, "Heb");


                block += 1;
            }





            InitData();



        }

        function CurrentDate() {


            block = 0;
            SearchDate = SourceSearchDate;
            InitData();


        }


    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table width="100%" border="0">
            <tr>
                <td align="center" valign="top">
                    <table class="tblMikra">
                        <tr>
                            <td class="mikratitle tdright">
                                סימני משמרת
                            </td>
                            <td class="mikratitle tdleft">
                                משמעות
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                                #
                            </td>
                            <td class="tdleft">
                                עבודה ביום מנוחה
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                                *
                            </td>
                            <td class="tdleft">
                                שינוי משמרת ביוזמת חברה
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                                ק
                            </td>
                            <td class="tdleft">
                                קריאה מיוחדת
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright"> 
                                +X
                            </td>
                            <td class="tdleft">
                                הארכת משמרת לפני/אחרי ב-X שעות
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                                ^^
                            </td>
                            <td class="tdleft">
                                הקדמה 2:45 במסוף
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                                ++
                            </td>
                            <td class="tdleft">
                                השכמה 03:45 במסוף
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                                !
                            </td>
                            <td class="tdleft">
                                העובד גר מחוץ לאשדוד
                            </td>
                        </tr>
                    </table>
                </td>
                <td align="left">
                    <div onclick="NextPrevWeek('prev')" style="cursor: pointer">
                        <div style="float: left; padding-top: 20px; color: Blue;">
                            שבוע קודם</div>
                        <img src="../assets/images/arrowr.png" height="50px" />
                    </div>
                </td>
                <td style="width: 150px; cursor: pointer">
                    <div class="area" onclick="CurrentDate()">
                    </div>
                </td>
                <td align="right">
                    <div onclick="NextPrevWeek('next')" style="cursor: pointer">
                        <div style="float: right; padding-top: 20px; color: Blue;">
                            שבוע הבא</div>
                        <img src="../assets/images/arrowl.png" height="50px" />
                    </div>
                </td>
                <td align="center" >
                         <table class="tblMikra">
                        <tr>
                            <td class="mikratitle tdright">
                                סימני תפקיד
                            </td>
                            <td class="mikratitle tdleft">
                                משמעות
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                                =
                            </td>
                            <td class="tdleft">
                               מפעיל ראשי
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                                ~
                            </td>
                            <td class="tdleft">
                                לווח שני
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                               -
                            </td>
                            <td class="tdleft">
                               לווח
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright"> 
                                כ
                            </td>
                            <td class="tdleft">
                               מוסמך לכבאי
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                              ל
                            </td>
                            <td class="tdleft">
                              מתלמד
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                               מ
                            </td>
                            <td class="tdleft">
                               מלאן
                            </td>
                        </tr>
                        <tr>
                            <td class="tdright">
                                ש
                            </td>
                            <td class="tdleft">
                             משגר
                            </td>
                        </tr>

                          <tr>
                            <td class="tdright">
                               י
                            </td>
                            <td class="tdleft">
                             עובד יום
                            </td>
                        </tr>

                          <tr>
                            <td class="tdright">
                                ש
                            </td>
                            <td class="tdleft">
                             משגר
                            </td>
                        </tr>

                          <tr>
                            <td class="tdright">
                                ה
                            </td>
                            <td class="tdleft">
                             הדרכת פנים
                            </td>
                        </tr>

                        <tr>
                            <td class="tdright">
                                ט
                            </td>
                            <td class="tdleft">
                            מוסמך למט"ש
                            </td>
                        </tr>

                          <tr>
                            <td class="tdright">
                               E
                            </td>
                            <td class="tdleft">
                           מוסמך לצוות חירום
                            </td>
                        </tr>

                           <tr>
                            <td class="tdright">
                              נז
                            </td>
                            <td class="tdleft">
                          מלאן מזוט
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <br />
        <table cellpadding="1" cellspacing="0" width="100%">
            <tr id="trSiftDate">
            </tr>
            <tr>
                <td class="shiftTitle">
                    בוקר &nbsp;<b style="color:red" id="boker11"></b>
                </td>
                <td class="shiftTitle">
                    בוקר &nbsp;<b style="color:red" id="boker12"></b>
                </td>
                <td class="shiftTitle">
                    בוקר &nbsp;<b style="color:red" id="boker13"></b>
                </td>
                <td class="shiftTitle">
                    בוקר &nbsp;<b style="color:red" id="boker14"></b>
                </td>
                <td class="shiftTitle">
                    בוקר &nbsp;<b style="color:red" id="boker15"></b>
                </td>
                <td class="shiftTitle">
                    בוקר &nbsp;<b style="color:red" id="boker16"></b>
                </td>
                <td class="shiftTitle">
                    בוקר &nbsp;<b style="color:red" id="boker17"></b>
                </td>
            </tr>
            <tr>
                <td class="shiftWorker" id="shift11">
                </td>
                <td class="shiftWorker" id="shift12">
                </td>
                <td class="shiftWorker" id="shift13">
                </td>
                <td class="shiftWorker" id="shift14">
                </td>
                <td class="shiftWorker" id="shift15">
                </td>
                <td class="shiftWorker" id="shift16">
                </td>
                <td class="shiftWorker" id="shift17">
                </td>
            </tr>
            <tr>
                <td class="shiftTitle">
                    צהריים &nbsp;<b style="color:red" id="tza21"></b>
                </td>
                <td class="shiftTitle">
                    צהריים &nbsp;<b style="color:red" id="tza22"></b>
                </td>
                <td class="shiftTitle">
                    צהריים &nbsp;<b style="color:red" id="tza23"></b>
                </td>
                <td class="shiftTitle">
                    צהריים &nbsp;<b style="color:red" id="tza24"></b>
                </td>
                <td class="shiftTitle">
                    צהריים &nbsp;<b style="color:red" id="tza25"></b>
                </td>
                <td class="shiftTitle">
                    צהריים &nbsp;<b style="color:red" id="tza26"></b>
                </td>
                <td class="shiftTitle">
                    צהריים &nbsp;<b style="color:red" id="tza27"></b>
                </td>
            </tr>
            <tr>
                <td class="shiftWorker" id="shift21">
                </td>
                <td class="shiftWorker" id="shift22">
                </td>
                <td class="shiftWorker" id="shift23">
                </td>
                <td class="shiftWorker" id="shift24">
                </td>
                <td class="shiftWorker" id="shift25">
                </td>
                <td class="shiftWorker" id="shift26">
                </td>
                <td class="shiftWorker" id="shift27">
                </td>
            </tr>
            <tr>
                <td class="shiftTitle">
                    לילה &nbsp;<b style="color:red" id="erev31"></b>
                </td>
                <td class="shiftTitle">
                    לילה &nbsp;<b style="color:red" id="erev32"></b>
                </td>
                <td class="shiftTitle">
                    לילה &nbsp;<b style="color:red" id="erev33"></b>
                </td>
                <td class="shiftTitle">
                    לילה &nbsp;<b style="color:red" id="erev34"></b>
                </td>
                <td class="shiftTitle">
                    לילה &nbsp;<b style="color:red" id="erev35"></b>
                </td>
                <td class="shiftTitle">
                    לילה &nbsp;<b style="color:red" id="erev36"></b>
                </td>
                <td class="shiftTitle">
                    לילה &nbsp;<b style="color:red" id="erev37"></b>
                </td>
            </tr>
            <tr>
                <td class="shiftWorker" id="shift31">
                </td>
                <td class="shiftWorker" id="shift32">
                </td>
                <td class="shiftWorker" id="shift33">
                </td>
                <td class="shiftWorker" id="shift34">
                </td>
                <td class="shiftWorker" id="shift35">
                </td>
                <td class="shiftWorker" id="shift36">
                </td>
                <td class="shiftWorker" id="shift37">
                </td>
            </tr>
            <tr>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
                <td class="shiftTitle">
                    מנוחה
                </td>
            </tr>
            <tr>
                <td class="shiftWorker" id="shift01">
                </td>
                <td class="shiftWorker" id="shift02">
                </td>
                <td class="shiftWorker" id="shift03">
                </td>
                <td class="shiftWorker" id="shift04">
                </td>
                <td class="shiftWorker" id="shift05">
                </td>
                <td class="shiftWorker" id="shift06">
                </td>
                <td class="shiftWorker" id="shift07">
                </td>
            </tr>
            <tr>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
                <td class="shiftTitle">
                    העדרויות
                </td>
            </tr>
            <tr>
                <td class="shiftWorker" id="shift991">
                </td>
                <td class="shiftWorker" id="shift992">
                </td>
                <td class="shiftWorker" id="shift993">
                </td>
                <td class="shiftWorker" id="shift994">
                </td>
                <td class="shiftWorker" id="shift995">
                </td>
                <td class="shiftWorker" id="shift996">
                </td>
                <td class="shiftWorker" id="shift997">
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
