//using System;
//using System.Collections.Generic;
//using System.Data;
//using System.Linq;
//using System.Web;

///// <summary>
///// Summary description for Hasot
///// </summary>
//public class Hasot
//{


//    //public DataTable dtEmpHasot;
//    //public DataTable dtCountInCity;
//    //public DataTable dtMaslulim;
//    public int DayId; // יום בשבוע
//    public string DayHebrew; // יום בשבוע
//    public string HolidayCode; // אם נופל על חג
//    public int? DayType; // אם נופל על חג
//    public int Dir;
//    public string Date;
//    public int ShiftId;
//    public string AshdodCityCode = "000000000070";
//    public int MaslulIdForMeyuhedet;

//    public string[] AshkelonCityCode = new string[] { "000000007110", "000000007120", "000000007130" };

//    public int CurrentDayInWeek; //שקלול אם נופל בחג
//    public string UserId = "";
//    public DateTime UpdateTimeStamp;

//    List<MishmarotWorkers> MishmarotWorkers = new List<MishmarotWorkers>();
//    List<OvdeYomWorkers> OvdeYomWorkers = new List<OvdeYomWorkers>();
//    List<Maps> Maps = new List<Maps>();
//    List<Area> Area = new List<Area>();
//    List<Maslulim> Maslulim = new List<Maslulim>();
//    List<Shift> Shift = new List<Shift>();
//    List<ShiftTimes> ShiftTimes = new List<ShiftTimes>();
//    List<HasotTemplate> HasotTemplateList = new List<HasotTemplate>();
//    List<HasotTemplate> CurrentHasotList = new List<HasotTemplate>();

//    // List<CurrentHasotTemp> CurrentHasotTempList = new List<CurrentHasotTemp>();

//    List<CarsBindToEmpNo> CarsBindToEmpNo = new List<CarsBindToEmpNo>();
//    List<Shift> ShiftReal = new List<Shift>();
//    Configure Configure;


//    public Hasot(DataSet ds, string Direction, string Date, string ShiftId)
//    {

//        this.Dir = Helper.ConvertToInt(Direction);
//        this.Date = Date;
//        this.ShiftId = Helper.ConvertToInt(ShiftId);
//        UserId = HttpContext.Current.Request.Cookies["UserData"]["UserId"];
//        UpdateTimeStamp = DateTime.Now;
//        if (ds.Tables.Count > 5)
//        {

//            foreach (DataRow row in ds.Tables[0].Rows)
//            {
//                MishmarotWorkers Obj = new MishmarotWorkers(row);

//                if (!MishmarotWorkers.Exists(x => x.EmpNo == Obj.EmpNo))
//                    MishmarotWorkers.Add(Obj);
//            }

//            foreach (DataRow row in ds.Tables[1].Rows)
//            {
//                OvdeYomWorkers Obj = new OvdeYomWorkers(row);
//                OvdeYomWorkers.Add(Obj);
//            }

//            Configure = new Configure(ds.Tables[7].Rows[0]);

//            foreach (DataRow row in ds.Tables[2].Rows)
//            {
//                Maps Obj = new Maps(row, Configure);
//                Maps.Add(Obj);
//            }

//            foreach (DataRow row in ds.Tables[3].Rows)
//            {
//                Area Obj = new Area(row);
//                Area.Add(Obj);
//            }

//            foreach (DataRow row in ds.Tables[4].Rows)
//            {
//                Maslulim Obj = new Maslulim(row);
//                Maslulim.Add(Obj);

//                if (Obj.Sap_Id == 99)
//                    MaslulIdForMeyuhedet = Obj.Id;

//            }




//            foreach (DataRow row in ds.Tables[5].Rows)
//            {
//                Shift Obj = new Shift(row);
//                Shift.Add(Obj);
//            }

//            foreach (DataRow row in ds.Tables[6].Rows)
//            {
//                ShiftTimes Obj = new ShiftTimes(row);

//                DayId = Obj.DayId;
//                DayHebrew = GetHebrewDay(DayId);
//                HolidayCode = Obj.HolidayCode;
//                DayType = Obj.DayType;// האם ערב חג או חג עצמו 
//                                      // 8 ערב חג
//                                      // 9 חג עצמו
//                                      // 5 בחירות


//                CurrentDayInWeek = (this.DayId < 6) ? 15 : this.DayId;

//                if (!string.IsNullOrEmpty(this.HolidayCode))
//                {
//                    if (this.DayType == 8) CurrentDayInWeek = 6;
//                    if (this.DayType.In(5, 9)) CurrentDayInWeek = 7;
//                }




//                ShiftTimes.Add(Obj);
//            }


//            foreach (DataRow row in ds.Tables[8].Rows)
//            {
//                HasotTemplate Obj = new HasotTemplate(row);
//                CurrentHasotList.Add(Obj);
//            }



//            this.ShiftReal = this.Shift.Where(x => x.ShiftId.In(1, 2, 3) && x.TypeId.In(1, 2)).ToList();


//        }
//    }

//    private string GetHebrewDay(int dayId)
//    {
//        switch (dayId)
//        {
//            case 1:
//                return "א";
//            case 2:
//                return "ב";
//            case 3:
//                return "ג";
//            case 4:
//                return "ד";
//            case 5:
//                return "ה";
//            case 6:
//                return "ו";
//            case 7:
//                return "ז";

//            default:
//                return "";

//        }
//    }

//    public void BindMaslulToTaxi()
//    {

//        TimeSpan? CurrentTime;




//        // שליפה מעובדי משמרת
//        var Workers = MishmarotWorkers.Where(x => //(
//                                                  //  (GetPrevNextShift(x) == ((Dir == 0) ? 1 : -1)) && x.AddedHours > 0)
//                                                (
//                                                  (x.CityCode != AshdodCityCode || x.AddedHours > 0) &&
//                                                  (string.IsNullOrEmpty(x.SwapEmpNo) || (!string.IsNullOrEmpty(x.SwapEmpNo) && x.IsAsterisk == 1))
//                                                  ) //מחוץ לאשדוד והוא לא החליף ביוזמתו
//                                                ||
//                                                (x.SourceAssignmentId == 0 && x.CityCode != AshdodCityCode)
//                                                // || (x.CityCode == AshdodCityCode && x.AddedHours > 0 && GetPrevNextShift(x) == ((Dir == 0) ? 1 : -1))  // הוא מקדים ממשמרת הבאה
//                                                || (x.CityCode == AshdodCityCode && x.RealShiftCode.In(5, 6))
//                                                ).OrderBy(x=>x.HasotId).ToList();


//        foreach (var item in Workers)
//        {



//            // אם משמרת נוכחית הוא הקדים או נשאר
//            // -1 הקדמתי 
//            //  1 נשארתי שעות נוספות
//            var PrevNextShift = GetPrevNextShift(item);
//            if ((Dir == 1 && PrevNextShift == 1) || (Dir == 0 && PrevNextShift == -1)) continue;

//            // משמרת מקורית לא צריך לדאוג לו מאחר והוא כבר 
//            var PrevNextShiftPrevNext = GetPrevNextShiftPrevNext(item);
//            if ((Dir == 1 && PrevNextShiftPrevNext == 1) || (Dir == 0 && PrevNextShiftPrevNext == -1)) continue;

