package pendinguser

import (
	db_response "company/models/db_response"
	user_auth "company/models/user_auth"
	db "company/utils/connection"
	encrypt "company/utils/cypher"
	ckErr "company/utils/error_handler"
	crypto_rand "crypto/rand"
	"encoding/hex"
	"fmt"
	"math/big"
	math_rand "math/rand"
	"strconv"
	"time"

	time_parser "company/utils/date_time_parser"

	"github.com/gofiber/fiber/v2"
)

func generateDefaultUsername(firstname string, middlename string, lastname string, timestamp string) string {
	time, err := time_parser.ParseStringToTime(timestamp)
	ckErr.ErrorChecker(err)
	defaultUsername := firstname[0:1] + middlename[0:1] + strconv.Itoa(time.Minute()) + lastname + strconv.Itoa(time.Hour())

	fmt.Println("DEFAULT USERNAME: ", defaultUsername)
	return defaultUsername
	// encText, err := encrypt.Encrypt([]byte(defaultUsername), *time)
	// ckErr.ErrorChecker(err)

	// return hex.EncodeToString(encText)
}

func generateSecureRandomSixDigit() int {
	n, err := crypto_rand.Int(crypto_rand.Reader, big.NewInt(900000))
	if err != nil {
		return 0
	}
	return int(n.Int64()) + 100000
}

func generateDefaultPassword(lastname string, birthdate string, timestamp string) string {
	defaultPassword := lastname + "@" + birthdate

	fmt.Println("DEFAULT PASSWORD: ", defaultPassword)
	time, err := time_parser.ParseStringToTime(timestamp)
	ckErr.ErrorChecker(err)
	encText, err := encrypt.Encrypt([]byte(defaultPassword), *time)
	ckErr.ErrorChecker(err)

	return hex.EncodeToString(encText)
}

func generateDefaultPin(timestamp string) string {
	defaultPin := generateSecureRandomSixDigit()

	fmt.Println("DEFAULT PIN: ", defaultPin)
	time, err := time_parser.ParseStringToTime(timestamp)
	ckErr.ErrorChecker(err)
	encText, err := encrypt.Encrypt([]byte(strconv.Itoa(defaultPin)), *time)
	ckErr.ErrorChecker(err)

	return hex.EncodeToString(encText)
}

func EncodeUser(c *fiber.Ctx) error {
	var user user_auth.PendingUser

	// Parse the JSON body into the user struct
	if err := c.BodyParser(&user); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":       "Invalid input",
			"actualError": err,
		})
	}

	location, err := time.LoadLocation("Asia/Manila")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":       "System Error",
			"actualError": err,
		})
	}
	// 38-f0b68772ab4ba406a2de29e078e9f4e0e78cb0a13c28856bcc4febc2776a34f6a51d7
	currentTimeInNY := time.Now().In(location)
	formattedTime := time_parser.DateTimeFormatter(currentTimeInNY)

	user.EncodedDate = formattedTime
	user.Status = "PENDING"
	user.Username = generateDefaultUsername(user.FirstName, user.MiddleName, user.LastName, formattedTime)
	user.Password = generateDefaultPassword(user.LastName, user.BirthDate, formattedTime)
	user.PIN = generateDefaultPin(formattedTime)

	// Generate a random string with a maximum length of 10
	// placement := math_rand.Intn(len(user.PIN)) + 1
	// randomString := generateRandomString(math_rand.Intn(15) + 1)
	// user.Password = randomString
	// txtLength := len(randomString)
	// lengthToAppend := strconv.Itoa(txtLength)
	// if txtLength < 10 {
	// 	lengthToAppend = "0" + lengthToAppend
	// }
	// user.PIN = strconv.Itoa(placement) + "-" + user.PIN[0:placement] + user.Password + user.PIN[placement:] + lengthToAppend
	// 54bccbad5495688d355c463f075e25891c7932c071a9b7eca9d0f9e6ff58decedd04  65-VReMmRRmlADStuZ15
	var response db_response.ProcedureResponse
	fullQuery := fmt.Sprintf("SET TIMEZONE TO 'Asia/Manila'; CALL public.insert_pending_user(%d,%d,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','%s','1','1','')", user.RoleID, user.CompanyID, user.FirstName, user.MiddleName, user.LastName, user.BirthDate, user.Sex, user.Username, user.Password, user.PIN, user.Email, user.Status, user.EncodedDate)

	fmt.Println("fullQuery: ", fullQuery)
	dbErr := db.DB.QueryRow(fullQuery).Scan(&response.PendingId, &response.Status, &response.Message)
	if dbErr != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error":       "Database Error",
			"actualError": dbErr.Error(),
			"data":        response,
		})
	}
	if response.PendingId.Valid {
		response.Id = int(response.PendingId.Int64)
	}
	return c.JSON(user)

}

func generateRandomString(length int) string {
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	result := make([]byte, length)

	for i := range result {
		result[i] = charset[math_rand.Intn(len(charset))]
	}

	return string(result)
}
