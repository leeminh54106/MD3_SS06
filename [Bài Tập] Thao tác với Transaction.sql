create database transaction;
use transaction;

create table users (
	id int auto_increment primary key,
    name varchar(100) not null,
    myMoney double check (myMoney >= 0),
    address varchar(255) not null,
    phone varchar(11) unique not null,
    dateOfBirth date not null,
    status bit(1)
);

create table transfer (
	sender_id int not null,
    foreign key (sender_id) references users(id),
    receiver_id int not null,
    foreign key (receiver_id) references users(id),
    money double check (money >= 0),
    transfer_date datetime
);

insert into users(name, myMoney, address, phone , dateOfBirth, status) 
values('tran van duc',27000,'hai phong','09876546871','1999-01-01',0),('tran van cao',30000,'dang xa','0987654662','2001-12-12',1);

-- drop ;
delimiter //
create procedure transfer_money(
	user_id_one int, 
    user_id_two int, 
    money_in double)
begin
	declare money double;
    select myMoney into money from users where id = user_id_one;
    start transaction;
    IF (money_in > money) 
			then rollback;
             signal sqlstate '45000' set message_text = 'Không có đủ tiền';
	else
		update users set myMoney = myMoney + money_in where id = user_id_two;
        update users set myMoney = myMoney - money_in where id = user_id_one;
        commit;
	end if;
end //
delimiter ;

select * from users;