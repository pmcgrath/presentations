// test with : go test
package main

import "testing"

func TestGetPrefixGreeting(t *testing.T) { // Method must being with Test and take a single t *testing.T arg
	prefix := " "
	name := "Ted"
	expectedGreeting := " Hello Ted!" // Remove ! to pass test

	prefixedGreeting := getPrefixedGreeting(prefix, name)

	if prefixedGreeting != expectedGreeting {
		t.Errorf("Expected [%s] but got [%s]", expectedGreeting, prefixedGreeting) // This is what indicates the test has failed
	}
}
