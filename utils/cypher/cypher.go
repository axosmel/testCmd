package cypher

import (
	ckErr "company/utils/error_handler"
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"errors"
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

func Encrypt(plaintext []byte, timestamp time.Time) ([]byte, error) {

	c, err := aes.NewCipher([]byte(getSecret(timestamp)))
	ckErr.ErrorChecker(err)

	gcm, err := cipher.NewGCM(c)
	ckErr.ErrorChecker(err)

	// random nonce
	nonce := make([]byte, gcm.NonceSize())
	_, err = io.ReadFull(rand.Reader, nonce)
	ckErr.ErrorChecker(err)

	return gcm.Seal(nonce, nonce, plaintext, nil), nil
}

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

// Decriptare text
func Decrypt(ciphertext []byte, currentTime time.Time) ([]byte, error) {
	key := getSecret(currentTime)
	secretKey, err := aes.NewCipher([]byte(key))
	ckErr.ErrorChecker(err)

	algo, err := cipher.NewGCM(secretKey)
	ckErr.ErrorChecker(err)

	nonceSize := algo.NonceSize()
	if len(ciphertext) < nonceSize {
		return nil, errors.New("ciphertext too short")
	}

	/*
		// MacSize is just for info, GoLang is smart enough to figure out it's mac size...
		macSize := 16
		mac := ciphertext[(len(ciphertext) - macSize):]
		fmt.Println("Mac:", len(mac), mac)
	*/

	nonce, ciphertext := ciphertext[:nonceSize], ciphertext[nonceSize:]

	// fmt.Println("Nonce:", len(nonce), nonce)
	// fmt.Println("CipherText:", len(ciphertext), ciphertext)

	return algo.Open(nil, nonce, ciphertext, nil)
}

func getSecret(currentTime time.Time) string {

	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	// currentTime := time.Now()

	year := currentTime.Year()
	month := currentTime.Month()
	day := currentTime.Day()
	hours := currentTime.Hour()
	minutes := currentTime.Minute()
	var reversedYear = reverseString(strconv.Itoa(year))
	var reversedMonth = reverseString(strconv.Itoa(int(month)))
	if len(reversedMonth) == 1 {
		reversedMonth = fmt.Sprintf("0%s", reversedMonth)
	}
	var reversedDay = reverseString(strconv.Itoa(day))
	if len(reversedDay) == 1 {
		reversedDay = fmt.Sprintf("0%s", reversedDay)
	}
	var reversedHours = reverseString(strconv.Itoa(hours))
	if len(reversedHours) == 1 {
		reversedHours = fmt.Sprintf("0%s", reversedHours)
	}
	var reversedMinutes = reverseString(strconv.Itoa(minutes))
	if len(reversedMinutes) == 1 {
		reversedMinutes = fmt.Sprintf("0%s", reversedMinutes)
	}

	stringsToAppend := []string{
		reversedYear,
		reversedMonth,
		reversedDay,
		reversedHours,
		reversedMinutes,
	}

	secret := os.Getenv("SECRET")
	newSecret := ""
	cntr := 0
	for index, value := range secret {
		if index%3 == 0 && cntr < 5 {
			newSecret = newSecret + stringsToAppend[cntr] + string(value)
			cntr++
		} else {
			newSecret = newSecret + string(value)
		}
	}
	fmt.Println("SECRET: ", newSecret)
	return newSecret
}
