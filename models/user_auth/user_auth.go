package userauth

import (
	"github.com/gofiber/fiber/v2"
)

type UserCredentials struct {
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
	CompanyId   int    `json:"companyId"`
	BirthDate   string `json:"birthdate"`
	Username    string `json:"username"`
	Password    string `json:"password"`
	PIN         string `json:"pin"`
	Email       string `json:"email"`
	Status      string `json:"status"`
	DateEncoded string `json:"dateEncoded"`
}

func (u *UserCredentials) Validate(isLogin bool) *fiber.Map {
	if u.Email == "" && u.Username == "" {
		return &fiber.Map{
			"error":       "Invalid input",
			"actualError": "Incomplete request body",
		}
	}
	if u.Password == "" {
		return &fiber.Map{
			"error":       "Invalid input",
			"actualError": "Incomplete request body",
		}
	}
	return nil
}
