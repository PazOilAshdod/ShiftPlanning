$(function () {


    DefinitionMask();
});


function InitFormValidation(elemId) {
    $("#" + elemId).validationEngine('attach', {
        showOneMessage: false,
        promptPosition: "bottomLeft",
        autoHidePrompt: true,
        scroll: true,
        onValidationComplete: function (form, status) {
            return status;
        }
        /*showPrompts:false*/
    });
}


function BuildCombo(mydata, elemId, Value, Display) {
    
    var Items = "";

    for (var i = 0; i < mydata.length; i++) {
        Items += '<option value="' + mydata[i][Value] + '">' + mydata[i][Display] + '</option>';
    }



    $(elemId).append(Items);


}


function GetComboItemsSync(TableName, Condition, elemId, Value, Display) {

    // var mydata = Ajax("Gen_GetTable", "TableName=" + TableName + "&Condition=" + Condition);
    //  AjaxAsync("Assign_GetAssignment", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode, );

  var myData =  Ajax("Gen_GetTable", "TableName=" + TableName + "&Condition=" + Condition);//, function (px) { BuildCombo(px, elemId, Value, Display) });
   BuildCombo(myData, elemId, Value, Display);

    //  return Items;
}

function GetComboItems(TableName, Condition, elemId, Value, Display) {

    // var mydata = Ajax("Gen_GetTable", "TableName=" + TableName + "&Condition=" + Condition);
    //  AjaxAsync("Assign_GetAssignment", "Date=" + SearchDate + "&OrgUnitCode=" + OrgUnitCode, );

    AjaxAsync("Gen_GetTable", "TableName=" + TableName + "&Condition=" + Condition, function (px) { BuildCombo(px, elemId, Value, Display) });


    //  return Items;
}

function GetComboItemsByData(mydata, Value, Display) {
    var Items = "";
    // var mydata = Ajax("Gen_GetTable", "TableName=" + TableName + "&Condition=" + Condition);
    for (var i = 0; i < mydata.length; i++) {
        Items += '<option value="' + mydata[i][Value] + '">' + mydata[i][Display] + '</option>';
    }

    return Items;
}

function GetMaskCharByNumber(Num) {

    if (Num == "8") return "z";
    if (Num == "7") return "h";
    if (Num == "6") return "f";
    if (Num == "5") return "e";
    if (Num == "4") return "d";
    if (Num == "3") return "c";
    if (Num == "2") return "b";
    if (Num == "1") return "a";



}

