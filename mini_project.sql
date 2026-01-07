create database project_mini;
use project_mini;

create table customers (
customer_id int auto_increment primary key,
customer_name varchar(100) not null,
email varchar(100) not null unique,
phone varchar(10) not null unique
);

create table categories (
category_id int auto_increment primary key,
category_name varchar(255) not null unique
);

create table products (
product_id int auto_increment primary key,
product_name varchar(255) not null unique,
price decimal(10,2) not null check (price > 0),
category_id int not null,
foreign key (category_id) references categories(category_id)
);

create table orders (
order_id int auto_increment primary key,
customer_id int not null,
order_date datetime default current_timestamp,
status enum('pending', 'completed', 'cancel') default 'pending',
foreign key (customer_id) references customers(customer_id)
);


create table order_items (
order_item_id int auto_increment primary key,
order_id int ,
product_id int ,
quantity int not null  check (quantity > 0),
foreign key (order_id) references orders(order_id),
foreign key (product_id) references products(product_id)
);


insert into customers (customer_name, email, phone)
 values
('nguyen van a', 'a@gmail.com', '0900000001'),
('tran thi b', 'b@gmail.com', '0900000002'),
('le van c', 'c@gmail.com', '0900000003'),
('pham thi d', 'd@gmail.com', '0900000004'),
('hoang van e', 'e@gmail.com', '0900000005');

insert into categories (category_name) 
values
('dien thoai'),
('laptop'),
('phu kien'),
('tablet'),
('dong ho');

insert into products (product_name, price, category_id)
 values
('iphone 15', 25000000, 1),
('samsung s23', 22000000, 1),
('macbook air m2', 28000000, 2),
('chuot logitech', 500000, 3),
('apple watch', 12000000, 5);

insert into orders (customer_id, status) values
(1, 'completed'),
(2, 'completed'),
(3, 'pending'),
(1, 'completed'),
(4, 'cancel');

insert into order_items (order_id, product_id, quantity) values
(1, 1, 1),
(1, 4, 2),
(2, 3, 1),
(3, 2, 1),
(4, 5, 1);


-- PHẦN A – TRUY VẤN DỮ LIỆU CƠ BẢN

-- Lấy danh sách tất cả danh mục sản phẩm trong hệ thống.
select *
from categories;
-- Lấy danh sách đơn hàng có trạng thái là COMPLETED
select *
from orders
where status ='completed';
-- Lấy danh sách sản phẩm và sắp xếp theo giá giảm dần
select *
from products
order by price desc;
-- Lấy 5 sản phẩm có giá cao nhất, bỏ qua 2 sản phẩm đầu tiên
 select *
from products
order by price desc
limit 5 offset 2;

-- PHẦN B – TRUY VẤN NÂNG CAO

-- Lấy danh sách sản phẩm kèm tên danh mục
 select  p.product_id ,p.product_name ,p.price , c.category_name 
 from products p
 join categories c
 on p.category_id=c.category_id;
 
-- Lấy danh sách đơn hàng gồm: order_id order_date customer_name status
select o.order_id, o.order_date, c.customer_name ,o.status
from orders o
left join customers c
on o.customer_id =c.customer_id;
-- Tính tổng số lượng sản phẩm trong từng đơn hàng
select o.order_id , sum(oi.quantity) as total_quantity
from orders o
join order_items oi 
on o.order_id = oi.order_id
group by o.order_id;
-- Thống kê số đơn hàng của mỗi khách hàng

select c.customer_id,c.customer_name,count(o.order_id) as total_order
from customers c
left join orders o 
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name;

-- Lấy danh sách khách hàng có tổng số đơn hàng ≥ 2
select c.customer_id,c.customer_name,count(o.order_id) as total_order
from customers c
left join orders o 
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having count(o.order_id)>=2;
-- Thống kê giá trung bình, thấp nhất và cao nhất của sản phẩm theo danh mục
select c.category_id, c.category_name, avg(p.price) as avg_price, min(p.price) as min_price, max(p.price) as max_price
from categories c
join products p 
on c.category_id = p.category_id
group by c.category_id, c.category_name;


-- PHẦN C – TRUY VẤN LỒNG (SUBQUERY)

-- Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
select *
from products
where price > (select avg(price) from products);

-- Lấy danh sách khách hàng đã từng đặt ít nhất một đơn hàng
select *
from customers 
where customer_id in (select customer_id from orders);

-- Lấy đơn hàng có tổng số lượng sản phẩm lớn nhất.



-- Lấy tên khách hàng đã mua sản phẩm thuộc danh mục có giá trung bình cao nhất

select distinct c.customer_name
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
where p.category_id = (
    select category_id
    from products
    group by category_id
    order by avg(price) desc
    limit 1
);

-- Từ bảng tạm (subquery), thống kê tổng số lượng sản phẩm đã mua của từng khách hàng



-- Viết lại truy vấn lấy sản phẩm có giá cao nhất, đảm bảo:
     -- Subquery chỉ trả về một giá trị
     -- Không gây lỗi “Subquery returns more than 1 row”
     
select *
from products
where price = (select max(price)from products);