//            var CurrentShift = Shift.Where(x => x.TypeId == 1 && x.ShiftId == item.RealShiftCode).FirstOrDefault();

//            if (Dir == 0 && PrevNextShift == 0 || (Dir == 1 && PrevNextShift == -1))
//                CurrentTime = Helper.AddHours((TimeSpan)CurrentShift.StartTime, ((item.AddedHours == null) ? 0 : (int)item.AddedHours));
//            else
//                CurrentTime = Helper.AddHours((TimeSpan)CurrentShift.EndTime, ((item.AddedHours == null) ? 0 : -1 * (int)item.AddedHours));



//            HasotTemplate ht = new HasotTemplate();
//            ht.CityCode = item.CityCode;

//            ht.CityDesc = GetCityDescFromMaslulForDev(item.CityCode);

//            ht.Dir = this.Dir;
//            ht.EmpNo = item.EmpNo;

//            ht.FullName = item.FullName;

//            ht.HasotDate = Helper.ConvertToDateTime(this.Date);
//            ht.HasotTime = CurrentTime;
//            ht.IsYom = false;
//            ht.ShiftId = this.ShiftId;
//            // ht.Map = GetMap(0, 0, StartTime, item.CityCode);
//            //if (ht.Map != null)
//            //{

//            //    ht.CarTypeId = ht.Map.CarTypeId;
//            //}
//            //else
//            //{
//            //    ht.CarTypeId = 1;

//            //}

//            ht.StatusAction = ((item.AddedHours < 0) ? 1 : 0);

//            ht.MaslulId = ((item.AddedHours < 0) ? null : GetMaslulId(item.CityCode, ht.HasotTime));


//            HasotTemplateList.Add(ht);

//        }

//        //במידה ומדובר ביום חול ולא בשבת או חג
//        if (!DayId.In(6, 7) && string.IsNullOrEmpty(HolidayCode))
//        {
//            // שליפת עובדי יום
//            var OvdeYom = OvdeYomWorkers.Where(x => x.TypeId > 1 && ShiftId == 1 && !Workers.Select(y => y.EmpNo).Contains(x.EmpNo)).ToList();
//            foreach (var item in OvdeYom)
//            {

//                //if (item.EmpNo == "53329")
//                //{

//                //}
//                // אמהות עובדות מאשדוד איסוף ל7:45 אמהות עובדות מחוץ לאשדוד כמו המשמרת
//                var CurrentShift = Shift.Where(x => x.TypeId == item.TypeId && x.ShiftId == ShiftId).FirstOrDefault();
//                CurrentTime = (this.Dir == 0) ? CurrentShift.StartTime : CurrentShift.EndTime;

//                // במידה והעובד מאשדוד ויש הסעות רגילות לא מגיע עם הסעות
//                if (item.CityCode == AshdodCityCode && (this.ShiftReal.Select(x => x.StartTime).Contains(CurrentTime) ||
//                                                    this.ShiftReal.Select(x => x.EndTime).Contains(CurrentTime))
//                                                    )
//                {
//                    continue;
//                }

//                if (this.DayId == 5 && this.Dir == 1 && (item.TypeId.In(2, 4))) CurrentTime = CurrentTime.Value.Add(TimeSpan.FromMinutes(-30));

//                HasotTemplate ht = new HasotTemplate();
//                ht.CityCode = item.CityCode;
//                ht.CityDesc = GetCityDescFromMaslulForDev(item.CityCode);
//                ht.Dir = this.Dir;
//                ht.EmpNo = item.EmpNo;
//                ht.HasotDate = Helper.ConvertToDateTime(this.Date);
//                ht.HasotTime = CurrentTime;
//                ht.IsYom = true;
//                ht.ShiftId = this.ShiftId;

//                int Imahot = (item.IsImahot > 1) ? 1 : 0;

//                ht.MaslulId = GetMaslulId(item.CityCode, ht.HasotTime);

//                HasotTemplateList.Add(ht);

//            }

//        }

//        var HasotTemplateListHeadrut = HasotTemplateList.Where(x => x.StatusAction == 1).ToList();
//        InsertIntoDb(HasotTemplateListHeadrut, null);





//        if (CurrentHasotList.Count > 0)
//        {
//            foreach (var item in CurrentHasotList)
//            {
//                //if (item.EmpNo == "51941")
//                //{


//                //}

//                if ((item.Status == 2 && !item.IsSource) || item.MaslulId == MaslulIdForMeyuhedet )
//                {
//                    var IsNewInCurrent = HasotTemplateList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault();
//                    //IsNewInCurrent.StatusAction = 1;
//                    //IsNewInCurrent.Status = 2;
//                    // IsNewInCurrent.IsSource = 2;
//                    HasotTemplateList.Remove(IsNewInCurrent);

//                }
//                else
//                {

//                    var TempHasotTemplate = HasotTemplateList.Where(x => x.EmpNo == item.EmpNo && x.Status == 1).FirstOrDefault();

//                    if (TempHasotTemplate != null)
//                    {
//                        if (item.CityCode != TempHasotTemplate.CityCode || item.HasotDate != TempHasotTemplate.HasotDate || item.HasotTime != TempHasotTemplate.HasotTime)
//                        {
//                            TempHasotTemplate.CityCode = item.CityCode;

//                            if (item.Status == 4)
//                            {
//                                TempHasotTemplate.HasotDate = item.HasotDate;
//                                TempHasotTemplate.HasotTime = item.HasotTime;

//                            }


//                            TempHasotTemplate.MaslulId = item.MaslulId;
//                            TempHasotTemplate.IsSource = item.IsSource;
//                        }
//                        if (item.IsSource && item.Status == 2)
//                        {
//                            TempHasotTemplate.Status = 3;
//                        }
//                        else
//                        {
//                            TempHasotTemplate.Status = item.Status;

//                        }


//                    }
//                    else
//                    {
//                        if (item.IsSource || item.EmpNo=="0") continue;

//                        TempHasotTemplate = new HasotTemplate();

//                        TempHasotTemplate.CityCode = item.CityCode;
//                        TempHasotTemplate.Dir = item.Dir;
//                        TempHasotTemplate.EmpNo = item.EmpNo;
//                        TempHasotTemplate.HasotDate = item.HasotDate;
//                        TempHasotTemplate.HasotTime = item.HasotTime;
//                        TempHasotTemplate.IsYom = item.IsYom;
//                        TempHasotTemplate.ShiftId = item.ShiftId;
//                        //TempHasotTemplate.MaslulId = item.MaslulId;
//                        TempHasotTemplate.Status = 3;
//                        TempHasotTemplate.StatusDelete = item.StatusDelete;
//                        //TempHasotTemplate.StatusAction = 1;
//                        TempHasotTemplate.Seq = item.Seq;
//                        TempHasotTemplate.IsSource = item.IsSource;
//                        TempHasotTemplate.Comment = item.Comment;

//                        //TempHasotTemplate.TempStreet = item.TempStreet;
//                        //TempHasotTemplate.Mdest = item.Mdest;
//                        //TempHasotTemplate.Mprice = item.Mprice;

