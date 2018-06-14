/*
Nächste Seminare:
14.06: Customer Value nochmal vertiefen & Partitionierungen -> Kundenbezogene Auswertung soll mal als Anregung für Projekt dienen
21.06: Analysis Tools werden vorgestellt mit kleinem Bsp was man für das Projekt werwenden könnte (aufgabenblatt bzw. kleine Anleitung soll als Blatt kommen)
28.06: Praktisch das Thema Indexierung
05.07: Indexierung an der Tafel
*/

/*Aus Übungsblatt 8:*/
SELECT 
	a.riskID, 
	COUNT (distinct a.customerNo) Konten,
	SUM (a.Bestellungen)Bestellungen, 
	SUM (a.Artikel) Artikel,
	SUM (a.Nettosumme)Nettosumme, 
	SUM (b.Retouren)Retouren,
	SUM (b.Ret_Artikel)Ret_Artikel, 
	SUM (b.Ret_Nettowert)Ret_Nettowert
FROM
	(
		SELECT 
			c.riskID, 
			s.customerNo,
			COUNT (distinct s.orderNo)Bestellungen, 
			sum (s.quantity)Artikel,
			cast (SUM (s.amount *s.quantity)as decimal(10,2))Nettosumme
		FROM 
			[dbo].[iw_customer]c,
			[dbo].[iw_sales]s
		WHERE 
			c.customerNo = s.customerNo
			and s.type = 2
		GROUP BY c.riskID, s.customerNo
	)a
	left outer join
	(
		SELECT 
			rl.customerNo,
			COUNT (distinct rl.returnNo)Retouren, 
			SUM (rl.quantity)Ret_Artikel,
			SUM (rl.line_amount)Ret_Nettowert
		FROM
			[dbo].[iw_return_line]rl
		WHERE 
			rl.type = 2
		GROUP BY rl.customerNo
	)b
	on a.customerNo = b.customerNo
GROUP BY a.riskID
;


/*Nicht alle Retouren haben auch Bestellungen:*/
SELECT 
	a.riskID, 
	COUNT (distinct a.customerNo) Konten,
	SUM (a.Bestellungen)Bestellungen, 
	SUM (a.Artikel) Artikel,
	SUM (a.Nettosumme)Nettosumme, 
	SUM (b.Retouren)Retouren,
	SUM (b.Ret_Artikel)Ret_Artikel, 
	SUM (b.Ret_Nettowert)Ret_Nettowert
FROM
	(
		SELECT 
			c.riskID, 
			s.customerNo,
			COUNT (distinct s.orderNo)Bestellungen, 
			sum (s.quantity)Artikel,
			cast (SUM (s.amount *s.quantity)as decimal(10,2))Nettosumme
		FROM 
			[dbo].[iw_customer]c,
			[dbo].[iw_sales]s
		WHERE 
			c.customerNo = s.customerNo
			and s.type = 2
		GROUP BY c.riskID, s.customerNo
	)a
	left outer join
	(
		SELECT 
			rl.customerNo,
			COUNT (distinct rl.returnNo)Retouren, 
			SUM (rl.quantity)Ret_Artikel,
			SUM (rl.line_amount)Ret_Nettowert
		FROM
			[dbo].[iw_return_line]rl
		WHERE 
			rl.type = 2
		GROUP BY rl.customerNo
	)b
	on a.customerNo = b.customerNo
where a.Artikel < b.Ret_Artikel
GROUP BY a.riskID
;

/*Für welche Retouren liegen keine Bestllungen vor?*/
select distinct orderNo
from iw_return_header

EXCEPT

select distinct orderNo
	from iw_sales

select distinct city 
from iw_customer
order by city 


/*Erweiterung um Kosten*/
SELECT 
	a.riskID, 
	COUNT (distinct a.customerNo) Konten,
	SUM (a.Bestellungen)Bestellungen, 
	SUM (a.Artikel) Artikel,
	SUM (a.Nettosumme)Nettosumme, 
	SUM (b.Retouren)Retouren,
	SUM (b.Ret_Artikel)Ret_Artikel, 
	SUM (b.Ret_Nettowert)Ret_Nettowert,
	(SUM (a.Bestellungen)*9.5)Bestellkosten,
	(SUM (b.Retouren)*5.8)Retourkosten
