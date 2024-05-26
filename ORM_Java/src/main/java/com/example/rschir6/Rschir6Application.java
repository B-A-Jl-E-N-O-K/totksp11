package com.example.rschir6;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;


@EntityScan("com.example.rschir6*")
@SpringBootApplication
public class Rschir6Application {

	public static void main(String[] args) {
		SpringApplication.run(Rschir6Application.class, args);
	}

}
