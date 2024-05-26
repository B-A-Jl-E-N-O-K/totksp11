package com.example.rschir6.repositories;

import com.example.rschir6.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Integer> {
}
