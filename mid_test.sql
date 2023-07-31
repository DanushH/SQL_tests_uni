--IT18081794 
--Y3S1.02(IT)
-- DS Tutorial 4

--question (a)(i)
SELECT AVG(p.premium) average_premium
	FROM Policies_IT18081794 p
		Where (MONTHS_BETWEEN(SYSDATE, p.inscar.owner.birthdate)/12) > 20 AND (MONTHS_BETWEEN(SYSDATE, p.inscar.owner.birthdate)/12) < 25
			
--question (a)(ii)
SELECT p.inscar.make make, p.inscar.model model, SUM(pc.amount) total_claim_amount
	FROM Policies_IT18081794 p, TABLE(p.claims) pc
		WHERE p.edate BETWEEN '01-JAN-04' AND '31-DEC-04'
			Group by p.inscar.make, p.inscar.model

--question (b)
INSERT INTO TABLE(SELECT p.claims FROM Policies_IT18081794 p WHERE p.pid = 'SL12354')
	VALUES('001', '12-Jul-04', 2000.00, (SELECT REF(c) FROM Customers_IT18081794 c WHERE c.cid='S25431'))

--question (c)
ALTER TYPE Policy_t_IT18081794 ADD MEMBER FUNCTION calculatePremium RETURN NUMBER CASCADE
/
CREATE OR REPLACE TYPE BODY Policy_t_IT18081794 AS 
	MEMBER FUNCTION calculatePremium RETURN NUMBER IS
		renewal NUMBER;
		total NUMBER;
	BEGIN
		SELECT SUM(pc.amount) INTO total FROM TABLE(self.claims) pc;
		IF (total < 1000) THEN
			renewal := self.premium;
		ELSE
			renewal := self.premium + (self.premium * 0.2);
		END IF;
		RETURN renewal;
	END calculatePremium;
END;
/

--question (d)
SELECT p.calculatePremium() renewed_premium
	FROM Policies_IT18081794 p
		WHERE p.inscar.regno= 'SLA984'


--creating types
CREATE TYPE Customer_t_IT18081794 AS OBJECT(
	cid CHAR(6),
	name VARCHAR2(15),
	birthdate DATE,
	phone CHAR(10),
	address VARCHAR2(50)
)
/

CREATE TYPE Car_t_IT18081794 AS OBJECT(
	regno CHAR(9),
	make VARCHAR2(12),
	model VARCHAR2(10),
	mdate DATE,
	owner REF Customer_t_IT18081794,
	value NUMBER(8,2)
)
/

CREATE TYPE Claim_t_IT18081794 AS OBJECT(
	claimno CHAR(12),
	cdate DATE,
	amount NUMBER(8,2),
	claimant REF Customer_t_IT18081794
)
/

CREATE TYPE Claim_ntab_IT18081794 AS TABLE OF Claim_t_IT18081794
/

CREATE TYPE Policy_t_IT18081794 AS OBJECT(
	pid CHAR(7),
	sdate DATE,
	edate DATE,
	inscar REF Car_t_IT18081794,
	premium NUMBER(6,2),
	claims Claim_ntab_IT18081794
)
/


--creating tables
CREATE TABLE Customers_IT18081794 OF Customer_t_IT18081794(
	CONSTRAINT PK_Customers_IT18081794 PRIMARY KEY (cid)
)
/

CREATE TABLE Cars_IT18081794 OF Car_t_IT18081794(
	CONSTRAINT PK_Cars_IT18081794 PRIMARY KEY (regno),
	CONSTRAINT FK_Cars_IT18081794 FOREIGN KEY (owner) REFERENCES Customers_IT18081794
)
/

CREATE TABLE Policies_IT18081794 OF Policy_t_IT18081794(
	CONSTRAINT PK_Policies_IT18081794 PRIMARY KEY (pid),
	CONSTRAINT FK_Policies_IT18081794 FOREIGN KEY (inscar) REFERENCES Cars_IT18081794
)
NESTED TABLE claims STORE AS claims_ntable_IT18081794
/


