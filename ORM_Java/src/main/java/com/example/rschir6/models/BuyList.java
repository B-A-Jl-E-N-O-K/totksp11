package com.example.rschir6.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "buy_list")
@NoArgsConstructor
public class BuyList {

    public BuyList(String name, int userId, int cost){
        this.name = name;
        this.userId = userId;
        this.cost = cost;
    }
    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int id;

    @Column(name = "name")
    private String name;

    @Column(name = "userId")
    private int userId;

    @Column(name = "cost")
    private int cost;
    
}
