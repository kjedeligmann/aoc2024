package main

import (
	"fmt"
	"os"
	"slices"
	"strings"
)

func main() {
    fmt.Println(part2())
}

type Entry struct{
    Before []string
    After []string
}

func part1() int {
    var sum int
    bytes, _ := os.ReadFile("input")
    input := string(bytes)

    rules := map[string]Entry{}

    lines := strings.Split(input, "\n")

    var idx int

    for lines[idx] != "" {
        nums := strings.Split(lines[idx], "|")
        first, last := nums[0], nums[1]

        f, _ := rules[first]
        f.After = append(f.After, last)
        rules[first] = f

        l, _ := rules[last]
        l.Before = append(l.Before, first)
        rules[last] = l

        idx++
    }

    idx++

    for lines[idx] != "" {
        pages := strings.Split(lines[idx], ",")
        middle := pages[len(pages)/2]

        for i := 0; i < len(pages); i++ {
            for j := 0; j < len(pages); j++ {
                if j < i {
                    if !slices.Contains(rules[pages[i]].Before, pages[j]) {
                        goto fail
                    }
                } else if j > i {
                    if !slices.Contains(rules[pages[i]].After, pages[j]) {
                        goto fail
                    }
                }
            }
        }
        sum += int(middle[0]-'0') * 10 + int(middle[1]-'0')

        fail:
        idx++
    }

    return sum
}

func part2() int {
    var sum int
    bytes, _ := os.ReadFile("input")
    input := string(bytes)

    rules := map[string]Entry{}

    lines := strings.Split(input, "\n")

    var idx int

    for lines[idx] != "" {
        nums := strings.Split(lines[idx], "|")
        first, last := nums[0], nums[1]

        f, _ := rules[first]
        f.After = append(f.After, last)
        rules[first] = f

        l, _ := rules[last]
        l.Before = append(l.Before, first)
        rules[last] = l

        idx++
    }

    idx++

    for lines[idx] != "" {
        pages := strings.Split(lines[idx], ",")

        for i := 0; i < len(pages); i++ {
            for j := 0; j < len(pages); j++ {
                if j < i {
                    if !slices.Contains(rules[pages[i]].Before, pages[j]) {
                        sum += restoreOrder(rules, pages)
                        goto end
                    }
                } else if j > i {
                    if !slices.Contains(rules[pages[i]].After, pages[j]) {
                        sum += restoreOrder(rules, pages)
                        goto end
                    }
                }
            }
        }

        end:
        idx++
    }

    return sum
}

func restoreOrder(rules map[string]Entry, update []string) int {
    slices.SortFunc(update, func(a, b string) int {
        if slices.Contains(rules[a].After, b) {
            return -1
        } else if slices.Contains(rules[b].After, a) {
            return 1
        }
        return 0
    })

    middle := update[len(update)/2]
    return int(middle[0]-'0') * 10 + int(middle[1]-'0')
}
