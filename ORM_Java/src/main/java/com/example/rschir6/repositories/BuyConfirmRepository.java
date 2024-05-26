package com.example.rschir6.repositories;

import com.example.rschir6.models.BuyConfirm;
import com.example.rschir6.models.BuyList;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BuyConfirmRepository extends JpaRepository<BuyConfirm, Integer> {
    BuyConfirm findByUserId(int user_id);
}
