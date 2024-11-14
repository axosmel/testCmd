// routes/user.go
package routes

import (
	user_auth "company/models/user_auth"
	db "company/utils/connection"
	"fmt"

	"github.com/gofiber/fiber/v2"

	pending_user "company/routes/private/pending_user"
	auth "company/routes/public/auth"
	"time"
)

// SetupRoutes initializes the routes
func SetupRoutes(app *fiber.App) {
	app.Get("/auth/signIn", auth.SignIn)
	app.Post("/auth/signUp", auth.Register)
	app.Post("/auth/encodeUser", pending_user.EncodeUser)

	app.Get("/", auth.SignIn)

	// app.Get("/json")

	// // User route
	app.Get("/checkTime", func(c *fiber.Ctx) error {

		var pendingUserQueryResponse user_auth.PendingUser
		pendingUserQuery := fmt.Sprintf("SET TIMEZONE TO 'Asia/Manila'; SELECT pending_id, username, password, pin, date_encoded FROM pending_users WHERE email = 'rlagurins@gmail.com'")
		pendingUserQueryErr := db.DB.QueryRow(pendingUserQuery).Scan(&pendingUserQueryResponse.PendingId, &pendingUserQueryResponse.Username, &pendingUserQueryResponse.Password, &pendingUserQueryResponse.PIN, &pendingUserQueryResponse.EncodedDate)
		if pendingUserQueryErr != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error":       "Database Error",
				"actualError": pendingUserQueryErr.Error(),
				"data":        pendingUserQueryResponse,
				"time":        time.Now(),
			})
		}
		return c.JSON(fiber.Map{"timestamp": time.Now()})

		// return c.JSON(pendingUserQueryResponse)
	})
}