//                        HasotTemplateList.Add(TempHasotTemplate);


//                    }

//                }
//                //// בדיקה על מה שקיים במסך ואינו מחוק ולא קיים בסידור משמע הוא נמחק
//                //var IsNewInCurrent = HasotTemplateList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault();
//                //if (IsNewInCurrent == null || (item.Status == 1 && IsNewInCurrent.StatusAction == 1))
//                //{
//                //    Dal.ExeSp("Hasot_SetHasot", item.HasotId, Date, item.HasotTime, ShiftId, Dir, "", 10, "", "", "", "", Seq, "", "", "", "", "", "", "", "", HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

//                //}

//            }
         
//        }

     
//        //if (CurrentHasotList.Count > 0)
//        //{

//        //    foreach (var item in CurrentHasotList)
//        //    {
//        //        // בדיקה על מה שקיים במסך ואינו מחוק ולא קיים בסידור משמע הוא נמחק
//        //        var IsNewInCurrent = HasotTemplateList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault();
//        //        if (IsNewInCurrent == null || (item.Status == 1 && IsNewInCurrent.StatusAction == 1))
//        //        {
//        //            Dal.ExeSp("Hasot_SetHasot", item.HasotId, Date, item.HasotTime, ShiftId, Dir, "", 10, "", "", "", "", Seq, "", "", "", "", "", "", "", "", HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

//        //        }


//        //    }





//        //    var HasotTemplateListTemp = new List<HasotTemplate>();
//        //    // נמצא בסידור 
//        //    foreach (var item in HasotTemplateList)
//        //    {
//        //        //if (item.EmpNo == "51941")
//        //        //{


//        //        //}

//        //        // חדש שהתווסף מהסידור
//        //        var IsNewInCurrent = CurrentHasotList.Where(x => x.EmpNo == item.EmpNo && item.StatusAction!=1).FirstOrDefault();

//        //        // התווסף חדש
//        //        // מהמסך הוא מחוק
//        //        if (IsNewInCurrent == null)
//        //        {
//        //            var Res = CurrentHasotList.Where(x => x.Status != 2 && x.MaslulId!=null).GroupBy(x => new { x.Seq, x.CarTypeId,x.MaslulId }).Select(x => new { GroupColumns = x.Key, SeqCount = x.Count() });

//        //            foreach (var r in Res)
//        //            {

//        //                var Maslul = Maslulim.Where(x => x.Id == r.GroupColumns.MaslulId && x.AllCity.Exists(y => y == item.CityCode)).FirstOrDefault();

//        //                if (r.GroupColumns.CarTypeId == 2 && r.SeqCount < Configure.MinibusNumber && Maslul!=null)
//        //                {
//        //                    item.CarTypeId = 2;
//        //                    item.Status = 3;
//        //                    item.MaslulId = r.GroupColumns.MaslulId;
//        //                    item.Seq = r.GroupColumns.Seq;

//        //                    HasotTemplateListTemp.Add(item);

//        //                    CurrentHasot ch = new CurrentHasot();
//        //                    ch.EmpNo = item.EmpNo;
//        //                    ch.CarTypeId = 2;
//        //                    ch.Status = 3;
//        //                    ch.MaslulId = r.GroupColumns.MaslulId;
//        //                    ch.Seq = r.GroupColumns.Seq;

//        //                    CurrentHasotList.Add(ch);

//        //                } 


//        //                else if (r.GroupColumns.CarTypeId==1 && r.SeqCount < Configure.TaxiNumber && Maslul != null)
//        //                {
//        //                    item.CarTypeId = 1;
//        //                    item.Status = 3;
//        //                    item.MaslulId = r.GroupColumns.MaslulId;
//        //                    item.Seq = r.GroupColumns.Seq;

//        //                    HasotTemplateListTemp.Add(item);

//        //                    CurrentHasot ch = new CurrentHasot();
//        //                    ch.EmpNo = item.EmpNo;
//        //                    ch.CarTypeId =1;
//        //                    ch.Status = 3;
//        //                    ch.MaslulId = r.GroupColumns.MaslulId;
//        //                    ch.Seq = r.GroupColumns.Seq;

//        //                    CurrentHasotList.Add(ch);

//        //                }
//        //                else
//        //                {


//        //                }



//        //            }


//        //            // item.Status = 3;

//        //            // Dal.ExeSp("Hasot_SetHasot", item.EmpNo, Date, HasotTime, ShiftId, Dir, City, 10, MaslulId, Comment, CarTypeId, CarSymbol, Seq, ExtraSapId, TempStreet, StartDate, EndDate, Mdest, Mprice, HasotId, Sap_Id, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

//        //        }


//        //    }


//        //    InsertIntoDb(HasotTemplateListTemp, null,false,true);
//        //    return;
//        //}

//        //    // נמצא במסך 
//        //    //foreach (var item in CurrentHasotList)
//        //    //{

//        //    //    if(item.EmpNo== "52768")
//        //    //    {


//        //    //    }

//        //    //    var IsNewInCurrent = HasotTemplateList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault();

//        //    //    // נמצא במסך בלבד
//        //    //    if (IsNewInCurrent == null)
//        //    //    {
//        //    //        // אם זה הגיע הוספה של המשתמש
//        //    //        if (item.Status == 4)
//        //    //        {

//        //    //            HasotTemplate ht = new HasotTemplate();
//        //    //            ht.CityCode = item.CityCode;
//        //    //            ht.Dir = item.Dir;
//        //    //            ht.EmpNo = item.EmpNo;
//        //    //            ht.HasotDate = item.HasotDate;
//        //    //            ht.HasotTime = GetIsIsufTime(item.HasotTime, item.MaslulId);
//        //    //            ht.IsYom = item.IsYom;
//        //    //            ht.ShiftId = item.ShiftId;
//        //    //            ht.MaslulId = item.MaslulId;
//        //    //            ht.Status = item.Status;
//        //    //            //ht.IsFromRefresh = true;
//        //    //            ht.Comment = item.Comment;


//        //    //            ht.Seq = item.Seq;
//        //    //            HasotTemplateList.Add(ht);
//        //    //        }

//        //    //        // אם זה נמחק מהסידור
//        //    //        if (item.Status == 1 || item.Status == 2)
//        //    //        {

//        //    //            HasotTemplate ht = new HasotTemplate();
//        //    //            ht.CityCode = item.CityCode;
//        //    //            ht.Dir = item.Dir;
//        //    //            ht.EmpNo = item.EmpNo;
//        //    //            ht.HasotDate = item.HasotDate;
//        //    //            ht.HasotTime = GetIsIsufTime(item.HasotTime, item.MaslulId);
//        //    //            ht.IsYom = item.IsYom;
//        //    //            ht.ShiftId = item.ShiftId;
//        //    //            ht.MaslulId = item.MaslulId;
//        //    //            ht.Status = 2;
//        //    //            ht.Comment = item.Comment;

//        //    //            // ht.StatusDelete = 1;



//        //    //            ht.Seq = item.Seq;
//        //    //            HasotTemplateList.Add(ht);
//        //    //        }

//        //    //    }
//        //    //    else
//        //    //    {



