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
	"os"
	"os/exec"
	"time"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

// Connect initializes the database connection
func Connect() {

	envLoadingErr := godotenv.Load()
	if envLoadingErr != nil {
		log.Fatal("Error loading .env file")
	}

	dbHost := os.Getenv("DATABASE_HOST")
	dbUser := os.Getenv("DATABASE_USER")
	dbPass := os.Getenv("DATABASE_PASSWORD")
	dbName := os.Getenv("DATABASE_NAME")

	connStr := fmt.Sprintf(
		"user=%s password=%s host=%s port=5432 dbname=%s TimeZone=Asia/Manila",
		dbUser,
		dbPass,
		dbHost,
		dbName,
	)
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

func RestoreDatabase( /*user, password, host, port, dbName, filePath string*/ ) error {
	// Construct the psql restore command
	// cmd := exec.Command("psql", "-U", user, "-h", host, "-p", port, "-d", dbName, "-f", filePath)

	// // Set the environment variable for the password
	// cmd.Env = append(os.Environ(), fmt.Sprintf("PGPASSWORD=%s", password))

	// // Run the command and capture the output

	cmd := exec.Command("pwd")
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to restore database: %v\nOutput: %s", err, string(output))
	}

	fmt.Printf("Database restored successfully. Output: %s\n", string(output))

	return nil
}
