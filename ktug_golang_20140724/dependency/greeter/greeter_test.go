// test with : go test
package greeter

import "testing"

func TestGetGreeting(t *testing.T) { // Method must being with Test and take a single t *testing.T arg
	name := "Ted"
	expectedGreeting := "Hello Ted"

	greeting := GetGreeting(name)

	if greeting != expectedGreeting {
		t.Errorf("Expected %s but got %s", expectedGreeting, greeting) // This is what indicates the test has failed
	}
}