//        //    //        IsNewInCurrent.CityCode = item.CityCode;
//        //    //        IsNewInCurrent.Dir = item.Dir;
//        //    //        IsNewInCurrent.EmpNo = item.EmpNo;
//        //    //         IsNewInCurrent.HasotDate = item.HasotDate;
//        //    //         IsNewInCurrent.HasotTime = item.HasotTime;
//        //    //        IsNewInCurrent.IsYom = item.IsYom;
//        //    //        IsNewInCurrent.ShiftId = item.ShiftId;
//        //    //        IsNewInCurrent.MaslulId = item.MaslulId;
//        //    //        IsNewInCurrent.Status = item.Status;
//        //    //        IsNewInCurrent.StatusDelete = item.StatusDelete;
//        //    //        //  ht.IsFromRefresh = true;
//        //    //        // IsNewInCurrent.StatusAction = 1;
//        //    //        IsNewInCurrent.Seq = item.Seq;

//        //    //        IsNewInCurrent.Comment = item.Comment;


//        //    //    }



//        //    //}

//        //    return;

//        //}



//        //List<int> DeletedSeq = new List<int>();

//        //var HasotTemplateListDeleted = HasotTemplateList.Where(x => x.Status == 2).ToList();

//        //foreach (var item in HasotTemplateListDeleted)
//        //{

//        //    var CurrentSeq = item.Seq;
//        //    var SameSeqActiveCount = HasotTemplateList.Where(x => x.Status != 2 && x.Seq == CurrentSeq).Count();

//        //    if (SameSeqActiveCount == 0 && !DeletedSeq.Any(x => x == CurrentSeq))
//        //    {
//        //        item.StatusDelete = 1;
//        //        DeletedSeq.Add(CurrentSeq);

//        //    }


//        //}

//        //InsertIntoDb(HasotTemplateListDeleted, null, false, true);

//        var MapsList = GetCurrentMaps();

//        foreach (var item in MapsList)
//        {
//            //******************   איחוד של מינובוסים AF
//            if (item.CarSymbol.Length > 1)
//            {

//                Maps SelectedMapBySymbol = new Maps();
//                int minCount = 100;
//                char[] Minibusims = item.CarSymbol.ToCharArray();

//                foreach (var mini in Minibusims)
//                {
//                    var MapBySymbol = MapsList.Where(x => x.CarSymbol.ToUpper() == mini.ToString().ToUpper() && x.Hour == item.Hour).FirstOrDefault();
//                    if (MapBySymbol != null)
//                    {
//                        int Count = HasotTemplateList.Where(x => x.Map == MapBySymbol && x.StatusAction == 1).Count();

//                        if (Count < minCount)
//                        {
//                            SelectedMapBySymbol = MapBySymbol;
//                            minCount = Count;

//                        }
//                    }

//                }


//                if (!string.IsNullOrEmpty(SelectedMapBySymbol.CarSymbol))
//                {
//                    if (Configure.MinibusNumber > minCount)
//                    {
//                        var MinibusListSelected = HasotTemplateList.Where(x => x.CityCode == item.City && x.HasotTime == item.Hour && x.StatusAction == 0 && x.Status != 2).Take(Configure.MinibusNumber - minCount).ToList();

//                        var OldMinibusList = HasotTemplateList.Where(x => x.Map != null && x.Map.CarSymbol == SelectedMapBySymbol.CarSymbol).ToList();

//                        DeleteListFromDb(OldMinibusList, SelectedMapBySymbol.Seq);

//                        OldMinibusList.AddRange(MinibusListSelected);

//                        InsertIntoDb(OldMinibusList, SelectedMapBySymbol, true);
//                    }

//                }

//                item.City = "";
//                continue;

//            }

//            if (string.IsNullOrEmpty(item.City)) continue;

//            //********************  אותו מיניבוס 
//            Seq++;

//            int CountInMinibus = 0;

//            var MinibusList = HasotTemplateList.Where(x => x.CityCode == item.City && x.HasotTime == item.Hour && x.StatusAction == 0 && x.Status != 2).Take(Configure.MinibusNumber).ToList();

//            //  InsertIntoDb(MinibusList, item);

//            CountInMinibus = MinibusList.Count;

//            if (CountInMinibus < Configure.MinibusNumber && CountInMinibus > 0)
//            {
//                var MapsSameSymbolList = MapsList.Where(x => x.CarSymbol.ToUpper() == item.CarSymbol.ToUpper() && x.Hour == item.Hour && x.Id != item.Id).ToList();
//                foreach (var map in MapsSameSymbolList)
//                {
//                    var MinibusListAddes = HasotTemplateList.Where(x => x.CityCode == map.City && x.HasotTime == map.Hour && x.StatusAction == 0 && x.Status != 2).Take(Configure.MinibusNumber - CountInMinibus).ToList();
//                    MinibusList.AddRange(MinibusListAddes);
//                    // InsertIntoDb(MinibusList, item);
//                    CountInMinibus += MinibusListAddes.Count;
//                    map.City = "";

//                }

//            }

//            if (CountInMinibus >= Configure.MinibusNumber)
//            {
//                var MapsSameSymbolList = MapsList.Where(x => x.CarSymbol.ToUpper() == item.CarSymbol.ToUpper() && x.Hour == item.Hour && x.Id != item.Id).ToList();
//                foreach (var map in MapsSameSymbolList)
//                {

//                    map.City = "";

//                }


//            }

//            InsertIntoDb(MinibusList, item);

//        }


//        //////********************************************* מוניות מלאות******************************************************************


//        var GroupByMS = HasotTemplateList.Where(x => x.StatusAction == 0 && x.Status != 2).GroupBy(s => new { s.CityCode, s.HasotTime })
//        .Select(gcs => new
//        {
//            Key = gcs.Key,
//            CityCode = gcs.Key.CityCode,
//            //   CityDesc = gcs.Key.CityDesc,
//            HasotTime = gcs.Key.HasotTime,
//            Children = gcs.ToList(),
//            Count = gcs.ToList().Count,
//            TaxiCount = gcs.ToList().Count / Configure.TaxiNumber
//        }).ToList();


//        var TaxiList = GroupByMS.Where(x => x.TaxiCount > 0).ToList();
//        foreach (var item in TaxiList)
//        {

//            var MaslulId = GetMaslulId(item.CityCode, item.HasotTime);

//            if (MaslulId != null)
//            {
//                List<HasotTemplate> TempHasotTemplateList = new List<HasotTemplate>();


//                foreach (var e in item.Children)
//                {
//                    e.MaslulId = MaslulId;
//                    e.CarTypeId = 1;

//                    TempHasotTemplateList.Add(e);

//                    if (TempHasotTemplateList.Count == Configure.TaxiNumber)
//                    {
//                        Seq++;
//                        //while (DeletedSeq.Any(x => x == Seq))
//                        //{
//                        //    Seq++;
//                        //}

//                        InsertIntoDb(TempHasotTemplateList, null);
//                        TempHasotTemplateList.Clear();
//                        //

//                    }
//                }





//            }



//        }

//        //////********************************************* עם איחודים מוניות******************************************************************


