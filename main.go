package main

import (
	encrypt "company/utils/cypher"
	ckErr "company/utils/error_handler"
	"encoding/hex"
	"fmt"
	"log"
	"time"

	"company/routes"

	db "company/utils/connection"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/recover"
)

const key = "use-openssl-rand--base64--256key"

func reverseString(s string) string {
	// Convert the string to a slice of runes
	runes := []rune(s)

	// Reverse the slice of runes
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		runes[i], runes[j] = runes[j], runes[i]
	}

	// Convert the slice of runes back to a string
	return string(runes)
}
func main() {

	db.Connect()
	defer db.Close() // Ensure the connection is closed when done

	// Example query
	var greeting string
	err := db.DB.QueryRow("SELECT 'Hello, World!'").Scan(&greeting)
	ckErr.ErrorChecker(err)

	encText, err := encrypt.Encrypt([]byte("Hello from GoLang"), time.Now())
	ckErr.ErrorChecker(err)

	fmt.Println("GoEnc:", hex.EncodeToString(encText))

	//decText, err := decrypt(encText, []byte(key))
	//ckErr(err)
	//fmt.Println(string(decText))

	// Dart decrypt
	// dartCipher, err := hex.DecodeString("61c83a9b4950b34b6748505f824de8a82855db672cf43d69386c6e1501052b47a653")
	// ckErr.ErrorChecker(err)
	// dartDecText, err := encrypt.Decrypt(dartCipher)
	// ckErr.ErrorChecker(err)

	// fmt.Println("GoDec:", string(dartDecText))
	app := fiber.New()
	app.Use(recover.New())

	// Initialize routes
	routes.SetupRoutes(app)

	// Start the server on port 3000
	log.Fatal(app.Listen(":3000"))
	// log.Fatal(app.Listen("192.168.1.24:3000"))
}
