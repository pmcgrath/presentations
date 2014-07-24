// test with : go test
package demo

import "testing"

func TestGetGreeting(t *testing.T) { // Method name must begin with Test and an uppercase letter (We are testing getGreeting but need to use GetGreeting in test function name) and take a single t *testing.T arg
	name := "Ted"
	expectedGreeting := "Hello Ted!" // Remove ! to show test passing

	greeting := getGreeting(name)

	if greeting != expectedGreeting {
		t.Errorf("Expected %s but got %s", expectedGreeting, greeting) // This is what indicates the test has failed
	}
}
