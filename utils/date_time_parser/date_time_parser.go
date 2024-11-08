package datetimeparser

import (
	"time"
)

func ParseStringToTime(timeString string) (*time.Time, error) {

	layout := "2006-01-02T15:04:05+08:00"

	// Convert the string to time.Time
	parsedTime, err := time.Parse(layout, timeString)
	if err != nil {
		return nil, err
	}
	return &parsedTime, nil
}

func DateTimeFormater(timestamp time.Time) string {
	return timestamp.Format("2006-01-02T15:04:05+08:00")
}
