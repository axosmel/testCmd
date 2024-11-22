// routes/user.go
package routes

import (
	"fmt"
	"time"

	"github.com/gofiber/fiber/v2"

	checkin "company/routes/private/check_in"
	pending_user "company/routes/private/pending_user"
	updateuser "company/routes/private/update_user"
	systemparameters "company/routes/public/system_parameters"
	user_auth_route "company/routes/public/user_auth"
	time_parser "company/utils/date_time_parser"
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

	// HEALTH CHECK SETUP
	healthCheckEndpoints(app)

	// ENDPOINT CALLS
	authEndpoints(authPath)

	pendingEndpoints(pendingPath)

	oneSignalEndpoints(oneSignalPath)

	userEndpoints(userPath)

	systemParamsEndpoints(systemParamsPath)

	checkInEndpoints(checkInPath)

}

func healthCheckEndpoints(app *fiber.App) {
	app.Get("/", healthCheck)
	app.Get("/health-check", healthCheck)
	app.Get("/health_check", healthCheck)
	app.Get("/healthcheck", healthCheck)
	app.Get("/health", healthCheck)
	app.Get("/check", healthCheck)
}

func healthCheck(c *fiber.Ctx) error {
	location, err := time.LoadLocation("Asia/Manila")
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":       "System Error",
			"actualError": err,
		})
	}
	currentTimeInNY := time.Now().In(location)
	formattedTime := time_parser.DateTimeFormatter(currentTimeInNY)
	return c.JSON(fiber.Map{"build": "v1.0.0", "timestamp": formattedTime})
}

// USER ENDPOINTS
func userEndpoints(userPath fiber.Router) {
	// GROUP OF PATHS
	updatePath := userPath.Group("/update")
	verificationPath := userPath.Group("/verification")

	// ENDPOINTS
	updatePath.Post("/profile", updateuser.UpdateProfile)

	userVerificationSetup(verificationPath)

	verificationPath.Get("/verify", func(c *fiber.Ctx) error {
		return c.Render("user_verification", fiber.Map{"Title": "Welcome to Fiber", "Message": "Hello, Fiber with HTML!"})
	})

}

func userVerificationSetup(verificationPath fiber.Router) {
	verificationPath.Get("/styles/user-verification.css", func(c *fiber.Ctx) error {
		return c.SendFile("./web/styles/user_verification.css")
	})

	verificationPath.Get("/styles/modal.css", func(c *fiber.Ctx) error {
		return c.SendFile("./web/styles/modal.css")
	})

	verificationPath.Get("/modal.js", func(c *fiber.Ctx) error {
		return c.SendFile("./web/js/modal.js")
	})
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
}
