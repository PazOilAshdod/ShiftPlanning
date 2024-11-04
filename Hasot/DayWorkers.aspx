<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage/MasterPage.master" AutoEventWireup="true"
    CodeFile="DayWorkers.aspx.cs" Inherits="Hasot_DayWorkers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link href="../assets/css/rtl-css/typeahead.js-bootstrap.css" rel="stylesheet" type="text/css" />
    <script src="../assets/js/bootstrap3-typeahead.min.js" type="text/javascript"></script>
    <script type="text/javascript">

        var mydata;


        var OrgUnitCode = "";
        var selectedEmp = "";
        $(document).ready(function () {
          
            $('input.typeahead').typeahead({
                items: 15,
                source: function (query, process) {
                    states = [];
                    map = {};

                    var data = Ajax("Employees_GetEmployeesList", "Type=0&EmpNo=");



                    $.each(data, function (i, state) {
                        map[state.FullText] = state;
                        states.push(state.FullText);
                    });

                    process(states);
                },

                updater: function (item) {

                    EmpNo = map[item].EmpNo;
                    SearchEmp(EmpNo);
                    return item;
                }


            });


            FillData();
        });

        function SearchEmp(EmpNo) {


            var data = Ajax("Employees_GetEmployeesList", "Type=1&EmpNo=" + EmpNo);

            if (data[0]) {
                selectedEmp = EmpNo;




                //$("#txtEmpNo").val(data[0].EmpNo);
                //$("#txtFirstName").val(data[0].FirstName);
                //$("#txtLastName").val(data[0].LastName);
                $("#txtArea").val(data[0].OrgUnitCode);
                //$("#txtStartDate").val(data[0].StartDate);
                //$("#txtEndDate").val(data[0].EndDate);
                //$("#txtPhone").val(data[0].PhoneNum);
                $("#txtCity").val(data[0].City);
                //$("#txtAddress").val(data[0].Address);
                $("#txtLooz").val(data[0].GroupCode);
                //$("#txtTaz").val(data[0].EmpId);
                //if (data[0].IsHasa == "1") {

                //    $('#chIsHasa').prop('checked', true);
                //} else {

                //    $('#chIsHasa').prop('checked', false);
                //}




            }



            //$("#dvQualContainer").html("");
            //var mydata = Ajax("Employees_GetEmployeesList", "Type=2&EmpNo=" + EmpNo);

            //for (var i = 0; i < mydata.length; i++) {
            //    QualHtml = $("#dvQualTemplate").html();
            //    QualHtml = QualHtml.replace("@Text", mydata[i].Text);
            //    $("#dvQualContainer").append(QualHtml);

            //}


            // SetAbsence(EmpNo);


        }

        function deleteUser(EmpNo) {



            bootbox.confirm("האם אתה בטוח שברצונך למחוק את העובד מתוך רשימת זכאים להסעה?", function (result) {
                if (result) {
                    var data = Ajax("Hasot_SetHasaForEmp", "EmpNo=" + EmpNo + "&IsHasa=0");
                    FillData();
                }

            });


        }


        function ReductWorker() {
            if (!selectedEmp) {

                bootbox.alert("חובה לבחור עובד\ת מרשימה!");
                return;
            }

            var data = Ajax("Hasot_SetHasaForEmp", "EmpNo=" + selectedEmp + "&IsHasa=100");
            FillData();

        }


        function AddWorker() {

            if (!selectedEmp) {

                bootbox.alert("חובה לבחור עובד\ת מרשימה!");
                return;
            }


            var Looz = $("#txtLooz").val();
            var IsImahot = $("#ddlImahotSug").val();

            if (Looz.indexOf("YOM") == -1) {

                bootbox.confirm("עובד זה אינו מוגדר כעובד יום , האם להוסיף אותו בכל זאת?", function (result) {
                    if (result) {
                        var data = Ajax("Hasot_SetHasaForEmp", "EmpNo=" + selectedEmp + "&IsHasa=1&IsImahot=" + IsImahot );
                        FillData();
                    }
                });

            } else {
                var data = Ajax("Hasot_SetHasaForEmp", "EmpNo=" + selectedEmp + "&IsHasa=1&IsImahot=" + IsImahot + "&IsYom=true");
                FillData();

            }




        }

        function updateImahot(EmpNo) {

            var ImahotVal = $("#chIsImahot_" + EmpNo).is(':checked');
            var data = Ajax("Hasot_SetHasaForEmp", "EmpNo=" + EmpNo + "&IsHasa=10&IsImahot=" + ImahotVal);
            // alert(ImahotVal);

        }


        function searchAngular() {

            var Search = $("#txtMainSearch").val();

            var mydatanew = mydata.filter(x => x.FirstName.includes(Search) || x.LastName.includes(Search) ||
                x.EmpNo.includes(Search) || x.GroupCode.includes(Search) || x.OrgUnitCode.includes(Search) || x.Imahot.includes(Search) || x.Reduct.includes(Search));

            //OrgUnitCode Imahot
            FillGrid(mydatanew);

        }


        function FillData() {

            $("#ddlImahotSug").val("");

            mydata = Ajax("Employees_GetEmployeesList", "Type=5&EmpNo=");



            FillGrid(mydata);





        }


        function FillGrid(mydata) {


            $("#dvReqContainer").html("");

            var ReqHtml = `
                     <tr class="@ReductRow">
                                    <td>@EmpNo</td>
                                    <td>@FirstName</td>
                                    <td>@LastName</td>
                                     <td>@GroupCode</td>
                                     <td>@OrgUnitCode</td>
                                     <td>@Imahot</td>
                                     <td style='text-align:center'><i class='fa fa-trash-o' style='color:red;font-size:25px' onclick='deleteUser(@EmpNo)'></i></td>
                                </tr>`;



            /*<input type="checkbox" id="chIsImahot_@EmpNo" name="chIsImahot" @IsImahot onchange = "updateImahot(@EmpNo)" />*/

            for (var i = 0; i < mydata.length; i++) {
                var QualHtml = ReqHtml;
                QualHtml = QualHtml.replace(/@EmpNo/g, mydata[i].EmpNo);
                // QualHtml = QualHtml.replace("@EmpNo", mydata[i].EmpNo);
                QualHtml = QualHtml.replace("@FirstName", mydata[i].FirstName);
                QualHtml = QualHtml.replace("@LastName", mydata[i].LastName);
                QualHtml = QualHtml.replace("@GroupCode", mydata[i].GroupCode);
                QualHtml = QualHtml.replace("@OrgUnitCode", mydata[i].OrgUnitCode);


                var ImahotDesc = "";
                if (mydata[i].IsImahot == 3) {

                    ImahotDesc = "06:45 - 14:45";

                }

                if (mydata[i].IsImahot == 4) {

                    ImahotDesc = "07:45 - 15:45";

                }

                QualHtml = QualHtml.replace("@Imahot", ImahotDesc);

                if (mydata[i].IsReduct == 1) {

                    QualHtml = QualHtml.replace("@ReductRow", "trReductRow");

                }




                $("#dvReqContainer").append(QualHtml);

                // $("#ddlImahotSug_" + mydata[i].EmpNo).val(mydata[i].IsImahot);


            }


        }

        var SelectedRequirementId = "";

        function EditRequirement(RequirementId, DateTypeCode, ShiftCode, QualificationCode, EmpQuantity, Seq,
            RequirementDesc, RequirementAbb, ObligatoryAssignment, ObligatoryCheck, BeginDate, EndDate, RequirementType, IsAssignAuto) {


            // alert(RequirementType);
            SelectedRequirementId = RequirementId;

            $('#fmrReqDetails').validationEngine('hideAll');

            $("#txtEmpQuantity").mask(GetMaskCharByNumber("8"));

            $("#txtRequirementDesc").val(RequirementDesc);
            $("#ddlQualification").val(QualificationCode);

            $("#ddlDayCode").val(DateTypeCode);
            $("#ddlShift").val(ShiftCode);
            $("#txtEmpQuantity").val(EmpQuantity);
            $("#ddlRequirmentType").val("");
            if (RequirementType != "null") {
                //   RequirementType = "";
                $("#ddlRequirmentType").val(RequirementType);
            }


            $("#txtRequirementAbb").val((RequirementAbb != "null") ? RequirementAbb : "");
            $("#txtSeq").val(Seq);

            $("#txtStartDate").val(BeginDate);
            $("#txtEndDate").val(EndDate);


            $("#chIsAuto").prop('checked', (ObligatoryAssignment == "true") ? true : false);
            $("#chIsMustCheck").prop('checked', (ObligatoryCheck == "true") ? true : false);
            $("#chIsAssignAuto").prop('checked', (IsAssignAuto == "true") ? true : false);

            $("#spReqDesc").text((RequirementDesc) ? RequirementDesc : "דרישה חדשה");

            if (!RequirementId) {
                $("#txtStartDate").val(getDateTimeNowFormat());
                $("#txtEndDate").val("31.12.9999");

                EnableDisableControls(false);

            }
            else {

                EnableDisableControls(true);

            }











            $("#ModalEdit").modal();
        }

        function EnableDisableControls(IsDisable) {
            $("#txtStartDate,#txtEndDate,#txtRequirementDesc,#ddlQualification,#ddlDayCode,#ddlShift,#ddlRequirmentType").prop("disabled", IsDisable);

        }

        function SaveDataTODB() {

            var form = $("#fmrReqDetails");
            var IsValid = form.validationEngine('validate');


            if (IsValid) {



                EnableDisableControls(false);

                var strPost = form.serialize();

                Ajax("Requirments_SetRequiremntsTODB", strPost + "&RequirementId=" + SelectedRequirementId + "&OrgUnitCode=" + OrgUnitCode);
                $("#ModalEdit").modal('hide');
                FillData();

            }

        }



    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp; הוספת עובד\ת
                    </h3>
                </div>
                <div class="panel-body" style="margin:0px;padding:0px;margin-bottom:2px;">

                   
                        <div class="col-md-2">
                            <label>חיפוש</label>
                            <input type="text" class="form-control typeahead" spellcheck="false" autocomplete="off"
                                placeholder="חיפוש עובד" />
                        </div>


                        <div class="col-md-2">
                            <label>אזור</label>
                            <input type="text" id="txtArea" disabled="" class="form-control rounded" />
                        </div>

                        <div class="col-md-2">
                            <label>עיר</label>
                            <input type="text" id="txtCity" disabled="" class="form-control rounded" />
                        </div>

                        <div class="col-md-1">
                            <label>
                                לו"ז עבודה</label>

                            <input type="text" id="txtLooz" disabled="" class="form-control rounded" />

                        </div>
                        <div class="col-md-2">
                            <label>אמהות עובדות</label>

                            <select id="ddlImahotSug" name="ddlImahotSug" class="form-control">
                                <option value="">-- בחר סוג אמהות --</option>
                                <option value="3">06:45 - 14:45</option>
                                <option value="4">07:45 - 15:45</option>
                            </select>

                            <%--   <input type="checkbox" id="chIsImahot" name="chIsImahot" value="1" /> &nbsp;אמהות ע'? &nbsp;--%>
                            <%-- <input type="text" id="chIsImahot" disabled="" class="form-control rounded" />--%>
                        </div>

                        <div class="col-md-1" style="margin-right:25px;">
                            <br />
                            <button type="button" class="btn btn-info btn-round" style="margin-top: 5px;" onclick="AddWorker()">
                                <i class="glyphicon glyphicon-user"></i>&nbsp; <span class="btnAssign">הוסף עובד </span>
                            </button>
                        </div>
                        <div class="col-md-1" style="margin-right:25px;">
                            <br />
                            <button type="button" class="btn btn-danger btn-round" style="margin-top: 5px;" onclick="ReductWorker()">
                                <i class="glyphicon glyphicon-user"></i>&nbsp; <span class="btnAssign">גרע עובד </span>
                            </button>
                        </div>

                    
                </div>
            </div>
        </div>
    </div>



    <div class="col-md-12">
        <div class="row">
            <div class="panel panel-info" style="margin: 2px">
                <div class="panel-heading">
                    <h3 class="panel-title">
                        <i class="glyphicon glyphicon-th-list"></i>&nbsp;<span class="spAreaName">רשימת עובדים הזכאים להסעה</span>
                        <input type="text" id="txtMainSearch" class="form-control" onkeyup="searchAngular()" style="background: white"
                            placeholder="חיפוש מרשימה קיימת לפי מספר עובד, שם פרטי, משפחה, לוז,אזור,אמהות(לרשום ''אמהות'') , גריעות (לרשום ''גריעות'') " />
                    </h3>



                </div>
                <div class="panel-body">

                    <style>
                        .trReductRow {
                            background: #ff9999;
                        }

                        tr:hover td {
                            background: #b3d9ff !important;
                        }

                        .trReductRow:hover td {
                            background: #ff6666 !important;
                        }

                        .tableFixHead {
                            overflow: auto;
                            height: 450px;
                        }

                            .tableFixHead thead th {
                                position: sticky;
                                top: 0;
                                z-index: 1;
                            }


                        table {
                            border-collapse: collapse;
                            width: 100%;
                        }

                        th, td {
                            padding: 8px 16px;
                        }

                        th {
                            color: #31708f;
                            background-color: #d9edf7;
                            border-color: #bce8f1;
                        }
                    </style>
                    <div class="tableFixHead">
                        <table class="table table-bordered table-hover">
                            <thead>
                                <tr>
                                    <th style="font-weight: bold">מס' עובד</th>
                                    <th style="font-weight: bold">שם פרטי</th>
                                    <th style="font-weight: bold">שם משפחה</th>

                                    <th style="font-weight: bold">לוז עבודה</th>
                                    <th style="font-weight: bold">אזור</th>
                                    <th style="font-weight: bold">אמהות עובדות</th>
                                    <th style="font-weight: bold"></th>
                                </tr>
                            </thead>
                            <tbody id="dvReqContainer">
                            </tbody>
                        </table>
                    </div>

                </div>



            </div>
        </div>
    </div>


    <%-- חלון מודלי של הגדרת דרישה--%>
    <div class="modal fade" id="ModalEdit" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header label-info">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        <span id="spReqDesc"></span>
                    </h4>
                </div>
                <div class="modal-body" id="Div8">
                    <form id="fmrReqDetails" method="post" action="">
                        <div class="col-md-3">
                            <span class="help-block m-b-none">שם דרישה:</span>
                        </div>
                        <div class="col-md-9">
                            <input type="text" id="txtRequirementDesc" name="txtRequirementDesc" class="form-control validate[required] text-input">
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>
                        <div class="col-md-3">
                            <span class="help-block m-b-none">כישור נדרש:</span>
                        </div>
                        <div class="col-md-9">
                            <select id="ddlQualification" name="ddlQualification" class="form-control validate[required]">
                            </select>
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>
                        <div class="col-md-3">
                            <span class="help-block m-b-none">סוג יום:</span>
                        </div>
                        <div class="col-md-4">
                            <select id="ddlDayCode" name="ddlDayCode" class="form-control validate[required]">
                                <option value="">-- בחר --</option>
                            </select>
                        </div>
                        <div class="col-md-1">
                            <span class="help-block m-b-none">משמרת:</span>
                        </div>
                        <div class="col-md-4">
                            <select id="ddlShift" name="ddlShift" class="form-control validate[required]">
                                <option value="">-- בחר --</option>
                            </select>
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>
                        <div class="col-md-3">
                            <span class="help-block m-b-none">כמות עובדים:</span>
                        </div>
                        <div class="col-md-4">
                            <div class="input-group ls-group-input">
                                <input type="text" id="txtEmpQuantity" name="txtEmpQuantity" class="form-control validate[required] text-input">
                            </div>
                        </div>

                        <div class="col-md-1">
                            <span class="help-block m-b-none">סימון:</span>
                        </div>
                        <div class="col-md-4">
                            <div class="input-group ls-group-input">
                                <input type="text" id="txtRequirementAbb" name="txtRequirementAbb" class="form-control">
                            </div>
                        </div>


                        <div class="clear">
                            &nbsp;
                        </div>

                        <div class="col-md-3">
                            <span class="help-block m-b-none">הדרכות/ע.חריגה:</span>
                        </div>
                        <div class="col-md-4">
                            <select id="ddlRequirmentType" name="ddlRequirmentType" class="form-control">
                                <option value="">-- בחר --</option>
                                <option value="1">עבודה חריגה</option>
                                <option value="2">הדרכות פנים</option>

                            </select>
                        </div>


                        <div class="col-md-1">
                            <span class="help-block m-b-none">סדר:</span>
                        </div>
                        <div class="col-md-4">
                            <div class="input-group ls-group-input">
                                <input type="text" id="txtSeq" name="txtSeq" class="form-control text-input">
                            </div>
                        </div>




                        <div class="clear">
                            &nbsp;
                        </div>
                        <div class="col-md-3">
                            <span class="help-block m-b-none">תאריך התחלה:</span>
                        </div>
                        <div class="col-md-4">
                            <div class="input-group ls-group-input">
                                <input type="text" id="txtStartDate" name="txtStartDate" class="form-control">
                                <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                            </div>
                        </div>
                        <div class="col-md-1">
                            <span class="help-block m-b-none">סיום:</span>
                        </div>
                        <div class="col-md-4">
                            <div class="input-group ls-group-input">
                                <input type="text" id="txtEndDate" name="txtEndDate" class="form-control">
                                <span class="input-group-addon spDateIcon"><i class="fa fa-calendar"></i></span>
                            </div>
                        </div>
                        <div class="clear">
                            &nbsp;
                        </div>



                        <div class="col-md-4" style="padding-right: 35px;">
                            <label class="checkbox">
                                <input type="checkbox" id="chIsAuto" name="chIsAuto" value="1">האם שיבוץ אוטמטי?
                            </label>
                        </div>



                        <div class="col-md-4">
                            <label class="checkbox">
                                <input type="checkbox" id="chIsMustCheck" name="chIsMustCheck" value="1">האם חובת
                            בדיקת תקינות?
                            </label>
                        </div>

                        <div class="col-md-3">
                            <label class="checkbox">
                                <input type="checkbox" id="chIsAssignAuto" name="chIsAssignAuto" value="1">ללא שיבוץ אנשים
                           
                            </label>
                        </div>


                        <div class="col-md-6">
                            &nbsp;
                        </div>
                        <div class="col-md-6" style="text-align: left">
                            <div class="btn btn-info btn-round" onclick="SaveDataTODB()">
                                <i class="glyphicon glyphicon-edit"></i>&nbsp; <span>עדכן</span>
                            </div>
                        </div>
                    </form>
                    <div class="clear">
                        &nbsp;
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-info btn-xs" data-dismiss="modal">
                        סגור</button>
                </div>
            </div>
        </div>
    </div>
    <%-- טמפלט של עובד --%>
    <div id="dvReqTemplate" style="display: none">
        <div class="col-md-3 dvRequireDetails">
            @RequirementDescTable
        </div>
        <div class="col-md-1 dvRequireDetails">
            @DayDesc
        </div>
        <div class="col-md-1 dvRequireDetails">
            @ShiftDesc
        </div>
        <div class="col-md-2 dvRequireDetailsOver" title="@QualificationDesc">
            @QualificationDesc
        </div>
        <%-- <div class="col-md-1 dvRequireDetails">
            @EmpQuantity
        </div>--%>
        <div class="col-md-1 dvRequireDetails">
            @ObligatoryAssignmentTable
        </div>
        <div class="col-md-1 dvRequireDetails">
            @ObligatoryCheckTable
        </div>

        <div class="col-md-2 dvRequireDetails">
            @Dates
        </div>
        <div class="col-md-1 dvRequireDetails">

            <div class="btn btn-primary btn-xs" style="width: 45%" onclick='EditRequirement("@RequirementId", "@DateTypeCode","@ShiftCode", "@QualificationCode", "@EmpQuantity","@Seq", "@RequirementDesc", "@RequirementAbb","@ObligatoryAssignment", "@ObligatoryCheck","@BeginDate", "@EndDate","@RequirementType","@IsAssignAuto")'>
                ערוך
            </div>

            <div class="btn btn-danger btn-xs" style="width: 45%" onclick='DeleteRequirement("@RequirementId")'>
                מחק
            </div>
        </div>




        <%--<div class="btn btn-primary btn-xs" onclick="EditRequirement('@RequirementId, '@DateTypeCode','@ShiftCode', '@QualificationCode', '@EmpQuantity', '@RequirementDesc', '@RequirementAbb','@ObligatoryAssignment', '@ObligatoryCheck','@BeginDate', '@EndDate')">
                <i class="fa fa-edit"></i>&nbsp;ערוך</div>
        --%>
    </div>
    <%-- <script src="../assets/js/pages/formValidation.js"></script>--%>
</asp:Content>
