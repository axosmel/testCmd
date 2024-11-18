package errorhandler

import "log"

// Simplify code error ck
func ErrorChecker(err error) {
	if err != nil {
		log.Fatal("SYSTEM: ", err.Error())
	}
}
