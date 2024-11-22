package structtostring

import (
	owned_strings "company/utils/strings"
	"database/sql"
	"fmt"
	"reflect"
)

func StructToString(s any) (string, string) {
	v := reflect.ValueOf(s)
	t := reflect.TypeOf(s)
	var (
		fields string
		values string
	)

	if t.Kind() == reflect.Slice {
		fields, values = sliceToString(v)
		return fields[:len(fields)/2], values[:len(values)-1]
		// return fields, values
	}
	fields, values = structConverter(v, t)
	return fields[:len(fields)-1], values[:len(values)-1]
	// return fields, values

}

func structConverter(v reflect.Value, t reflect.Type) (string, string) {
	var fields string
	var values string
	for i := 0; i < v.NumField(); i++ {
		field := t.Field(i).Name
		if field != "AddressId" && field != "ContactId" {
			value := v.Field(i).Interface()
			if value != "" && value != nil && value != 0 {
				fields += fmt.Sprintf("%s, ", owned_strings.TitleToSnakeCase(field))
				values += fmt.Sprintf("'%v', ", value)
			}
		}
	}
	fields = fmt.Sprintf("(%s),", fields)
	values = fmt.Sprintf("(%s),", values[:len(values)-2])
	return fields, values
}

func sliceToString(v reflect.Value) (string, string) {
	var field string
	var value string

	for i := 0; i < v.Len(); i++ {
		receivedField, receivedValue := StructToString(v.Index(i).Interface())
		field += fmt.Sprintf("%s)", receivedField[:len(receivedField)-3])
		value += fmt.Sprintf("%s,", receivedValue)
	}
	return field, value
}

// Function to scan rows into a slice of structs
func ScanRowsToStruct(rows *sql.Rows, dest interface{}) any {
	columns, err := rows.Columns()
	if err != nil {
		return err
	}

	results := []map[string]interface{}{}
	for rows.Next() {
		columnsData := make([]interface{}, len(columns))
		columnsPointers := make([]interface{}, len(columns))
		for i := range columnsData {
			columnsPointers[i] = &columnsData[i]
		}

		if err := rows.Scan(columnsPointers...); err != nil {
			return err
		}

		result := make(map[string]interface{})
		for i, colName := range columns {
			value := columnsPointers[i].(*interface{})
			result[colName] = *value
		}
		results = append(results, result)
	}
	if err := rows.Err(); err != nil {
		return err
	}

	return results
}
