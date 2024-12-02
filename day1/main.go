package main

import (
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func main() {
    fmt.Println(part2())
}

func part1() int {
    var sum int

    bytes, _ := os.ReadFile("input")
    input := string(bytes)

    first, second := []int{}, []int{}

    for _, line := range strings.Split(input, "\n") {
        if line == "" {
            continue
        }
        fs := strings.SplitN(line, "   ", 2)
        f, _ := strconv.ParseInt(fs[0], 10, 64)
        first = append(first, int(f))
        s, _ := strconv.ParseInt(fs[1], 10, 64)
        second = append(second, int(s))
    }

    slices.Sort(first)
    slices.Sort(second)

    for i := 0; i < len(first); i++ {
        if first[i] < second[i] {
            sum += second[i] - first[i]
        } else {
            sum += first[i] - second[i]
        }
    }

    return sum
}

func part2() int {
    var sum int

    bytes, _ := os.ReadFile("input")
    input := string(bytes)

    first, second := []int{}, map[int]int{}

    for _, line := range strings.Split(input, "\n") {
        if line == "" {
            continue
        }
        fs := strings.SplitN(line, "   ", 2)
        f, _ := strconv.ParseInt(fs[0], 10, 64)
        first = append(first, int(f))
        s, _ := strconv.ParseInt(fs[1], 10, 64)
        second[int(s)] += int(s)
    }

    for _, num := range first {
        sum += second[num]
    }

    return sum
}
