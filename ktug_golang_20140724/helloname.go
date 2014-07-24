// Comments - same as c, single line and multiline with /*
// Once go is on your path, should be able to run with : go run helloname.go

// This will result in an executable as package name is main
package main

// using\imports - Referenced packages
// 	Can do individual lines per packge or use this format to avoid having to repeatedly type import
import (
	"fmt"
	"os"      // Need this for the Args variable that is populated on app start
	"strings" // Need this for the Println function calls
)

// Main function - { on same line as go is vry particular about this, so we can avoid semicolons with a small number of exceptions
func main() {
	var name string
	if len(os.Args) > 1 { // Notice no surrounding (), len is a build in function, we are using the Args var from the os package which is string slice
		name = os.Args[1] // To see what type Args is 1) hg clone -u release https://code.google.com/p/go 2) cd go/src/pkg 3) grep 'var Args' *.go -rn .
	} else {
		name = "world"
	}

	fmt.Printf("Processing for %s\n", name) // Like c printf
	fmt.Println("-----")

	greeting := getGreeting(name) // Call function, storing in greeting var using type inference
	fmt.Println(greeting)
	fmt.Println("-----")

	nameContainsSpace, nameLength := getNameAttributes(name)                              // Capturing 2 return values, using long names, go seems to use short names
	fmt.Printf("Name attributes are %t and %d\n", nameContainsSpace, nameLength)          // Using format verbs, see http://golang.org/pkg/fmt/
	fmt.Printf("Stringer name attributes are %v and %v\n", nameContainsSpace, nameLength) // Relying on the stringer for a type
}

// Private function, only available in local package due to lowercase first char in function name - this is global within the package
func getGreeting(name string) string { // Takes a single string arg and returns a string
	return fmt.Sprintf("Hello %s", name) // Like string.Format
}

// Function with 2 return values, we have named them here, this is optional
func getNameAttributes(name string) (containsASpace bool, length int) {
	containsASpace = strings.Index(name, " ") > -1 // Since the return values were named we can use in the function
	length = len(name)

	return // Since we are using named return values no need to include here, could have used return containsASpace, length
}
