package com.example.rschir6.controllers;

import com.example.rschir6.models.BuyList;
import com.example.rschir6.models.User;
import com.example.rschir6.services.BuyService;
import com.example.rschir6.services.UserService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/")
public class UserController {
    private final UserService userService;
    private final BuyService buyService;

    public UserController(UserService userService, BuyService buyService) {
        this.userService = userService;
        this.buyService = buyService;
    }

    @PostMapping()
    public boolean addUser(@RequestBody User user)
    {
        userService.save(user);
        return true;
    }

    @PostMapping("/buy")
    public boolean makeBuy(@RequestBody BuyList buyList) {
        buyService.saveBuy(buyList);
        return true;
    }

    @GetMapping("/pay/{id}")
    public boolean makePay(@PathVariable int id) {

        return buyService.pay(id);
    }

}