//        var GroupByMSIhud = HasotTemplateList.Where(x => x.StatusAction == 0 && x.Status != 2).GroupBy(s => new { s.HasotTime })
//         .Select(gcs => new
//         {
//             Key = gcs.Key,
//             HasotTime = gcs.Key.HasotTime,
//             Children = gcs.ToList(),
//             Count = gcs.ToList().Count,
//             TaxiCount = gcs.ToList().Count / Configure.TaxiNumber
//         }).ToList();

//        foreach (var group in GroupByMSIhud)
//        {
//            CityMaslulim cm = new CityMaslulim(group.Children.Count);
//            cm.CityCodes = group.Children.Select(x => x.CityCode).ToList();
//            cm.EmpNo = group.Children.Select(x => x.EmpNo).ToList();
//            //   cm.MaslulId = group.Children.Select(0).ToList();


//            GetMultiMaslulim(cm, group.HasotTime);

//            // List<HasotTemplate> TempHasotTemplateList = new List<HasotTemplate>();


//            for (int i = 0; i < group.Children.Count; i++)
//            {

//                if (cm.MaslulId[i] == 0)
//                {

//                    group.Children[i].MaslulId = null;


//                }
//                else
//                {
//                    group.Children[i].MaslulId = cm.MaslulId[i];
//                }

//            }

//            int PrevMaslulId = 0;
//            int Count = 0;
//            List<HasotTemplate> TempHasotTemplateList = new List<HasotTemplate>();
//            foreach (var item in group.Children.OrderBy(x => x.MaslulId))
//            {

//                if (item.MaslulId == null)
//                {
//                    Seq++;

//                    TempHasotTemplateList.Add(item);

//                    InsertIntoDb(TempHasotTemplateList, null);

//                    TempHasotTemplateList.Clear();


//                }
//                else
//                {

//                    if (PrevMaslulId != item.MaslulId || Count == Configure.TaxiNumber)
//                    {
//                        if (TempHasotTemplateList.Count > 0)
//                        {
//                            Seq++;
//                            SetTypeToAshkelon(TempHasotTemplateList);
//                            InsertIntoDb(TempHasotTemplateList, null);
//                            Count = 0;
//                            TempHasotTemplateList.Clear();
//                        }

//                    }


//                    TempHasotTemplateList.Add(item);
//                    Count++;
//                    PrevMaslulId = (int)item.MaslulId;

//                }


//            }

//            if (TempHasotTemplateList.Count > 0)
//            {
//                Seq++;
//                //while (DeletedSeq.Any(x => x == Seq))
//                //{
//                //    Seq++;
//                //}

//                SetTypeToAshkelon(TempHasotTemplateList);

//                InsertIntoDb(TempHasotTemplateList, null);
//                Count = 0;
//                TempHasotTemplateList.Clear();
//            }




//        }


//        if (CurrentHasotList.Count > 0)
//        {


          

//            int maxSeq = HasotTemplateList.Max(p => p.Seq);


//            List<HasotTemplate> HasotTemplateAdd = new List<HasotTemplate>();

//            foreach (var item in CurrentHasotList)
//            {
//                if(item.EmpNo== "52530")
//                {


//                }

//                // HasotTemplateList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault()

//                if (item.StatusAction == 1) continue;

//                var IsExist = HasotTemplateList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault();

//                if (item.EmpNo == "0" || item.MaslulId == MaslulIdForMeyuhedet)
//                {
//                    maxSeq++;
//                    item.Seq = maxSeq;
//                    HasotTemplateAdd.Add(item);
//                    continue;

//                }

//                if (item.Status != 2)
//                {

//                    if (IsExist == null)
//                    {
//                        //maxSeq++;
//                        //item.Seq = maxSeq;
//                        item.Status = 2;
//                        // item.StatusDelete = 1;
//                        // item.StatusAction = 1;
//                        //  HasotTemplateAdd.Add(item);

//                    }
//                }


//                if (item.Status == 2)
//                {
//                    var IsExistMaslul = HasotTemplateList.Where(x => x.MaslulId == item.MaslulId).FirstOrDefault();

//                    if (IsExist != null) continue;

//                    if (IsExistMaslul != null)
//                    {
//                        item.MaslulId = IsExistMaslul.MaslulId;
//                        item.Seq = IsExistMaslul.Seq;
//                        HasotTemplateAdd.Add(item);

//                    }
//                    else
//                    {
//                        maxSeq++;

//                        var AllDeleted = CurrentHasotList.Where(x => x.MaslulId == item.MaslulId && x.Status == 2).ToList();
//                        foreach (var ad in AllDeleted)
//                        {
//                            ad.Seq = maxSeq;
//                            ad.StatusDelete = 1;
//                            ad.StatusAction = 1;
//                            HasotTemplateAdd.Add(ad);

//                        }

//                    }
//                }



//            }

//            //foreach (var item in HasotTemplateList)
//            //{
//            //    var IsExist = CurrentHasotList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault();



//            //}




//            InsertIntoDb(HasotTemplateAdd, null, false, true);

//            ////  List<SeqObject> SeqObjectList = new List<SeqObject>();

//            //foreach (var item in CurrentHasotList)
//            //{
//            //    var ExistEmpInHasotTemplate = HasotTemplateList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault();
//            //    if (ExistEmpInHasotTemplate != null)
//            //    {
//            //        if (ExistEmpInHasotTemplate.EmpNo == "0") continue;

//            //        item.MaslulId = ExistEmpInHasotTemplate.MaslulId;
//            //        item.HasotTime = ExistEmpInHasotTemplate.HasotTime;
//            //        item.Map = ExistEmpInHasotTemplate.Map;
//            //        item.Status = ExistEmpInHasotTemplate.Status;
//            //    }
//            //    else
//            //    {
//            //        if (item.MaslulId != MaslulIdForMeyuhedet)
//            //            //item.MaslulId = ExistEmpInHasotTemplate.MaslulId;
//            //            //item.HasotTime = ExistEmpInHasotTemplate.HasotTime;
//            //            //item.Map = ExistEmpInHasotTemplate.Map;
//            //            item.Status = 2;
//            //    }
//            //}

//            //foreach (var item in HasotTemplateList)
//            //{


//            //    var ExistEmpInCurrentHasotList = CurrentHasotList.Where(x => x.EmpNo == item.EmpNo).FirstOrDefault();
//            //    if (ExistEmpInCurrentHasotList == null)
//            //    {

//            //        HasotTemplate NewAdd = new HasotTemplate();
//            //        NewAdd = (HasotTemplate)item.Clone();
//            //        NewAdd.Status = 3;
//            //        CurrentHasotList.Add(NewAdd);

//            //    }

//            //}

//            //SeqObject PrevSo = new SeqObject();
//            //// int TempSeq = 0;
//            //foreach (var item in CurrentHasotList.OrderBy(x => x.CarTypeId).ThenBy(x => x.MaslulId).ThenBy(x => x.HasotTime))
//            //{

//            //    //if (item.CarTypeId == 2)
//            //    //{

//            //    //    item.StatusAction = 1;
//            //    //    continue;
//            //    //}


