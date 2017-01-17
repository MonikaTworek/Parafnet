CREATE TABLE Rodzina (
	IDRodziny bigint NOT NULL PRIMARY KEY IDENTITY(1,1),
	AdresZamieszkania varchar(max) NOT NULL,
	CzyPrzyjmujeKolede bit NOT NULL,
)
GO

CREATE TABLE Wierny (
	IDWiernego bigint NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDRodziny bigint NOT NULL REFERENCES Rodzina(IDRodziny),
	Imiona varchar(max) NOT NULL,
	Nazwisko varchar(max) NOT NULL,
	DataUrodzenia date NOT NULL,
	CzyZywy bit NOT NULL default 1,
)
GO

CREATE TABLE Ksiadz (
	IDKsiedza bigint NOT NULL PRIMARY KEY IDENTITY(1,1),
	Imie varchar(max) NOT NULL,
	Nazwisko varchar(max) NOT NULL,
	DataPrzybycia date NOT NULL,
	DataOpuszczenia date default NULL,
)
GO

CREATE TABLE Msza (
	IDMszy int NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDKsiedza bigint NOT NULL REFERENCES Ksiadz(IDKsiedza),
	Intencja varchar(max) NOT NULL,
	DataMszy date NOT NULL,
	Kwota int,
)
GO

CREATE TABLE Koleda (
	IDKoledy int NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDRodziny bigint NOT NULL REFERENCES Rodzina(IDRodziny),
	IDKsiedza bigint NOT NULL REFERENCES Ksiadz(IDKsiedza),
	DataKoledy date NOT NULL,
	Kwota int,
)
GO

CREATE TABLE BazaSakramentow (
	IDSakramentu int NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nazwa varchar(max) NOT NULL,
)
GO

CREATE TABLE Sakrament (
	IDSakramentu bigint NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDWiernego bigint NOT NULL REFERENCES Wierny(IDWiernego),
	IDNazwySakramentu int NOT NULL REFERENCES BazaSakramentow(IDSakramentu),
	DataSakramentu date NOT NULL,
	Kwota int,
)
GO

CREATE TABLE Pogrzeb (
	IDPogrzebu bigint NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDZmarlego bigint NOT NULL REFERENCES Wierny(IDWiernego),
	IDKsiedza bigint NOT NULL REFERENCES Ksiadz(IDKsiedza),
	AdresKwatery varchar(max) NOT NULL,
	Kwota int,
	DataPogrzebu date NOT NULL,
)
GO




/*******************************************************************************************************/
/*Sakramenty - dane*/
INSERT INTO BazaSakramentow (Nazwa)
VALUES ('Chrzest'), ('Komunia Œwiêta'), ('Bierzmowanie'), ('Namaszczenie chorych'), ('Ma³¿eñstwo')


/*Widok na pieni¹dze*/
CREATE TABLE kasa(
	Nazwa varchar(max),
	Kwota int
)

INSERT INTO kasa(Nazwa, Kwota)  VALUES ('Msza',0),('Koleda',0),('Sakrament',0), ('Pogrzeb',0)

GO 
CREATE PROCEDURE UpdateKasa
AS
BEGIN
	DECLARE @Kwota int
	SET @Kwota=(SELECT COUNT(Kwota) FROM Msza)
	UPDATE kasa SET Kwota=@Kwota WHERE Nazwa = 'Msza'
	SET @Kwota=(SELECT COUNT(Kwota) FROM Koleda)
	UPDATE kasa SET Kwota=@Kwota WHERE Nazwa = 'Koleda'
	SET @Kwota=(SELECT COUNT(Kwota) FROM Sakrament)
	UPDATE kasa SET Kwota=@Kwota WHERE Nazwa = 'Sakrament'
	SET @Kwota=(SELECT COUNT(Kwota) FROM Pogrzeb)
	UPDATE kasa SET Kwota=@Kwota WHERE Nazwa = 'Pogrzeb'
END

EXECUTE UpdateKasa

GO
CREATE VIEW pieniadzePogrupowane
AS
SELECT * FROM kasa
GO

GO
CREATE VIEW pieniadzeJednostkowe
AS
SELECT Kwota FROM Msza
UNION
SELECT Kwota FROM Koleda
UNION
SELECT Kwota FROM Sakrament
UNION
SELECT Kwota FROM Pogrzeb
GO

/*zaœwiadczenie*/
GO
CREATE FUNCTION Zaswiadczenie (@IDWierny int, @IDSakramentu  int)
RETURNS TABLE
AS
RETURN ( SELECT Wierny.Imiona, Wierny.Nazwisko, Wierny.DataUrodzenia, Sakrament.DataSakramentu, BazaSakramentow.Nazwa 
		FROM Wierny INNER JOIN Sakrament ON Wierny.IDWiernego=Sakrament.IDWiernego
		INNER JOIN BazaSakramentow ON Sakrament.IDNazwySakramentu=BazaSakramentow.IDSakramentu 
		WHERE Sakrament.IDWiernego=@IDWierny AND Sakrament.IDNazwySakramentu=@IDSakramentu)
GO

SELECT * FROM Zaswiadczenie(6,3);


/*trigger do sakramentów*/
GO
CREATE TRIGGER CheckSakrament ON BazaSakramentow
INSTEAD OF INSERT
AS
BEGIN
	print 'YOLO'
END

GO
CREATE TRIGGER CheckSakrament2 ON BazaSakramentow
INSTEAD OF UPDATE
AS
BEGIN
	print 'YOLO'
END

GO
CREATE TRIGGER CheckSakrament3 ON BazaSakramentow
INSTEAD OF DELETE
AS
BEGIN
	print 'YOLO'
END

INSERT INTO BazaSakramentow (Nazwa) VALUES ('sprawdzam')

/*trigger do dodawania pogrzebów*/
GO
CREATE TRIGGER DeadPool ON Pogrzeb
AFTER INSERT
AS
BEGIN
declare @ID int
select @ID = IDZmarlego from inserted
UPDATE Wierny SET CzyZywy=0 WHERE IDWiernego=@ID
END


/*terminarz od dziœ do za tydzieñ*/
GO
CREATE FUNCTION Terminarz (@IDKsiedza int)
RETURNS TABLE
AS
RETURN ( SELECT Msza.DataMszy AS Dataa, Msza.Intencja AS CoRobi FROM Msza WHERE Msza.IDKsiedza=@IDKsiedza AND DATEDIFF(day,  Msza.DataMszy, GETDATE()) <7
		UNION
		SELECT Koleda.DataKoledy AS Dataa, Rodzina.AdresZamieszkania AS CoRobi FROM Koleda INNER JOIN Rodzina ON Koleda.IDRodziny=Rodzina.IDRodziny WHERE Koleda.IDKsiedza=@IDKsiedza AND DATEDIFF(day, Koleda.DataKoledy, GETDATE()) <7
		UNION
		SELECT Pogrzeb.DataPogrzebu AS Dataa, Pogrzeb.AdresKwatery AS CoRobi FROM Pogrzeb WHERE Pogrzeb.IDKsiedza=@IDKsiedza AND DATEDIFF(day, Pogrzeb.DataPogrzebu, GETDATE()) <7
		)
GO

INSERT INTO Msza ( IDKsiedza, Intencja, DataMszy, Kwota) VALUES (1, 'Dziêkczynno b³agalna za Kowalsk¹', '2017-01-18', 60)


/* login Piekna with password 'jestem123'.  */
CREATE LOGIN Piekna   
    WITH PASSWORD = 'jestemja123';  
GO  

-- Creates a database user for the login created above.  
CREATE USER Adminn FOR LOGIN Piekna;  
GO















BEGIN TRANSACTION;-- pocz¹tek transakcji
BEGIN TRY
    INSERT INTO Rodzina(AdresZamieszkania, CzyPrzyjmujeKolede) VALUES ('ul. Karolkowa 1', true)
END TRY
 
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
		,ERROR_MESSAGE() AS ErrorMessage;
 
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;-- wycofywanie zmian 
END CATCH;

IF @@TRANCOUNT > 0 
    COMMIT TRANSACTION;-- akceptacja zmian


























/****************************************************************************************************************************/
/* Dane do tabel */

