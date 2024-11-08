package userauth

type RegisterUser struct {
	Email       string `json:"email"`
	Username    string `json:"username"`
	Password    string `json:"password"`
	PIN         string `json:"pin"`
	NewUsername string `json:"newUsername"`
	NewPassword string `json:"newPassword"`
	NewPIN      string `json:"newPIN"`
}

type PendingUser struct {
	PendingId   int    `json:"pendingId"`
	RoleID      int    `json:"roleId"`
	FirstName   string `json:"firstname"`
	MiddleName  string `json:"middlename"`
	LastName    string `json:"lastname"`
	Sex         string `json:"sex"`
	CompanyID   int    `json:"company_id"`
	BirthDate   string `json:"birthdate"`
	Username    string `json:"username"`
	Password    string `json:"password"`
	PIN         string `json:"pin"`
	Email       string `json:"email"`
	Status      string `json:"status"`
	EncodedDate string `json:"encodedDate"`
}
