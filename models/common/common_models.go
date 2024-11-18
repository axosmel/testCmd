package common

import (
	owned_strings "company/utils/strings"
	"fmt"
	"reflect"
	"strings"
)

type UserTable struct {
	UserId         int64  `json:"userId,omitempty"`
	RoleID         int64  `json:"roleId,omitempty"`
	Firstname      string `json:"firstname,omitempty"`
	Middlename     string `json:"middlename,omitempty"`
	Lastname       string `json:"lastname,omitempty"`
	Sex            string `json:"sex,omitempty"`
	CompanyID      int64  `json:"company_id,omitempty"`
	Birthdate      string `json:"birthdate,omitempty"`
	Username       string `json:"username,omitempty"`
	Password       string `json:"password,omitempty"`
	PIN            string `json:"pin,omitempty"`
	Email          string `json:"email,omitempty"`
	Status         string `json:"status,omitempty"`
	RegisteredDate string `json:"registeredDate,omitempty"`
	EncodedDate    string `json:"encodedDate,omitempty"`
}

type User struct {
	PendingId      int64     `json:"pendingId,omitempty"`
	UserId         int64     `json:"userId,omitempty"`
	RoleID         int64     `json:"roleId,omitempty"`
	Firstname      string    `json:"firstname,omitempty"`
	Middlename     string    `json:"middlename,omitempty"`
	Lastname       string    `json:"lastname,omitempty"`
	Sex            string    `json:"sex,omitempty"`
	CompanyID      int64     `json:"company_id,omitempty"`
	Birthdate      string    `json:"birthdate,omitempty"`
	Email          string    `json:"email,omitempty"`
	Status         string    `json:"status,omitempty"`
	RegisteredDate string    `json:"registeredDate,omitempty"`
	EncodedDate    string    `json:"encodedDate,omitempty"`
	ContactsList   []Contact `json:"contactsList,omitempty"`
	AddresseList   []Address `json:"addresseList,omitempty"`
	UserRole       Role      `json:"userRole,omitempty"`
	UserCompany    Company   `json:"userCompany,omitempty"`
	UserAccess     Access    `json:"userAccess,omitempty"`
}

type Contact struct {
	ContactId      int64  `json:"contactId,omitempty"`
	UserDetailsId  int64  `json:"userDetailsId,omitempty"`
	ContactType    string `json:"contactType,omitempty"`
	ContactDetails string `json:"contactDetails,omitempty"`
	Prioritization string `json:"prioritization,omitempty"`
}

type Address struct {
	AddressId     int64  `json:"addressId,omitempty"`
	UserDetailsId int64  `json:"userDetailsId,omitempty"`
	HouseNo       string `json:"houseNo,omitempty"`
	Purok         string `json:"purok,omitempty"`
	AddrStreet    string `json:"street,omitempty"`
	Subdivision   string `json:"subdivision,omitempty"`
	AddrBrgy      string `json:"brgy,omitempty"`
	AddrCity      string `json:"city,omitempty"`
	AddrProvince  string `json:"province,omitempty"`
}

type Role struct {
	RoleId          int64  `json:"roleId,omitempty"`
	RoleTitle       string `json:"roleTitle,omitempty"`
	RoleDescription string `json:"roleDescription,omitempty"`
}

type Company struct {
	CompanyId   int64  `json:"companyId,omitempty"`
	Title       string `json:"title,omitempty"`
	Description string `json:"description,omitempty"`
	Business    string `json:"business,omitempty"`
	Street      string `json:"street,omitempty"`
	Brgy        string `json:"brgy,omitempty"`
	City        string `json:"city,omitempty"`
	Province    string `json:"province,omitempty"`
	Longitude   string `json:"longitude,omitempty"`
	Latitude    string `json:"latitude,omitempty"`
}

type Access struct {
	MatrixId           int64  `json:"matrixId,omitempty"`
	MatrixTitle        string `json:"matrixTitle,omitempty"`
	MatrixDescription  string `json:"matrixDescription,omitempty"`
	AccessType         string `json:"accessType,omitempty"`
	FeatureId          int64  `json:"featureId,omitempty"`
	FeatureTitle       string `json:"featureTitle,omitempty"`
	FeatureDescription string `json:"featureDescription,omitempty"`
}

type Feature struct {
	FeatureId          int64  `json:"featureId,omitempty"`
	FeatureTitle       string `json:"featureTitle,omitempty"`
	FeatureDescription string `json:"featureDescription,omitempty"`
}

// Function to copy fields from UserTable to User using reflection
func CopyFields(src interface{}, dst interface{}) {
	srcVal := reflect.ValueOf(src)
	dstVal := reflect.ValueOf(dst).Elem()
	for i := 0; i < srcVal.NumField(); i++ {
		field := srcVal.Type().Field(i)
		if dstField := dstVal.FieldByName(field.Name); dstField.IsValid() && dstField.CanSet() {
			dstField.Set(srcVal.Field(i))
		}
	}
}

// Function to dynamically copy fields from map to struct
func MapToStruct(data map[string]interface{}, result interface{}) error {
	val := reflect.ValueOf(result).Elem()
	typ := val.Type()

	for key, value := range data {
		for i := 0; i < typ.NumField(); i++ {
			structField := typ.Field(i)
			tag := structField.Tag.Get("json")
			// Strip the omitempty part
			tagName := strings.Split(tag, ",")[0]

			if tagName == owned_strings.SnakeToCamel(key) {
				fieldVal := val.FieldByName(structField.Name)
				if fieldVal.IsValid() && fieldVal.CanSet() {
					fieldValue := reflect.ValueOf(value)
					if tagName == "userId" && owned_strings.SnakeToCamel(key) == "userId" {
						fmt.Println("KIND: ", fieldVal.Kind(), " -- ", fieldValue.Kind())
					}
					if fieldVal.Kind() == fieldValue.Kind() {
						fieldVal.Set(fieldValue)
					} else if fieldVal.Kind() == reflect.Float64 && fieldValue.Kind() == reflect.Float64 {
						fieldVal.SetInt(int64(fieldValue.Float()))
					} else if fieldVal.Kind() == reflect.String && fieldValue.Kind() == reflect.Float64 {
						fieldVal.SetString(fmt.Sprintf("%f", fieldValue.Float()))
					}
				}
				break
			}
		}
	}
	return nil
}

// Function to convert a slice of maps to a slice of structs
func MapsToStructs(data []map[string]interface{}, result interface{}) error {
	resultVal := reflect.ValueOf(result).Elem()
	elemType := resultVal.Type().Elem()

	for _, item := range data {
		elemPtr := reflect.New(elemType)
		if err := MapToStruct(item, elemPtr.Interface()); err != nil {
			return err
		}
		resultVal.Set(reflect.Append(resultVal, elemPtr.Elem()))
	}

	return nil
}

func RemoveDuplicates(slice interface{}) interface{} {
	val := reflect.ValueOf(slice)
	if val.Kind() != reflect.Slice {
		panic("removeDuplicates: input is not a slice")
	}

	uniqueMap := make(map[interface{}]bool)
	uniqueSlice := reflect.MakeSlice(val.Type(), 0, val.Len())

	for i := 0; i < val.Len(); i++ {
		item := val.Index(i).Interface()
		if !uniqueMap[item] {
			uniqueMap[item] = true
			uniqueSlice = reflect.Append(uniqueSlice, val.Index(i))
		}
	}

	return uniqueSlice.Interface()
}
