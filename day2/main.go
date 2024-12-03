package main

import (
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func main() {
    fmt.Println(part2dumb())
}

func part1() int {
    var sum int

    bytes, _ := os.ReadFile("input")
    input := string(bytes)

    for _, line := range strings.Split(input, "\n") {
        if line == "" {
            continue
        }

        var ns []int

        for _, s := range strings.Split(line, " ") {
            n, _ := strconv.ParseInt(s, 10, 64)
            ns = append(ns, int(n))
        }

        if !slices.IsSorted(ns) {
            slices.Reverse(ns)
            if !slices.IsSorted(ns) {
                continue
            }
        }

        fmt.Println(ns)
        for i := 1; i < len(ns); i++ {
            if (ns[i] - ns[i-1]) > 3 || ns[i] == ns[i-1] {
                goto fail
            }
        }
        
        sum++

        fail:
    }

    return sum
}

func part2dumb() int {
    var sum int

    bytes, _ := os.ReadFile("input")
    input := string(bytes)

    for _, line := range strings.Split(input, "\n") {
        if line == "" {
            continue
        }

        var ns []int

        for _, s := range strings.Split(line, " ") {
            n, _ := strconv.ParseInt(s, 10, 64)
            ns = append(ns, int(n))
        }
        for i := 0; i < len(ns); i++ {
            if safe(ns, i) {
                sum++
                break
            }
        }
    }

    return sum
}

func safe(origin []int, hole int) bool {
    nums := make([]int, len(origin)-1)
    copy(nums[:hole], origin[:hole]) 
    copy(nums[hole:], origin[hole+1:]) 

    fmt.Println(origin)
    fmt.Println(nums)

    if !slices.IsSorted(nums) {
        slices.Reverse(nums)
        if !slices.IsSorted(nums) {
            return false
        }
    }

    fmt.Println(nums)
    for i := 1; i < len(nums); i++ {
        if (nums[i] - nums[i-1]) > 3 || nums[i] == nums[i-1] {
            return false
        }
    }
    return true
}