GO
INSERT INTO Rodzina(AdresZamieszkania, CzyPrzyjmujeKolede) VALUES
('Adres1', 'false'),
('Adres2', 'true'),
('Adres3', 'true'),
('Adres4', 'false'),
('Adres5', 'false'),
('Adres6', 'false'),
('Adres7', 'false'),
('Adres8', 'true'),
('Adres9', 'false'),
('Adres10', 'true'),
('Adres11', 'true'),
('Adres12', 'true'),
('Adres13', 'false'),
('Adres14', 'true'),
('Adres15', 'false'),
('Adres16', 'false'),
('Adres17', 'false'),
('Adres18', 'false'),
('Adres19', 'true'),
('Adres20', 'false'),
('Adres21', 'true'),
('Adres22', 'true'),
('Adres23', 'false'),
('Adres24', 'false'),
('Adres25', 'false'),
('Adres26', 'false'),
('Adres27', 'false'),
('Adres28', 'false'),
('Adres29', 'true'),
('Adres30', 'false'),
('Adres31', 'true'),
('Adres32', 'false'),
('Adres33', 'false'),
('Adres34', 'true'),
('Adres35', 'true'),
('Adres36', 'false'),
('Adres37', 'false'),
('Adres38', 'false'),
('Adres39', 'true'),
('Adres40', 'true'),
('Adres41', 'false'),
('Adres42', 'false'),
('Adres43', 'false'),
('Adres44', 'true'),
('Adres45', 'true'),
('Adres46', 'false'),
('Adres47', 'false'),
('Adres48', 'false'),
('Adres49', 'true'),
('Adres50', 'false'),
('Adres51', 'false'),
('Adres52', 'false'),
('Adres53', 'false'),
('Adres54', 'true'),
('Adres55', 'false'),
('Adres56', 'true'),
('Adres57', 'false'),
('Adres58', 'false'),
('Adres59', 'false'),
('Adres60', 'true'),
('Adres61', 'true'),
('Adres62', 'false'),
('Adres63', 'false'),
('Adres64', 'false'),
('Adres65', 'true'),
('Adres66', 'false'),
('Adres67', 'false'),
('Adres68', 'true'),
('Adres69', 'false'),
('Adres70', 'false'),
('Adres71', 'false'),
('Adres72', 'true'),
('Adres73', 'true'),
('Adres74', 'true'),
('Adres75', 'true'),
('Adres76', 'false'),
('Adres77', 'true'),
('Adres78', 'false'),
('Adres79', 'false'),
('Adres80', 'false'),
('Adres81', 'true'),
('Adres82', 'false'),
('Adres83', 'true'),
('Adres84', 'true'),
('Adres85', 'false'),
('Adres86', 'false'),
('Adres87', 'false'),
('Adres88', 'true'),
('Adres89', 'false'),
('Adres90', 'true'),
('Adres91', 'true'),
('Adres92', 'false'),
('Adres93', 'false'),
('Adres94', 'false'),
('Adres95', 'false'),
('Adres96', 'false'),
('Adres97', 'false'),
('Adres98', 'true'),
('Adres99', 'false'),
('Adres100', 'true'),
('Adres101', 'true'),
('Adres102', 'true'),
('Adres103', 'false'),
('Adres104', 'false'),
('Adres105', 'false'),
('Adres106', 'false'),
('Adres107', 'false'),
('Adres108', 'false'),
('Adres109', 'true'),
('Adres110', 'true'),
('Adres111', 'true'),
('Adres112', 'false'),
('Adres113', 'true'),
('Adres114', 'true'),
('Adres115', 'false'),
('Adres116', 'true'),
('Adres117', 'false'),
('Adres118', 'false'),
('Adres119', 'true'),
('Adres120', 'false'),
('Adres121', 'true'),
('Adres122', 'true'),
('Adres123', 'false'),
('Adres124', 'false'),
('Adres125', 'false'),
('Adres126', 'true'),
('Adres127', 'true'),
('Adres128', 'true'),
('Adres129', 'false'),
('Adres130', 'true'),
('Adres131', 'false'),
('Adres132', 'true'),
('Adres133', 'false'),
('Adres134', 'false'),
('Adres135', 'true'),
('Adres136', 'true'),
('Adres137', 'false'),
('Adres138', 'true'),
('Adres139', 'false'),
('Adres140', 'true'),
('Adres141', 'true'),
('Adres142', 'false'),
('Adres143', 'true'),
('Adres144', 'true'),
('Adres145', 'true'),
('Adres146', 'true'),
('Adres147', 'true'),
('Adres148', 'false'),
('Adres149', 'true'),
('Adres150', 'true'),
('Adres151', 'false'),
('Adres152', 'true'),
('Adres153', 'false'),
('Adres154', 'true'),
('Adres155', 'false'),
('Adres156', 'true'),
('Adres157', 'false'),
('Adres158', 'true'),
('Adres159', 'true'),
('Adres160', 'false'),
('Adres161', 'false'),
('Adres162', 'true'),
('Adres163', 'false'),
('Adres164', 'true'),
('Adres165', 'false'),
('Adres166', 'true'),
('Adres167', 'true'),
('Adres168', 'false'),
('Adres169', 'false'),
('Adres170', 'false'),
('Adres171', 'false'),
('Adres172', 'true'),
('Adres173', 'true'),
('Adres174', 'false'),
('Adres175', 'true'),
('Adres176', 'true'),
('Adres177', 'false'),
('Adres178', 'false'),
('Adres179', 'false'),
('Adres180', 'true'),
('Adres181', 'false'),
('Adres182', 'false'),
('Adres183', 'false'),
('Adres184', 'true'),
('Adres185', 'true'),
('Adres186', 'true'),
('Adres187', 'true'),
('Adres188', 'true'),
('Adres189', 'true'),
('Adres190', 'false'),
('Adres191', 'true'),
('Adres192', 'false'),
('Adres193', 'false'),
('Adres194', 'true'),
('Adres195', 'false'),
('Adres196', 'false'),
('Adres197', 'true'),
('Adres198', 'true'),
('Adres199', 'false'),
('Adres200', 'false')
GO

GO
INSERT INTO Wierny(IDRodziny, Imiona, Nazwisko, DataUrodzenia) VALUES 
(1, 'Marcela', 'Nowak', '1983-02-18'),
(1, 'Violetta', 'Nowak', '1957-05-11'),
(1, 'Tacjanna', 'Nowak', '1954-10-25'),

(2, 'Edyta', 'Kowalska', '1971-07-05'),
(2, 'Jacek', 'Kowalski', '1994-02-20'),

(3, 'Nataniel', 'Wiœniewski', '1947-09-22'),
(3, 'Olimpia', 'Wiœniewska', '1973-01-30'),
(3, 'Olga', 'Wiœniewska', '1943-04-30'),
(3, 'Telimena', 'Wiœniewska', '1972-02-21'),

(4, 'Zbros³aw', 'D¹browski', '1971-11-08'),
(4, 'Harasym', 'D¹browski', '1992-04-22'),
(4, 'Edmund', 'D¹browski', '1995-01-24'),

(5, 'Zbis³aw', 'Lewandowski', '1966-08-20'),
(5, 'Oda', 'Lewandowska', '1967-12-07'),
(5, 'Magda', 'Lewandowska', '1985-10-13'),
(5, 'Dagna', 'Lewandowska', '2006-11-05'),
(5, 'Rajmunda', 'Lewandowska', '1969-02-06'),

(6, 'Cecylia', 'Wójcik', '1954-07-01'),
(6, 'Sara', 'Wójcik', '1980-04-14'),
(6, 'Narcyz', 'Wójcik', '1966-10-22'),
(6, 'Celestyna', 'Wójcik', '1968-05-03'),
(6, 'Saba', 'Wójcik', '1974-03-23'),

(7, 'Heliodor', 'Kamiñski', '1950-05-12'),
(7, 'Fabian', 'Kamiñski', '1985-03-14'),
(7, 'Magdalena', 'Kamiñska', '1958-04-09'),
(7, 'Oleg', 'Kamiñski', '1976-01-13'),
(7, 'Radomi³a', 'Kamiñska', '1963-03-13'),
(7, 'Teodozjusz', 'Kamiñski', '1995-01-29'),

(8, 'Heliodor', 'Kowalczyk', '1995-10-20'),
(8, 'Kaja', 'Kowalczyk', '1976-08-20'),
(8, 'Saba', 'Kowalczyk', '1968-07-20'),
(8, 'Zdzis³awa', 'Kowalczyk', '1978-01-05'),

(9, 'Helena', 'Zieliñska', '1977-08-05'),
(9, 'Salomon', 'Zieliñski', '1952-10-13'),
(9, 'Leila', 'Zieliñska', '1992-02-21'),
(9, 'Œwiêtomira', 'Zieliñska', '2000-04-27'),

(10, 'Karolina', 'Szymañska', '2009-07-31'),
(10, 'Adela', 'Szymañska', '1993-09-27'),

(11, 'Salwator', 'WoŸniak', '1978-01-29'),
(11, 'Teobald', 'WoŸniak', '1984-10-11'),
(11, 'Adelajda', 'WoŸniak', '1991-12-31'),
(11, 'Kamila', 'WoŸniak', '1953-06-24'),

(12, 'Galla', 'Koz³owska', '1997-11-22'),
(12, 'Lech', 'Koz³owski', '1940-08-11'),

(13, 'Walentyn', 'Jankowski', '1994-06-01'),

(14, 'Cecylia', 'Wojciechowska', '1961-12-23'),
(14, 'Tacjanna', 'Wojciechowska', '1986-11-18'),
(14, '¯aklina', 'Wojciechowska', '1947-03-04'),
(14, 'Celestyn', 'Wojciechowski', '1942-07-11'),
(14, 'Kajetan', 'Wojciechowski', '1989-08-30'),

(15, 'Fabian', 'Kwiatkowski', '1978-11-11'),
(15, 'Sabina', 'Kwiatkowska', '1950-06-19'),
(15, 'Narcyz', 'Kwiatkowski', '1958-02-06'),

(16, 'Teodor', 'Kaczmarek', '2009-05-02'),

(17, 'Zelmira', 'Mazur', '1992-07-02'),
(17, 'Genowefa', 'Mazur', '1950-02-26'),
(17, 'Karena', 'Mazur', '1978-09-22'),
(17, 'Radomys³', 'Mazur', '1996-10-24'),

(18, 'Waldemar', 'Krawczyk', '2007-11-17'),
(18, 'Adelajda', 'Krawczyk', '2008-01-14'),
(18, 'Imis³awa', 'Krawczyk', '1973-06-13'),
(18, 'Zacheusz', 'Krawczyk', '1948-04-04'),
(18, 'Jakub', 'Krawczyk', '1991-04-17'),

(19, 'Dalida', 'Piotrowska', '1960-10-05'),
(19, 'Iga', 'Piotrowska', '1997-07-07'),
(19, 'Hadrian', 'Piotrowski', '1966-03-06'),

(20, 'Kamila', 'Grabowska', '1967-04-29'),
(20, 'Patrycja', 'Grabowska', '2001-08-15'),
(20, 'Natalis', 'Grabowski', '1999-12-22'),

(21, 'Edeltrauda', 'Nowakowska', '1954-07-29'),
(21, 'Kaja', 'Nowakowska', '1944-11-22'),
(21, 'Radomys³', 'Nowakowski', '1971-04-01'),
(21, 'Œwiêtomira', 'Nowakowska', '1998-03-05'),
(21, 'Tadeusz', 'Nowakowski', '2001-09-05'),
(21, 'Zofia', 'Nowakowska', '2008-04-17'),

(22, 'Eliza', 'Paw³owska', '1991-06-16'),
(22, 'Lea', 'Paw³owska', '2004-03-10'),

(23, 'Karina', 'Michalska', '1999-03-01'),
(23, 'Sara', 'Michalska', '1992-02-24'),

(24, 'Samuela', 'Nowicka', '1995-04-09'),
(24, 'Radomi³a', 'Nowicka', '1999-12-31'),
(24, 'Walerian', 'Nowicki', '1985-06-30'),
(24, 'Wera', 'Nowicka', '1968-04-25'),
(24, 'Dacjan', 'Nowicki', '2003-10-12'),
(24, 'Edda', 'Nowicka', '1962-04-22'),

(25, 'Bartosz', 'Adamczyk', '2001-09-01'),
(25, 'Cezary', 'Adamczyk', '1951-07-17'),
(25, 'Tadeusz', 'Adamczyk', '2004-12-12'),
(25, 'Baltazar', 'Adamczyk', '1947-11-19'),
(25, 'Dacjan', 'Adamczyk', '1947-12-29'),

(26, 'Wadim', 'Dudek', '1987-03-19'),
(26, 'Malkolm', 'Dudek', '1963-12-15'),

(27, 'Felicyta', 'Zaj¹c', '1997-06-17'),

(28, 'Œcibora', 'Wieczorek', '1964-03-09'),
(28, 'Celestyn', 'Wieczorek', '1965-02-23'),
(28, 'Zbys³awa', 'Wieczorek', '1944-12-12'),
(28, 'Zacheusz', 'Wieczorek', '1971-11-05'),

(29, 'Lenart', 'Jab³oñski', '1973-03-02'),
(29, 'Sandra', 'Jab³oñska', '1988-07-09'),

(30, 'Machabeusz', 'Król', '1983-09-22'),
(30, 'Oleg', 'Król', '1997-09-08'),

(31, 'Penelopa', 'Majewska', '1963-08-02'),

(32, 'Ignacy', 'Olszewski', '1988-12-02'),
(32, 'Irwin', 'Olszewski', '1988-03-26'),
(32, 'Barbara', 'Olszewska', '1967-03-06'),
(32, 'Edeltrauda', 'Olszewska', '1988-12-17'),
(32, 'Malwina', 'Olszewska', '1955-01-15'),
(32, 'Patrycja', 'Olszewska', '1944-03-09'),

(33, 'Jacek', 'Jaworski', '2002-10-12'),
(33, 'Waleriusz', 'Jaworski', '1949-02-27'),
(33, 'Igor', 'Jaworski', '1940-12-02'),