//            //    SeqObject so = new SeqObject();
//            //    so.CarTypeId = item.CarTypeId;
//            //    so.HasotTime = item.HasotTime;
//            //    so.MaslulId = item.MaslulId;

//            //    //if(item.Status!=2)
//            //    //SeqObjectList.Add(so);

//            //    if (PrevSo != so)
//            //    {

//            //        var Res = CurrentHasotList.Where(x => x.CarTypeId == item.CarTypeId && x.MaslulId == item.MaslulId && x.HasotTime == item.HasotTime && x.Status != 2).ToList();

//            //        int Counter = 0;


//            //        for (int i = 0; i < Res.Count; i++)
//            //        {

//            //            if (Res[i].CarTypeId == 1)
//            //            {

//            //                if (i % Configure.TaxiNumber == 0)
//            //                {

//            //                    Counter++;

//            //                }

//            //                Res[i].StatusAction = Counter;

//            //            }

//            //            //if (Res[i].CarTypeId == 2)
//            //            //{

//            //            //    if (i % Configure.MinibusNumber == 0 )
//            //            //    {

//            //            //       // Counter++;

//            //            //    }

//            //            //    Res[i].StatusAction = Counter;

//            //            //}


//            //        }


//            //        Res = CurrentHasotList.Where(x => x.CarTypeId == item.CarTypeId && x.MaslulId == item.MaslulId && x.HasotTime == item.HasotTime && x.Status == 2).ToList();

//            //        foreach (var itemDelete in Res)
//            //        {
//            //            itemDelete.StatusAction = 1;
//            //        }

//            //        PrevSo = so;

//            //    }




//            //    //if (item.MaslulId == 87)
//            //    //{


//            //    //}

//            //    //  var SeqObjectCount = SeqObjectList.Where(x => x.CarTypeId == item.CarTypeId && x.HasotTime == item.HasotTime && x.MaslulId == item.MaslulId && item.Status!=2).Count();


//            //    //  if (item.CarTypeId == 1)
//            //    //  {
//            //    //      var Reminder = SeqObjectCount % Configure.TaxiNumber;

//            //    //      if (Reminder == 0)
//            //    //      {
//            //    //          TempSeq++;
//            //    //      }

//            //    //  }

//            //    //  if (item.CarTypeId == 2)
//            //    //  {
//            //    //      var Reminder = SeqObjectCount % Configure.MinibusNumber;

//            //    //      if (Reminder == 0)
//            //    //      {
//            //    //          TempSeq++;
//            //    //      }

//            //    //  }


//            //    //  item.StatusAction = TempSeq;

//            //    //  SeqObject so = new SeqObject();
//            //    //  so.CarTypeId = item.CarTypeId;
//            //    //  so.HasotTime = item.HasotTime;
//            //    //  so.MaslulId = item.MaslulId;
//            //    ////  if(item.Status!=2)
//            //    //  SeqObjectList.Add(so);


//            //}



//            //var GroupByDateAndMaslul = CurrentHasotList.GroupBy(s => new { s.MaslulId, s.HasotTime, s.CarTypeId, s.StatusAction })
//            //.Select(gcs => new
//            //{
//            //    Key = gcs.Key,
//            //    MaslulId = gcs.Key.MaslulId,
//            //    HasotTime = gcs.Key.HasotTime,
//            //    CarTypeId = gcs.Key.CarTypeId,
//            //    Children = gcs.ToList(),
//            //    Count = gcs.ToList().Count
//            //    // TaxiCount = gcs.ToList().Count / Configure.TaxiNumber
//            //}).ToList();

//            //for (int i = 0; i < GroupByDateAndMaslul.Count(); i++)
//            //{
//            //    var group = GroupByDateAndMaslul[i];
//            //    var groupChildren = group.Children;
//            //    var groupChildrenCount = groupChildren.Count();
//            //    var groupChildrenDelete = groupChildren.Where(x => x.Status == 2).Count();



//            //    foreach (var item in groupChildren)
//            //    {
//            //        if (groupChildrenCount == groupChildrenDelete)
//            //        {
//            //            item.StatusDelete = 1;
//            //        }
//            //        else
//            //        {
//            //            item.StatusDelete = 0;

//            //        }

//            //        item.Seq = i + 1;
//            //    }

//            //}

//            //foreach (var item in CurrentHasotList)
//            //{
//            //    if (item.EmpNo == "51941")
//            //    {


//            //    }

//            //    var CarSymbol = "";
//            //    if (item.Map != null)
//            //    {
//            //        CarSymbol = item.Map.CarSymbol;

//            //    }

//            //    var MaslulId = (item.MaslulId == null) ? "" : item.MaslulId.ToString();
//            //    var HasotId = (item.HasotId == null) ? "" : item.HasotId.ToString();

//            //    Dal.ExeSp("Hasot_SetHasot", item.EmpNo, Date, item.HasotTime, ShiftId, Dir, item.CityCode, 11, MaslulId, "", item.CarTypeId, CarSymbol, item.Seq, item.StatusDelete, "", "", "", "", "", HasotId, item.Status, HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

//            //}



//            //  DataTable dt = Dal.ExeSp("Hasot_SetHasot", "1", Date, "", ShiftId, Dir, "", 11, "", "", "", "", Seq, "", "", "", "", "", "", "", "", HttpContext.Current.Request.Cookies["UserData"]["UserId"]);
//            ////foreach (DataRow row in dt.Rows)
//            ////{
//            ////    CurrentHasotTemp Obj = new CurrentHasotTemp(row);
//            ////    CurrentHasotTempList.Add(Obj);
//            ////}

//            ////var ChangeList = CurrentHasotTempList.Where(x => x.EmpNo != "0" && (x.MaslulId != x.MaslulIdTemp || (x.IsSource && x.Status == 2)));

//            ////foreach (var item in ChangeList.OrderByDescending(x => x.HasotIdTemp))
//            ////{

//            ////    Dal.ExeSp("Hasot_SetHasot", item.HasotId, this.Date, "", this.ShiftId, Dir, "", 12, "", "", "", "", item.HasotIdTemp, "", "", "", "", "", "", "", "", HttpContext.Current.Request.Cookies["UserData"]["UserId"]);

//            ////}




//        }

//    }



//    private void SetTypeToAshkelon(List<HasotTemplate> TempHasotTemplateList)
//    {
//        int Counter = 0; //TempHasotTemplateList.Count();
//        int NewMaslulId = 0;
//        foreach (var item in TempHasotTemplateList)
//        {
//            int? Type = GetTypeMaslulId(item.CityCode, item.HasotTime);
//            if (Type == 2)
//            {
//                var MaslulimSearch = Maslulim.Where(x => x.Type == 2 && x.AllCity.Exists(y => y == item.CityCode)).FirstOrDefault();
//                if (MaslulimSearch != null)
//                {
//                    NewMaslulId = MaslulimSearch.Id;
//                    Counter++;
//                }
//            }

//        }


//        if (Counter == TempHasotTemplateList.Count)
//        {
//            foreach (var item in TempHasotTemplateList)
//            {
//                item.MaslulId = NewMaslulId;
//            }
//        }
//    }

//    private TimeSpan? GetIsIsufTime(TimeSpan? hasotTime, int? maslulId)
//    {

