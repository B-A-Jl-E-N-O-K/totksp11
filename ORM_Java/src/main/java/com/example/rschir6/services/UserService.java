package com.example.rschir6.services;

import com.example.rschir6.models.BuyList;
import com.example.rschir6.models.User;
import com.example.rschir6.repositories.BuyListRepository;
import com.example.rschir6.repositories.UserRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;

    private final BuyListRepository buyListRep;

    public UserService(UserRepository userRepository, BuyListRepository buyListRep) {
        this.userRepository = userRepository;
        this.buyListRep = buyListRep;
    }

    public void save(User user){
        userRepository.save(user);
    }

    public User getOne(int id) {
        return userRepository.findById(id).get();
    }

}