(34, 'Magnus', 'Wróbel', '1986-11-18'),
(34, 'Malwin', 'Wróbel', '2008-12-23'),
(34, 'Gabin', 'Wróbel', '1989-05-12'),
(34, 'Maksymilian', 'Wróbel', '1977-11-28'),
(34, 'Janis³aw', 'Wróbel', '1992-08-26'),

(35, 'Pantaleon', 'Malinowski', '1991-08-29'),
(35, 'Eleazar', 'Malinowski', '1976-09-03'),
(35, 'Wac³aw', 'Malinowski', '1980-06-11'),
(35, 'Gallina', 'Malinowska', '1970-04-03'),
(35, 'Adolfa', 'Malinowska', '1974-07-15'),

(36, 'Radomi³a', 'Pawlak', '2009-11-05'),
(36, 'Magnus', 'Pawlak', '1951-11-04'),
(36, 'Tadeusz', 'Pawlak', '1958-07-13'),
(36, 'Pelagia', 'Pawlak', '1969-11-08'),
(36, 'Teodozjusz', 'Pawlak', '1945-11-10'),

(37, 'Faustyn', 'Witkowski', '1963-03-08'),
(37, 'Paula', 'Witkowska', '1950-01-02'),

(38, 'Irwin', 'Walczak', '1953-06-20'),
(38, 'Edgar', 'Walczak', '2005-10-03'),
(38, 'Kallina', 'Walczak', '1979-03-01'),
(38, 'Kacper', 'Walczak', '1984-03-24'),
(38, 'Carmen', 'Walczak', '1958-03-10'),
(38, 'Felicjana', 'Walczak', '1984-03-20'),

(39, 'Maksym', 'Stêpieñ', '1953-02-19'),
(39, 'Nataniel', 'Stêpieñ', '1993-09-23'),
(39, 'Taras', 'Stêpieñ', '2003-08-07'),
(39, 'Perpetua', 'Stêpieñ', '1969-02-13'),

(40, 'Paula', 'Górska', '1981-04-14'),
(40, 'Wac³awa', 'Górska', '1980-03-02'),
(40, 'Maksymin', 'Górski', '2002-09-22'),

(41, 'Zachariasz', 'Rutkowski', '1969-05-31'),
(41, 'Feliks', 'Rutkowski', '1990-05-31'),
(41, 'Dawida', 'Rutkowska', '1963-05-26'),
(41, 'Oksana', 'Rutkowska', '1940-04-07'),
(41, 'Namys³aw', 'Rutkowski', '1970-09-10'),

(42, 'Lechos³aw', 'Michalak', '1978-07-11'),
(42, 'Nastazja', 'Michalak', '1959-04-12'),

(43, '¯aneta', 'Sikora', '1965-01-22'),
(43, 'Radek', 'Sikora', '2009-03-14'),
(43, 'Halka', 'Sikora', '1943-04-07'),
(43, 'Gabriela', 'Sikora', '1962-02-16'),
(43, 'Wadim', 'Sikora', '1978-12-26'),
(43, 'Faust', 'Sikora', '1989-07-31'),

(44, 'Dalebor', 'Ostrowski', '1948-02-11'),
(44, 'Waleriusz', 'Ostrowski', '1959-02-18'),

(45, 'Patrycjusz', 'Baran', '1992-04-14'),

(46, 'Jagoda', 'Duda', '1965-12-12'),
(46, 'Helmut', 'Duda', '2008-01-05'),
(46, 'Halina', 'Duda', '1969-01-22'),
(46, 'Salomon', 'Duda', '1970-03-10'),
(46, 'Zoe', 'Duda', '1951-04-25'),
(46, 'Magda', 'Duda', '1957-08-24'),

(47, 'Paloma', 'Szewczyk', '1983-05-13'),
(47, 'Tatiana', 'Szewczyk', '1941-12-24'),
(47, 'Halina', 'Szewczyk', '1994-03-28'),

(48, 'Kacper', 'Tomaszewski', '2001-11-20'),
(48, 'Edward', 'Tomaszewski', '2006-05-14'),
(48, 'Pafnucy', 'Tomaszewski', '1959-07-28'),
(48, 'Eliga', 'Tomaszewska', '1952-07-29'),
(48, 'Parys', 'Tomaszewski', '2007-01-19'),

(49, 'Magnus', 'Pietrzak', '1960-09-19'),
(49, 'Jagoda', 'Pietrzak', '1961-07-12'),
(49, 'Edda', 'Pietrzak', '1954-07-04'),
(49, 'Edda', 'Pietrzak', '1958-01-11'),
(49, 'Perpetua', 'Pietrzak', '1943-06-27'),
(49, 'Innocenty', 'Pietrzak', '2008-07-10'),

(50, 'Teodor', 'Marciniak', '1992-03-12'),
(50, 'Oktawiusz', 'Marciniak', '1982-11-03'),
(50, 'Oktawian', 'Marciniak', '1992-01-01'),
(50, 'Janis³aw', 'Marciniak', '1958-02-17'),

(51, 'Kacper', 'Wróblewski', '1958-12-01'),
(51, 'Faustyna', 'Wróblewska', '1944-12-07'),
(51, 'Lech', 'Wróblewski', '1990-02-21'),
(51, 'Ida', 'Wróblewska', '2008-12-11'),
(51, 'Teobald', 'Wróblewski', '1962-03-25'),
(51, 'Adolfa', 'Wróblewska', '1955-08-17'),

(52, 'Lea', 'Zalewska', '1955-07-07'),
(52, 'Ilza', 'Zalewska', '1973-12-10'),

(53, 'Zbis³aw', 'Jakubowski', '1946-03-23'),
(53, 'Fabia', 'Jakubowska', '1950-07-06'),
(53, 'Irwin', 'Jakubowski', '1965-07-28'),
(53, '£ucja', 'Jakubowska', '2000-08-22'),

(54, 'Baltazar', 'Jasiñski', '2001-04-28'),
(54, 'Helena', 'Jasiñska', '1942-05-16'),

(55, 'Malwin', 'Zawadzki', '1979-06-13'),

(56, 'Kandyd', 'Sadowski', '1961-12-16'),
(56, 'Nadzieja', 'Sadowska', '1965-08-14'),
(56, 'B¹dzimir', 'Sadowski', '1967-09-14'),
(56, 'Hanna', 'Sadowska', '1972-02-27'),
(56, '£ucja', 'Sadowska', '1986-12-25'),
(56, 'Natan', 'Sadowski', '2003-09-08'),

(57, 'Laurencja', 'B¹k', '1949-02-04'),

(58, 'Pelagia', 'Chmielewska', '2009-10-01'),

(59, 'Cecylia', 'W³odarczyk', '1962-04-28'),
(59, 'Zbigniew', 'W³odarczyk', '1982-12-01'),
(59, 'Wanesa', 'W³odarczyk', '1965-03-12'),
(59, 'Edna', 'W³odarczyk', '2008-12-23'),

(60, 'Kajetan', 'Borkowski', '1979-05-10'),
(60, 'Fabrycjan', 'Borkowski', '1948-04-20'),

(61, 'Nadia', 'Czarnecka', '1945-02-22'),
(61, 'Napoleon', 'Czarnecki', '1974-03-07'),
(61, 'Olaf', 'Czarnecki', '1975-06-28'),
(61, 'Walentyna', 'Czarnecka', '1993-05-07'),
(61, 'Kacper', 'Czarnecki', '1954-01-27'),
(61, 'Zbros³aw', 'Czarnecki', '2003-08-11'),

(62, 'Achilles', 'Sawicki', '1949-04-03'),

(63, 'Nadzieja', 'Soko³owska', '1984-07-31'),
(63, 'Kamil', 'Soko³owski', '1989-08-23'),
(63, 'Urszula', 'Soko³owska', '1955-12-05'),
(63, 'Malwina', 'Soko³owska', '2001-07-24'),

(64, 'Radomi³a', 'Urbañska', '2003-03-11'),
(64, 'Gaja', 'Urbañska', '1977-10-15'),
(64, 'Eleazar', 'Urbañski', '1981-04-30'),
(64, 'Radomys³', 'Urbañski', '2008-06-05'),
(64, 'Cezary', 'Urbañski', '1952-04-24'),
(64, 'Hadrian', 'Urbañski', '1969-12-17'),

(65, 'Naczes³aw', 'Kubiak', '1940-01-09'),
(65, 'Oktawiusz', 'Kubiak', '1966-06-23'),
(65, 'Beata', 'Kubiak', '1942-09-27'),
(65, 'Wac³aw', 'Kubiak', '1952-04-06'),
(65, 'Eligia', 'Kubiak', '1965-11-23'),
(65, 'Cezary', 'Kubiak', '1971-03-06'),

(66, 'Olga', 'Maciejewska', '1987-03-05'),

(67, 'Zbros³aw', 'Szczepañski', '1999-04-09'),

(68, 'Hegezyp', 'Kucharski', '1993-05-05'),
(68, 'Samuela', 'Kucharska', '1984-06-22'),

(69, 'Gajusz', 'Wilk', '1948-12-25'),
(69, 'Nadmir', 'Wilk', '1946-08-09'),

(70, 'Tacjusz', 'Kalinowski', '1969-06-29'),

(71, '¯elis³aw', 'Lis', '1964-05-25'),
(71, '¯elis³aw', 'Lis', '1950-05-08'),
(71, 'Ulryk', 'Lis', '2006-05-09'),

(72, 'Eleonora', 'Mazurek', '1946-01-19'),
(72, 'Zelmira', 'Mazurek', '1950-02-13'),
(72, 'Odyseusz', 'Mazurek', '1956-04-08'),

(73, 'Salwator', 'Wysocki', '1957-03-28'),

(74, 'Cecyliusz', 'Adamski', '1966-07-25'),
(74, 'Lamberta', 'Adamska', '1959-11-24'),
(74, 'Hadrian', 'Adamski', '1991-10-20'),
(74, 'Maksym', 'Adamski', '1965-05-01'),

(75, 'Zacheusz', 'KaŸmierczak', '1985-04-01'),
(75, 'Pankracy', 'KaŸmierczak', '1953-04-04'),

(76, 'Waldemar', 'Wasilewski', '1981-08-31'),

(77, '£ucja', 'Sobczak', '1954-05-09'),
(77, 'Helmut', 'Sobczak', '1957-09-04'),

(78, 'Malina', 'Czerwiñska', '1956-10-11'),
(78, 'Oleg', 'Czerwiñski', '1998-10-06'),
(78, 'Absalon', 'Czerwiñski', '1971-09-23'),
(78, 'Eligia', 'Czerwiñska', '1968-06-04'),
(78, 'Samson', 'Czerwiñski', '1966-09-03'),
(78, 'Henryk', 'Czerwiñski', '1954-02-21'),

(79, 'Magdalena', 'Andrzejewska', '1990-11-18'),

(80, 'Zawisza', 'Cieœlak', '1953-07-16'),
(80, 'Kandyd', 'Cieœlak', '1956-08-27'),
(80, 'Jagoda', 'Cieœlak', '1978-05-12'),
(80, 'Zbigniew', 'Cieœlak', '1995-08-04'),
(80, '¯ytomir', 'Cieœlak', '1992-05-07'),
(80, 'Olimpia', 'Cieœlak', '2009-04-30'),

