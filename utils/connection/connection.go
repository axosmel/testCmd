// package connection

// import (
// 	"database/sql"
// 	"fmt"
// 	"log"

// 	_ "github.com/lib/pq" // Import the PostgreSQL driver
// )

// var DB *sql.DB

// // Connect initializes the database connection
// func Connect() {
// 	var err error
// 	connStr := "user=rommellagurin password=postgres host=localhost port=5432 dbname=san_juan_businesses sslmode=disable"

// 	DB, err = sql.Open("postgres", connStr)
// 	if err != nil {
// 		log.Fatal("Failed to open database:", err)
// 	}

// 	// Check if the connection is alive
// 	if err = DB.Ping(); err != nil {
// 		log.Fatal("Failed to connect to database:", err)
// 	}

// 	fmt.Println("Connected to PostgreSQL!")
// }

// // Close closes the database connection
// func Close() {
// 	if err := DB.Close(); err != nil {
// 		log.Fatal("Error closing the database connection:", err)
// 	}
// }

package connection

import (
	"fmt"
	"log"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

// Connect initializes the database connection
func Connect() {
	// dsn := "user=a password=postgres host=a port=1234 dbname=s sslmode=disable"
	connStr := "user=rommel password=boslagu host=postgresql-rommel.alwaysdata.net port=5432 dbname=rommel_company sslmode=disable TimeZone=Asia/Manila"
	var err error
	// Get the current time
	now := time.Now()              // Get the timezone name and offset
	timezone, offset := now.Zone() // Print the timezone name and offset
	fmt.Printf("Current Timezone: %s\nOffset: %d seconds\n", timezone, offset)
	DB, err = gorm.Open(postgres.Open(connStr), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to open database:", err)
	}

	// Check if the connection is alive
	sqlDB, err := DB.DB()
	if err != nil {
		log.Fatal("Failed to get database handle:", err)
	}

	if err = sqlDB.Ping(); err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	fmt.Println("Connected to PostgreSQL!")
}

// Close closes the database connection
func Close() {
	sqlDB, err := DB.DB()
	if err != nil {
		log.Fatal("Failed to get database handle:", err)
	}

	if err := sqlDB.Close(); err != nil {
		log.Fatal("Error closing the database connection:", err)
	}
}
