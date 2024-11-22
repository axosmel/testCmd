package pendinguser

import (
	db_response "company/models/db_response"
	user_auth "company/models/user_auth"
	db "company/utils/connection"
	encrypt "company/utils/cypher"
	ckErr "company/utils/error_handler"
	"company/utils/mailer"
	systemparameter "company/utils/system_parameter"
	crypto_rand "crypto/rand"
	"encoding/hex"
	"fmt"
	"math/big"
	math_rand "math/rand"
	"reflect"

	// "reflect"
	"strconv"
	"time"

	time_parser "company/utils/date_time_parser"

	"github.com/gofiber/fiber/v2"
)

func generateDefaultUsername(firstname string, middlename string, lastname string, timestamp string) string {
	time, err := time_parser.ParseStringToTime(timestamp)
	ckErr.ErrorChecker(err)
	defaultUsername := firstname[0:1] + middlename[0:1] + strconv.Itoa(time.Minute()) + lastname + strconv.Itoa(time.Hour())
	fmt.Println("defaultUsername: ", defaultUsername)
	return defaultUsername
}

func generateSecureRandomSixDigit() int {
	n, err := crypto_rand.Int(crypto_rand.Reader, big.NewInt(900000))
	if err != nil {
		return 0
	}
	return int(n.Int64()) + 100000
}

func generateDefaultPassword(lastname string, birthdate string, timestamp string) (string, string) {
	defaultPassword := lastname + "@" + birthdate

	time, err := time_parser.ParseStringToTime(timestamp)
	ckErr.ErrorChecker(err)
	encText, err := encrypt.Encrypt([]byte(defaultPassword), *time)
	ckErr.ErrorChecker(err)
	fmt.Println("defaultPassword: ", defaultPassword)
	return hex.EncodeToString(encText), defaultPassword
}

func generateDefaultPin(timestamp string) (string, int) {
	defaultPin := generateSecureRandomSixDigit()
	fmt.Println("defaultPin: ", defaultPin)

	time, err := time_parser.ParseStringToTime(timestamp)
	ckErr.ErrorChecker(err)
	encText, err := encrypt.Encrypt([]byte(strconv.Itoa(defaultPin)), *time)
	ckErr.ErrorChecker(err)

	return hex.EncodeToString(encText), defaultPin
}

func EncodeUser(c *fiber.Ctx) error {
	var user user_auth.PendingUser

	// Parse the JSON body into the user struct
	if err := c.BodyParser(&user); err != nil {
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
	var txtFormatPassword string
	var intFormatPin int

	user.DateEncoded = formattedTime
	user.Status = "PENDING"
	user.Username = generateDefaultUsername(user.FirstName, user.MiddleName, user.LastName, formattedTime)
	user.Password, txtFormatPassword = generateDefaultPassword(user.LastName, user.BirthDate, formattedTime)
	user.PIN, intFormatPin = generateDefaultPin(formattedTime)
	var response db_response.ProcedureResponse
	fullQuery := fmt.Sprintf("CALL public.insert_pending_user(%d,%d,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','1','1','')", user.RoleID, user.CompanyId, user.FirstName, user.MiddleName, user.LastName, user.BirthDate, user.Sex, user.Username, user.Password, user.PIN, user.Email, user.Status, user.DateEncoded)

	result := db.DB.Raw(fullQuery).Scan(&response)
	if result.Error != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":       "Database Error",
			"actualError": result.Error.Error(),
			"data":        response,
		})
	}

	if response.Status != 200 {
		return c.Status(response.Status).JSON(response)
	}
	if response.PendingId.Valid {
		response.Id = int(response.PendingId.Int64)
	}

	smtp := *systemparameter.GetSystemParameter("SMTP")
	service := *systemparameter.GetSystemParameter("SERVICE")
	url := fmt.Sprintf("%s/verification/verify", service[0].ParameterValue)
	body := fmt.Sprintf("Dear %s,\n\nThis is the final step for your registration to the Company! The details below contains your temporary credentials, please don't let anyone know this details.\n\nUsername: %s\nPassword: %s\nPin: %d\n\nPlease use the credentials here %s", user.LastName, user.Username, txtFormatPassword, intFormatPin, url)
	subject := "Account Verification"
	to := user.Email
	mailErr := mailer.SendEmail(smtp[0].ParameterValue, smtp[1].ParameterValue, smtp[2].ParameterValue, smtp[3].ParameterValue, subject, body, to)

	if mailErr != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":       "Mailer error",
			"actualError": err,
			"data":        user,
		})
	}

	return c.JSON(user)

}