/*inserting dummy data
INSERT INTO Customers_IT18081794 VALUES(1, 'aaa', '14-AUG-2005', 789, 'add');
INSERT INTO Customers_IT18081794 VALUES(2, 'bbb', '14-AUG-1997', 789, 'add');
INSERT INTO Customers_IT18081794 VALUES(3, 'ccc', '14-AUG-1998', 789, 'add');
INSERT INTO Customers_IT18081794 VALUES(4, 'ddd', '15-AUG-1998', 500, 'add');
INSERT INTO Customers_IT18081794 VALUES(5, 'ddd', '15-AUG-1998', 500, 'add');
INSERT INTO Customers_IT18081794 VALUES(6, 'ddd', '15-AUG-1998', 500, 'add');
INSERT INTO Customers_IT18081794 VALUES(7, 'ddd', '15-AUG-1998', 500, 'add');

INSERT INTO Cars_IT18081794 VALUES(1, 'mak1', 'mod1', '14-AUG-1953', (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='1'), 500);
INSERT INTO Cars_IT18081794 VALUES(2, 'mak1', 'mod1', '14-AUG-1953', (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='2'), 600);
INSERT INTO Cars_IT18081794 VALUES(3, 'mak1', 'mod1', '14-AUG-1953', (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='3'), 700);
INSERT INTO Cars_IT18081794 VALUES(4, 'mak1', 'mod1', '14-AUG-1953', (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='4'), 800);
INSERT INTO Cars_IT18081794 VALUES(5, 'mak51', 'mod51', '14-AUG-1953', (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='5'), 900);
INSERT INTO Cars_IT18081794 VALUES(6, 'mak61', 'mod61', '14-AUG-1953', (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='6'), 1000);
INSERT INTO Cars_IT18081794 VALUES(7, 'mak71', 'mod71', '14-AUG-1953', (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='7'), 2000);
INSERT INTO Cars_IT18081794 VALUES('SLA984', 'mak71', 'mod71', '14-AUG-1953', (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='7'), 5000);

INSERT INTO Policies_IT18081794 VALUES(1, '14-AUG-2005', '14-AUG-2006', (SELECT ref(c) FROM Cars_IT18081794 c WHERE c.regno='1'),
	789, Claim_ntab_IT18081794(Claim_t_IT18081794(1, '14-AUG-1953', 450, (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='1'))));
INSERT INTO Policies_IT18081794 VALUES(2, '14-AUG-1953', '14-AUG-2004', (SELECT ref(c) FROM Cars_IT18081794 c WHERE c.regno='2'),
	789, Claim_ntab_IT18081794(Claim_t_IT18081794(1, '14-AUG-1953', 450, (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='2'))));
INSERT INTO Policies_IT18081794 VALUES(8, '14-AUG-1953', '14-AUG-2004', (SELECT ref(c) FROM Cars_IT18081794 c WHERE c.regno='3'),
	789, Claim_ntab_IT18081794(Claim_t_IT18081794(1, '14-AUG-1953', 450, (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='3'))));
INSERT INTO Policies_IT18081794 VALUES(4, '14-AUG-1953', '14-AUG-2008', (SELECT ref(c) FROM Cars_IT18081794 c WHERE c.regno='4'),
	500, Claim_ntab_IT18081794(Claim_t_IT18081794(1, '14-AUG-1953', 450, (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='4'))));
INSERT INTO Policies_IT18081794 VALUES(5, '14-AUG-1953', '14-AUG-2004', (SELECT ref(c) FROM Cars_IT18081794 c WHERE c.regno='5'),
	500, Claim_ntab_IT18081794(Claim_t_IT18081794(5, '14-AUG-1953', 500, (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='5'))));
INSERT INTO Policies_IT18081794 VALUES(6, '14-AUG-1953', '14-JAN-2004', (SELECT ref(c) FROM Cars_IT18081794 c WHERE c.regno='6'),
	500, Claim_ntab_IT18081794(Claim_t_IT18081794(6, '14-AUG-1953', 450, (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='6'))));
INSERT INTO Policies_IT18081794 VALUES(7, '14-AUG-1953', '19-AUG-2004', (SELECT ref(c) FROM Cars_IT18081794 c WHERE c.regno='7'),
	500, Claim_ntab_IT18081794(Claim_t_IT18081794(7, '14-AUG-1953', 1450, (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='7'))));
INSERT INTO Policies_IT18081794 VALUES(10, '14-AUG-1953', '19-AUG-2004', (SELECT ref(c) FROM Cars_IT18081794 c WHERE c.regno='SLA984'),
	4500, Claim_ntab_IT18081794(Claim_t_IT18081794(7, '14-AUG-1953', 1500, (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='7'))));
INSERT INTO Policies_IT18081794 VALUES(11, '14-AUG-1953', '19-AUG-2004', (SELECT ref(c) FROM Cars_IT18081794 c WHERE c.regno='SLA984'),
	4500, Claim_ntab_IT18081794(Claim_t_IT18081794(7, '14-AUG-1953', 500, (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='7'))));
INSERT INTO Customers_IT18081794 VALUES('S25431', 'test', '15-AUG-1999', 500, 'add');
INSERT INTO Policies_IT18081794 VALUES('SL12354', '14-AUG-1953', '19-AUG-2004', (SELECT ref(c) FROM Cars_IT18081794 c WHERE c.regno='7'),
	500, Claim_ntab_IT18081794(Claim_t_IT18081794(7, '14-AUG-1953', 1450, (SELECT ref(c) FROM Customers_IT18081794 c WHERE c.cid='7'))));
*/



