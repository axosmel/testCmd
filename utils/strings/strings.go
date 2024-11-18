package strings

import (
	"strings"
	"unicode"
)

func TitleToSnakeCase(s string) string {
	var result []rune
	for i, r := range s {
		if unicode.IsUpper(r) {
			if i > 0 {
				result = append(result, '_')
			}
			result = append(result, unicode.ToLower(r))
		} else {
			result = append(result, r)
		}
	}
	return string(result)
}

// Convert snake_case to CamelCase
func SnakeToCamel(input string) string {
	isToUpper := false
	var output string
	for _, r := range input {
		if r == '_' {
			isToUpper = true
		} else {
			if isToUpper {
				output += strings.ToUpper(string(r))
				isToUpper = false
			} else {
				output += string(r)
			}
		}
	}
	return output
}
