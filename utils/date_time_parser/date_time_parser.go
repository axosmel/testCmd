package datetimeparser

import (
	"fmt"
	"strings"
	"time"
)

const (
	myFormat         = "2006-01-02T15:04:05+08:00"
	alternativFormat = "2006-01-02T15:04:05+08"
	tz               = "Asia/Manila"
)

func ParseStringToTime(timeString string) (*time.Time, error) {
	fmt.Println("timeString: ", timeString)

	// Convert the string to time.Time
	parsedTime, err := time.Parse(myFormat, timeString)
	if err != nil {
		parsedAlternativeTime, err := time.Parse(alternativFormat, timeString)
		if err != nil {
			return forceParsing(timeString)
		}
		return &parsedAlternativeTime, nil
	}
	return &parsedTime, nil
}

func forceParsing(timestampUTC string) (*time.Time, error) {

	// Parse the timestamp in UTC
	parsedTime, err := time.Parse(time.RFC3339, timestampUTC)
	if err != nil {
		return nil, err
	}

	location, err := time.LoadLocation(tz)
	if err != nil {
		return nil, err
	}

	// Convert the parsed time to the desired timezone
	localTime := parsedTime.In(location)

	return &localTime, nil
}

func DateTimeFormatter(timestamp time.Time) string {
	return timestamp.Format(myFormat)
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
	loc, err := time.LoadLocation(tz)
	if err != nil {
		fmt.Println("Error loading location:", err)
	}
	// Convert the UTC time to the desired timezone
	localTime := utcTime.In(loc)

	layout := myFormat

	// // Convert the string to time.Time
	// parsedTime, err := time.Parse(layout, timeString)
	if err != nil {
		return nil, err
	}
	formattedTime := localTime.Format(myFormat)

	parsedTime, err := time.Parse(layout, formattedTime)
	if err != nil {
		fmt.Println("Error parsing time:", err)
	}
	fmt.Println("parsedTime: ", parsedTime)
	return &parsedTime, nil
}

func GetTimeInLocation() (time.Time, error) {
	location, err := time.LoadLocation(tz)
	if err != nil {
		return time.Time{}, err
	}
	now := time.Now().In(location)
	return now, nil
}
