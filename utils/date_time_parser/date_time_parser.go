package datetimeparser

import (
	"fmt"
	"strings"
	"time"
)

func ParseStringToTime(timeString string) (*time.Time, error) {
	// Use RFC3339 to handle both "Z" (UTC) and timezone offsets
	parsedTime, err := time.Parse(time.RFC3339, timeString)
	if err != nil {
		return nil, err
	}
	return &parsedTime, nil
}

func DateTimeFormatter(timestamp time.Time) string {
	return timestamp.Format("2006-01-02T15:04:05+08:00")
}

func ParseStringToTimeV2(timeString string) (*time.Time, error) {
	fmt.Println("timeString: ", timeString)
	var utcTime time.Time
	var err error
	if strings.Contains(timeString, "Z") {
		utcTime, err = time.Parse(time.RFC3339, timeString)
		if err != nil {
			fmt.Println("Error parsing time:", err)
		}
	}

	// Load the desired timezone (e.g., UTC+08:00)
	loc, err := time.LoadLocation("Asia/Manila")
	if err != nil {
		fmt.Println("Error loading location:", err)
	}
	// Convert the UTC time to the desired timezone
	localTime := utcTime.In(loc)

	layout := "2006-01-02T15:04:05+08:00"

	// // Convert the string to time.Time
	// parsedTime, err := time.Parse(layout, timeString)
	if err != nil {
		return nil, err
	}
	formattedTime := localTime.Format("2006-01-02T15:04:05+08:00")

	parsedTime, err := time.Parse(layout, formattedTime)
	if err != nil {
		fmt.Println("Error parsing time:", err)
	}
	fmt.Println("parsedTime: ", parsedTime)
	return &parsedTime, nil
}
