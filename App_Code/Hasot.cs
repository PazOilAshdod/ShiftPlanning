using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for Hasot
/// </summary>
public class Hasot
{


    //public DataTable dtEmpHasot;
    //public DataTable dtCountInCity;
    //public DataTable dtMaslulim;
    public int DayId; // יום בשבוע
    public string DayHebrew; // יום בשבוע
    public string HolidayCode; // אם נופל על חג
    public int? DayType; // אם נופל על חג
    public int? TomorrowDayType; // אם יום למחרת נועד למשמרת 3 של חזור על חג
    
    public int Dir;
    public string Date;
    public int ShiftId;
    public string AshdodCityCode = "000000000070";
    public int MaslulIdForMeyuhedet;

    public string[] AshkelonCityCode = new string[] { "000000007110", "000000007120", "000000007130" };

    public int CurrentDayInWeek; //שקלול אם נופל בחג
    public string UserId = "";
    public DateTime UpdateTimeStamp;

    List<MishmarotWorkers> MishmarotWorkers = new List<MishmarotWorkers>();
    List<OvdeYomWorkers> OvdeYomWorkers = new List<OvdeYomWorkers>();
    List<Maps> Maps = new List<Maps>();
    List<Area> Area = new List<Area>();
    List<Maslulim> Maslulim = new List<Maslulim>();
    List<Shift> Shift = new List<Shift>();
    List<ShiftTimes> ShiftTimes = new List<ShiftTimes>();
    List<HasotTemplate> HasotTemplateList = new List<HasotTemplate>();
    List<HasotTemplate> CurrentHasotList = new List<HasotTemplate>();

    // List<CurrentHasotTemp> CurrentHasotTempList = new List<CurrentHasotTemp>();

    List<CarsBindToEmpNo> CarsBindToEmpNo = new List<CarsBindToEmpNo>();
    List<Shift> ShiftReal = new List<Shift>();
    Configure Configure;

    // constructor לפני ביצוע הפעלת המנוע
    // השמה בעצם של כל הטבלאות בצורת אובייקטים
    public Hasot(DataSet ds, string Direction, string Date, string ShiftId)
    {

        this.Dir = Helper.ConvertToInt(Direction);
        this.Date = Date;
        this.ShiftId = Helper.ConvertToInt(ShiftId);
        UserId = HttpContext.Current.Request.Cookies["UserData"]["UserId"];
        UpdateTimeStamp = DateTime.Now;
        if (ds.Tables.Count > 5)
        {

            foreach (DataRow row in ds.Tables[0].Rows)
            {
                MishmarotWorkers Obj = new MishmarotWorkers(row);

                if (!MishmarotWorkers.Exists(x => x.EmpNo == Obj.EmpNo))
                    MishmarotWorkers.Add(Obj);
            }

            foreach (DataRow row in ds.Tables[1].Rows)
            {
                OvdeYomWorkers Obj = new OvdeYomWorkers(row);
                OvdeYomWorkers.Add(Obj);
            }

            Configure = new Configure(ds.Tables[7].Rows[0]);

            foreach (DataRow row in ds.Tables[2].Rows)
            {
                Maps Obj = new Maps(row, Configure);
                Maps.Add(Obj);
            }

            foreach (DataRow row in ds.Tables[3].Rows)
            {
                Area Obj = new Area(row);
                Area.Add(Obj);
            }

            foreach (DataRow row in ds.Tables[4].Rows)
            {
                Maslulim Obj = new Maslulim(row);
                Maslulim.Add(Obj);

                if (Obj.Sap_Id == 99)
                    MaslulIdForMeyuhedet = Obj.Id;

            }




            foreach (DataRow row in ds.Tables[5].Rows)
            {
                Shift Obj = new Shift(row);
                Shift.Add(Obj);
            }

            foreach (DataRow row in ds.Tables[6].Rows)
            {
                ShiftTimes Obj = new ShiftTimes(row);

                DayId = Obj.DayId;
                DayHebrew = GetHebrewDay(DayId);
                HolidayCode = Obj.HolidayCode;
                DayType = Obj.DayType;// האם ערב חג או חג עצמו 
                                      // 8 ערב חג
                                      // 9 חג עצמו
                                      // 5 בחירות
                TomorrowDayType = Obj.TomorrowDayType;

                CurrentDayInWeek = (this.DayId < 6) ? 15 : this.DayId;

                if (!string.IsNullOrEmpty(this.HolidayCode))
                {
                    if (this.DayType == 8) CurrentDayInWeek = 6;
                    if (this.DayType.In(5, 9)) CurrentDayInWeek = 7;
                }




                ShiftTimes.Add(Obj);
            }


            foreach (DataRow row in ds.Tables[8].Rows)
            {
                HasotTemplate Obj = new HasotTemplate(row);
                CurrentHasotList.Add(Obj);
            }



            this.ShiftReal = this.Shift.Where(x => x.ShiftId.In(1, 2, 3) && x.TypeId.In(1, 2)).ToList();


        }
    }

    // קבלת יום מאיידי לסטרינג
    private string GetHebrewDay(int dayId)
    {
        switch (dayId)
        {
            case 1:
                return "א";
            case 2:
                return "ב";
            case 3:
                return "ג";
            case 4:
                return "ד";
            case 5:
                return "ה";
            case 6:
                return "ו";
            case 7:
                return "ז";

            default:
                return "";

        }
    }