FROM
	(
		SELECT 
			c.riskID, 
			s.customerNo,
			COUNT (distinct s.orderNo)Bestellungen, 
			sum (s.quantity)Artikel,
			cast (SUM (s.amount *s.quantity)as decimal(10,2))Nettosumme
		FROM 
			[dbo].[iw_customer]c,
			[dbo].[iw_sales]s
		WHERE 
			c.customerNo = s.customerNo
			and s.type = 2
		GROUP BY c.riskID, s.customerNo
	)a
	left outer join
	(
		SELECT 
			rl.customerNo,
			COUNT (distinct rl.returnNo)Retouren, 
			SUM (rl.quantity)Ret_Artikel,
			SUM (rl.line_amount)Ret_Nettowert
		FROM
			[dbo].[iw_return_line]rl
		WHERE 
			rl.type = 2
		GROUP BY rl.customerNo
	)b
	on a.customerNo = b.customerNo
GROUP BY a.riskID
;


/*Mit NULL-Behandlung und Ertrags-Berechnnung*/
SELECT 
	a.riskID, 
	COUNT (distinct a.customerNo) Konten,
	SUM (a.Bestellungen)Bestellungen, 
	SUM (a.Artikel) Artikel,
	SUM (a.Nettosumme)Nettosumme, 
	ISNULL(SUM (b.Retouren),0)Retouren,
	ISNULL(SUM (b.Ret_Artikel),0)Ret_Artikel, 
	ISNULL(SUM (b.Ret_Nettowert),0)Ret_Nettowert,
	(SUM (a.Bestellungen)*9.5)Bestellkosten,
	ISNULL((SUM (b.Retouren)*5.8),0)Retourkosten,
	SUM(a.Nettosumme)- ISNULL(SUM (b.Ret_Nettowert),0)- (SUM(a.Bestellungen)*9.5)- ISNULL((SUM(b.Retouren)*5.8),0)Nettoertrag
FROM
	(
		SELECT 
			c.riskID, 
			s.customerNo,
			COUNT (distinct s.orderNo)Bestellungen, 
			sum (s.quantity)Artikel,
			cast (SUM (s.amount *s.quantity)as decimal(10,2))Nettosumme
		FROM 
			[dbo].[iw_customer]c,
			[dbo].[iw_sales]s
		WHERE 
			c.customerNo = s.customerNo
			and s.type = 2
		GROUP BY c.riskID, s.customerNo
	)a
	left outer join
	(
		SELECT 
			rl.customerNo,
			COUNT (distinct rl.returnNo)Retouren, 
			SUM (rl.quantity)Ret_Artikel,
			SUM (rl.line_amount)Ret_Nettowert
		FROM
			[dbo].[iw_return_line]rl
		WHERE 
			rl.type = 2
		GROUP BY rl.customerNo
	)b
	on a.customerNo = b.customerNo
GROUP BY a.riskID
ORDER BY 11
;

/*wollte ma´l die Summe sehen*/

select sum(Nettoertrag)
from (
	SELECT 
		a.riskID, 
		COUNT (distinct a.customerNo) Konten,
		SUM (a.Bestellungen)Bestellungen, 
		SUM (a.Artikel) Artikel,
		SUM (a.Nettosumme)Nettosumme, 
		ISNULL(SUM (b.Retouren),0)Retouren,
		ISNULL(SUM (b.Ret_Artikel),0)Ret_Artikel, 
		ISNULL(SUM (b.Ret_Nettowert),0)Ret_Nettowert,
		(SUM (a.Bestellungen)*9.5)Bestellkosten,
		ISNULL((SUM (b.Retouren)*5.8),0)Retourkosten,
		SUM(a.Nettosumme)- ISNULL(SUM (b.Ret_Nettowert),0)- (SUM(a.Bestellungen)*9.5)- ISNULL((SUM(b.Retouren)*5.8),0)Nettoertrag
	FROM
		(
			SELECT 
				c.riskID, 
				s.customerNo,
				COUNT (distinct s.orderNo)Bestellungen, 
				sum (s.quantity)Artikel,
				cast (SUM (s.amount *s.quantity)as decimal(10,2))Nettosumme
			FROM 
				[dbo].[iw_customer]c,
				[dbo].[iw_sales]s
			WHERE 
				c.customerNo = s.customerNo
				and s.type = 2
			GROUP BY c.riskID, s.customerNo
		)a
		left outer join
		(
			SELECT 
				rl.customerNo,
				COUNT (distinct rl.returnNo)Retouren, 
				SUM (rl.quantity)Ret_Artikel,
				SUM (rl.line_amount)Ret_Nettowert
			FROM
				[dbo].[iw_return_line]rl
			WHERE 
				rl.type = 2
			GROUP BY rl.customerNo
		)b
		on a.customerNo = b.customerNo
	GROUP BY a.riskID
)y


