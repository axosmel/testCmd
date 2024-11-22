// routes/user.go
package routes

import (
	"fmt"

	"github.com/gofiber/fiber/v2"

	checkin "company/routes/private/check_in"
	pending_user "company/routes/private/pending_user"
	updateuser "company/routes/private/update_user"
	systemparameters "company/routes/public/system_parameters"
	user_auth_route "company/routes/public/user_auth"
)

// SetupRoutes initializes the routes
func SetupRoutes(app *fiber.App) {
	// ENDPOINT GROUPS
	authPath := app.Group("/auth")
	pendingPath := app.Group("/pending")
	oneSignalPath := app.Group("/onesignal")
	userPath := app.Group("/user")
	systemParamsPath := app.Group("/system-params")
	checkInPath := app.Group("/customer")

	// ENDPOINT CALLS
	authEndpoints(authPath)

	pendingEndpoints(pendingPath)

	oneSignalEndpoints(oneSignalPath)

	userEndpoints(userPath)

	systemParamsEndpoints(systemParamsPath)

	checkInEndpoints(checkInPath)

}

// USER ENDPOINTS
func userEndpoints(userPath fiber.Router) {
	// GROUP OF PATHS
	updatePath := userPath.Group("/update")

	// ENDPOINTS
	updatePath.Post("/profile", updateuser.UpdateProfile)
}

// USER ENDPOINTS
func systemParamsEndpoints(systemParamsPath fiber.Router) {
	// ENDPOINTS
	systemParamsPath.Get("/companies", systemparameters.GetCompanies)
	systemParamsPath.Get("/roles", systemparameters.GetRoles)
	systemParamsPath.Get("/features", systemparameters.GetFeatures)
}

// AUTH ENDPOINTS
func authEndpoints(authPath fiber.Router) {
	authPath.Post("/signIn", user_auth_route.SignIn)
}

// PENDING ENDPOINTS
func pendingEndpoints(pendingPath fiber.Router) {
	pendingPath.Post("/encode", pending_user.EncodeUser)
	pendingPath.Post("/signUp", pending_user.Register)
}

// PENDING ENDPOINTS
func checkInEndpoints(pendingPath fiber.Router) {
	pendingPath.Post("/check-in", checkin.CheckIn)
	pendingPath.Post("/check-out", checkin.CheckOut)
	pendingPath.Get("/current-guests", checkin.GetCurrentGuests)
}

// ONESIGNAL ENDPOINTS
func oneSignalEndpoints(oneSignalPath fiber.Router) {
	oneSignalPath.Get("/subscribe-onesignal", func(c *fiber.Ctx) error {
		return c.Render("index", fiber.Map{"Title": "Welcome to Fiber", "Message": "Hello, Fiber with HTML!"})
	})
	oneSignalPath.Get("/user-verification", func(c *fiber.Ctx) error {
		return c.Render("user_verification", fiber.Map{"Title": "Welcome to Fiber", "Message": "Hello, Fiber with HTML!"})
	})

	oneSignalPath.Get("/styles/user-verification.css", func(c *fiber.Ctx) error {
		return c.SendFile("./web/styles/user_verification.css")
	})

	oneSignalPath.Get("/styles/modal.css", func(c *fiber.Ctx) error {
		return c.SendFile("./web/styles/modal.css")
	})

	oneSignalPath.Get("/modal.js", func(c *fiber.Ctx) error {
		return c.SendFile("./web/js/modal.js")
	})

	oneSignalPath.Get("/OneSignalSDKWorker.js", func(c *fiber.Ctx) error {
		c.Set("Content-Type", "application/javascript")
		return c.SendFile("./OneSignalSDKWorker.js")
	})

	oneSignalPath.Post("/notification-displayed", func(c *fiber.Ctx) error {
		fmt.Println("Notification displayed")
		return c.JSON("Notification Displayed")
	})

	oneSignalPath.Post("/notification-clicked", func(c *fiber.Ctx) error {
		fmt.Println("Notification clicked")
		return c.JSON("Notification clicked")
	})

	oneSignalPath.Post("/notification-dismissed", func(c *fiber.Ctx) error {
		fmt.Println("Notification dismissed")
		return c.JSON("Notification dismissed")
	})

	oneSignalPath.Get("/subscribe", func(c *fiber.Ctx) error {

		// var pendingUserQueryResponse user_auth_model.PendingUser
		// pendingUserQuery := fmt.Sprintf("SET TIMEZONE TO 'Asia/Manila'; SELECT pending_id, username, password, pin, date_encoded FROM pending_users WHERE email = 'rlagurins@gmail.com'")
		// pendingUserQueryErr := db.DB.QueryRow(pendingUserQuery).Scan(&pendingUserQueryResponse.PendingId, &pendingUserQueryResponse.Username, &pendingUserQueryResponse.Password, &pendingUserQueryResponse.PIN, &pendingUserQueryResponse.EncodedDate)
		// if pendingUserQueryErr != nil {
		// 	return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
		// 		"error":       "Database Error",
		// 		"actualError": pendingUserQueryErr.Error(),
		// 		"data":        pendingUserQueryResponse,
		// 		"time":        time.Now(),
		// 	})
		// }
		// return c.JSON(fiber.Map{"timestamp": time.Now()})
		return nil
	})
}