(81, 'Cezary', 'G³owacki', '2008-01-19'),
(81, 'Achilles', 'G³owacki', '1986-11-17'),
(81, 'Cecyliusz', 'G³owacki', '1985-03-31'),
(81, 'Jadwiga', 'G³owacka', '1940-07-02'),
(81, 'Manuela', 'G³owacka', '1975-07-31'),

(82, 'Laurentyna', 'Zakrzewska', '2009-12-13'),
(82, 'Innocenty', 'Zakrzewski', '2008-02-09'),

(83, 'Zbis³aw', 'Ko³odziej', '2002-06-25'),
(83, 'Felicjana', 'Ko³odziej', '1940-02-05'),
(83, 'Janis³aw', 'Ko³odziej', '1965-07-23'),
(83, 'Maksym', 'Ko³odziej', '1992-02-02'),

(84, 'Fawila', 'Sikorska', '1966-10-22'),
(84, 'Lech', 'Sikorski', '1961-04-10'),

(85, 'Faustyna', 'Krajewska', '1979-06-01'),

(86, 'Urszula', 'Gajewska', '1997-05-26'),
(86, 'Tatiana', 'Gajewska', '1981-06-30'),
(86, 'D¹brówka', 'Gajewska', '1965-10-06'),
(86, 'Natalia', 'Gajewska', '1965-07-28'),
(86, 'Egbert', 'Gajewski', '2001-12-19'),
(86, 'Oktawia', 'Gajewska', '1987-12-10'),

(87, 'Helmut', 'Szymczak', '1999-01-07'),
(87, 'Machabeusz', 'Szymczak', '1982-04-09'),
(87, 'Kalistrat', 'Szymczak', '1965-10-11'),
(87, 'Lechos³awa', 'Szymczak', '1955-07-15'),

(88, 'Saba', 'Szulc', '1944-03-04'),
(88, 'Naczes³aw', 'Szulc', '1993-03-19'),
(88, 'Karolina', 'Szulc', '1974-09-21'),
(88, 'Damian', 'Szulc', '1978-06-05'),
(88, 'Walter', 'Szulc', '1963-04-10'),

(89, 'Wanesa', 'Baranowska', '1993-12-31'),

(90, 'Helena', 'Laskowska', '1949-03-01'),
(90, 'Salomea', 'Laskowska', '2006-06-17'),
(90, 'Tekla', 'Laskowska', '1986-01-11'),
(90, 'Pafnucy', 'Laskowski', '1976-12-22'),
(90, 'Nastazja', 'Laskowska', '2004-12-07'),
(90, 'Janis³aw', 'Laskowski', '1959-01-30'),

(91, 'Harasym', 'Brzeziñski', '1942-07-08'),
(91, 'Nastazja', 'Brzeziñska', '1957-12-03'),
(91, 'Paula', 'Brzeziñska', '1959-03-25'),
(91, 'Violetta', 'Brzeziñska', '1945-10-02'),
(91, 'Patrycja', 'Brzeziñska', '1941-05-14'),

(92, 'Tekla', 'Makowska', '1996-09-12'),
(92, 'Walentyn', 'Makowski', '1944-08-10'),
(92, 'Achilles', 'Makowski', '1956-10-15'),
(92, '£ada', 'Makowska', '1999-05-10'),

(93, 'Oleg', 'Zió³kowski', '1956-10-25'),
(93, 'Larysa', 'Zió³kowska', '1973-10-09'),
(93, 'Wac³awa', 'Zió³kowska', '1977-10-31'),

(94, 'Odyseusz', 'Przybylski', '1951-10-28'),
(94, 'Œwiêtochna', 'Przybylska', '1991-07-08'),
(94, 'Namys³aw', 'Przybylski', '2008-06-16'),
(94, 'Edeltrauda', 'Przybylska', '1998-11-17'),
(94, 'Machabeusz', 'Przybylski', '1943-12-15'),

(95, 'Hegezyp', 'Domañski', '1996-06-29'),
(95, 'Edeltrauda', 'Domañska', '1954-06-15'),
(95, 'Beda', 'Domañska', '1954-05-03'),
(95, 'Zelmira', 'Domañska', '1945-03-09'),

(96, 'Petronela', 'Nowacka', '1955-10-03'),
(96, 'Malina', 'Nowacka', '1977-03-16'),
(96, 'Petronela', 'Nowacka', '1966-10-18'),
(96, 'Petronela', 'Nowacka', '1964-03-16'),

(97, 'Wadim', 'Borowski', '1977-12-16'),
(97, 'Edmund', 'Borowski', '1983-01-04'),

(98, 'Olaf', 'B³aszczyk', '1958-03-25'),
(98, 'Larysa', 'B³aszczyk', '2000-07-14'),
(98, 'Adolfa', 'B³aszczyk', '1949-10-12'),

(99, 'Zbros³aw', 'Chojnacki', '1961-02-27'),
(99, 'Iga', 'Chojnacka', '2006-06-07'),
(99, 'Ignacy', 'Chojnacki', '1942-09-11'),
(99, 'Natan', 'Chojnacki', '1971-05-02'),
(99, '£ukasz', 'Chojnacki', '1994-07-20'),
(99, 'Igor', 'Chojnacki', '1979-09-10'),

(100, 'Achacjusz', 'Ciesielski', '1986-01-23'),

(101, 'Lea', 'Mróz', '2005-02-24'),
(101, 'Fabrycjan', 'Mróz', '1974-03-31'),
(101, 'Heloiza', 'Mróz', '2008-11-07'),
(101, 'Ildefons', 'Mróz', '1967-11-05'),
(101, 'Galfryd', 'Mróz', '1948-02-24'),
(101, 'Walentyna', 'Mróz', '1956-09-17'),

(102, 'Walentyna', 'Szczepaniak', '1970-12-22'),
(102, 'Telimena', 'Szczepaniak', '1981-05-03'),
(102, '£ada', 'Szczepaniak', '1949-03-06'),
(102, 'Perpetua', 'Szczepaniak', '1995-10-25'),

(103, 'Galfryd', 'Weso³owski', '1945-07-13'),

(104, 'Fabrycjan', 'Górecki', '1945-09-03'),

(105, 'Ulryk', 'Krupa', '1962-12-02'),
(105, 'Magnus', 'Krupa', '1953-05-21'),

(106, 'Kaja', 'Kaczmarczyk', '1993-12-19'),
(106, 'Napoleon', 'Kaczmarczyk', '1995-10-25'),

(107, 'Kandyd', 'Leszczyñski', '1992-12-09'),
(107, 'Œwiêcimir', 'Leszczyñski', '1941-06-07'),
(107, 'Innocenty', 'Leszczyñski', '2005-10-15'),
(107, 'Wera', 'Leszczyñska', '1970-01-08'),
(107, 'Leila', 'Leszczyñska', '2009-10-06'),

(108, 'Radek', 'Lipiñski', '1969-06-09'),

(109, 'Radomys³', 'Kowalewski', '2006-11-16'),
(109, 'Maksym', 'Kowalewski', '1971-12-05'),

(110, 'Genowefa', 'Urbaniak', '1977-04-23'),
(110, 'Ignacy', 'Urbaniak', '1967-06-11'),
(110, 'Cezara', 'Urbaniak', '2002-09-02'),
(110, 'Teodoziusz', 'Urbaniak', '1945-01-20'),
(110, 'Natalia', 'Urbaniak', '1978-02-11'),
(110, 'Ireneusz', 'Urbaniak', '1996-03-03'),

(111, 'Tacjusz', 'Kozak', '1962-04-06'),
(111, 'Œwiêtos³aw', 'Kozak', '1989-09-21'),

(112, 'Ilona', 'Kania', '1955-10-15'),

(113, 'Barbara', 'Miko³ajczyk', '1949-09-30'),

(114, 'Waleriusz', 'Czajkowski', '1977-05-17'),
(114, 'Magda', 'Czajkowska', '1971-01-03'),
(114, 'Zenona', 'Czajkowska', '1992-08-01'),
(114, 'Jakobina', 'Czajkowska', '1994-11-25'),
(114, 'Irwin', 'Czajkowski', '2005-06-15'),

(115, 'Daria', 'Mucha', '1955-12-24'),
(115, 'Felicja', 'Mucha', '1978-04-16'),
(115, 'Adela', 'Mucha', '1963-01-16'),
(115, 'Edwin', 'Mucha', '1993-09-10'),
(115, 'Saba', 'Mucha', '2001-04-13'),

(116, 'Zenobia', 'Tomczak', '1971-04-01'),

(117, 'Oktawiusz', 'Kozio³', '2006-06-08'),
(117, 'Cecyliusz', 'Kozio³', '1964-02-07'),

(118, 'Barabasz', 'Markowski', '1941-01-27'),
(118, 'Beatrycze', 'Markowska', '1999-08-25'),
(118, 'Malkolm', 'Markowski', '1943-09-03'),
(118, 'Urszula', 'Markowska', '1943-10-24'),
(118, 'Teodozjusz', 'Markowski', '1941-04-04'),
(118, 'Naczes³aw', 'Markowski', '1991-05-31'),

(119, 'Rachela', 'Kowalik', '1963-06-06'),
(119, 'Fabian', 'Kowalik', '2006-03-14'),

(120, 'Ramona', 'Nawrocka', '1950-01-10'),
(120, 'Felicja', 'Nawrocka', '1942-04-02'),
(120, 'Natan', 'Nawrocki', '1993-11-13'),
(120, 'Perpetua', 'Nawrocka', '1966-03-16'),

(121, 'Janina', 'Brzozowska', '1990-09-11'),
(121, 'Oktawiusz', 'Brzozowski', '1988-10-01'),

(122, 'Barabasz', 'Janik', '1958-01-08'),
(122, 'D¹brówka', 'Janik', '1966-01-28'),
(122, 'Ada', 'Janik', '1952-05-08'),
(122, 'Heloiza', 'Janik', '1967-02-09'),

(123, 'Olech', 'Musia³', '1967-12-19'),
(123, 'Dacjan', 'Musia³', '1992-03-12'),
(123, 'Igor', 'Musia³', '1961-07-06'),
(123, 'Adolfa', 'Musia³', '1983-11-22'),

(124, 'Beatrycze', 'Wawrzyniak', '1951-09-03'),
(124, 'Danuta', 'Wawrzyniak', '1993-05-16'),
(124, 'Samanta', 'Wawrzyniak', '1946-09-15'),
(124, 'Halka', 'Wawrzyniak', '1959-02-15'),
(124, 'Halina', 'Wawrzyniak', '1982-10-22'),
(124, 'Nadia', 'Wawrzyniak', '1952-05-06'),

(125, 'Edward', 'Markiewicz', '1960-10-01'),
(125, 'Olech', 'Markiewicz', '1993-08-18'),
(125, 'Œwiêtomir', 'Markiewicz', '1967-09-14'),
(125, 'Nadia', 'Markiewicz', '1982-08-04'),
(125, 'Olaf', 'Markiewicz', '1980-10-14'),