/*BSP zu Partitionen und Windows
Window wird weitergeschoben entlang der Zeit

Für jeden Kunden sollen die Bestellungen nach Bestelldatum geordnet untereinander geschrieben werden, so dass die Bestellungen zueinander in Beziehung gesetzt werden können. 
Die einzelnen Bestellungen erhalten eine laufende Nummer zur Kennzeichnung der ersten, zweiten, …, n-ten Bestellung eines Kunden.
Die Ergebnistabelle soll folgende Informationen beinhalten: 
- lfdNr pro Kunde, 
- riskID, 
- Datum,
- Bestell-Nr., 
- Artikelmenge, 
- Gesamtsumme, 
- Anzahl_R_Artikel, 
- R_Nettowert

Hinweis: Die Syntax für die Ausgabe der Werte in Partitionen pro Kunde sieht wie folgt aus:
ROW_NUMBER() OVER (PARTITION BY <Spaltenname> ORDER BY <Spaltenname>)
*/

SELECT 
	bd.riskID, 
	ROW_NUMBER() OVER (PARTITION BY bd.riskID ORDER BY bd.Datum) as lfdNr,
	-- Laufende Nummer
	bd.Datum, 
	bd.Bestellung, 
	bd.Artikelmenge,
	bd.Gesamtsumme,
	ISNULL(rd.Anzahl_R_Artikel,0) Anzahl_R_Artikel, 
	ISNULL(rd.R_Nettowert,0) R_Nettowert
FROM
	(
		SELECT 
			a.riskID, 
			a.Datum, 
			a.Bestellung, 
			a.Artikelmenge, 
			a.Gesamtsumme
		FROM
			(
				SELECT 
					c.riskID,
					s.postingDate Datum,
					s.orderNo Bestellung,
					cast (SUM (s.quantity)as decimal(10,0))Artikelmenge,
					cast (SUM (s.amount)as decimal(10,2))Gesamtsumme
				FROM 
					[dbo].[iw_sales]s,
					[dbo].[iw_customer]c
				WHERE 
					s.customerNo = c.customerNo
					and s.type = 2 -- ohne Frachtkosten
					and s.quantity > 0
				GROUP BY c.riskID,s.postingDate,s.orderNo
			)a
	) bd			
	-- Das sind die Bestelldaten
	LEFT OUTER JOIN
	(
		SELECT 
			c.riskID IRID,
			s.postingDate Datum,
			rh.orderNo Bestellung,
			cast(SUM( rl.quantity)as decimal(10,0)) Anzahl_R_Artikel,
			cast(SUM (rl.line_amount)as decimal(10,2))R_Nettowert
		FROM 
			[dbo].[iw_sales]s,
			[dbo].[iw_customer]c,
			[dbo].[iw_return_line]rl,[dbo].[iw_return_header]rh
		WHERE s.type = 2
			and s.orderNo = rh.orderNo
			and rh.returnNo = rl.returnNo
			and s.IWAN = rl.IWAN -- Artikelnummer hinzu!
			and rl.type = 2
			and s.customerNo = c.customerNo
		GROUP BY c.riskID, s.postingDate, rh.orderNo
	)as rd
	-- Das sind die Retourendaten
	on bd.Bestellung = rd.Bestellung
			