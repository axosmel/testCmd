package checkin

import (
	checkin "company/models/check_in"
	db_response "company/models/db_response"
	"fmt"
	"time"

	db "company/utils/connection"
	time_parser "company/utils/date_time_parser"

	"github.com/gofiber/fiber/v2"
)

func CheckIn(c *fiber.Ctx) error {
	var visitor checkin.CustomerIn

	// Parse the JSON body into the user struct
	if err := c.BodyParser(&visitor); err != nil {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{
			"error":       "Invalid input",
			"actualError": err,
		})
	}

	location, err := time.LoadLocation("Asia/Manila")
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":       "System Error",
			"actualError": err,
		})
	}

	currentTimeInNY := time.Now().In(location)
	formattedTime := time_parser.DateTimeFormatter(currentTimeInNY)
	visitor.TimeIn = formattedTime
	// initialSql := "CALL company_record.insert_checkin('1', 'lemem', 'mel', 'memel', 'spc', 'laguna', '2', '3', '4', '2', 'overnight', '2024-11-23 16:03:49.103909+08', '1', '2', '')"
	fullQuery := ` CALL company_record.insert_checkin($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15) `
	// Define your parameters
	args := []interface{}{
		visitor.CompanyId,
		visitor.VisitorsFirstname,
		visitor.VisitorsMiddlename,
		visitor.VisitorsLastname,
		visitor.VisitorsCity,
		visitor.VisitorsProvince,
		visitor.AdultsFemaleCnt,
		visitor.AdultsMaleCnt,
		visitor.KidsFemaleCnt,
		visitor.KidsMaleCnt,
		visitor.VisitType,
		visitor.TimeIn,
		1,
		2,
		"",
	}
	var response db_response.ProcedureResponse

	result := db.DB.Raw(fullQuery, args...).Scan(&response)
	if result.Error != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":       "Database Error",
			"actualError": result.Error.Error(),
			"data":        response,
		})
	}
	return c.Status(response.Status).JSON(response)
}

func CheckOut(c *fiber.Ctx) error {
	var visitor checkin.CustomerIn

	// Parse the JSON body into the user struct
	if err := c.BodyParser(&visitor); err != nil {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{
			"error":       "Invalid input",
			"actualError": err,
		})
	}

	location, err := time.LoadLocation("Asia/Manila")
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":       "System Error",
			"actualError": err,
		})
	}

	currentTimeInNY := time.Now().In(location)
	formattedTime := time_parser.DateTimeFormatter(currentTimeInNY)
	visitor.TimeIn = formattedTime

	fullQuery := fmt.Sprintf("CALL company_record.visitor_checkout('%d', '%s', '1', '1', '')", visitor.CheckinId, formattedTime)
	var response db_response.ProcedureResponse

	result := db.DB.Raw(fullQuery).Scan(&response)
	if result.Error != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":       "Database Error",
			"actualError": result.Error.Error(),
			"data":        response,
		})
	}
	return c.Status(response.Status).JSON(response)
}

func GetCurrentGuests(c *fiber.Ctx) error {
	var visitor []checkin.CustomerIn
	fullQuery := "SELECT * FROM company_record.checkins WHERE time_out IS NULL"

	result := db.DB.Raw(fullQuery).Scan(&visitor)
	if result.Error != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":       "Database Error",
			"actualError": result.Error.Error(),
			"data":        visitor,
		})
	}
	if visitor != nil {
		return c.JSON(visitor)
	}
	return c.JSON(fiber.Map{"message": "There is no visitor"})
}
