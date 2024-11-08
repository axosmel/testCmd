package connection

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq" // Import the PostgreSQL driver
)

var DB *sql.DB

// Connect initializes the database connection
func Connect() {
	var err error
	connStr := "user=rommellagurin password=postgres host=localhost port=5432 dbname=san_juan_businesses sslmode=disable"

	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Failed to open database:", err)
	}

	// Check if the connection is alive
	if err = DB.Ping(); err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	fmt.Println("Connected to PostgreSQL!")
}

// Close closes the database connection
func Close() {
	if err := DB.Close(); err != nil {
		log.Fatal("Error closing the database connection:", err)
	}
}
