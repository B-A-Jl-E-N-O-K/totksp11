package com.example.rschir6.repositories;

import com.example.rschir6.models.BuyList;
import com.example.rschir6.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BuyListRepository extends JpaRepository<BuyList, Integer> {
    List<BuyList> findAllByUserId(int user_id);
}
