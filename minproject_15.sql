/*
 * DATABASE SETUP - SESSION 15 EXAM
 * Database: StudentManagement
 */

DROP DATABASE IF EXISTS StudentManagement;
CREATE DATABASE StudentManagement;
USE StudentManagement;

-- =============================================
-- 1. TABLE STRUCTURE
-- =============================================

-- Table: Students
CREATE TABLE Students (
    StudentID CHAR(5) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    TotalDebt DECIMAL(10,2) DEFAULT 0
);

-- Table: Subjects
CREATE TABLE Subjects (
    SubjectID CHAR(5) PRIMARY KEY,
    SubjectName VARCHAR(50) NOT NULL,
    Credits INT CHECK (Credits > 0)
);

-- Table: Grades
CREATE TABLE Grades (
    StudentID CHAR(5),
    SubjectID CHAR(5),
    Score DECIMAL(4,2) CHECK (Score BETWEEN 0 AND 10),
    PRIMARY KEY (StudentID, SubjectID),
    CONSTRAINT FK_Grades_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    CONSTRAINT FK_Grades_Subjects FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)
);

-- Table: GradeLog
CREATE TABLE GradeLog (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID CHAR(5),
    OldScore DECIMAL(4,2),
    NewScore DECIMAL(4,2),
    ChangeDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 2. SEED DATA
-- =============================================

-- Insert Students
INSERT INTO Students (StudentID, FullName, TotalDebt) VALUES 
('SV01', 'Ho Khanh Linh', 5000000),
('SV03', 'Tran Thi Khanh Huyen', 0);

-- Insert Subjects
INSERT INTO Subjects (SubjectID, SubjectName, Credits) VALUES 
('SB01', 'Co so du lieu', 3),
('SB02', 'Lap trinh Java', 4),
('SB03', 'Lap trinh C', 3);

-- Insert Grades
INSERT INTO Grades (StudentID, SubjectID, Score) VALUES 
('SV01', 'SB01', 8.5), -- Passed
('SV03', 'SB02', 3.0); -- Failed

-- PHẦN A – CƠ BẢN (4 điểm)
-- Câu 1:
delimiter $$
create trigger tg_checkscore
before insert on grades
for each row
begin
    -- nếu điểm nhỏ hơn 0, tự động gán về 0
    if new.score < 0 then
        set new.score = 0;
    end if;

    -- nếu điểm lớn hơn 10, tự động gán về 10
    if new.score > 10 then
        set new.score = 10;
    end if;
end $$
delimiter ;

-- Test thử bài 1
insert into grades (studentid, subjectid, score) values ('SV01', 'SB02', -5);
insert into grades (studentid, subjectid, score) values ('SV03', 'SB03', 15);
select * from grades;


-- Câu 2 
start transaction;
insert into students (studentid, fullname) values ('SV02', 'Doan Manh Duy');

update students set totaldebt = 5000000 where studentid = 'SV02';

commit;
-- Test câu 2
select * from students where studentid = 'SV02';



-- PHẦN B – KHÁ (3 điểm)
-- Câu 3
delimiter $$
create trigger tg_loggradeupdate
after update on grades
for each row
begin
    if old.score <> new.score then
        insert into gradelog (studentid, oldscore, newscore, changedate)
        values (old.studentid, old.score, new.score, now());
    end if;
end $$
delimiter ;

-- Test Câu 3
update grades set score = 9.0 where studentid = 'SV01' and subjectid = 'SB01';
select * from gradelog;

-- Câu 4 
delimiter $$
create procedure sp_paytuition()
begin
    declare v_remaining_debt decimal(10,2);
    start transaction;
    update students set totaldebt = totaldebt - 2000000 where studentid = 'SV01';

    select totaldebt into v_remaining_debt from students where studentid = 'SV01';
    
    if v_remaining_debt < 0 then
        rollback;
    else
        commit;
    end if;

end $$
delimiter ;

call sp_paytuition();
select * from students where studentid = 'SV01';