package systemparameters

import (
	"company/models/common"
	"time"

	db "company/utils/connection"

	"github.com/gofiber/fiber/v2"
)

const errorMessage = "Database Error"

func GetCompanies(c *fiber.Ctx) error {
	var (
		companies []common.Company
	)

	companyQuery := "SELECT * FROM company_record.companies"

	result := db.DB.Raw(companyQuery).Scan(&companies)
	if result.Error != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":       errorMessage,
			"actualError": result.Error.Error(),
			"time":        time.Now(),
		})
	}

	return c.JSON(companies)
}

func GetRoles(c *fiber.Ctx) error {
	var (
		roles []common.Role
	)

	companyQuery := "SELECT * FROM roles"

	result := db.DB.Raw(companyQuery).Scan(&roles)
	if result.Error != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":       errorMessage,
			"actualError": result.Error.Error(),
			"time":        time.Now(),
		})
	}

	return c.JSON(roles)
}

func GetFeatures(c *fiber.Ctx) error {
	var (
		features []common.Feature
	)

	companyQuery := "SELECT * FROM features"

	result := db.DB.Raw(companyQuery).Scan(&features)
	if result.Error != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":       errorMessage,
			"actualError": result.Error.Error(),
			"time":        time.Now(),
		})
	}

	return c.JSON(features)
}
