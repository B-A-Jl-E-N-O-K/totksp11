package com.example.rschir6.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "buy_confirm")
@NoArgsConstructor
public class BuyConfirm {

    public BuyConfirm(int user_id, boolean is_wait, boolean is_finish){
        this.userId = user_id;
    }
    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int id;

    @Column(name = "userId")
    private int userId;

    @Column(name = "is_wait")
    private boolean is_wait;

    @Column(name = "is_finish")
    private boolean is_finish;
    
}