(126, 'Leila', 'Or³owska', '1982-03-08'),
(126, 'Celestyn', 'Or³owski', '1969-03-17'),
(126, 'Laurentyna', 'Or³owska', '1975-01-05'),

(127, 'Rebeka', 'Tomczyk', '1970-10-30'),
(127, 'Edmund', 'Tomczyk', '1979-05-05'),
(127, 'Baltazar', 'Tomczyk', '1969-03-11'),

(128, 'Dagmara', 'Jarosz', '1990-01-16'),
(128, 'Malkolm', 'Jarosz', '1947-10-24'),
(128, 'Barnaba', 'Jarosz', '1962-01-06'),
(128, 'Kamila', 'Jarosz', '2003-10-12'),
(128, 'Kacper', 'Jarosz', '1961-01-08'),
(128, 'Adelina', 'Jarosz', '1973-05-14'),

(129, 'Beatrycze', 'Ko³odziejczyk', '1959-07-10'),
(129, 'Heloiza', 'Ko³odziejczyk', '2007-10-26'),
(129, 'Edmund', 'Ko³odziejczyk', '2001-01-03'),

(130, 'Jacek', 'Kurek', '1959-11-11'),

(131, 'Jagoda', 'Kopeæ', '1960-09-19'),
(131, 'Magnus', 'Kopeæ', '1949-02-20'),
(131, 'Salomon', 'Kopeæ', '1970-05-02'),
(131, 'Radomys³', 'Kopeæ', '1975-09-09'),

(132, 'Eliza', '¯ak', '1983-08-08'),
(132, 'Zenona', '¯ak', '1958-10-08'),
(132, 'Adelajda', '¯ak', '1948-11-17'),

(133, 'Œwiêtos³awa', 'Wolska', '1967-12-30'),
(133, 'Lech', 'Wolski', '1995-10-01'),
(133, 'Teodor', 'Wolski', '1947-12-19'),

(134, 'Cezary', '£uczak', '1997-11-23'),
(134, 'Zawisza', '£uczak', '1974-10-23'),
(134, 'Taras', '£uczak', '1980-06-13'),
(134, 'Œwiêtomir', '£uczak', '2009-05-28'),
(134, 'Damazy', '£uczak', '1951-02-23'),
(134, 'Teodor', '£uczak', '1947-03-02'),

(135, 'Radzis³awa', 'Dziedzic', '2006-07-15'),
(135, 'Balbina', 'Dziedzic', '1941-04-29'),

(136, 'Narcyza', 'Kot', '1985-03-24'),

(137, 'Jakubina', 'Stasiak', '1978-01-15'),
(137, 'Karolina', 'Stasiak', '1949-06-13'),
(137, 'Saba', 'Stasiak', '1951-03-05'),
(137, 'Gall', 'Stasiak', '1942-01-26'),
(137, 'Halina', 'Stasiak', '1943-07-28'),
(137, 'Walery', 'Stasiak', '1972-01-07'),

(138, 'Beda', 'Stankiewicz', '1991-05-01'),
(138, 'Waleriana', 'Stankiewicz', '1940-08-19'),
(138, 'Adiana', 'Stankiewicz', '1943-06-08'),
(138, 'Jakub', 'Stankiewicz', '1968-04-26'),
(138, 'Gall', 'Stankiewicz', '1945-08-21'),

(139, 'Kaja', 'Pi¹tek', '1940-12-18'),
(139, 'Lenart', 'Pi¹tek', '1957-12-01'),
(139, 'Makary', 'Pi¹tek', '1954-01-12'),
(139, 'Gabin', 'Pi¹tek', '1973-08-22'),
(139, 'Zofia', 'Pi¹tek', '1990-02-11'),
(139, 'Innocenty', 'Pi¹tek', '1940-09-19'),

(140, 'Feliks', 'JóŸwiak', '1945-10-11'),
(140, 'Innocenty', 'JóŸwiak', '1950-09-20'),
(140, 'Gallina', 'JóŸwiak', '1944-03-17'),
(140, 'Barabasz', 'JóŸwiak', '1977-05-25'),

(141, 'Perpetua', 'Urban', '1979-04-24'),
(141, 'Kamelia', 'Urban', '2002-11-10'),
(141, 'Kallina', 'Urban', '1998-08-13'),
(141, 'Ilona', 'Urban', '1976-06-14'),
(141, 'Malkolm', 'Urban', '1950-06-18'),
(141, 'Perpetua', 'Urban', '1995-03-13'),

(142, 'Madlena', 'Dobrowolska', '1996-09-10'),
(142, 'Beatrycze', 'Dobrowolska', '1973-11-04'),

(143, 'Oktawiusz', 'Pawlik', '2008-01-06'),
(143, 'Maciej', 'Pawlik', '1949-09-01'),

(144, 'Walerian', 'Kruk', '1990-05-22'),
(144, 'Parys', 'Kruk', '1982-09-08'),
(144, 'Zbis³aw', 'Kruk', '1956-05-24'),
(144, 'Salomea', 'Kruk', '1968-07-19'),

(145, 'Galla', 'Domaga³a', '2002-11-08'),
(145, 'Karolina', 'Domaga³a', '1976-01-28'),
(145, 'Lamberta', 'Domaga³a', '1976-03-11'),
(145, 'Egon', 'Domaga³a', '1972-11-16'),
(145, 'Natalia', 'Domaga³a', '1983-04-13'),

(146, 'Beata', 'Piasecka', '1951-04-23'),

(147, 'Barnaba', 'Wierzbicki', '1955-05-11'),
(147, 'Zbigniew', 'Wierzbicki', '1957-06-23'),
(147, 'Hegezyp', 'Wierzbicki', '1961-10-14'),
(147, 'Odyseusz', 'Wierzbicki', '1962-10-17'),
(147, 'Harasym', 'Wierzbicki', '1987-07-07'),
(147, 'Zdzis³awa', 'Wierzbicka', '2007-12-14'),

(148, 'Zenobia', 'Karpiñska', '1990-04-13'),
(148, 'Salomon', 'Karpiñski', '1969-10-05'),
(148, 'Wadim', 'Karpiñski', '1974-08-02'),

(149, '£ucjusz', 'Jastrzêbski', '1968-03-25'),
(149, 'Hanna', 'Jastrzêbska', '1944-07-12'),

(150, 'Celina', 'Polak', '2004-06-26'),
(150, 'Kajetan', 'Polak', '2006-07-30'),
(150, 'Samuela', 'Polak', '1967-07-27'),

(151, 'Heliodor', 'Ziêba', '2006-02-26'),
(151, 'Natasza', 'Ziêba', '1992-11-27'),

(152, 'Waleriusz', 'Janicki', '1991-03-24'),
(152, 'Œwiêtos³awa', 'Janicka', '2002-10-26'),
(152, 'Ulryk', 'Janicki', '1986-01-26'),
(152, 'Eliga', 'Janicka', '1952-07-09'),

(153, 'Zofia', 'Wójtowicz', '2002-03-10'),

(154, 'Salomea', 'Stefañska', '1964-06-15'),
(154, 'Samson', 'Stefañski', '1952-11-13'),

(155, 'Edwin', 'Sosnowski', '1992-12-29'),
(155, 'Sara', 'Sosnowska', '1990-02-22'),
(155, 'Maciej', 'Sosnowski', '1965-11-30'),
(155, 'Tatiana', 'Sosnowska', '1962-06-22'),
(155, 'Helmut', 'Sosnowski', '1999-05-24'),

(156, 'Kaja', 'Bednarek', '1940-10-07'),
(156, 'Carmen', 'Bednarek', '1972-05-13'),
(156, 'Laurencja', 'Bednarek', '1988-02-16'),
(156, 'Namys³aw', 'Bednarek', '1982-08-21'),
(156, 'Dalia', 'Bednarek', '1959-10-06'),
(156, 'Ilona', 'Bednarek', '1987-08-20'),

(157, 'Samuela', 'Majchrzak', '1953-12-12'),
(157, 'Zbis³aw', 'Majchrzak', '1974-12-27'),

(158, 'Dagmara', 'Bielecka', '2006-10-17'),
(158, 'Genowefa', 'Bielecka', '1952-03-05'),

(159, 'Laurencja', 'Ma³ecka', '2008-08-23'),

(160, 'Fabiola', 'Maj', '1971-10-02'),

(161, 'Petronela', 'Sowa', '1951-03-12'),
(161, 'Sara', 'Sowa', '1991-01-12'),
(161, 'Achilles', 'Sowa', '2001-10-27'),
(161, 'Wadim', 'Sowa', '1964-02-16'),
(161, 'Larysa', 'Sowa', '1942-12-31'),

(162, 'Olimpia', 'Milewska', '1952-08-05'),
(162, 'Olech', 'Milewski', '1995-04-08'),
(162, 'Heloiza', 'Milewska', '2002-02-11'),

(163, 'Dagmara', 'Gajda', '2007-05-22'),
(163, 'Heliodor', 'Gajda', '2005-01-28'),
(163, 'Namys³aw', 'Gajda', '2005-04-01'),
(163, 'Jakubina', 'Gajda', '1954-06-30'),
(163, 'Nadzieja', 'Gajda', '1941-11-01'),

(164, 'Lambert', 'Klimek', '1983-12-04'),
(164, 'Malwina', 'Klimek', '1976-01-03'),

(165, 'Jakubina', 'Olejniczak', '1995-01-14'),
(165, 'Odyseusz', 'Olejniczak', '1960-03-15'),
(165, 'Salomea', 'Olejniczak', '1981-07-23'),

(166, 'Fabia', 'Ratajczak', '1956-03-09'),
(166, 'Jadwiga', 'Ratajczak', '1940-08-04'),
(166, 'Lechos³aw', 'Ratajczak', '1942-09-01'),
(166, 'Ireneusz', 'Ratajczak', '1959-12-10'),

(167, '¯aklina', 'Romanowska', '1992-02-11'),
(167, 'Rajmunda', 'Romanowska', '1951-12-04'),

(168, 'Jagna', 'Matuszewska', '1965-11-12'),

(169, 'Malwin', 'Œliwiñski', '1960-10-16'),
(169, 'Magnus', 'Œliwiñski', '1985-11-25'),
(169, 'Rajmunda', 'Œliwiñska', '1989-02-12'),
(169, 'Halina', 'Œliwiñska', '1978-02-05'),
(169, 'Edmund', 'Œliwiñski', '1962-09-27'),
(169, 'Laurentyna', 'Œliwiñska', '1940-03-15'),

(170, 'Ildefons', 'Madej', '1951-01-17'),
(170, 'Daniela', 'Madej', '1954-02-24'),
(170, 'Zbigniew', 'Madej', '2000-01-12'),

(171, 'Petronela', 'Kasprzak', '1940-02-14'),
(171, 'Radzis³awa', 'Kasprzak', '1969-08-30'),
(171, 'Taras', 'Kasprzak', '1963-10-23'),
(171, 'Larysa', 'Kasprzak', '1989-09-14'),
(171, 'Patrycjusz', 'Kasprzak', '1987-12-16'),

