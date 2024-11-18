package mailer

import (
	"fmt"
	"net/smtp"
)

func SendEmail(username string, password string, host string, address string, subject string, body string, to string) error {
	auth := smtp.PlainAuth(
		"",
		username,
		password,
		host,
		// "m.rommellagurin@gmail.com",
		// "dewmnefanfsmqczg",
		// "smtp.gmail.com",
	)

	msg := fmt.Sprintf("Subject: %s\n%s", subject, body)

	err := smtp.SendMail(
		fmt.Sprintf("%s:%s", host, address),
		// "smtp.gmail.com:587",
		auth,
		username,
		// "m.rommellagurin@gmail.com",
		[]string{to},
		[]byte(msg),
	)
	if err != nil {
		fmt.Println("error: ", err)
		return err
	}
	return nil
}
