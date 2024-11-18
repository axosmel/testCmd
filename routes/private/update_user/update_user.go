package updateuser

import (
	"company/models/common"
	structtostring "company/utils/struct_to_string"
	"fmt"

	"time"

	db "company/utils/connection"

	"github.com/gofiber/fiber/v2"
)

func UpdateProfile(c *fiber.Ctx) error {
	var (
		user               common.User
		addresseListFields string
		addresseListValues string
		contactsListFields string
		contactsListValues string
	)

	// Parse the JSON body into the user struct
	if err := c.BodyParser(&user); err != nil {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{
			"error":       "Invalid input",
			"actualError": err,
		})
	}

	addresseListFields, addresseListValues = structtostring.StructToString(user.AddresseList)
	contactsListFields, contactsListValues = structtostring.StructToString(user.ContactsList)

	userDetailsQuery := fmt.Sprintf("INSERT INTO address %s\nVALUES %s;\nINSERT INTO contacts %s\nVALUES %s", addresseListFields, addresseListValues, contactsListFields, contactsListValues)

	result := db.DB.Exec(userDetailsQuery)
	if result.Error != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":       "Database Error",
			"actualError": result.Error.Error(),
			"data":        user, // Include relevant data structure
			"time":        time.Now(),
		})
	}

	return c.JSON(fiber.Map{
		"status":  "200",
		"message": "Success updating client profile",
	})
}
