drop database if exists Mini_Social_Network;
CREATE DATABASE Mini_Social_Network;
USE Mini_Social_Network;

CREATE TABLE Users(
	user_id int primary key auto_increment,
    username varchar(50) unique not null,
    password varchar(255) not null,
    email varchar(100) unique not null,
    created_at datetime default current_timestamp
);

CREATE TABLE Posts(
	post_id int primary key auto_increment,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
    foreign key (user_id) references Users(user_id) on delete cascade
);

CREATE TABLE Comments(
	comment_id int primary key auto_increment,
    post_id int not null,
    user_id int not null,
    content text not null,
    created_at datetime default current_timestamp,
	foreign key (user_id) references Users(user_id) on delete cascade,
    foreign key (post_id) references Posts(post_id) on delete cascade
);

CREATE TABLE Friends(
	user_id int not null,
    friend_id int not null,
    status varchar(20) not null check(status IN ('pending', 'accepted')),
	created_at datetime default current_timestamp,
	primary key (user_id, friend_id),
    foreign key (user_id) references Users(user_id) on delete cascade,
	foreign key (friend_id) references Users(user_id) on delete cascade
);

CREATE TABLE Likes(
	like_id int primary key auto_increment,
    user_id int not null,
    post_id int not null,
	created_at datetime default current_timestamp,
	unique key(post_id, user_id),
	foreign key (user_id) references Users(user_id) on delete cascade,
    foreign key (post_id) references Posts(post_id) on delete cascade
);

insert into users (username, password, email) values 
('nguyen van a', 'pass123', 'nguyenvana@example.com'),
('tran thi b', 'pass456', 'tranthib@example.com'),
('le van c', 'pass789', 'levanc@example.com'),
('pham thi d', 'secret1', 'phamthid@example.com'),
('hoang van e', 'secret2', 'hoangvane@example.com');

-- 2. thêm dữ liệu bài viết (posts)
insert into posts (user_id, content) values 
(1, 'hom nay troi dep qua, di code thoi'),
(1, 'sql kho qua nhung ma vui'),
(2, 'tim dong doi di da bong chieu nay'),
(3, 'chuc mung nam moi ca nha'),
(4, 'review quan cafe moi o quan 1');

-- 3. thêm dữ liệu bình luận (comments)
insert into comments (post_id, user_id, content) values 
(1, 2, 'dong y, thoi tiet tuyet voi'),
(1, 3, 'code o dau the ban'),
(2, 4, 'co len ban oi, sap xong roi'),
(3, 1, 'minh dang ky 1 slot nhe'),
(5, 2, 'gia ca the nao ban');

-- 4. thêm dữ liệu lượt thích (likes)
-- (lưu ý: mỗi cặp user_id và post_id là duy nhất)
insert into likes (user_id, post_id) values 
(2, 1), -- b like bài của a
(3, 1), -- c like bài của a
(4, 1), -- d like bài của a
(1, 3), -- a like bài của c
(5, 5); -- e like bài của d

-- 5. thêm dữ liệu bạn bè (friends)
insert into friends (user_id, friend_id, status) values 
(1, 2, 'accepted'), -- a và b là bạn bè
(1, 3, 'pending'),  -- a gửi lời mời cho c (đang chờ)
(2, 4, 'accepted'), -- b và d là bạn bè
(3, 5, 'pending');  -- c gửi lời mời cho e (đang chờ)


-- F11 Quản lý xóa bài viết
-- Tạo bảng lưu lịch sử bài viết bị xóa
create table deleted_posts_log (
    log_id int primary key auto_increment,
    post_id int,
    user_id int,
    content text,
    deleted_at datetime default current_timestamp
);

-- tạo trigger: tự động lưu bài viết vào log trước khi bị xóa vĩnh viễn
delimiter $$
drop trigger if exists tg_before_delete_post $$
create trigger tg_before_delete_post
before delete on posts
for each row
begin
    insert into deleted_posts_log (post_id, user_id, content)
    values (old.post_id, old.user_id, old.content);
end $$
delimiter ;

-- tạo procedure xóa bài viết (sử dụng transaction)
delimiter $$
drop procedure if exists sp_delete_post $$
create procedure sp_delete_post(
    in p_post_id int
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
        signal sqlstate '45000' set message_text = 'lỗi: không thể xóa bài viết!';
    end;

    start transaction;
        -- kiểm tra bài viết có tồn tại không
        if not exists (select 1 from posts where post_id = p_post_id) then
            signal sqlstate '45000' set message_text = 'bài viết không tồn tại!';
        end if;

        -- thực hiện xóa
        delete from posts where post_id = p_post_id;

    commit;
end $$
delimiter ;

-- F12 Quản lý xóa tài khoản người dùng
delimiter $$
drop procedure if exists sp_delete_user $$
create procedure sp_delete_user(
    in p_user_id int
)
begin
    -- khai báo xử lý lỗi
    declare exit handler for sqlexception
    begin
        rollback;
        signal sqlstate '45000' set message_text = 'lỗi: không thể xóa tài khoản!';
    end;

    start transaction;
        -- kiểm tra user có tồn tại không
        if not exists (select 1 from users where user_id = p_user_id) then
            signal sqlstate '45000' set message_text = 'người dùng không tồn tại!';
        end if;

        -- xóa người dùng
        -- toàn bộ posts, comments, likes, friends sẽ tự động bị xóa nhờ on delete cascade
        delete from users where user_id = p_user_id;

    commit;
end $$
delimiter ;


-- Test xóa bài viết
call sp_delete_post(2);
-- kiểm tra log xem đã lưu chưa
select * from deleted_posts_log;

-- Test xóa user
call sp_delete_user(3);
-- kiểm tra bảng users
select * from users;