//        var res = hasotTime;
//        if (Dir == 1) return res;

//        var MaslulimData = Maslulim.Where(x => x.Id == maslulId).FirstOrDefault();

//        if (MaslulimData != null && MaslulimData.TimeBeforeTaxi != null)
//        {
//            res = Helper.AddMinutes((TimeSpan)hasotTime, (Int32)(MaslulimData.TimeBeforeTaxi));

//        }
//        return res;

//    }

//    private string GetCityDescFromMaslulForDev(string cityCode)
//    {
//        var Maslul = Maslulim.Where(x => x.City1 == cityCode && x.City2 == "").FirstOrDefault();
//        if (Maslul != null)
//        {

//            return Maslul.MaslulDesc;

//        }
//        else
//        {
//            return null;

//        }
//    }

//    private void DeleteListFromDb(List<HasotTemplate> oldMinibusList, int Seq)
//    {
//        foreach (var ht in oldMinibusList)
//        {
//            string sql = @"delete from Hasot where Dir={0} and ShiftId={1} and HasotDate='{2}' and HasotTime='{3}' and Seq={4}";
//            sql = string.Format(sql, this.Dir, this.ShiftId, ht.HasotDate, ht.HasotTime, Seq);

//            Dal.ExecuteNonQuery(sql);
//        }
//    }

//    private int? GetTypeMaslulId(string cityCode, TimeSpan? HasotTime)
//    {
//        bool IsYom6AndLayla = false;

//        TimeSpan StartTime;
//        TimeSpan EndTime;
//        if (CurrentDayInWeek == 6)
//        {
//            StartTime = new TimeSpan(0, 17, 0, 0);
//            EndTime = new TimeSpan(0, 21, 0, 0);
//            IsYom6AndLayla = CalculateDalUren(HasotTime, StartTime, EndTime);
//        }

//        if (CurrentDayInWeek == 7 || (CurrentDayInWeek == 6 && IsYom6AndLayla))
//        {
//            return 1;
//        }
//        else
//        {
//            bool IsBetween_15_18 = false;
//            bool IsBetween_21_05 = false;


//            //************************  בדיקה נסיעה של אשקלון בין 15 ל 18

//            if (AshkelonCityCode.Contains(cityCode))
//            {
//                StartTime = new TimeSpan(0, 14, 45, 0);
//                EndTime = new TimeSpan(0, 18, 0, 0);
//                IsBetween_15_18 = CalculateDalUren(HasotTime, StartTime, EndTime);
//                if (IsBetween_15_18)
//                {
//                    return 2;
//                }
//            }

//            //************************  בדיקה נסיעה של  בין 21 ל 5
//            StartTime = new TimeSpan(0, 21, 0, 0);
//            EndTime = new TimeSpan(1, 5, 0, 0);
//            var candidateTime = HasotTime;

//            if (candidateTime.Value.Hours <= 5)
//            {
//                candidateTime.Value.Add(new TimeSpan(1, 0, 0, 0));
//            }


//            IsBetween_21_05 = CalculateDalUren(candidateTime, StartTime, EndTime);

//            if (IsBetween_21_05) return 1;

//            return null;

//        }
//    }


//    private int? GetMaslulId(string cityCode, TimeSpan? HasotTime)
//    {
//        int? Type = GetTypeMaslulId(cityCode, HasotTime);
//        if (Type == 2)
//        {
//            var MaslulAshkelon = Maslulim.Where(x => x.Type == 2 && x.AllCity.Contains(cityCode)).FirstOrDefault();
//            if (MaslulAshkelon != null)
//            {

//                return MaslulAshkelon.Id;
//            }
//            else
//            {
//                return null;

//            }
//        }


//        var Maslul = Maslulim.Where(x => x.City1 == cityCode && x.Type == Type && x.City2 == "").FirstOrDefault();
//        if (Maslul != null)
//        {

//            return Maslul.Id;

//        }
//        else
//        {
//            return null;

//        }
//    }

//    private void GetMultiMaslulim(CityMaslulim cm, TimeSpan? HasotTime)
//    {
//        // פה סתם שמתי את אשדוד רק כדי לקבל את הסוג של היום
//        int? Type = GetTypeMaslulId(AshdodCityCode, HasotTime);

//        var MaslulimSearch = Maslulim.Where(x => x.Type == null).ToList();
//        if (Type == 1) MaslulimSearch = Maslulim.Where(x => x.Type == 1).ToList();
//        foreach (var item in MaslulimSearch.OrderBy(x => x.AllCity.Count).ThenBy(x => x.Tarif))
//        {

//            //if (item.AllCity[0] == "000000007100")
//            //{ }


//            //if (item.Sap_Id == 20 && item.AllCity.Count>2) 
//            //{ }

//            IEnumerable<string> both = item.AllCity.Intersect(cm.CityCodes);

//            List<int> CountList = new List<int>();
//            // string PrevCity = "";
//            foreach (var city in both)
//            {
//                for (int i = 0; i < cm.CityCodes.Count; i++)
//                {
//                    if (cm.CityCodes[i] == city && CountList.Count < Configure.TaxiNumber && (both.Count() > cm.Count[i] || cm.Count[i] == 0))
//                    {

//                        CountList.Add(i);
//                        //PrevCity = city;
//                        //cm.MaslulId[i] = item.Id;
//                        //cm.Count[i] = both.Count();
//                    }
//                }
//            }


//            if (CountList.Count > 0 && CountList.Count >= both.Count())
//            {
//                foreach (var itemI in CountList)
//                {
//                    cm.MaslulId[itemI] = item.Id;
//                    cm.Count[itemI] = both.Count();
//                }
//            }

//        }
//    }

//    private void InsertIntoDb(List<HasotTemplate> minibusList, Maps item, bool IsSeqFromMap = false, bool IsSeqFromHasotTemplate = false)
//    {
//        int? CarTypeId = 1;
//        int SeqInner = Seq;
//        var CarSymbol = "";

//        if (item != null)
//        {
//            if (!IsSeqFromMap)
//            { item.Seq = Seq; }

//            CarTypeId = item.CarTypeId;
//            SeqInner = item.Seq;
//            CarSymbol = item.CarSymbol;

//        }


//        int NewMaslulId = 0;



//        if (CarTypeId == 2)
//        {
//            var AllCityInSeq = minibusList.Select(x => x.CityCode).Distinct().ToList();
//            NewMaslulId = GetNewMaslulIdByList(AllCityInSeq);
//        }





//        foreach (var ht in minibusList)
//        {

//            if (NewMaslulId != 0) ht.MaslulId = NewMaslulId;

//            if (IsSeqFromHasotTemplate) SeqInner = ht.Seq;

//            ht.Map = item;

//            if (this.Dir == 0 && ht.StatusAction != 1)
//            {



//                var Maslul = Maslulim.Where(x => x.Id == ht.MaslulId).FirstOrDefault();
//                if (Maslul != null && Maslul.TimeBeforeTaxi != null)
//                {
//                    ht.HasotTime = ht.HasotTime.Value.Add(TimeSpan.FromMinutes(-1 * (int)Maslul.TimeBeforeTaxi));

//                }


