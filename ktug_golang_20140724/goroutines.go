package main

import (
	"fmt"
	"time"
)

func main() {
	// Like c#'s using - will get called as function completes
	defer fmt.Println("Exiting")

	// Run infinite goroutine
	go printTimePeriodicallyInfinetly()

	// Run finite inline goroutine
	go func(milliseconds int) {
		sleepDuration := time.Duration(milliseconds) * time.Millisecond
		for i := 0; i <= 10; i++ { // Run for 10 iterations
			fmt.Printf("\t\tInline func time is %v\n", time.Now())
			time.Sleep(sleepDuration)
		}
	}(500) // Args to inline function

	fmt.Println("Hit enter to exit")
	var line string
	fmt.Scanf("%s", &line) // Stall main thread of execution, if not all running go routines will terminate and the process complete
}

func printTimePeriodicallyInfinetly() {
	for { // Infinite loop
		fmt.Printf("\tInfinte func time is %v\n", time.Now())
		time.Sleep(1 * time.Second)
	}
}
