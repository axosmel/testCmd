package userauth

import (
	encrypt "company/utils/cypher"
	ckErr "company/utils/error_handler"
	"reflect"
	"strings"

	"company/models/common"
	user_auth "company/models/user_auth"
	"encoding/hex"
	"fmt"

	db "company/utils/connection"

	time_parser "company/utils/date_time_parser"

	"github.com/gofiber/fiber/v2"
)

func SignIn(c *fiber.Ctx) error {

	var user user_auth.UserCredentials
	// Parse the JSON body into the user struct
	if err := c.BodyParser(&user); err != nil {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{
			"error":       "Invalid input",
			"actualError": err,
		})
	}

	validationErr := user.Validate(true)
	if validationErr != nil {
		return c.Status(fiber.StatusBadRequest).JSON(validationErr)
	}

	searchKeys := make(map[string]interface{})
	searchKeys["key"] = "username"
	searchKeys["value"] = user.Username
	if user.Username == "" {
		searchKeys["key"] = "email"
		searchKeys["value"] = user.Email
	}

	var credentialsQueryResponse user_auth.PendingUser
	credentialsUserQuery := fmt.Sprintf("SELECT username, password, pin, registered_date date_encoded FROM users WHERE %s = '%s'", searchKeys["key"], searchKeys["value"])

	result := db.DB.Raw(credentialsUserQuery).Scan(&credentialsQueryResponse)
	if result.Error != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error":       "Database Error",
			"actualError": result.Error.Error(),
			"data":        credentialsQueryResponse,
		})
	}

	// Convert the string to time.Time
	encodedTime, err := time_parser.ParseStringToTime(credentialsQueryResponse.DateEncoded)
	ckErr.ErrorChecker(err)

	hexDecodedPassword, err := hex.DecodeString(credentialsQueryResponse.Password)
	ckErr.ErrorChecker(err)
	decryptedPassword, _ := encrypt.Decrypt([]byte(hexDecodedPassword), *encodedTime)

	fmt.Println(credentialsQueryResponse.Username)
	fmt.Println(user.Username)

	if credentialsQueryResponse.Username == user.Username && reflect.DeepEqual(decryptedPassword, []byte(user.Password)) {
		var (
			// userTable        common.UserTable
			userContacts     []common.Contact
			userAddress      []common.Address
			userMatrix       common.Access
			userRoles        common.Role
			userCompany      common.CustomizedCompany
			userLoginData    common.User
			actualDbResponse []map[string]interface{}
		)

		userDataQuery := fmt.Sprintf("SELECT * FROM backend_functions.get_user_data_wrapper('%s')", user.Username)
		fmt.Println("userDataQuery: ", userDataQuery)
		result := db.DB.Raw(userDataQuery).Scan(&actualDbResponse)
		if result.Error != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error":       "Database Error",
				"actualError": result.Error.Error(),
				"data":        userContacts,
			})
		}

		if err := common.MapToStruct(actualDbResponse[0], &userLoginData); err != nil {
			fmt.Println("Error mapping data to struct:", err)
		}
		if err := common.MapsToStructs(actualDbResponse, &userContacts); err != nil {
			fmt.Println("Error mapping data to struct:", err)
		}
		if err := common.MapsToStructs(actualDbResponse, &userAddress); err != nil {
			fmt.Println("Error mapping data to struct:", err)
		}
		if err := common.MapToStruct(actualDbResponse[0], &userMatrix); err != nil {
			fmt.Println("Error mapping data to struct:", err)
		}
		if err := common.MapToStruct(actualDbResponse[0], &userRoles); err != nil {
			fmt.Println("Error mapping data to struct:", err)
		}
		if err := common.MapToStruct(actualDbResponse[0], &userCompany); err != nil {
			fmt.Println("Error mapping data to struct:", err)
		}

		userContacts = common.RemoveDuplicates(userContacts).([]common.Contact)
		userAddress = common.RemoveDuplicates(userAddress).([]common.Address)
		userLoginData.ContactsList = userContacts
		userLoginData.AddresseList = userAddress
		replaceResult := strings.ReplaceAll(userMatrix.AccessType, "{", "[")
		userMatrix.AccessType = strings.ReplaceAll(replaceResult, "}", "]")
		userLoginData.UserAccess = userMatrix
		userLoginData.UserRole = userRoles
		userLoginData.UserCompany = userCompany

		return c.JSON(userLoginData)
	}

	return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
		"error": "Invalid Credentials",
	})
}
