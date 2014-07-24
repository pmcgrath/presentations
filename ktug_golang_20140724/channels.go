package main

import (
	"fmt"
	"time"
)

type workItem struct {
	quantity int
}

func main() {
	workChannel := make(chan workItem) // Make a non buffered channel

	go worker(1, workChannel)
	go worker(2, workChannel)
	go worker(3, workChannel)

	var quantity int
	for {
		fmt.Println("Enter quantity, -1 to exit ")
		fmt.Scanf("%d", &quantity)
		if quantity == -1 {
			break // Break out of loop so process can complete
		}
		item := workItem{quantity} // Using a composite literal to create instance, using sequence to set member value
		workChannel <- item        // Put quantity into channel
	}
	fmt.Println("Exiting")
}

func worker(id int, workChannel <-chan workItem) { // Can optionally restrict channel direction, here we indicate we can take from channel but cannot send to the channel
	for {
		item := <-workChannel // Receive from work channel, this is a blocking operation if nothing in the channel as we are using an unbufered channel
		fmt.Printf("\t%v Worker [%d] - Working on work item with quantity %d\n", time.Now(), id, item.quantity)
	}
}