//            }
//            ht.StatusAction = 1;



//            if (ht.StatusDelete != 1)
//            {
//                var ExistSeqOfDelete = HasotTemplateList.Where(x => x.StatusDelete == 1 && x.Seq == SeqInner).FirstOrDefault();
//                if (ExistSeqOfDelete != null)
//                {
//                    Seq++;
//                    SeqInner++;
//                }

//            }

//            ht.CarTypeId = CarTypeId;
//            ht.Seq = SeqInner;
//            //if (CurrentHasotList.Count == 0)
//            //{
//                string sql = @"insert into {17}(Dir, ShiftId, EmpNo, IsYom, CityCode, HasotDate, HasotTime,CarTypeId,MaslulId,Seq,CarSymbol,UpdateBy,UpdateTimeStamp,Status,IsSource,StatusDelete,Comment,TempStreet,Mdest,Mprice)
//                                values({0},{1},{2},{3},'{4}','{5}','{6}',{7},{8},{9},'{10}',{11},'{12}',{13},{14},{15},'{16}',NULLIF('{18}',''),NULLIF('{19}',''),{20})  
//                               ";
//                sql = string.Format(sql, this.Dir, this.ShiftId, ht.EmpNo, (ht.IsYom ? 1 : 0), ht.CityCode, ht.HasotDate, ht.HasotTime, CarTypeId,
//                    ((ht.MaslulId == null) ? "null" : ht.MaslulId.ToString()), SeqInner, CarSymbol, UserId, UpdateTimeStamp, ht.Status, ((ht.IsSource) ? 1 : 0), ht.StatusDelete
//                    , ht.Comment, ((CurrentHasotList.Count > 0) ? "Hasot" : "Hasot"), ht.TempStreet, ht.Mdest, ht.Mprice);

//                Dal.ExecuteNonQuery(sql);

//         //   }
//        }
//    }


//    public Boolean CalculateDalUren(TimeSpan? candidateTime, TimeSpan? StartTime, TimeSpan? EndTime)
//    {
//        if (StartTime < EndTime)
//        {
//            // Normal case, e.g. 8am-2pm
//            return StartTime <= candidateTime && candidateTime < EndTime;
//        }
//        else
//        {
//            // Reverse case, e.g. 10pm-2am
//            return StartTime <= candidateTime || candidateTime < EndTime;
//        }
//    }


//    private int GetNewMaslulIdByList(List<string> AllCityInSeq)
//    {

//        var MaslulimList = Maslulim.Where(x => x.Type != 1).OrderBy(x => x.AllCity.Count).ToList();
//        foreach (var item in MaslulimList.OrderBy(x => x.AllCity.Count))
//        {
//            IEnumerable<string> both = item.AllCity.Intersect(AllCityInSeq);

//            if (both.Count() == AllCityInSeq.Count)
//                return item.Id;

//        }

//        return 0;
//    }

//    private List<Maps> GetCurrentMaps()
//    {


//        var ReturnMap = Maps.Where(x => x.DayInWeek == CurrentDayInWeek &&
//                                                x.ShiftId == this.ShiftId &&

//                                                x.Type == Dir
//                                                ).ToList();


//        return ReturnMap;
//    }

//    public List<Maps> CurrentCarList = new List<Maps>();
//    public int Seq = 0;
//    private Maps GetMap(int IsOvdeYom, int? IsImahot, TimeSpan? StartTime, string CityCode)
//    {
//        var CurrentDayInWeek = (this.DayId < 6) ? 15 : this.DayId;

//        if (!string.IsNullOrEmpty(this.HolidayCode))
//        {
//            if (this.DayType == 8) CurrentDayInWeek = 6;
//            if (this.DayType.In(5, 9)) CurrentDayInWeek = 7;
//        }


//        var ReturnMap = Maps.Where(x => x.DayInWeek == CurrentDayInWeek &&
//                                                x.ShiftId == this.ShiftId &&
//                                                x.Hour == StartTime &&
//                                                (x.IsOvdeYom == IsOvdeYom || x.IsOvdeYom == null) &&
//                                                (x.IsImahot == IsImahot || x.IsImahot == null) &&
//                                                (x.OnlyDays.Contains(this.DayHebrew) || x.OnlyDays == "") &&
//                                                x.City == CityCode &&
//                                                x.Type == Dir
//                                                ).FirstOrDefault();

//        var IsExist = CurrentCarList.Any(x => x.City == CityCode && x.Hour == StartTime);
//        if (!IsExist)
//        {
//            Seq++;
//            var NewMap = new Maps();
//            NewMap.Id = Seq;
//            NewMap.City = CityCode;
//            NewMap.Hour = StartTime;
//            NewMap.Count = (ReturnMap == null) ? Configure.TaxiNumber : (int)ReturnMap.Count;
//            NewMap.CurrentCount = 0;
//            NewMap.CarTypeId = (ReturnMap == null) ? 1 : (int)ReturnMap.CarTypeId;
//            NewMap.CarSymbol = (ReturnMap == null) ? "" : ReturnMap.CarSymbol;
//            CurrentCarList.Add(NewMap);

//        }

//        //if (ReturnMap != null && ReturnMap.CarTypeId==2 && !CurrentMinibusList.Contains(ReturnMap))
//        //{
//        //    CurrentMinibusList.Add(ReturnMap);

//        //}



//        return ReturnMap;
//    }

//    //private int? GetMapsId()
//    //{

//    //    var Map = Maps.Where(x=>x.Type==Dir && x.DayInWeek)
//    //}

//    private int GetPrevNextShift(MishmarotWorkers x)
//    {


//        if (x.SourceShiftDate == null) return 0;

//        // כאן אם זה הקדמתי ממשמרת הבאה
//        if (x.SourceShiftDate > x.ShiftDate || (x.SourceShiftDate == x.ShiftDate && x.SourceShiftCode > x.ShiftCode)) return 1;

//        // כאן זה אם נשארתי שעות נוספות מהמשמרת הקודמת
//        if (x.SourceShiftDate < x.ShiftDate || (x.SourceShiftDate == x.ShiftDate && x.SourceShiftCode < x.ShiftCode)) return -1;


//        return 0;
//    }


//    private int GetPrevNextShiftPrevNext(MishmarotWorkers x)
//    {


//        if (x.SourceShiftDatePrevNext == null) return 0;

//        // כאן אם זה הקדמתי ממשמרת הבאה
//        if (x.SourceShiftDatePrevNext > x.ShiftDate || (x.SourceShiftDatePrevNext == x.ShiftDate && x.SourceShiftCodePrevNext > x.ShiftCode)) return 1;

//        // כאן זה אם נשארתי שעות נוספות מהמשמרת הקודמת
//        if (x.SourceShiftDatePrevNext < x.ShiftDate || (x.SourceShiftDatePrevNext == x.ShiftDate && x.SourceShiftCodePrevNext < x.ShiftCode)) return -1;


//        return 0;
//    }



//    public DataTable GetFINALDataFroMHasot()
//    {

//        DataSet ds = Dal.ExeDataSetSp("Hasot_BindMaslul", Date, ShiftId, Dir);

//        return ds.Tables[0];
//    }

//}

