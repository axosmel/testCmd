package auth

import (
	db_response "company/models/db_response"
	encrypt "company/utils/cypher"
	ckErr "company/utils/error_handler"
	"os"
	"reflect"
	"time"

	user_auth "company/models/user_auth"
	"encoding/hex"
	"fmt"

	db "company/utils/connection"

	time_parser "company/utils/date_time_parser"

	"github.com/gofiber/fiber/v2"
)

func SignIn(c *fiber.Ctx) error {
	os.Exit(1)
	time, err := time_parser.ParseStringToTime("2024-11-04T04:53:33+08:00")
	ckErr.ErrorChecker(err)
	encText, err := encrypt.Encrypt([]byte("defaultUsername"), *time)
	ckErr.ErrorChecker(err)
	decoded := hex.EncodeToString(encText)

	encText1, err := encrypt.Encrypt([]byte("defaultUsername"), *time)
	ckErr.ErrorChecker(err)
	decoded1 := hex.EncodeToString(encText)

	fmt.Println("encText", encText)
	fmt.Println("decoded", decoded)
	fmt.Println("encText1", encText1)
	fmt.Println("decoded1", decoded1)

	return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
		"encText":  encText,
		"decoded":  decoded,
		"encText1": encText1,
		"decoded1": decoded1,
	})
}

func Register(c *fiber.Ctx) error {

	var user user_auth.RegisterUser

	// Parse the JSON body into the user struct
	if err := c.BodyParser(&user); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid input",
		})
	}
	var pendingUserQueryResponse user_auth.PendingUser
	pendingUserQuery := fmt.Sprintf("SELECT pending_id, username, password, pin, date_encoded FROM pending_users WHERE email = '%s'", user.Email)
	pendingUserQueryErr := db.DB.QueryRow(pendingUserQuery).Scan(&pendingUserQueryResponse.PendingId, &pendingUserQueryResponse.Username, &pendingUserQueryResponse.Password, &pendingUserQueryResponse.PIN, &pendingUserQueryResponse.EncodedDate)
	if pendingUserQueryErr != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":       "Database Error",
			"actualError": pendingUserQueryErr.Error(),
			"data":        pendingUserQueryResponse,
		})
	}
	// Convert the string to time.Time
	encodedTime, err := time_parser.ParseStringToTime(pendingUserQueryResponse.EncodedDate)
	ckErr.ErrorChecker(err)

	// hexDecodedUsername, err := hex.DecodeString(pendingUserQueryResponse.Username)
	// ckErr.ErrorChecker(err)
	// decryptedUsername, _ := encrypt.Decrypt([]byte(hexDecodedUsername), *encodedTime)

	//
	hexDecodedPassword, err := hex.DecodeString(pendingUserQueryResponse.Password)
	ckErr.ErrorChecker(err)
	decryptedPassword, _ := encrypt.Decrypt([]byte(hexDecodedPassword), *encodedTime)

	//
	hexDecodedPin, err := hex.DecodeString(pendingUserQueryResponse.PIN)
	ckErr.ErrorChecker(err)
	decryptedPin, _ := encrypt.Decrypt([]byte(hexDecodedPin), *encodedTime)
	/*reflect.DeepEqual(decryptedUsername, []byte(user.Username))*/
	if pendingUserQueryResponse.Username == user.Username && reflect.DeepEqual(decryptedPassword, []byte(user.Password)) && reflect.DeepEqual(decryptedPin, []byte(user.PIN)) {
		location, err := time.LoadLocation("America/New_York")
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error":       "System Error",
				"actualError": err,
			})
		}

		currentTimeInNY := time.Now().In(location)
		formattedTime := time_parser.DateTimeFormater(currentTimeInNY)
		registeredTime, err := time_parser.ParseStringToTime(formattedTime)
		ckErr.ErrorChecker(err)

		// updatedUsername, err := encrypt.Encrypt([]byte(user.NewUsername), *registeredTime)
		// ckErr.ErrorChecker(err)
		// user.NewUsername = hex.EncodeToString(updatedUsername)

		updatedPassword, err := encrypt.Encrypt([]byte(user.NewPassword), *registeredTime)
		ckErr.ErrorChecker(err)
		user.NewPassword = hex.EncodeToString(updatedPassword)

		updatedPin, err := encrypt.Encrypt([]byte(user.NewPIN), *registeredTime)
		ckErr.ErrorChecker(err)
		user.NewPIN = hex.EncodeToString(updatedPin)

		var registerVerifiedQueryResponse db_response.ProcedureResponse
		registerVerifiedQuery := fmt.Sprintf("SELECT * FROM backend_functions.register_user('%d', '%s', '%s', '%s', '%s')", pendingUserQueryResponse.PendingId, user.NewUsername, user.NewPassword, user.NewPIN, formattedTime)

		fmt.Println(registerVerifiedQuery)
		registerVerifiedQueryErr := db.DB.QueryRow(registerVerifiedQuery).Scan(&registerVerifiedQueryResponse.UserId, &registerVerifiedQueryResponse.Message)
		if registerVerifiedQueryErr != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error":       "Database Error",
				"actualError": registerVerifiedQueryErr.Error(),
				"data":        pendingUserQueryResponse,
			})
		}

		if registerVerifiedQueryResponse.UserId.Valid {
			registerVerifiedQueryResponse.Id = int(registerVerifiedQueryResponse.UserId.Int64)
		}
		return c.JSON(registerVerifiedQueryResponse)
	}

	return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
		"error": "Invalid Credentials",
	})
}
