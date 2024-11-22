package checkin

type CustomerIn struct {
	CheckinId          int    `json:"checkinId"`
	CompanyId          int    `json:"companyId"`
	VisitorsFirstname  string `json:"visitorFirstname"`
	VisitorsMiddlename string `json:"visitorMiddlename"`
	VisitorsLastname   string `json:"visitorLastname"`
	VisitorsCity       string `json:"city"`
	VisitorsProvince   string `json:"province"`
	AdultsMaleCnt      int    `json:"adultMaleCount"`
	AdultsFemaleCnt    int    `json:"adultFemaleCount"`
	KidsMaleCnt        int    `json:"kidsMaleCount"`
	KidsFemaleCnt      int    `json:"kidsFemaleCount"`
	VisitType          string `json:"visitType"`
	TimeIn             string `json:"timeIn"`
	TimeOut            string `json:"timeOut"`
}
