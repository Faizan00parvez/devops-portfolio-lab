package com.example.usersapi;

import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/users")
public class UsersController {

    private static final List<User> SAMPLE = List.of(
        new User("1", "Alice"),
        new User("2", "Bob"),
        new User("3", "Charlie")
    );

    @GetMapping
    public List<User> list() {
        return SAMPLE;
    }

    @GetMapping("/{id}")
    public User get(@PathVariable String id) {
        return SAMPLE.stream().filter(u -> u.id().equals(id)).findFirst()
            .orElseThrow(() -> new NoSuchElementException("User not found"));
    }
}