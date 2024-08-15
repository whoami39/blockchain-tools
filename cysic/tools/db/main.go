package main

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	_ "github.com/mattn/go-sqlite3"
)

// showUsage prints the usage information for the application
func showUsage() {
	programName := filepath.Base(os.Args[0])
	fmt.Printf(`
Usage: %s <database_path> [options]

Description:
    This application interacts with an SQLite database, allowing you to clear the tasks table
    or execute custom SQL commands.

Arguments:
    <database_path>    Path to the SQLite database file (required)

Options:
    exec <SQL>         Execute a custom SQL command (query, insert, update, delete, etc.)

Examples:
    %s ./cysic-verifier.db                               Clear the tasks table
    %s ./cysic-verifier.db exec "SELECT * FROM tasks"    Execute a SELECT query


- Telegram: https://t.me/blockchain_minter
- GitHub: https://github.com/whoami39/blockchain-tools/tree/main/cysic/tools/db
`, programName, programName, programName)
}
func printMsg(msg string) {
	fmt.Print(msg)
	fmt.Println(". ( If you have any questions: https://t.me/blockchain_minter )")
}

func main() {
	// Check if the correct number of arguments is provided
	if len(os.Args) < 2 {
		showUsage()
		return
	}

	dbPath := os.Args[1]

	// Check if the database file exists
	if _, err := os.Stat(dbPath); os.IsNotExist(err) {
		printMsg(fmt.Sprintf("Error: Database file '%s' does not exist", dbPath))
		return
	}

	// Open the database
	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		printMsg(fmt.Sprintf("Error opening database: %v", err))
		return
	}
	defer db.Close()

	// Test the database connection
	err = db.Ping()
	if err != nil {
		printMsg(fmt.Sprintf("Error connecting to database: %v", err))
		return
	}

	// Handle different command options
	if len(os.Args) == 2 {
		// Begin a transaction
		tx, err := db.Begin()
		if err != nil {
			printMsg(fmt.Sprintf("Error starting transaction: %v", err))
			return
		}

		// Clear the tasks table
		_, err = tx.Exec("DELETE FROM tasks")
		if err != nil {
			tx.Rollback()
			printMsg(fmt.Sprintf("Error clearing tasks table: %v", err))
			return
		}

		// Reset the auto-increment ID
		_, err = tx.Exec("DELETE FROM sqlite_sequence WHERE name='tasks'")
		if err != nil {
			tx.Rollback()
			printMsg(fmt.Sprintf("Error resetting auto-increment ID: %v", err))
			return
		}

		// Commit the transaction
		err = tx.Commit()
		if err != nil {
			printMsg(fmt.Sprintf("Error committing transaction: %v", err))
			return
		}

		printMsg("Tasks table cleared and auto-increment ID reset successfully")
	} else if len(os.Args) == 4 && os.Args[2] == "exec" {
		// Execute a custom SQL command
		sqlCommand := os.Args[3]
		result, err := db.Exec(sqlCommand)
		if err != nil {
			printMsg(fmt.Sprintf("Error executing SQL command: %v", err))
			return
		}

		if strings.HasPrefix(strings.ToUpper(sqlCommand), "SELECT") {
			// If the command is a SELECT query, print the results
			rows, err := db.Query(sqlCommand)
			if err != nil {
				printMsg(fmt.Sprintf("Error executing query: %v", err))
				return
			}
			defer rows.Close()

			columns, _ := rows.Columns()
			values := make([]interface{}, len(columns))
			valuePtrs := make([]interface{}, len(columns))
			for i := range columns {
				valuePtrs[i] = &values[i]
			}

			for rows.Next() {
				err := rows.Scan(valuePtrs...)
				if err != nil {
					printMsg(fmt.Sprintf("Error scanning row: %v", err))
					return
				}
				rowOutput := ""
				for i, col := range values {
					rowOutput += fmt.Sprintf("%s: %v\t", columns[i], col)
				}
				fmt.Println(rowOutput)
			}
		} else {
			// If the command is not a SELECT query, print the number of rows affected
			rowsAffected, _ := result.RowsAffected()
			printMsg(fmt.Sprintf("Command executed successfully. Rows affected: %d", rowsAffected))
		}
	} else {
		fmt.Println("Invalid arguments.")
		showUsage()
	}
}
