package com.example.rschir6.services;

import com.example.rschir6.models.BuyConfirm;
import com.example.rschir6.models.BuyList;
import com.example.rschir6.models.User;
import com.example.rschir6.repositories.BuyConfirmRepository;
import com.example.rschir6.repositories.BuyListRepository;
import com.example.rschir6.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;

import java.util.List;
import java.util.Optional;

@Service
public class BuyService {

    @Autowired
    public JavaMailSender emailSender;
    private final UserRepository userRepository;

    private final BuyListRepository buyListRep;

    private final BuyConfirmRepository buyConfRep;

    private final String ourEmail = "";

    public BuyService(UserRepository userRepository, BuyListRepository buyListRep, BuyConfirmRepository buyConfRep) {
        this.userRepository = userRepository;
        this.buyListRep = buyListRep;
        this.buyConfRep = buyConfRep;
    }

    public void saveBuy(BuyList thing){
        BuyConfirm isConfirmSaved = buyConfRep.findByUserId(thing.getUserId());
        if(isConfirmSaved == null){
            BuyConfirm newConf = new BuyConfirm(thing.getUserId(), true, false);
            buyConfRep.save(newConf);
        }

        buyListRep.save(thing);
    }

    public List<BuyList> getAllByUserId(int user_id) {
        return buyListRep.findAllByUserId(user_id);
    }

    public BuyConfirm getConfById(int user_id) {
        return buyConfRep.findByUserId(user_id);
    }


    public boolean pay(int user_id){
        List<BuyList> basketOfUser = getAllByUserId(user_id);
        int summaryCost = 0;
        if(!basketOfUser.isEmpty()){
            for(int i = 0; i < basketOfUser.size(); i++){
                summaryCost += basketOfUser.get(i).getCost();
            }
        }
        if(summaryCost > 0){
            sendConfEmail(user_id, summaryCost);
            return true;
        }

        return false;
    }

    public void sendConfEmail(int user_id, int summaryCost) {
        Optional<User> currUserOpt = userRepository.findById(user_id);
        User user = currUserOpt.get();
        sendSimpleEmail(user.getEmail(), "Спасибо за покупку, " + user.getName(),
                "Сумма вашего заказа:" + summaryCost + " рублей");


    }


    public void sendSimpleEmail(String toAddress, String subject, String message) {

        SimpleMailMessage simpleMailMessage = new SimpleMailMessage();
        simpleMailMessage.setFrom(ourEmail);
        simpleMailMessage.setTo(toAddress);
        simpleMailMessage.setSubject(subject);
        simpleMailMessage.setText(message);
        emailSender.send(simpleMailMessage);
    }
}
