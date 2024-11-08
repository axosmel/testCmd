package dbresponse

import "database/sql"

type ProcedureResponse struct {
	Id        int           `json:"id"`
	PendingId sql.NullInt64 `json:"-"`
	UserId    sql.NullInt64 `json:"-"`
	Status    int           `json:"status"`
	Message   string        `json:"message"`
}