    // פונקציה שמפעילה את המנוע
    public void BindMaslulToTaxi()
    {

        TimeSpan? CurrentTime;




        // שליפה מעובדי משמרת
        var Workers = MishmarotWorkers.Where(x => //(
                                                  //  (GetPrevNextShift(x) == ((Dir == 0) ? 1 : -1)) && x.AddedHours > 0)
                                                (
                                                  (x.CityCode != AshdodCityCode || x.AddedHours > 0) &&
                                                  (string.IsNullOrEmpty(x.SwapEmpNo) || (!string.IsNullOrEmpty(x.SwapEmpNo) && (x.IsAsterisk == 1 || x.AddedHours > 0)))
                                                  ) //מחוץ לאשדוד והוא לא החליף ביוזמתו
                                                ||
                                                (x.SourceAssignmentId == 0 && x.CityCode != AshdodCityCode)
                                                 // || (x.CityCode == AshdodCityCode && x.AddedHours > 0 && GetPrevNextShift(x) == ((Dir == 0) ? 1 : -1))  // הוא מקדים ממשמרת הבאה
                                                 || (x.CityCode == AshdodCityCode && x.RealShiftCode.In(5, 6) && Dir == 0)
                                                 || (x.CityCode == AshdodCityCode && x.RealShiftCode == 5 && Dir == 1)
                                                ).OrderBy(x => x.HasotId).ToList();


        foreach (var item in Workers)
        {

            // 53222


            if (item.EmpNo == "52816")
            {

            }


            // אם משמרת נוכחית הוא הקדים או נשאר
            // -1 הקדמתי 
            //  1 נשארתי שעות נוספות
            var PrevNextShift = GetPrevNextShift(item);
            if ((Dir == 1 && PrevNextShift == 1) || (Dir == 0 && PrevNextShift == -1)) continue;

            // משמרת מקורית לא צריך לדאוג לו מאחר והוא כבר 
            var PrevNextShiftPrevNext = GetPrevNextShiftPrevNext(item);
            if ((Dir == 1 && PrevNextShiftPrevNext == 1) || (Dir == 0 && PrevNextShiftPrevNext == -1)) continue;

            var CurrentShift = Shift.Where(x => x.TypeId == 1 && x.ShiftId == item.RealShiftCode).FirstOrDefault();

            if (Dir == 0 && PrevNextShift == 0 || (Dir == 1 && PrevNextShift == -1))
                CurrentTime = Helper.AddHours((TimeSpan)CurrentShift.StartTime, ((item.AddedHours == null) ? 0 : (int)item.AddedHours));
            else
                CurrentTime = Helper.AddHours((TimeSpan)CurrentShift.EndTime, ((item.AddedHours == null) ? 0 : -1 * (int)item.AddedHours));

            if (Dir == 0 && PrevNextShift == 0 && item.AddedHours < 0)
            {
                CurrentTime = Helper.AddHours((TimeSpan)CurrentShift.EndTime, ((item.AddedHours == null) ? 0 : (int)item.AddedHours));

            }


            HasotTemplate ht = new HasotTemplate();

            ht.HasotId = item.HasotId;

            ht.CityCode = item.CityCode;

            ht.CityDesc = GetCityDescFromMaslulForDev(item.CityCode);

            ht.Dir = this.Dir;
            ht.EmpNo = item.EmpNo;

            ht.FullName = item.FullName;

            ht.HasotDate = Helper.ConvertToDateTime(this.Date);
            ht.HasotTime = CurrentTime;
            ht.IsYom = false;
            ht.ShiftId = this.ShiftId;


            ht.StatusAction = ((item.AddedHours < 0) ? 1 : 0);

            ht.MaslulId = ((item.AddedHours < 0) ? null : GetMaslulId(item.CityCode, ht.HasotTime));
            ht.AddedHours = item.AddedHours;

            HasotTemplateList.Add(ht);

        }

        //במידה ומדובר ביום חול ולא בשבת או חג
        if (!DayId.In(6, 7) && string.IsNullOrEmpty(HolidayCode))
        {
            // שליפת עובדי יום
            var OvdeYom = OvdeYomWorkers.Where(x => x.TypeId > 1 && ShiftId == 1 && !Workers.Select(y => y.EmpNo).Contains(x.EmpNo)).ToList();
            foreach (var item in OvdeYom)
            {

                //if (item.EmpNo == "53329")
                //{

                //}
                // אמהות עובדות מאשדוד איסוף ל7:45 אמהות עובדות מחוץ לאשדוד כמו המשמרת
                var CurrentShift = Shift.Where(x => x.TypeId == item.TypeId && x.ShiftId == ShiftId).FirstOrDefault();
                CurrentTime = (this.Dir == 0) ? CurrentShift.StartTime : CurrentShift.EndTime;

                // במידה והעובד מאשדוד ויש הסעות רגילות לא מגיע עם הסעות
                if (item.CityCode == AshdodCityCode && (this.ShiftReal.Select(x => x.StartTime).Contains(CurrentTime) ||
                                                    this.ShiftReal.Select(x => x.EndTime).Contains(CurrentTime))
                                                    )
                {
                    continue;
                }

                if (this.DayId == 5 && this.Dir == 1 && (item.TypeId.In(2, 4))) CurrentTime = CurrentTime.Value.Add(TimeSpan.FromMinutes(-30));

                HasotTemplate ht = new HasotTemplate();
                ht.CityCode = item.CityCode;
                ht.CityDesc = GetCityDescFromMaslulForDev(item.CityCode);
                ht.Dir = this.Dir;
                ht.EmpNo = item.EmpNo;
                ht.HasotDate = Helper.ConvertToDateTime(this.Date);
                ht.HasotTime = CurrentTime;
                ht.IsYom = true;
                ht.ShiftId = this.ShiftId;

                int Imahot = (item.IsImahot > 1) ? 1 : 0;

                ht.MaslulId = GetMaslulId(item.CityCode, ht.HasotTime);

                HasotTemplateList.Add(ht);

            }

        }




        var HasotTemplateListHeadrut = HasotTemplateList.Where(x => x.StatusAction == 1).ToList();
        InsertIntoDb(HasotTemplateListHeadrut, null);



        var MapsList = GetCurrentMaps();

        List<HasotTemplate> MinibusimHasotTemplateList = new List<HasotTemplate>();
        int CountOfMinibus = 0;

        Maps LastMap = new Maps();
        foreach (var item in MapsList)
        {

            MinibusimHasotTemplateList.Clear();
            CountOfMinibus = 0;

            LastMap = item;



            if (string.IsNullOrEmpty(item.City)) continue;



            int TypeOfSymbol = GetTypeOfSymbol(item.CarSymbol);

            var MinibusListSelected = HasotTemplateList.Where(x => x.CityCode == item.City && x.HasotTime == item.Hour && x.StatusAction == 0 && x.Status != 2).Take(Configure.MinibusNumber - CountOfMinibus).ToList();
            CountOfMinibus = CountOfMinibus + MinibusListSelected.Count();
            if (MinibusListSelected.Count() > 0)
                MinibusimHasotTemplateList.AddRange(MinibusListSelected);


            var MapsChild = MapsList.Where(x => item.CarSymbol.Contains(x.CarSymbol) && x.Id != item.Id && x.Hour == item.Hour).ToList();

            //  במידה ומדובר בחיפוש בילדים AF 
            if (TypeOfSymbol == 2)
            {


                var MinibusListSelectedTemp1 = HasotTemplateList.Where(x => x.CityCode == MapsChild[0].City && x.HasotTime == MapsChild[0].Hour && x.StatusAction == 0 && x.Status != 2).Take(Configure.MinibusNumber).ToList();
                var MinibusListSelectedTemp2 = HasotTemplateList.Where(x => x.CityCode == MapsChild[1].City && x.HasotTime == MapsChild[1].Hour && x.StatusAction == 0 && x.Status != 2).Take(Configure.MinibusNumber).ToList();

                if (MinibusListSelectedTemp1.Count() >= MinibusListSelectedTemp2.Count())
                {
                    MinibusListSelectedTemp1 = HasotTemplateList.Where(x => x.CityCode == MapsChild[0].City && x.HasotTime == MapsChild[0].Hour && x.StatusAction == 0 && x.Status != 2).Take(Configure.MinibusNumber - CountOfMinibus).ToList();
                    MinibusimHasotTemplateList.AddRange(MinibusListSelectedTemp1);
                    Seq++;
                    InsertIntoDb(MinibusimHasotTemplateList, MapsChild[0]);
                    MapsChild[0].City = "";



                    Seq++;
                    InsertIntoDb(MinibusListSelectedTemp2, MapsChild[1]);
                    MapsChild[1].City = "";

                }
                else
                {
                    MinibusListSelectedTemp2 = HasotTemplateList.Where(x => x.CityCode == MapsChild[1].City && x.HasotTime == MapsChild[1].Hour && x.StatusAction == 0 && x.Status != 2).Take(Configure.MinibusNumber - CountOfMinibus).ToList();
                    MinibusimHasotTemplateList.AddRange(MinibusListSelectedTemp2);
                    Seq++;
                    InsertIntoDb(MinibusimHasotTemplateList, MapsChild[1]);
                    MapsChild[0].City = "";

                    Seq++;
                    InsertIntoDb(MinibusListSelectedTemp1, MapsChild[0]);
                    MapsChild[0].City = "";

                }



                //Seq++;
                //InsertIntoDb(MinibusListSelectedTemp, map);
                //map.City = "";



                item.City = "";
                continue;
            }


            if (CountOfMinibus < Configure.MinibusNumber)
            {

                int TempCount = 0;
                MinibusListSelected.Clear();
                foreach (var map in MapsChild)
                {

                    var MinibusListSelectedTemp = HasotTemplateList.Where(x => x.CityCode == map.City && x.HasotTime == map.Hour && x.StatusAction == 0 && x.Status != 2).OrderBy(x => x.HasotId).Take(Configure.MinibusNumber - CountOfMinibus).ToList();

                    //אם מדובר באותו מזהה מיניבוס 
                    if (TypeOfSymbol == 1)
                    {
                        CountOfMinibus = CountOfMinibus + MinibusListSelectedTemp.Count();
                        if (MinibusListSelectedTemp.Count() > 0)
                            MinibusimHasotTemplateList.AddRange(MinibusListSelectedTemp);

                    }




                    //  במידה ומדובר בחיפוש בילדים AA 
                    else if (TypeOfSymbol == 3 && MinibusListSelectedTemp.Count > TempCount)
                    {
                        MinibusListSelected = MinibusListSelectedTemp;

                        TempCount = MinibusListSelectedTemp.Count;
                    }


                    LastMap = map;
                }


                if (MinibusListSelected.Count() > 0 && TypeOfSymbol == 3)
                {
                    CountOfMinibus = CountOfMinibus + MinibusListSelected.Count();
                    MinibusimHasotTemplateList.AddRange(MinibusListSelected);
                }



            }

            foreach (var itemMapsChild in MapsChild)
            {
                itemMapsChild.City = "";
            }

            if (MinibusimHasotTemplateList.Count() > 0)
            {

                Seq++;
                InsertIntoDb(MinibusimHasotTemplateList, LastMap);
            }

            item.City = "";

        }


        //////********************************************* מוניות מלאות******************************************************************


        var GroupByMS = HasotTemplateList.Where(x => x.StatusAction == 0 && x.Status != 2).GroupBy(s => new { s.CityCode, s.HasotTime })
        .Select(gcs => new
        {
            Key = gcs.Key,
            CityCode = gcs.Key.CityCode,
            //   CityDesc = gcs.Key.CityDesc,
            HasotTime = gcs.Key.HasotTime,
            Children = gcs.ToList(),
            Count = gcs.ToList().Count,
            TaxiCount = gcs.ToList().Count / Configure.TaxiNumber
        }).ToList();


        var TaxiList = GroupByMS.Where(x => x.TaxiCount > 0).ToList();
        foreach (var item in TaxiList)
        {

            var MaslulId = GetMaslulId(item.CityCode, item.HasotTime);

            if (MaslulId != null)
            {
                List<HasotTemplate> TempHasotTemplateList = new List<HasotTemplate>();


                foreach (var e in item.Children)
                {
                    e.MaslulId = MaslulId;
                    e.CarTypeId = 1;

                    TempHasotTemplateList.Add(e);

                    if (TempHasotTemplateList.Count == Configure.TaxiNumber)
                    {
                        Seq++;
                        //while (DeletedSeq.Any(x => x == Seq))
                        //{
                        //    Seq++;
                        //}

                        InsertIntoDb(TempHasotTemplateList, null);
                        TempHasotTemplateList.Clear();
                        //

                    }
                }





            }



        }

        //////********************************************* עם איחודים מוניות******************************************************************


        var GroupByMSIhud = HasotTemplateList.Where(x => x.StatusAction == 0 && x.Status != 2).GroupBy(s => new { s.HasotTime })
         .Select(gcs => new
         {
             Key = gcs.Key,
             HasotTime = gcs.Key.HasotTime,
             Children = gcs.ToList(),
             Count = gcs.ToList().Count,
             TaxiCount = gcs.ToList().Count / Configure.TaxiNumber
         }).ToList();

        foreach (var group in GroupByMSIhud)
        {
            CityMaslulim cm = new CityMaslulim(group.Children.Count);
            cm.CityCodes = group.Children.Select(x => x.CityCode).ToList();
            cm.EmpNo = group.Children.Select(x => x.EmpNo).ToList();
            //   cm.MaslulId = group.Children.Select(0).ToList();


            GetMultiMaslulim(cm, group.HasotTime);

            // List<HasotTemplate> TempHasotTemplateList = new List<HasotTemplate>();


            for (int i = 0; i < group.Children.Count; i++)
            {

                if (cm.MaslulId[i] == 0)
                {

                    group.Children[i].MaslulId = null;


                }
                else
                {
                    group.Children[i].MaslulId = cm.MaslulId[i];
                }

            }

            int PrevMaslulId = 0;
            int Count = 0;
            List<HasotTemplate> TempHasotTemplateList = new List<HasotTemplate>();
            foreach (var item in group.Children.OrderBy(x => x.MaslulId))
            {

                if (item.MaslulId == null)
                {
                    Seq++;

                    TempHasotTemplateList.Add(item);

                    InsertIntoDb(TempHasotTemplateList, null);

                    TempHasotTemplateList.Clear();


                }
                else
                {

                    if (PrevMaslulId != item.MaslulId || Count == Configure.TaxiNumber)
                    {
                        if (TempHasotTemplateList.Count > 0)
                        {
                            Seq++;
                            SetTypeToAshkelon(TempHasotTemplateList);
                            InsertIntoDb(TempHasotTemplateList, null);
                            Count = 0;
                            TempHasotTemplateList.Clear();
                        }

                    }


                    TempHasotTemplateList.Add(item);
                    Count++;
                    PrevMaslulId = (int)item.MaslulId;

                }


            }

            if (TempHasotTemplateList.Count > 0)
            {
                Seq++;
                //while (DeletedSeq.Any(x => x == Seq))
                //{
                //    Seq++;
                //}

                SetTypeToAshkelon(TempHasotTemplateList);

                InsertIntoDb(TempHasotTemplateList, null);
                Count = 0;
                TempHasotTemplateList.Clear();
            }




        }


        if (CurrentHasotList.Count > 0)
        {
            //  List<string> HasotTemplateListEmpList = HasotTemplateList.Where(x => x.Status.In(1, 3)).Select(x => x.EmpNo).ToList();

            // מחיקה מהסידור
            foreach (var item in CurrentHasotList)
            {
                if (item.EmpNo == "52698" || item.EmpNo == "52664")
                {


                }

                if (item.EmpNo != "0" &&
                    item.Status.In(1, 3) &&
                    item.MaslulId != null &&
                    !HasotTemplateList.Any(x => x.EmpNo == item.EmpNo && x.MaslulId != null))
                {
                    // DataTable dt = Dal.ExeSp("Hasot_SetHasot", EmpId, Date, HasotTime, ShiftId, Dir, City, Mode, MaslulId, Comment, CarTypeId, CarSymbol, Seq, ExtraSapId, TempStreet, StartDate, EndDate, Mdest, Mprice, HasotId, Sap_Id, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
                    DataTable dt = Dal.ExeSp("Hasot_SetHasot", item.EmpNo, Date, "", ShiftId, Dir, "", 0, "", "", 0, "", Seq, 0, "", "", "", "", 0, 0, 99, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
                    item.Status = 2;
                    var CurrentHasotBySeq = CurrentHasotList.Where(x => x.Status != 2 && x.Seq == item.Seq).ToList();
                    if (item.CarTypeId == 2 || CurrentHasotBySeq.Count() == 0) continue;

                    ChangeMaslulIdAfterAll(CurrentHasotBySeq, item);




                }
            }


            // הוספה מהסידור
            foreach (var item in HasotTemplateList)
            {

                // 52698 - שלומי אוחנה
                // 52808 - שמעון רביבו
                // 52812 - איתי ביבי
                // 52664
                if (item.EmpNo == "52698" || item.EmpNo == "52722")
                {


                }

                // זה שנוסף בסידור וקיים בהיסעים
                var CurrentHasotListEmp = CurrentHasotList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault();

                // אם לא קיים תכניס אותו
                if (CurrentHasotListEmp == null) CurrentHasotListEmp = item;

                // אם מסלול ריק או שלא מקורי כיוון שאולי זיוה הכניסה ידנית אז אין מה לנגוע בו 
                if (!CurrentHasotListEmp.IsSource || item.MaslulId == null) continue;



                //  var ddddd = CurrentHasotList.Where(x => x.EmpNo == "52722").ToList();

                //52722 ערן אחרק

                // לא קיים בהסעות על אותו זמן
                // או קיים מחוק בהסעות
                // או שזמן הסעות שונה 
                if (!CurrentHasotList.Any(x => x.EmpNo == item.EmpNo && item.MaslulId != null && item.HasotTime == x.HasotTime) ||
                    (CurrentHasotListEmp.Status == 2 ||
                    item.HasotTime != CurrentHasotListEmp.HasotTime))
                {

                    //var CurrentHasotBySeq = CurrentHasotList.Where(x => x.Status != 2 && x.EmpNo != CurrentHasotListEmp.EmpNo && x.Seq == CurrentHasotListEmp.Seq && x.Seq > 0).ToList();

                    //if (CurrentHasotBySeq.Count() > 0 && CurrentHasotBySeq[0].CarTypeId == 1)
                    //    ChangeMaslulIdAfterAll(CurrentHasotBySeq, item);

                    //var SelectedHasa = CurrentHasotList.Where(x => x.Status != 2 && item.HasotTime == x.HasotTime && item.CityCode == x.CityCode).OrderByDescending(y => y.CarTypeId).ToList();

                    bool IsShibutz = false;

                    //foreach (var Hasa in SelectedHasa)
                    //{

                    //    var SelectedChooseHasa = CurrentHasotList.Where(x => x.Status != 2 && x.Seq == Hasa.Seq).ToList();
                    //    if (SelectedChooseHasa.Count() > 0)
                    //    {
                    //        var FirstHasa = SelectedChooseHasa[0];

                    //        if (
                    //            FirstHasa.Status.In(1, 3) &&
                    //            ((FirstHasa.CarTypeId == 1 && SelectedChooseHasa.Count() < Configure.TaxiNumber) ||
                    //            (FirstHasa.CarTypeId == 2 && SelectedChooseHasa.Count() < Configure.MinibusNumber))
                    //            )
                    //        {
                    //            InsertIntoDbAfterAll(item, Hasa);
                    //            Hasa.EmpNo = item.EmpNo;
                    //            Hasa.HasotTime = item.HasotTime;
                    //            CurrentHasotList.Add(Hasa);
                    //            IsShibutz = true;
                    //            break;
                    //        }
                    //    }


                    //}





                    var MinibusGroupBy = CurrentHasotList.Where(x => x.StatusAction == 0 && x.Status != 2 && x.MaslulId != null && x.CarTypeId == 2).GroupBy(s => new { s.Seq, s.HasotTime, s.MaslulId })
                                                    .Select(gcs => new
                                                    {
                                                        Key = gcs.Key,
                                                        Seq = gcs.Key.Seq,
                                                        HasotTime = gcs.Key.HasotTime,
                                                        MaslulId = gcs.Key.MaslulId,
                                                        Children = gcs.ToList(),
                                                        Count = gcs.ToList().Count,
                                                        TaxiCount = gcs.ToList().Count / Configure.MinibusNumber
                                                    }).ToList();

                    foreach (var group in MinibusGroupBy)
                    {
                        //CityMaslulim cm = new CityMaslulim(group.Children.Count);
                        //cm.CityCodes = group.Children.Select(x => x.CityCode).ToList();
                        //cm.EmpNo = group.Children.Select(x => x.EmpNo).ToList();
                        //cm.MaslulId = group.Children.Select(0).ToList();

                        //int? MaslulId = group.Children.Select(x => x.MaslulId).FirstOrDefault();

                        var MaslulimSearch = Maslulim.Where(x => x.Id == group.MaslulId && x.AllCity.Contains(item.CityCode) && item.HasotTime == group.HasotTime).FirstOrDefault();

                        if (MaslulimSearch != null)
                        {
                            var Hasa = (HasotTemplate)CurrentHasotList.Where(x => x.Seq == group.Seq).FirstOrDefault().Clone();

                            InsertIntoDbAfterAll(item, Hasa);
                            Hasa.EmpNo = item.EmpNo;
                            Hasa.HasotTime = item.HasotTime;
                            CurrentHasotList.Add(Hasa);

                            IsShibutz = true;
                            break;

                        }

                        //if(group.Count < Configure.MinibusNumber)


                        //GetMultiMaslulim(cm, group.HasotTime);

                    }


                    if (!IsShibutz)
                    {

                        var TaxiGroupBy = CurrentHasotList.Where(x => x.StatusAction == 0 && x.Status != 2 && x.MaslulId != null && x.CarTypeId == 1).GroupBy(s => new { s.Seq, s.HasotTime, s.MaslulId })
                                                    .Select(gcs => new
                                                    {
                                                        Key = gcs.Key,
                                                        Seq = gcs.Key.Seq,
                                                        HasotTime = gcs.Key.HasotTime,
                                                        MaslulId = gcs.Key.MaslulId,
                                                        Children = gcs.ToList(),
                                                        Count = gcs.ToList().Count,
                                                        TaxiCount = gcs.ToList().Count / Configure.TaxiNumber
                                                    }).ToList();

                        foreach (var group in TaxiGroupBy)
                        {

                            if (group.Count < Configure.TaxiNumber)
                            {

                                List<string> AllCities = group.Children.Select(x => x.CityCode).ToList();

                                if (AllCities.Contains(item.CityCode) && item.HasotTime == group.HasotTime)
                                {

                                    var HasaExist = (HasotTemplate)CurrentHasotList.Where(x => x.Seq == group.Seq && x.CityCode == item.CityCode).FirstOrDefault().Clone();

                                    HasaExist.EmpNo = item.EmpNo;
                                    HasaExist.HasotTime = item.HasotTime;
                                    HasaExist.CityCode = item.CityCode;

                                    InsertIntoDbAfterAll(item, HasaExist);

                                    CurrentHasotList.Add(HasaExist);

                                    IsShibutz = true;

                                    break;
                                }

                            }

                        }


                        foreach (var group in TaxiGroupBy)
                        {
                           
                            if(IsShibutz) break;

                            if (group.Count < Configure.TaxiNumber && group.HasotTime==item.HasotTime)
                            {

                                    List<string> AllCities = group.Children.Select(x => x.CityCode).ToList();

                                

                                    AllCities.Add(item.CityCode);
                                    int? NewMaslulId = GetNewMaslulIdByListAfterAllOnlyTwoUp(AllCities, item.HasotTime);

                                    if (NewMaslulId != null)
                                    {

                                        var Hasa = (HasotTemplate)(CurrentHasotList.Where(x => x.Seq == group.Seq).FirstOrDefault().Clone());
                                        //  var Hasa = new HasotTemplate();//
                                        // var Hasa =(HasotTemplate)HasaExist.Clone();

                                        Hasa.EmpNo = item.EmpNo;
                                        Hasa.HasotTime = item.HasotTime;
                                        Hasa.CityCode = item.CityCode;

                                        InsertIntoDbAfterAll(item, Hasa);

                                        CurrentHasotList.Add(Hasa);

                                        IsShibutz = true;

                                        string Sql = "Update Hasot Set MaslulId={0} Where HasotDate='{1}' and HasotTime='{2}' and ShiftId={3} and Dir={4} and Seq={5}";
                                        Sql = string.Format(Sql, NewMaslulId, item.HasotDate, item.HasotTime, item.ShiftId, item.Dir, group.Seq);
                                        Dal.ExecuteNonQuery(Sql);




                                        break;

                                        //foreach (var row in CurrentHasotBySeq)
                                        //{
                                        //    string Sql = "Update Hasot Set MaslulId={0} Where HasotId={1}";
                                        //    Sql = string.Format(Sql, NewMaslulId, row.HasotId);
                                        //    Dal.ExecuteNonQuery(Sql);
                                        //}

                                    }
                                

                            }

                        }






                    }






                    //if (SelectedHasa.Count() == 0 || !IsShibutz)
                    if (!IsShibutz)
                    {
                        int NewSeq = CurrentHasotList.Max(p => p.Seq);
                        item.Seq = NewSeq + 1;
                        item.MaslulId = GetMaslulId(item.CityCode, item.HasotTime);

                        if (item.MaslulId != null)
                        {

                            InsertIntoDbAfterAll(item, item);
                            CurrentHasotList.Add(item);

                        }


                    }


                }
            }

            // קטע
            var DiffFromHasotTemplate = CurrentHasotList.Where(x => x.Status.In(2, 4)).ToList();

            foreach (var item in DiffFromHasotTemplate)
            {

                string TextChange = "";

                var IsExistOrHourChange = HasotTemplateList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault();

                if (IsExistOrHourChange == null)
                {
                    if (string.IsNullOrEmpty(item.TextChange))
                        TextChange = "העובד אינו נמצא בסידור";
                    else TextChange = item.TextChange;
                }
                else
                {

                    if (IsExistOrHourChange.HasotTime != item.HasotTime)
                    {

                        if (IsExistOrHourChange.AddedHours < 0)
                        {
                            TextChange = "העובד יצא להיעדרות: " + IsExistOrHourChange.AddedHours;

                        }
                        else
                        {

                            TextChange = "השעה בסידור שונתה ל: " + IsExistOrHourChange.HasotTime.Value.ToString(@"hh\:mm");
                        }



                    }

                }


                if (!string.IsNullOrEmpty(TextChange) || !string.IsNullOrEmpty(item.TextChange))
                {
                    string Sql = "Update Hasot Set TextChange='{0}' Where HasotId={1}";
                    Sql = string.Format(Sql, TextChange, item.HasotId);
                    Dal.ExecuteNonQuery(Sql);


                }



            }


        }

        // מכניס את כל העובדים שהולחפו ולא ביוזמת החברה
        var WorkersSwapOnWorkersOnly = MishmarotWorkers.Where(x => (!string.IsNullOrEmpty(x.SwapEmpNo) && (x.IsAsterisk == 0 && x.AddedHours == 0))).ToList();
        foreach (var item in WorkersSwapOnWorkersOnly)
        {
            if (!HasotTemplateList.Any(x => x.EmpNo == item.EmpNo) && !CurrentHasotList.Any(x => x.EmpNo == item.EmpNo))
            {
                // DataTable dt = Dal.ExeSp("Hasot_SetHasot", EmpId, Date, HasotTime, ShiftId, Dir, City, Mode, MaslulId, Comment, CarTypeId, CarSymbol, Seq, ExtraSapId, TempStreet, StartDate, EndDate, Mdest, Mprice, HasotId, Sap_Id, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
                DataTable dt = Dal.ExeSp("Hasot_SetHasot", item.EmpNo, Date, "", ShiftId, Dir, item.CityCode, 16, "", "עובד הוחלף שלא ביוזמת החברה", 0, "", 0, 0, "", "", "", "", 0, 0, 99, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

            }


        }


    }

    //שינוי אחרי שכבר בוצעו כל ההשמות בעיקר לשינויים 
    private void ChangeMaslulIdAfterAll(List<HasotTemplate> CurrentHasotBySeq, HasotTemplate item)
    {
        int NewMaslulId = GetNewMaslulIdByListAfterAll(CurrentHasotBySeq.Select(x => x.CityCode).ToList(), item.HasotTime);
        foreach (var row in CurrentHasotBySeq)
        {
            string Sql = "Update Hasot Set MaslulId={0},ExtraSapId=991 Where HasotId={1}";
            Sql = string.Format(Sql, NewMaslulId, row.HasotId);
            Dal.ExecuteNonQuery(Sql);
        }
    }

    // הכנסה לבסיס נתונים
    private void InsertIntoDbAfterAll(HasotTemplate item, HasotTemplate Hasa)
    {
        DataTable dt = Dal.ExeSp("Hasot_SetHasot", item.EmpNo, Date, item.HasotTime, ShiftId, Dir, Hasa.CityCode, 1, Hasa.MaslulId, (Hasa.Comment == null) ? "" : Hasa.Comment, Hasa.CarTypeId, (Hasa.CarSymbol == null) ? "" : Hasa.CarSymbol, Hasa.Seq, 0, "", "", "", "", 0, 0, 99, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

    }

    // קבלת המסלול המתאים ביותר
    private int GetNewMaslulIdByListAfterAll(List<string> AllCityInSeq, TimeSpan? HasotTime)
    {
        int? Type = GetTypeMaslulId(AllCityInSeq[0], HasotTime);
        int res = 0;
        var MaslulimSearch = Maslulim.Where(x => !x.IsOnlyMinibus && x.Type == null).ToList();
        if (Type != 0) MaslulimSearch = Maslulim.Where(x => !x.IsOnlyMinibus && x.Type == Type).ToList();
        foreach (var item in MaslulimSearch.OrderByDescending(x => x.AllCity.Count))
        {
            IEnumerable<string> both = item.AllCity.Intersect(AllCityInSeq);

            if (both.Count() > 1)
            {
                return item.Id;

            }

            if (both.Count() == 1)
            {
                res = item.Id;

            }



            //if (both.Count() == AllCityInSeq.Count)
            //    return item.Id;

        }

        return res;
    }

    // קבלת המסלול המתאים ביותר
    private int? GetNewMaslulIdByListAfterAllOnlyTwoUp(List<string> AllCityInSeq, TimeSpan? HasotTime)
    {
        int? Type = GetTypeMaslulId(AllCityInSeq[0], HasotTime);
        int? res = null;
        var MaslulimSearch = Maslulim.Where(x => !x.IsOnlyMinibus && x.Type == null).ToList();
        if (Type != 0) MaslulimSearch = Maslulim.Where(x => !x.IsOnlyMinibus && x.Type == Type).ToList();
        foreach (var item in MaslulimSearch.OrderByDescending(x => x.AllCity.Count))
        {
            IEnumerable<string> both = item.AllCity.Intersect(AllCityInSeq);

            if (both.Count() > 1)
            {
                return item.Id;

            }


        }

        return res;
    }




    // קבלת המספר מיניבוס
    private int GetTypeOfSymbol(string carSymbol)
    {
        if (carSymbol.Length == 1) return 1;

        char[] characters = carSymbol.ToCharArray();

        char PrevChar = characters[0];

        for (int i = 1; i < characters.Length; i++)
        {
            if (characters[i] != PrevChar) return 2;
        }

        return 3;


    }

    // מספר מיוחד להסעות מסוג אשקלון
    private void SetTypeToAshkelon(List<HasotTemplate> TempHasotTemplateList)
    {
        int Counter = 0; //TempHasotTemplateList.Count();
        int NewMaslulId = 0;
        foreach (var item in TempHasotTemplateList)
        {
            int? Type = GetTypeMaslulId(item.CityCode, item.HasotTime);
            if (Type == 2)
            {
                var MaslulimSearch = Maslulim.Where(x => x.Type == 2 && x.AllCity.Exists(y => y == item.CityCode)).FirstOrDefault();
                if (MaslulimSearch != null)
                {
                    NewMaslulId = MaslulimSearch.Id;
                    Counter++;
                }
            }

        }


        if (Counter == TempHasotTemplateList.Count)
        {
            foreach (var item in TempHasotTemplateList)
            {
                item.MaslulId = NewMaslulId;
            }
        }
    }

    // קבלת איסוף זמן 
    private TimeSpan? GetIsIsufTime(TimeSpan? hasotTime, int? maslulId)
    {

        var res = hasotTime;
        if (Dir == 1) return res;

        var MaslulimData = Maslulim.Where(x => x.Id == maslulId).FirstOrDefault();

        if (MaslulimData != null && MaslulimData.TimeBeforeTaxi != null)
        {
            res = Helper.AddMinutes((TimeSpan)hasotTime, (Int32)(MaslulimData.TimeBeforeTaxi));

        }
        return res;

    }

    // בשביל הפיתוח קבלת שם עיר מתוך איידי
    private string GetCityDescFromMaslulForDev(string cityCode)
    {
        var Maslul = Maslulim.Where(x => x.City1 == cityCode && x.City2 == "").FirstOrDefault();
        if (Maslul != null)
        {

            return Maslul.MaslulDesc;

        }
        else
        {
            return null;

        }
    }

    // מחיקה
    private void DeleteListFromDb(HasotTemplate ht)
    {

        string sql = @"delete from Hasot where Dir={0} and ShiftId={1} and HasotDate='{2}' and EmpNo={3}";
        sql = string.Format(sql, this.Dir, this.ShiftId, ht.HasotDate, ht.EmpNo);

        Dal.ExecuteNonQuery(sql);

    }

    // קבלת סוג יום מתוך מסלול בהתאם לשעה וסוג היום
    private int? GetTypeMaslulId(string cityCode, TimeSpan? HasotTime)
    {
        bool IsYom6AndLayla = false;

        TimeSpan StartTime;
        TimeSpan EndTime;

        if (CurrentDayInWeek == 6)
        {

            if (ShiftId == 3 && Dir == 1)
            {
                IsYom6AndLayla = true;
            }
            else
            {
                StartTime = new TimeSpan(0, 17, 0, 0);
                EndTime = new TimeSpan(0, 21, 0, 0);
                IsYom6AndLayla = CalculateDalUren(HasotTime, StartTime, EndTime);

            }
        }

        //במידה וזה איסוף של לילה 
        if (CurrentDayInWeek == 7)
        {
            if (ShiftId == 3 && Dir == 1 && TomorrowDayType!=9)
            {
                CurrentDayInWeek = 15;
            }
        }

        if (CurrentDayInWeek == 7 || (CurrentDayInWeek == 6 && IsYom6AndLayla))
        {


            return 1;
        }
        else
        {
            bool IsBetween_15_18 = false;
            bool IsBetween_21_05 = false;


            //************************  בדיקה נסיעה של אשקלון בין 15 ל 18

            if (AshkelonCityCode.Contains(cityCode))
            {
                StartTime = new TimeSpan(0, 15, 00, 0);
                EndTime = new TimeSpan(0, 18, 0, 0);
                IsBetween_15_18 = CalculateDalUren(HasotTime, StartTime, EndTime);
                if (IsBetween_15_18)
                {
                    return 2;
                }
            }

            //************************  בדיקה נסיעה של  בין 21 ל 5
            StartTime = new TimeSpan(0, 21, 0, 0);
            EndTime = new TimeSpan(1, 5, 30, 0);
            var candidateTime = HasotTime;

            if (candidateTime.Value.Hours <= 5)
            {
                candidateTime = candidateTime.Value.Add(new TimeSpan(1, 0, 0, 0));
            }


            IsBetween_21_05 = CalculateDalUren(candidateTime, StartTime, EndTime);

            if (IsBetween_21_05) return 1;

            return null;

        }
    }



    //קבלת מסלול בהתאם לעיר
    private int? GetMaslulId(string cityCode, TimeSpan? HasotTime)
    {
        int? Type = GetTypeMaslulId(cityCode, HasotTime);
        if (Type == 2)
        {
            var MaslulAshkelon = Maslulim.Where(x => !x.IsOnlyMinibus && x.Type == 2 && x.AllCity.Contains(cityCode)).FirstOrDefault();
            if (MaslulAshkelon != null)
            {

                return MaslulAshkelon.Id;
            }
            else
            {
                return null;

            }
        }


        var Maslul = Maslulim.Where(x => !x.IsOnlyMinibus && x.City1 == cityCode && x.Type == Type && x.City2 == "").FirstOrDefault();
        if (Maslul != null)
        {

            return Maslul.Id;

        }
        else
        {
            return null;

        }
    }

    // קבלת מסלול מתוך רשימת ערים 
    private void GetMultiMaslulim(CityMaslulim cm, TimeSpan? HasotTime)
    {
        // פה סתם שמתי את אשדוד רק כדי לקבל את הסוג של היום
        int? Type = GetTypeMaslulId(AshdodCityCode, HasotTime);

        var MaslulimSearch = Maslulim.Where(x => !x.IsOnlyMinibus && x.Type == null).ToList();
        if (Type == 1) MaslulimSearch = Maslulim.Where(x => !x.IsOnlyMinibus && x.Type == 1).ToList();
        foreach (var item in MaslulimSearch.OrderBy(x => x.AllCity.Count).ThenBy(x => x.Tarif))
        {




            IEnumerable<string> both = item.AllCity.Intersect(cm.CityCodes);

            // if (both.Count() > 1) continue;

            List<int> CountList = new List<int>();
            // string PrevCity = "";
            foreach (var city in both)
            {
                for (int i = 0; i < cm.CityCodes.Count; i++)
                {
                    if (cm.CityCodes[i] == city && CountList.Count < Configure.TaxiNumber && (both.Count() > cm.Count[i] || cm.Count[i] == 0))
                    {

                        CountList.Add(i);
                        //PrevCity = city;
                        //cm.MaslulId[i] = item.Id;
                        //cm.Count[i] = both.Count();
                    }
                }
            }


            if (CountList.Count > 0 && CountList.Count >= both.Count())
            {

                if (both.Count() > 1)
                {
                    var Count = 0;

                    List<int> TempMaslulIdList = new List<int>();
                    foreach (var itemI in CountList)
                    {

                        var TempMaslulId = cm.MaslulId[itemI];

                        if (!TempMaslulIdList.Exists(x => x == TempMaslulId))
                        {

                            Count += cm.MaslulId.Where(x => x == TempMaslulId).Count();

                            TempMaslulIdList.Add(TempMaslulId);
                        }


                        //var TempCount
                    }


                    if (Count > Configure.TaxiNumber) continue;

                }



                foreach (var itemI in CountList)
                {
                    cm.MaslulId[itemI] = item.Id;
                    cm.Count[itemI] = both.Count();
                }
            }

        }
    }

    // הכנסה ראשית לבסיס נתונים
    private void InsertIntoDb(List<HasotTemplate> minibusList, Maps item, bool IsSeqFromMap = false, bool IsSeqFromHasotTemplate = false)
    {
        int? CarTypeId = 1;
        int SeqInner = Seq;
        var CarSymbol = "";

        if (item != null)
        {
            if (!IsSeqFromMap)
            { item.Seq = Seq; }

            CarTypeId = item.CarTypeId;
            SeqInner = item.Seq;
            CarSymbol = item.CarSymbol;

        }


        int NewMaslulId = 0;



        if (CarTypeId == 2)
        {
            //if (CarSymbol == "D")
            //{


            //}

            var AllCityInSeq = minibusList.Select(x => x.CityCode).Distinct().ToList();
            NewMaslulId = GetNewMaslulIdByList(AllCityInSeq);



        }





        foreach (var ht in minibusList)
        {

            if (NewMaslulId != 0) ht.MaslulId = NewMaslulId;

            if (IsSeqFromHasotTemplate) SeqInner = ht.Seq;

            ht.Map = item;

            if (this.Dir == 0 && ht.StatusAction != 1)
            {



                var Maslul = Maslulim.Where(x => x.Id == ht.MaslulId).FirstOrDefault();
                if (Maslul != null && Maslul.TimeBeforeTaxi != null)
                {
                    ht.HasotTime = ht.HasotTime.Value.Add(TimeSpan.FromMinutes(-1 * (int)Maslul.TimeBeforeTaxi));

                }


            }
            ht.StatusAction = 1;



            if (ht.StatusDelete != 1)
            {
                var ExistSeqOfDelete = HasotTemplateList.Where(x => x.StatusDelete == 1 && x.Seq == SeqInner).FirstOrDefault();
                if (ExistSeqOfDelete != null)
                {
                    Seq++;
                    SeqInner++;
                }

            }

            ht.CarTypeId = CarTypeId;
            ht.Seq = SeqInner;
            if (CurrentHasotList.Count == 0)
            {
                string sql = @"insert into {17}(Dir, ShiftId, EmpNo, IsYom, CityCode, HasotDate, HasotTime,CarTypeId,MaslulId,Seq,CarSymbol,UpdateBy,UpdateTimeStamp,Status,IsSource,StatusDelete,Comment,TempStreet,Mdest,Mprice,TextChange)
                                values({0},{1},{2},{3},'{4}','{5}','{6}',{7},{8},{9},'{10}',{11},'{12}',{13},{14},{15},'{16}',NULLIF('{18}',''),NULLIF('{19}',''),{20},NULLIF('{21}',''));  ";

                sql += @"insert into Hasot_Log(Dir, ShiftId, EmpNo, City, HasotDate, HasotTime,CarTypeId,MaslulId,Seq,CarSymbol,UpdateBy,Comment,TempStreet,Mdest,Mprice,[TimeStamp])
                                values({0},{1},{2},'{4}','{5}','{6}',{7},{8},{9},'{10}',{11},'{16}',NULLIF('{18}',''),NULLIF('{19}',''),{20},'{12}');  ";






                sql = string.Format(sql, this.Dir, this.ShiftId, ht.EmpNo, (ht.IsYom ? 1 : 0), ht.CityCode, ht.HasotDate, ht.HasotTime, CarTypeId,
                    ((ht.MaslulId == null) ? "null" : ht.MaslulId.ToString()), SeqInner, CarSymbol, UserId, UpdateTimeStamp, ht.Status, ((ht.IsSource) ? 1 : 0), ht.StatusDelete
                    , ht.Comment, ((CurrentHasotList.Count > 0) ? "Hasot" : "Hasot"), ht.TempStreet, ht.Mdest, ht.Mprice, ((ht.AddedHours < 0) ? ("העובד יצא להיעדרות: " + ht.AddedHours) : ""));

                Dal.ExecuteNonQuery(sql);

            }
        }
    }

    // קבלת האם שעה נמצא בין שתי תחומים
    public Boolean CalculateDalUren(TimeSpan? candidateTime, TimeSpan? StartTime, TimeSpan? EndTime)
    {




        if (StartTime < EndTime)
        {
            // Normal case, e.g. 8am-2pm
            return StartTime <= candidateTime && candidateTime < EndTime;
        }
        else
        {
            // Reverse case, e.g. 10pm-2am
            return StartTime <= candidateTime || candidateTime < EndTime;
        }
    }

    // מסלול חדש
    private int GetNewMaslulIdByList(List<string> AllCityInSeq)
    {

        var MaslulimList = Maslulim.Where(x => x.Type != 1).OrderBy(x => x.AllCity.Count).ToList();
        foreach (var item in MaslulimList.OrderBy(x => x.AllCity.Count))
        {
            IEnumerable<string> both = item.AllCity.Intersect(AllCityInSeq);

            if (both.Count() > 1)
                return item.Id;

            //if (both.Count() == AllCityInSeq.Count)
            //    return item.Id;

        }

        return 0;
    }

    // קבלת מפה מעודכנת מתאימה לעיר ולזמן
    private List<Maps> GetCurrentMaps()
    {


        var ReturnMap = Maps.Where(x => x.DayInWeek == CurrentDayInWeek &&
                                                x.ShiftId == this.ShiftId &&

                                                x.Type == Dir
                                                ).OrderByDescending(x => x.CarSymbol.Length).ToList();


        return ReturnMap;
    }


    // קבלת מיפוי מתאים 
    public List<Maps> CurrentCarList = new List<Maps>();
    public int Seq = 0;
    private Maps GetMap(int IsOvdeYom, int? IsImahot, TimeSpan? StartTime, string CityCode)
    {
        var CurrentDayInWeek = (this.DayId < 6) ? 15 : this.DayId;

        if (!string.IsNullOrEmpty(this.HolidayCode))
        {
            if (this.DayType == 8) CurrentDayInWeek = 6;
            if (this.DayType.In(5, 9)) CurrentDayInWeek = 7;
        }


        var ReturnMap = Maps.Where(x => x.DayInWeek == CurrentDayInWeek &&
                                                x.ShiftId == this.ShiftId &&
                                                x.Hour == StartTime &&
                                                (x.IsOvdeYom == IsOvdeYom || x.IsOvdeYom == null) &&
                                                (x.IsImahot == IsImahot || x.IsImahot == null) &&
                                                (x.OnlyDays.Contains(this.DayHebrew) || x.OnlyDays == "") &&
                                                x.City == CityCode &&
                                                x.Type == Dir
                                                ).FirstOrDefault();

        var IsExist = CurrentCarList.Any(x => x.City == CityCode && x.Hour == StartTime);
        if (!IsExist)
        {
            Seq++;
            var NewMap = new Maps();
            NewMap.Id = Seq;
            NewMap.City = CityCode;
            NewMap.Hour = StartTime;
            NewMap.Count = (ReturnMap == null) ? Configure.TaxiNumber : (int)ReturnMap.Count;
            NewMap.CurrentCount = 0;
            NewMap.CarTypeId = (ReturnMap == null) ? 1 : (int)ReturnMap.CarTypeId;
            NewMap.CarSymbol = (ReturnMap == null) ? "" : ReturnMap.CarSymbol;
            CurrentCarList.Add(NewMap);

        }

        //if (ReturnMap != null && ReturnMap.CarTypeId==2 && !CurrentMinibusList.Contains(ReturnMap))
        //{
        //    CurrentMinibusList.Add(ReturnMap);

        //}



        return ReturnMap;
    }

    //private int? GetMapsId()
    //{

    //    var Map = Maps.Where(x=>x.Type==Dir && x.DayInWeek)
    //}
    // במשמרות קבלת סוג משמרת בפועל האם שעות נוספות וכו...
    private int GetPrevNextShift(MishmarotWorkers x)
    {


        if (x.SourceShiftDate == null) return 0;

        // כאן אם זה הקדמתי ממשמרת הבאה
        if (x.SourceShiftDate > x.ShiftDate || (x.SourceShiftDate == x.ShiftDate && x.SourceShiftCode > x.ShiftCode)) return 1;

        // כאן זה אם נשארתי שעות נוספות מהמשמרת הקודמת
        if (x.SourceShiftDate < x.ShiftDate || (x.SourceShiftDate == x.ShiftDate && x.SourceShiftCode < x.ShiftCode)) return -1;


        return 0;
    }

    // במשמרות קבלת סוג משמרת בפועל האם שעות נוספות וכו...
    private int GetPrevNextShiftPrevNext(MishmarotWorkers x)
    {


        if (x.SourceShiftDatePrevNext == null) return 0;

        // כאן אם זה הקדמתי ממשמרת הבאה
        if (x.SourceShiftDatePrevNext > x.ShiftDate || (x.SourceShiftDatePrevNext == x.ShiftDate && x.SourceShiftCodePrevNext > x.ShiftCode)) return 1;

        // כאן זה אם נשארתי שעות נוספות מהמשמרת הקודמת
        if (x.SourceShiftDatePrevNext < x.ShiftDate || (x.SourceShiftDatePrevNext == x.ShiftDate && x.SourceShiftCodePrevNext < x.ShiftCode)) return -1;


        return 0;
    }


    // פונקציה שמחזירה למסך את כל ההסעות שבוצעו
    public DataTable GetFINALDataFroMHasot()
    {

        DataSet ds = Dal.ExeDataSetSp("Hasot_BindMaslul", Date, ShiftId, Dir);

        return ds.Tables[0];
    }

}

