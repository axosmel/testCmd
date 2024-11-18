package systemparameter

import (
	db "company/utils/connection"
	"fmt"
)

func GetSystemParameter(paramKey string) *[]SystemParameter {
	var params []SystemParameter

	fullQuery := fmt.Sprintf("SELECT * FROM system.system_parameters WHERE parameter_name LIKE '%%%s%%' ORDER BY parameter_id", paramKey)

	result := db.DB.Raw(fullQuery).Scan(&params)
	if result.Error != nil {
		fmt.Println("Error executing query:", result.Error)
		return nil
	}
	return &params
}

type SystemParameter struct {
	Id             int    `json:"id"`
	ParameterName  string `json:"parameterName"`
	ParameterValue string `json:"parameterValue"`
}