(172, 'Olga', 'Wilczyñska', '1970-04-08'),
(172, 'Gajusz', 'Wilczyñski', '1948-09-18'),
(172, 'Radzis³awa', 'Wilczyñska', '1989-04-28'),
(172, 'Laurencja', 'Wilczyñska', '1972-03-17'),

(173, 'Paula', 'Grzelak', '1949-02-06'),
(173, 'Paramon', 'Grzelak', '1971-12-20'),
(173, 'Olga', 'Grzelak', '1996-07-22'),
(173, 'Egon', 'Grzelak', '1970-03-09'),

(174, 'Patrycja', 'Socha', '1942-03-06'),
(174, 'Zacheusz', 'Socha', '2000-02-29'),
(174, 'Nataniel', 'Socha', '1963-07-13'),
(174, 'Adela', 'Socha', '1994-08-06'),
(174, 'Tacjana', 'Socha', '1976-10-04'),
(174, 'Abraham', 'Socha', '1943-08-21'),

(175, 'Dagmara', 'Czajka', '2001-01-29'),

(176, 'Ildefons', 'Marek', '1944-09-27'),
(176, 'Ildefons', 'Marek', '1957-08-02'),
(176, '£ucjan', 'Marek', '1996-04-13'),

(177, 'Olech', 'Kowal', '1955-02-04'),
(177, 'Adelina', 'Kowal', '1950-01-26'),

(178, 'Nela', 'Bednarczyk', '1949-10-13'),
(178, 'Wanesa', 'Bednarczyk', '1972-01-20'),
(178, 'Adela', 'Bednarczyk', '2007-04-15'),
(178, 'Cezara', 'Bednarczyk', '1964-10-14'),
(178, 'Balbina', 'Bednarczyk', '1952-02-26'),

(179, 'Paula', 'Skiba', '1997-03-08'),
(179, 'Tacjanna', 'Skiba', '1984-02-07'),
(179, 'Felicja', 'Skiba', '1958-10-12'),
(179, 'Naczes³aw', 'Skiba', '1948-06-20'),

(180, 'Laza', 'Wrona', '2005-02-14'),
(180, 'Daniela', 'Wrona', '1956-11-04'),
(180, 'Eligia', 'Wrona', '1945-10-11'),
(180, 'Adolfa', 'Wrona', '1942-12-02'),

(181, 'Beatrycze', 'Owczarek', '1968-10-05'),
(181, 'Janis³aw', 'Owczarek', '1987-04-07'),

(182, 'Natalis', 'Marcinkowski', '2003-04-10'),
(182, 'Zacheusz', 'Marcinkowski', '1991-07-14'),
(182, 'Cecylia', 'Marcinkowska', '1977-12-26'),
(182, 'Tacjanna', 'Marcinkowska', '2005-02-19'),
(182, 'Zawisza', 'Marcinkowski', '1989-12-18'),

(183, 'Teodor', 'Matusiak', '1945-06-01'),
(183, 'Maja', 'Matusiak', '1951-02-24'),
(183, 'Janis³aw', 'Matusiak', '1993-02-17'),
(183, 'Daniela', 'Matusiak', '1974-05-27'),

(184, 'B¹dzimir', 'Orzechowski', '2008-10-25'),
(184, 'Celestyna', 'Orzechowska', '1997-02-18'),

(185, 'Edgar', 'Sobolewski', '1974-01-02'),
(185, 'Tatiana', 'Sobolewska', '1948-11-15'),
(185, 'Perpetua', 'Sobolewska', '1989-10-13'),
(185, 'Kallina', 'Sobolewska', '1982-09-26'),

(186, 'Ireneusz', 'Kêdzierski', '1961-01-24'),
(186, 'Paulina', 'Kêdzierska', '1982-01-13'),

(187, 'Walenty', 'Kurowski', '1986-08-31'),
(187, 'Adelina', 'Kurowska', '1941-06-11'),
(187, 'Hadrian', 'Kurowski', '1983-07-17'),
(187, 'Harald', 'Kurowski', '1944-12-20'),
(187, 'Taras', 'Kurowski', '1987-06-01'),
(187, 'Pantaleon', 'Kurowski', '1995-06-18'),

(188, 'Achacjusz', 'Rogowski', '2006-12-23'),
(188, 'Adelajda', 'Rogowska', '1953-10-19'),
(188, 'Dagmara', 'Rogowska', '1949-01-07'),
(188, 'Olaf', 'Rogowski', '1997-04-17'),

(189, 'Teodozjusz', 'Olejnik', '1988-02-06'),
(189, 'Jacek', 'Olejnik', '1998-01-19'),
(189, 'Daniela', 'Olejnik', '1948-12-15'),

(190, 'Gabin', 'Dêbski', '2002-06-06'),
(190, 'Samanta', 'Dêbski', '1972-02-29'),
(190, 'Samson', 'Dêbski', '1962-11-23'),

(191, '¯aklina', 'Barañska', '1976-04-23'),
(191, 'Zbigniew', 'Barañski', '1972-08-17'),
(191, 'Henryk', 'Barañski', '1943-01-15'),
(191, 'Oda', 'Barañska', '1991-06-01'),
(191, 'Innocenty', 'Barañski', '1980-03-04'),
(191, 'Tadeusz', 'Barañski', '1943-09-25'),

(192, 'Wac³aw', 'Skowroñski', '1976-09-18'),
(192, 'Egbert', 'Skowroñski', '1999-10-28'),
(192, 'Laura', 'Skowroñska', '1952-10-03'),
(192, 'Zdzis³awa', 'Skowroñska', '1985-02-14'),
(192, 'Oksana', 'Skowroñska', '1980-11-07'),

(193, 'Teodoziusz', 'Mazurkiewicz', '1962-03-21'),
(193, 'Felicyta', 'Mazurkiewicz', '1968-08-14'),
(193, '£ucjusz', 'Mazurkiewicz', '1992-03-18'),
(193, 'Rebeka', 'Mazurkiewicz', '1966-11-18'),
(193, '£azarz', 'Mazurkiewicz', '1964-08-20'),

(194, 'Paula', 'Paj¹k', '2006-01-18'),
(194, 'Olaf', 'Paj¹k', '1983-08-24'),
(194, 'Wadim', 'Paj¹k', '1942-08-26'),
(194, 'Teodor', 'Paj¹k', '2002-01-17'),
(194, 'Madlena', 'Paj¹k', '1964-04-15'),
(194, 'Maciej', 'Paj¹k', '1992-11-16'),

(195, 'Œwiêtochna', 'Czech', '2002-05-17'),
(195, 'Wanesa', 'Czech', '2007-04-27'),
(195, 'Jagna', 'Czech', '1980-05-29'),
(195, 'Teodoziusz', 'Czech', '1987-02-07'),

(196, 'Eliza', 'Janiszewska', '1980-11-10'),
(196, 'Waleriusz', 'Janiszewski', '1997-04-16'),
(196, 'Sabina', 'Janiszewska', '1996-04-08'),
(196, 'Radomys³', 'Janiszewski', '1965-07-13'),
(196, 'Faust', 'Janiszewski', '1995-09-09'),

(197, 'Karena', 'Bednarska', '1940-08-02'),
(197, 'Dacjan', 'Bednarski', '1947-08-22'),
(197, 'Rebeka', 'Bednarska', '1951-12-06'),
(197, 'Egon', 'Bednarski', '1993-08-22'),

(198, 'Ulryk', '£ukasik', '1979-12-17'),

(199, 'Walerian', 'Chrzanowski', '2008-01-13'),
(199, 'Nadia', 'Chrzanowska', '2005-04-25'),
(199, 'Naczes³aw', 'Chrzanowski', '1961-10-09'),

(200, 'Pankracy', 'Bukowski', '1983-08-05'),
(200, 'Fabian', 'Bukowski', '1961-12-26')
GO


/*Ksiadz - dane*/
INSERT INTO Ksiadz(Imie, Nazwisko, DataPrzybycia) VALUES ('£ucjan', 'Nowacki', '2004-11-05')
INSERT INTO Ksiadz(Imie, Nazwisko, DataPrzybycia) VALUES ('Pankracy', 'Kurek', '1987-12-25')
INSERT INTO Ksiadz(Imie, Nazwisko, DataPrzybycia) VALUES ('Dalebor', 'Czerwiñski', '1982-06-12')


/*Pogrzeby i zmiana stanu wiernego*/

UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '597'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('597', '3', 'Kwatera nr751', '79', '2017-01-18')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '178'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('178', '1', 'Kwatera nr768', '69', '2017-01-23')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '490'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('490', '1', 'Kwatera nr780', '95', '2017-01-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '410'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('410', '1', 'Kwatera nr944', '97', '2017-01-26')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '668'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('668', '2', 'Kwatera nr821', '55', '2017-01-19')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '424'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('424', '1', 'Kwatera nr745', '66', '2017-01-23')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '600'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('600', '2', 'Kwatera nr45', '82', '2000-03-20')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '415'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('415', '1', 'Kwatera nr136', '88', '1950-07-01')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '405'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('405', '1', 'Kwatera nr640', '65', '1942-01-29')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '54'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('54', '3', 'Kwatera nr815', '97', '2003-11-22')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '639'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('639', '1', 'Kwatera nr51', '93', '1948-09-17')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '60'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('60', '3', 'Kwatera nr188', '78', '1989-09-02')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '428'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('428', '3', 'Kwatera nr639', '51', '2007-11-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '492'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('492', '1', 'Kwatera nr893', '56', '1990-06-09')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '327'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('327', '3', 'Kwatera nr322', '71', '1966-07-28')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '628'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('628', '2', 'Kwatera nr511', '67', '1965-04-10')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '143'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('143', '1', 'Kwatera nr346', '69', '1952-10-24')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '411'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('411', '1', 'Kwatera nr87', '54', '1979-02-06')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '248'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('248', '3', 'Kwatera nr74', '68', '1990-03-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '579'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('579', '3', 'Kwatera nr313', '97', '1942-10-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '163'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('163', '3', 'Kwatera nr808', '65', '1977-01-03')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '634'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('634', '1', 'Kwatera nr211', '77', '2007-11-15')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '529'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('529', '2', 'Kwatera nr493', '88', '1944-06-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '278'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('278', '2', 'Kwatera nr842', '59', '1987-03-24')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '552'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('552', '3', 'Kwatera nr769', '62', '1992-11-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '536'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('536', '3', 'Kwatera nr513', '66', '1962-09-13')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '363'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('363', '1', 'Kwatera nr96', '92', '1951-06-03')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '343'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('343', '2', 'Kwatera nr629', '70', '1973-08-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '173'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('173', '3', 'Kwatera nr67', '71', '1945-09-19')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '245'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('245', '1', 'Kwatera nr980', '75', '1948-04-03')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '37'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('37', '2', 'Kwatera nr896', '53', '1962-08-24')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '171'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('171', '3', 'Kwatera nr557', '90', '1944-04-19')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '246'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('246', '1', 'Kwatera nr163', '69', '1970-03-16')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '272'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('272', '3', 'Kwatera nr426', '71', '1948-10-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '189'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('189', '2', 'Kwatera nr946', '78', '1967-03-17')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '229'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('229', '2', 'Kwatera nr974', '89', '1946-05-10')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '361'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('361', '1', 'Kwatera nr138', '91', '1996-08-03')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '528'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('528', '1', 'Kwatera nr984', '82', '2002-07-14')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '160'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('160', '3', 'Kwatera nr430', '100', '1990-03-19')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '159'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('159', '2', 'Kwatera nr66', '64', '1982-04-24')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '369'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('369', '3', 'Kwatera nr50', '71', '1967-09-16')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '28'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('28', '1', 'Kwatera nr831', '89', '2002-12-03')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '491'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('491', '3', 'Kwatera nr545', '75', '2007-03-05')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '267'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('267', '2', 'Kwatera nr532', '66', '2004-01-14')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '379'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('379', '1', 'Kwatera nr971', '95', '1987-06-08')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '212'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('212', '3', 'Kwatera nr731', '92', '1965-06-22')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '617'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('617', '3', 'Kwatera nr758', '66', '1992-03-11')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '470'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('470', '2', 'Kwatera nr377', '94', '1974-06-13')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '554'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('554', '2', 'Kwatera nr382', '87', '1961-12-22')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '673'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('673', '1', 'Kwatera nr257', '71', '2001-10-11')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '141'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('141', '2', 'Kwatera nr969', '70', '1993-12-11')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '368'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('368', '3', 'Kwatera nr658', '58', '1953-03-15')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '623'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('623', '3', 'Kwatera nr797', '56', '1965-06-16')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '682'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('682', '2', 'Kwatera nr712', '82', '1974-11-15')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '49'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('49', '1', 'Kwatera nr296', '99', '2005-02-15')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '649'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('649', '1', 'Kwatera nr717', '55', '1956-01-18')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '266'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('266', '3', 'Kwatera nr961', '71', '1998-12-12')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '232'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('232', '2', 'Kwatera nr381', '68', '1977-05-23')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '24'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('24', '1', 'Kwatera nr869', '57', '2000-05-18')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '601'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('601', '2', 'Kwatera nr249', '52', '1991-12-14')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '252'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('252', '1', 'Kwatera nr785', '92', '1980-11-01')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '247'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('247', '2', 'Kwatera nr756', '63', '2002-06-24')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '249'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('249', '1', 'Kwatera nr591', '87', '1944-08-30')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '323'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('323', '3', 'Kwatera nr260', '85', '1964-05-30')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '88'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('88', '3', 'Kwatera nr197', '51', '1959-08-06')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '307'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('307', '3', 'Kwatera nr214', '61', '1941-12-06')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '9'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('9', '1', 'Kwatera nr754', '76', '1968-07-19')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '296'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('296', '3', 'Kwatera nr178', '90', '1955-08-24')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '607'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('607', '3', 'Kwatera nr996', '95', '2003-03-15')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '32'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('32', '1', 'Kwatera nr680', '61', '1972-06-05')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '322'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('322', '3', 'Kwatera nr43', '79', '1994-07-05')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '564'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('564', '2', 'Kwatera nr28', '87', '2002-01-30')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '481'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('481', '1', 'Kwatera nr816', '71', '1949-06-24')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '56'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('56', '3', 'Kwatera nr963', '51', '1987-10-18')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '188'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('188', '3', 'Kwatera nr467', '79', '1942-03-09')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '466'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('466', '3', 'Kwatera nr663', '86', '1957-08-24')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '499'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('499', '3', 'Kwatera nr638', '89', '1989-03-18')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '153'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('153', '3', 'Kwatera nr320', '78', '1995-10-12')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '22'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('22', '3', 'Kwatera nr123', '64', '1970-07-09')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '10'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('10', '1', 'Kwatera nr264', '70', '1964-07-07')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '503'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('503', '1', 'Kwatera nr398', '51', '1998-07-22')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '522'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('522', '3', 'Kwatera nr694', '95', '1946-02-28')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '396'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('396', '3', 'Kwatera nr124', '79', '1979-11-29')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '427'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('427', '3', 'Kwatera nr813', '93', '1949-12-24')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '40'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('40', '2', 'Kwatera nr579', '59', '1982-01-19')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '626'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('626', '3', 'Kwatera nr627', '91', '1979-09-06')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '452'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('452', '2', 'Kwatera nr908', '52', '1942-02-15')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '337'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('337', '1', 'Kwatera nr777', '82', '1988-07-08')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '168'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('168', '2', 'Kwatera nr861', '53', '2002-03-01')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '203'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('203', '2', 'Kwatera nr960', '68', '1976-10-20')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '383'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('383', '1', 'Kwatera nr837', '97', '1952-08-28')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '187'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('187', '1', 'Kwatera nr193', '72', '1967-05-08')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '388'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('388', '1', 'Kwatera nr385', '75', '1991-04-15')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '218'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('218', '1', 'Kwatera nr165', '78', '1995-11-07')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '348'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('348', '2', 'Kwatera nr740', '73', '1984-07-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '85'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('85', '3', 'Kwatera nr181', '57', '1981-12-22')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '662'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('662', '3', 'Kwatera nr656', '96', '2004-01-22')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '530'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('530', '2', 'Kwatera nr130', '56', '1951-07-16')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '433'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('433', '1', 'Kwatera nr105', '84', '2002-02-28')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '636'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('636', '3', 'Kwatera nr55', '65', '1978-09-30')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '205'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('205', '1', 'Kwatera nr965', '63', '1945-02-28')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '375'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('375', '1', 'Kwatera nr108', '80', '1973-01-08')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '2'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('2', '1', 'Kwatera nr6', '79', '1944-09-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '284'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('284', '2', 'Kwatera nr5', '53', '1967-08-02')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '652'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('652', '1', 'Kwatera nr949', '86', '1977-09-22')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '98'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('98', '3', 'Kwatera nr236', '70', '1966-02-15')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '151'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('151', '1', 'Kwatera nr333', '81', '2005-09-20')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '43'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('43', '1', 'Kwatera nr671', '79', '1944-01-11')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '18'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('18', '2', 'Kwatera nr288', '76', '1985-05-01')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '381'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('381', '2', 'Kwatera nr812', '92', '1951-01-27')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '576'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('576', '2', 'Kwatera nr775', '55', '2007-08-20')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '671'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('671', '1', 'Kwatera nr312', '99', '1982-08-21')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '319'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('319', '3', 'Kwatera nr803', '86', '1958-07-14')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '41'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('41', '2', 'Kwatera nr962', '58', '1968-05-23')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '354'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('354', '1', 'Kwatera nr244', '68', '1988-02-19')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '566'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('566', '2', 'Kwatera nr674', '57', '1985-01-05')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '117'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('117', '3', 'Kwatera nr63', '86', '1970-11-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '345'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('345', '2', 'Kwatera nr942', '62', '1986-08-05')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '197'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('197', '3', 'Kwatera nr649', '91', '1946-10-25')
UPDATE Wierny SET CzyZywy = 'false' WHERE IDWiernego = '93'
INSERT INTO Pogrzeb(IDZmarlego, IDKsiedza, AdresKwatery, Kwota, DataPogrzebu)
 VALUES ('93', '1', 'Kwatera nr550', '63', '1965-08-02')

 
/*Msze - dane*/
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja0', '1998-07-12', '84')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja1', '1959-04-11', '96')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja2', '1994-06-19', '88')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja3', '1960-01-15', '60')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja4', '2006-12-19', '83')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja5', '1979-03-11', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja6', '2002-09-10', '100')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja7', '1992-02-12', '64')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja8', '2008-10-10', '81')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja9', '1942-09-04', '51')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja10', '1996-05-11', '67')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja11', '2000-04-20', '81')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja12', '1957-07-22', '58')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja13', '1957-06-08', '65')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja14', '1991-10-16', '56')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja15', '2007-12-20', '51')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja16', '1970-06-18', '81')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja17', '2001-03-07', '58')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja18', '1945-09-30', '79')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja19', '2008-11-24', '97')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja20', '1940-11-22', '76')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja21', '1962-03-22', '62')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja22', '1954-10-19', '70')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja23', '1940-03-30', '60')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja24', '1967-05-12', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja25', '1950-04-01', '91')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja26', '1964-07-08', '50')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja27', '1991-08-14', '50')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja28', '2000-03-09', '77')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja29', '1992-03-28', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja30', '2003-12-28', '53')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja31', '1950-04-30', '70')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja32', '2000-10-14', '93')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja33', '1998-09-07', '82')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja34', '2005-07-28', '64')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja35', '1940-03-29', '87')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja36', '2005-10-12', '59')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja37', '1988-07-02', '66')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja38', '1967-02-06', '81')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja39', '1969-01-10', '81')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja40', '1964-09-03', '71')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja41', '1965-05-31', '89')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja42', '1961-07-24', '50')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja43', '1993-07-19', '51')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja44', '1978-11-30', '61')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja45', '2001-12-01', '51')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja46', '1979-10-06', '52')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja47', '1957-07-18', '84')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja48', '1989-04-12', '51')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja49', '1941-06-11', '62')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja50', '1961-01-12', '67')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja51', '1991-03-29', '73')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja52', '1996-07-14', '86')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja53', '1950-03-31', '66')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja54', '1950-09-03', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja55', '1969-07-10', '68')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja56', '2001-12-08', '84')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja57', '2000-03-10', '77')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja58', '1992-09-19', '81')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja59', '2009-08-24', '70')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja60', '2004-06-10', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja61', '1968-07-29', '68')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja62', '1974-10-16', '55')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja63', '2001-02-08', '55')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja64', '2007-03-15', '88')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja65', '1991-03-10', '90')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja66', '1978-07-02', '95')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja67', '1944-06-01', '98')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja68', '1953-10-24', '50')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja69', '1956-06-03', '89')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja70', '1993-07-03', '99')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja71', '1988-05-06', '66')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja72', '1957-02-05', '87')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja73', '1982-03-20', '92')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja74', '1943-05-27', '73')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja75', '1966-09-07', '98')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja76', '1981-06-09', '61')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja77', '1980-08-10', '84')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja78', '1951-10-27', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja79', '1994-07-31', '60')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja80', '1973-01-18', '97')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja81', '1957-07-24', '100')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja82', '1946-02-07', '88')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja83', '2003-04-28', '75')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja84', '1979-05-21', '53')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja85', '1955-11-11', '95')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja86', '2003-12-08', '87')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja87', '1947-04-20', '94')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja88', '2008-06-21', '67')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja89', '1980-12-26', '52')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja90', '2007-11-17', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja91', '2005-12-05', '94')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja92', '1962-07-10', '78')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja93', '1971-01-12', '55')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja94', '2003-12-28', '81')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja95', '1972-12-12', '64')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja96', '1982-08-03', '64')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja97', '1971-03-13', '70')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja98', '1946-03-07', '88')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja99', '2008-04-20', '71')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja100', '1954-08-15', '86')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja101', '1948-02-20', '56')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja102', '1966-12-26', '52')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja103', '1940-09-17', '53')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja104', '1996-06-30', '68')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja105', '1962-01-24', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja106', '1953-07-06', '57')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja107', '1947-02-02', '50')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja108', '2005-03-17', '60')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja109', '1940-02-01', '80')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja110', '1967-12-31', '66')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja111', '1994-09-12', '57')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja112', '1995-12-13', '72')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja113', '1985-10-10', '83')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja114', '1981-01-27', '52')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja115', '1972-09-06', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja116', '1984-01-16', '100')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja117', '1989-11-24', '68')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja118', '1987-01-31', '70')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja119', '1969-01-30', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja120', '1989-07-13', '70')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja121', '1993-07-22', '75')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja122', '1997-12-29', '51')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja123', '1940-03-18', '52')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja124', '1965-07-23', '67')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja125', '1943-06-21', '60')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja126', '1995-01-24', '70')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja127', '1953-10-20', '66')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja128', '1948-12-30', '62')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja129', '1989-01-16', '65')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja130', '1984-12-11', '55')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja131', '2000-11-17', '80')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja132', '2000-09-22', '79')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja133', '1966-05-20', '65')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja134', '1948-04-09', '61')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja135', '1960-08-23', '51')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja136', '1962-11-01', '82')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja137', '2009-04-20', '56')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja138', '1958-06-10', '63')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja139', '2007-05-09', '72')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja140', '2006-09-28', '82')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja141', '1973-03-30', '75')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('1', 'Intencja142', '2017-01-24', '50')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja143', '2017-01-25', '76')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja144', '2017-01-18', '70')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja145', '2017-01-22', '84')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('2', 'Intencja146', '2017-01-23', '70')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja147', '2017-01-21', '74')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja148', '2017-01-18', '85')
INSERT INTO Msza(IDKsiedza, Intencja, DataMszy, Kwota) VALUES ('3', 'Intencja149', '2017-01-20', '94')

