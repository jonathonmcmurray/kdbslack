package main

import "fmt"
import "os"
import "github.com/rivo/uniseg"

func main(){
	gr := uniseg.NewGraphemes(os.Args[1]);
	i := 0;
	for gr.Next() {
		i += 1;
	}
	fmt.Printf("%d\n",i)
}