func Register(c *fiber.Ctx) error {

	var user user_auth.UserCredentials

	// Parse the JSON body into the user struct
	if err := c.BodyParser(&user); err != nil {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{
			"error":       "Invalid input",
			"actualError": err,
		})
	}
	var pendingUserQueryResponse user_auth.PendingUser
	pendingUserQuery := fmt.Sprintf("SELECT pending_id, username, password, pin, REPLACE(date_encoded::TEXT, ' ', 'T') date_encoded FROM pending_users WHERE email = '%s'", user.Email)

	result := db.DB.Raw(pendingUserQuery).Scan(&pendingUserQueryResponse)
	if result.Error != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":       "Database Error",
			"actualError": result.Error.Error(),
			"data":        pendingUserQueryResponse,
		})
	}
	fmt.Println("pendingUserQueryResponse.DateEncoded: ", pendingUserQueryResponse.DateEncoded)

	encodedTime, err := time_parser.ParseStringToTime(pendingUserQueryResponse.DateEncoded)
	ckErr.ErrorChecker(err)
	fmt.Println("pendingUserQueryResponse.DateEncoded: ", pendingUserQueryResponse.DateEncoded)
	fmt.Println("encodedTime: ", encodedTime)

	hexDecodedPassword, err := hex.DecodeString(pendingUserQueryResponse.Password)
	ckErr.ErrorChecker(err)
	decryptedPassword, _ := encrypt.Decrypt([]byte(hexDecodedPassword), *encodedTime)

	//
	hexDecodedPin, err := hex.DecodeString(pendingUserQueryResponse.PIN)
	ckErr.ErrorChecker(err)
	decryptedPin, _ := encrypt.Decrypt([]byte(hexDecodedPin), *encodedTime)

	if pendingUserQueryResponse.Username == user.Username && reflect.DeepEqual(decryptedPassword, []byte(user.Password)) && reflect.DeepEqual(decryptedPin, []byte(user.PIN)) {
		location, err := time.LoadLocation("Asia/Manila")
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error":       "System Error",
				"actualError": err,
			})
		}

		currentTimeInNY := time.Now().In(location)
		formattedTime := time_parser.DateTimeFormatter(currentTimeInNY)
		registeredTime, err := time_parser.ParseStringToTime(formattedTime)
		ckErr.ErrorChecker(err)

		updatedPassword, err := encrypt.Encrypt([]byte(user.NewPassword), *registeredTime)
		ckErr.ErrorChecker(err)
		user.NewPassword = hex.EncodeToString(updatedPassword)

		updatedPin, err := encrypt.Encrypt([]byte(user.NewPIN), *registeredTime)
		ckErr.ErrorChecker(err)
		user.NewPIN = hex.EncodeToString(updatedPin)

		var registerVerifiedQueryResponse db_response.ProcedureResponse
		registerVerifiedQuery := fmt.Sprintf("SELECT user_id, out_status status, message FROM backend_functions.register_user('%d', '%s', '%s', '%s', '%s')", pendingUserQueryResponse.PendingId, user.NewUsername, user.NewPassword, user.NewPIN, formattedTime)

		fmt.Println(registerVerifiedQuery)
		result := db.DB.Raw(registerVerifiedQuery).Scan(&registerVerifiedQueryResponse)
		if result.Error != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error":       "Database Error",
				"actualError": result.Error.Error(),
				"data":        pendingUserQueryResponse,
			})
		}

		fmt.Println("CHECK: ", registerVerifiedQueryResponse)
		if registerVerifiedQueryResponse.Status != 200 {
			fmt.Println("CHECK: ")
			return c.Status(registerVerifiedQueryResponse.Status).JSON(registerVerifiedQueryResponse)
		}

		if registerVerifiedQueryResponse.UserId.Valid {
			registerVerifiedQueryResponse.Id = int(registerVerifiedQueryResponse.UserId.Int64)
		}
		return c.JSON(fiber.Map{"userData": registerVerifiedQueryResponse, "initialLogin": "true"})
	}

	return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
		"error": "Invalid Credentials",
	})
}

func generateRandomString(length int) string {
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	result := make([]byte, length)

	for i := range result {
		result[i] = charset[math_rand.Intn(len(charset))]
	}

	return string(result)
}