/* Sakramenty */
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('637', '5', '2017-06-19', '78')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('96', '2', '2017-01-19', '126')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('669', '2', '2017-01-19', '148')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('455', '4', '2017-01-22', '109')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('293', '5', '2017-01-25', '87')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('398', '5', '2017-01-18', '143')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('363', '2', '2017-01-21', '120')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('391', '4', '2017-01-23', '65')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('284', '3', '1957-12-24', '54')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('333', '5', '1998-10-29', '84')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('79', '2', '1960-09-12', '137')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('304', '1', '1996-01-14', '107')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('136', '1', '1941-06-04', '120')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('285', '4', '1996-05-26', '78')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('491', '5', '1954-03-11', '121')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('427', '4', '1987-08-03', '130')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('532', '5', '2008-03-11', '79')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('423', '4', '1976-07-01', '82')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('415', '1', '1993-04-30', '76')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('173', '2', '1962-03-03', '113')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('682', '4', '1991-07-28', '124')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('349', '1', '1940-10-08', '146')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('38', '3', '1979-03-09', '113')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('183', '3', '1988-10-23', '78')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('617', '1', '1955-08-07', '92')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('316', '3', '1979-08-09', '101')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('624', '3', '1951-09-28', '132')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('403', '1', '1950-05-07', '92')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('234', '5', '1966-04-30', '116')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('526', '4', '1959-10-08', '74')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('594', '1', '1952-06-08', '140')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('224', '4', '1964-11-23', '126')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('589', '5', '1969-08-28', '134')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('181', '3', '1981-01-08', '101')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('385', '2', '1946-12-11', '63')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('531', '5', '1963-01-29', '140')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('466', '1', '2000-10-11', '57')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('684', '4', '1979-10-26', '72')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('554', '5', '1972-01-28', '81')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('390', '1', '1951-11-07', '108')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('450', '2', '1951-04-17', '121')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('284', '5', '1996-06-29', '144')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('473', '4', '1946-08-12', '121')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('347', '1', '1940-09-21', '81')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('235', '5', '1956-05-27', '140')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('333', '4', '2004-12-15', '128')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('663', '5', '1956-10-25', '123')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('627', '4', '1948-02-18', '108')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('260', '4', '1980-03-25', '113')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('164', '1', '1958-11-05', '65')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('315', '4', '1990-12-25', '51')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('534', '3', '1982-04-15', '136')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('48', '3', '1960-07-21', '135')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('261', '5', '2008-06-04', '68')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('140', '5', '2007-12-28', '143')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('104', '3', '1995-02-22', '113')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('282', '1', '1989-03-18', '117')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('73', '5', '1967-12-10', '72')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('186', '5', '2009-09-08', '108')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('79', '1', '1983-09-03', '69')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('399', '2', '1940-09-27', '97')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('268', '3', '1995-01-28', '80')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('521', '5', '1971-02-24', '119')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('387', '5', '1943-01-15', '118')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('111', '1', '1990-10-12', '71')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('393', '1', '1969-06-22', '113')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('571', '2', '1953-12-07', '79')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('493', '4', '1968-07-25', '112')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('71', '5', '1962-09-18', '113')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('275', '2', '1985-03-28', '77')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('631', '2', '1982-05-21', '55')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('264', '3', '2007-05-17', '67')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('673', '5', '1971-01-15', '117')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('594', '2', '1984-04-27', '100')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('411', '2', '2006-02-17', '115')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('275', '2', '1976-05-10', '122')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('635', '4', '1958-01-02', '71')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('344', '5', '1977-04-07', '91')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('372', '4', '1976-12-30', '96')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('452', '5', '1988-04-04', '123')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('386', '4', '1991-02-04', '85')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('405', '2', '1995-12-09', '135')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('386', '1', '1985-02-24', '129')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('45', '1', '2003-12-12', '103')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('617', '3', '2000-09-30', '56')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('395', '1', '1966-09-06', '85')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('551', '4', '2006-06-10', '64')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('538', '5', '1999-07-24', '149')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('148', '5', '1985-06-05', '77')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('666', '3', '2006-06-26', '113')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('605', '4', '2001-01-02', '54')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('623', '1', '1990-04-16', '51')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('450', '3', '1943-09-21', '130')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('155', '4', '1954-05-17', '145')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('463', '5', '1980-05-31', '131')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('37', '3', '1987-09-06', '133')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('139', '3', '1984-06-30', '123')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('202', '4', '1972-05-06', '118')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('359', '3', '1962-02-03', '149')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('62', '2', '1967-06-08', '82')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('679', '5', '1957-01-19', '133')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('538', '1', '1994-09-27', '58')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('109', '4', '1961-02-07', '80')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('341', '2', '2002-05-04', '90')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('635', '4', '1966-06-13', '78')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('668', '3', '1959-11-01', '70')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('549', '1', '1979-02-16', '112')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('263', '5', '1954-09-04', '98')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('73', '4', '1974-04-24', '111')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('279', '2', '1994-07-25', '124')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('201', '5', '1957-05-18', '68')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('422', '5', '1943-08-28', '107')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('535', '1', '1959-06-24', '106')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('658', '1', '1946-04-26', '112')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('42', '3', '1980-01-01', '111')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('47', '1', '2003-01-25', '77')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('670', '5', '1997-03-08', '80')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('263', '2', '2000-07-02', '96')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('163', '3', '1978-07-19', '97')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('135', '4', '1980-11-17', '68')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('659', '2', '1999-02-15', '60')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('372', '1', '1954-05-23', '137')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('613', '3', '1963-03-21', '119')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('74', '5', '1995-08-15', '69')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('323', '1', '2005-02-18', '70')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('493', '5', '2008-08-08', '146')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('571', '3', '1941-11-27', '63')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('416', '3', '1954-10-29', '80')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('188', '3', '1964-09-29', '136')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('252', '5', '1970-02-26', '129')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('13', '3', '2006-07-21', '100')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('482', '3', '1994-01-05', '106')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('175', '5', '1954-05-20', '98')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('575', '3', '1948-02-27', '148')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('59', '4', '1971-01-23', '146')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('305', '4', '1970-03-03', '66')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('516', '2', '1966-02-19', '120')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('11', '2', '1940-08-03', '134')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('641', '3', '1987-02-07', '123')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('464', '1', '1990-06-29', '148')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('308', '5', '1979-06-11', '88')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('21', '4', '1951-05-07', '137')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('343', '1', '2006-09-15', '122')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('686', '2', '1957-05-30', '121')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('431', '1', '2002-10-12', '59')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('501', '5', '1982-02-09', '114')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('487', '5', '1998-02-20', '69')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('327', '3', '2007-12-14', '71')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('444', '5', '2004-11-05', '63')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('213', '5', '1952-09-12', '120')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('380', '4', '1980-11-13', '113')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('15', '4', '2008-08-20', '57')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('297', '4', '1967-11-08', '62')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('485', '3', '1983-10-08', '54')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('110', '3', '1953-06-24', '53')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('6', '3', '1986-11-14', '121')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('147', '1', '1942-11-27', '130')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('384', '4', '1994-06-13', '141')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('58', '1', '1975-09-26', '149')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('153', '4', '1992-08-20', '89')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('174', '5', '2001-02-27', '104')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('206', '4', '2003-03-21', '133')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('49', '3', '1953-12-23', '97')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('172', '5', '1969-10-26', '80')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('149', '1', '1947-05-23', '107')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('412', '4', '1963-07-31', '89')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('443', '4', '1949-04-23', '95')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('178', '3', '1958-09-01', '145')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('675', '2', '1970-05-09', '127')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('240', '1', '1980-07-11', '97')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('155', '5', '1945-05-06', '133')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('515', '1', '1966-05-19', '121')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('552', '3', '1978-02-01', '91')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('47', '5', '1985-05-30', '148')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('426', '5', '1999-07-03', '68')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('561', '5', '1984-01-03', '128')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('437', '4', '1940-12-15', '145')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('517', '4', '1959-01-15', '58')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('279', '3', '1976-10-21', '138')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('72', '1', '1991-03-16', '145')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('589', '2', '1946-08-14', '112')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('447', '1', '1966-09-13', '63')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('240', '2', '1993-10-18', '58')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('122', '5', '1975-05-25', '141')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('647', '2', '1970-05-26', '60')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('591', '3', '1969-06-13', '116')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('359', '1', '1981-11-22', '139')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('670', '2', '1941-01-01', '105')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('379', '4', '1970-11-15', '113')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('308', '1', '1987-01-21', '67')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('7', '2', '1980-05-14', '59')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('34', '4', '1950-04-27', '119')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('139', '1', '1995-11-12', '53')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('539', '4', '1981-05-20', '71')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('212', '5', '1986-05-16', '111')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('240', '2', '1955-12-25', '119')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('370', '2', '1957-09-27', '98')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('288', '5', '1986-05-08', '86')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('485', '4', '1942-10-05', '57')
INSERT INTO Sakrament(IDWiernego, IDNazwySakramentu, DataSakramentu, Kwota) VALUES ('222', '4', '1962-05-17', '118')