function DefinitionMask() {

    $.mask.definitions['z'] = "[1-8]";
    $.mask.definitions['h'] = "[1-7]";
    $.mask.definitions['f'] = "[1-6]";
    $.mask.definitions['e'] = "[1-5]";
    $.mask.definitions['d'] = "[1-4]";
    $.mask.definitions['c'] = "[1-3]";
    $.mask.definitions['b'] = "[1-2]";
    $.mask.definitions['a'] = "[1-1]";


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


function AjaxAsync(sp, params, callback) {
    //   var result = null;
    $.ajax({

        type: "POST",
        url: "../WebService.asmx/" + sp,
        data: params,
        async: true,
        dataType: "json",
        success: function (data) {
            //  BuildPage(data);
            //result = data;
            callback(data);
            // json = data;
        },

        error: function (request, status, error) {
            // json = (error);
        }

    });
    //return result;

}






function InitDateTimePickerPlugin(elem, dateInit, mindate,isEvent) {

   
    $(elem).datetimepicker(
     {
         value: dateInit,
         minDate: mindate,
         timepicker: false,
         format: 'd.m.Y',
         mask: true,
         validateOnBlur: false,
         onChangeDateTime: (isEvent)? OnDateChange : false

     });
     


 }


function getFirstDayOfMonth(monthAddremove) {
    const d = new Date();
    var dd = new Date(d.getFullYear(), d.getMonth() + monthAddremove , 1);
    return formatDate(dd);
}


function getLastDayOfMonth(monthAddremove) {
    const d = new Date();
    var dd = new Date(d.getFullYear(), d.getMonth() + monthAddremove , 0);
    return formatDate(dd);
}



function IsNullDB(val) {

    if (val) {
        return val;
    } else {
    return "&nbsp;";
    }

}



function IsDateValid(HebrewDate) {

    try {
        
        var day = HebrewDate.substring(0, 2);
        var month = HebrewDate.substring(3, 5);
        var year = HebrewDate.substring(6, 10);

        var result = new Date(year, eval(month) - 1, day);
        result.setDate(result.getDate() + 0);
        return true;
    } catch { return false; }

}

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


function getDateTimeNowFormat() {
  
    var d = new Date();
    var curr_date = d.getDate();
    var curr_month = d.getMonth() + 1; //Months are zero based
    var curr_year = d.getFullYear();

    if (curr_date < 10) {
        curr_date = '0' + curr_date
    }
    if (curr_month < 10) {
        curr_month = '0' + curr_month
    }


   

    return curr_date + "." + curr_month + "." + curr_year;

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



function getDayfromDate(date) {
    
    var day = (ConvertHebrewDateToJSDATE(date,0,false)).getDay() + 1;
   
    if (day == "1") return "יום ראשון";
    if (day == "2") return "יום שני";
    if (day == 3) return "יום שלישי";
    if (day == 4) return "יום רביעי";
    if (day == 5) return "יום חמישי";
    if (day == 6) return "יום שישי";
    if (day == 7) return "יום שבת";



}

function parseJsonDate(jsonDateString, Type) {

    // פורמט לתצוגה
    if (Type == "1")
        return formatDate(new Date(parseInt(jsonDateString.replace('/Date(', ''))));

    // javascript date
    if (Type == "2")

        return new Date(parseInt(jsonDateString.replace('/Date(', '')));

    return "";

}

function addDays(date, days, type) {
    var result = new Date(date);
    result.setDate(result.getDate() + days);

    // פורמט לתצוגה
    if (type == "1")
        return formatDate(result);
    if (type == "2")
        return result;
}

function ConvertStrToJsDate(val) {


    var result = new Date(val);
    return result;

}


function PrintDiv(data, Area) {
    var mywindow = window.open('', 'my div', 'height=400,width=600');
    mywindow.document.write('<html dir="rtl"><head>'

     + "<title>סידור עבודה " + Area + "</title>");


    //  mywindow.document.write('<link rel="stylesheet" href="http://172.22.11.52/ShiftPlaning/assets/css/rtl-css/Print.css" type="text/css" />');
    mywindow.document.write('</head><body >');
    mywindow.document.write(data);
    mywindow.document.write('</body></html>');

    mywindow.document.close(); // necessary for IE >= 10
    mywindow.focus(); // necessary for IE >= 10

    mywindow.print();
    mywindow.close();

    return true;
}


function PrintDivFood(data, Area) {
    var mywindow = window.open('', 'my div', 'height=400,width=600');
    mywindow.document.write('<html dir="rtl"><head>'

        + "<title></title>");


    //  mywindow.document.write('<link rel="stylesheet" href="http://172.22.11.52/ShiftPlaning/assets/css/rtl-css/Print.css" type="text/css" />');
    mywindow.document.write('</head><body >');
    mywindow.document.write(data);
    mywindow.document.write('</body></html>');

    mywindow.document.close(); // necessary for IE >= 10
    mywindow.focus(); // necessary for IE >= 10

    mywindow.print();
    mywindow.close();

    return true;
}


function datediff(firstDate, secDate) {


    // alert(strDate.split('.')[2]);
    // alert(strDate.split('.')[1] - 1);
    // alert(strDate.split('.')[0]);
    var firstRunDate = new Date(firstDate.split('.')[2], firstDate.split('.')[1] - 1, firstDate.split('.')[0]);
    var secRunDate = new Date(secDate.split('.')[2], secDate.split('.')[1] - 1, secDate.split('.')[0]);

    var timeDiff = firstRunDate.getTime() - secRunDate.getTime();
    var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
    //  RunDate.setDate(RunDate.getDate() + Days);
    return diffDays;

}


function formatDate(value) {

    if (!value) return "";

    // var d = new Date();
    var curr_date = value.getDate();
    var curr_month = value.getMonth() + 1; //Months are zero based
    var curr_year = value.getFullYear();

    if (curr_date < 10) {
        curr_date = '0' + curr_date
    }
    if (curr_month < 10) {
        curr_month = '0' + curr_month
    }


    return curr_date + "." + curr_month + "." + curr_year;

}

function ConvertIntToTime(time) {

   

    if (time == 0 || time == 9999) return;
    var hours = time.substring(0, 2);
    var minutes = time.substring(2, 4);
   
    //if (hours < 10) { hours = "0" + hours; }
    //if (minutes < 10) { minutes = "0" + minutes; }
  
    return hours + ':' + minutes;
}

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


(function ($, window) {

    $.fn.contextMenu = function (settings) {

        return this.each(function () {

            // Open context menu
            $(this).on("contextmenu", function (e) {
                // return native menu if pressing control
                if (e.ctrlKey) return;

                //open menu
                var $menu = $(settings.menuSelector)
                    .data("invokedOn", $(e.target))
                    .show()
                    .css({
                        position: "absolute",
                        left: getMenuPosition(e.clientX, 'width', 'scrollLeft'),
                        top: getMenuPosition(e.clientY, 'height', 'scrollTop')
                    })
                    .off('click')
                    .on('click', 'a', function (e) {

                        e.preventDefault();
                        $menu.hide();

                        var $invokedOn = $menu.data("invokedOn");
                        var $selectedMenu = $(e.target);

                        settings.menuSelected.call(this, $invokedOn, $selectedMenu);
                    });

                return false;
            });

            //make sure menu closes on any click
            $(document).click(function () {
                $(settings.menuSelector).hide();
            });
        });

        function getMenuPosition(mouse, direction, scrollDir) {
            var win = $(window)[direction](),
                scroll = $(window)[scrollDir](),
                menu = $(settings.menuSelector)[direction](),
                position = mouse + scroll;

            // opening menu would pass the side of the page
            if (mouse + menu > win && menu < mouse)
                position -= menu;

            return position;
        }

    };
})(jQuery, window);


///////--------------- Cookies -----------------------------------------


function setCookie(cname, cvalue, exminutes) {
    var d = new Date();
    d.setTime(d.getTime() + (exminutes * 24 * 60 * 60 * 1000));
    var expires = "expires=" + d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
    }
    return "";
}

function checkCookie() {
    var user = getCookie("username");
    if (user != "") {
        alert("Welcome again " + user);
    } else {
        user = prompt("Please enter your name:", "");
        if (user != "" && user != null) {
            setCookie("username", user, 365);
        }
    }
}


