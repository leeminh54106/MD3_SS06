create database shopping;
use shopping;

create table user (
	id int auto_increment primary key,
    name varchar(100) not null,
    address varchar(255) not null,
    phone varchar(11) unique not null,
    dateofbirth date not null,
    status bit(1)
);

create table product (
	id int auto_increment primary key,
    name varchar(100) not null,
    price double check (price > 0) not null,
    stock int check (stock >= 0) not null,
    status bit(1)
);

create table shopping_cart (
	id int auto_increment primary key,
    user_id int not null,
    foreign key (user_id) references user(id),
    product_id int not null,
    foreign key (product_id) references product(id),
    quantity int check (quantity >= 0) not null,
    amount double not null
);

-- Tạo triggle khi thay đổi giá của sản phẩm thì amount của shopping_cart cũng phải cập nhật lại

delimiter //
create trigger update_amount 
	after update 
    on product
    for each row
    begin
		update shopping_cart as sc join product as p on sc.product_id = old.id set sc.amount = new.price * sc.quantity;
    end//
delimiter ;
insert into product(name, price, stock, status) value ('giầy nam', 2000, 20, 1);
insert into user(name, address, phone, dateofbirth, status) value ('trần hải','long biên','09234567891','2005-5-20',1);
insert into shopping_cart(user_id, product_id, quantity, amount) value (1, 1, 3, 2400);
update product set price = 1500 where id = 1;
select * from shopping_cart;

# khi xoá product thì những dữ liệu ở bảng shopping_cart có chứa product bị xoá cũng phải xoá theo
delimiter //
create trigger dele_product
	after delete on product
    for each row
    begin
		delete from shopping_cart where product_id = old.id;
    end//
delimiter ;
    delete from product where id = 3;
 
	
# Khi thêm 1 sản phẩm vào shopping_cart với số lượng n thì bên product cũng sẽ bị trừ đi n số lượng

delimiter //
create trigger before_update
before update on shopping_cart
for each row
begin
    declare current_stock int;

    select stock into current_stock
    from product
    where id = old.product_id;

    if (new.quantity > old.quantity) and (current_stock - (new.quantity - old.quantity) < 0) then
        signal sqlstate '56000' set message_text = 'vượt qua số lượng trong kho';
    end if;
end//
delimiter ;

delimiter //
create trigger after_update
after update on shopping_cart
for each row
begin
  if(new.quantity < old.quantity)
  then update product set stock = stock + (old.quantity - new.quantity);
  elseif (new.quantity > old.quantity)
  then update product set stock = stock - (new.quantity-old.quantity);
  end if;
end//
delimiter ;