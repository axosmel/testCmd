// routes/user.go
package routes

import (
	"github.com/gofiber/fiber/v2"

	pending_user "company/routes/private/pending_user"
	auth "company/routes/public/auth"
)

// SetupRoutes initializes the routes
func SetupRoutes(app *fiber.App) {
	app.Get("/auth/signIn", auth.SignIn)
	app.Post("/auth/signUp", auth.Register)
	app.Post("/auth/encodeUser", pending_user.EncodeUser)

	app.Get("/", auth.SignIn)

	// app.Get("/json")

	// // User route
	// app.Get("/user/:id", func(c *fiber.Ctx) error {
	// 	id := c.Params("id")
	// 	return c.JSON(fiber.Map{
	// 		"user": fiber.Map{
	// 			"id":   id,
	// 			"name": "John Doe",
	// 		},
	// 	})
	// })
}
