/***SEMINAR 07 ***/

/*Aufgabe 01 - Analyse von Unique Kunden
Um unique Kunden zu erkennen, könnte man die persönlichen Daten, wie Name, Geschlecht, Geburtsdatum und Wohnort, miteinander abgleichen. 
In der Praxis eines Online-Shops gibt es dafür schon eine Funktionalität und zwar die Bonitätsprüfung. 
Dabei wird jede neue Kundenadresse geprüft und die Bonität ermittelt, die Einfluss hat auf mögliche Zahlarten (Vorkasse, Rechnung etc.). 
Somit haben auch Gastkäufer mit unterschiedlichen Kunden-nummern nur eine riskID.
*/

/*A) Vergleichen Sie die Anzahl der Kundennummern mit der Anzahl der unterschiedlichen riskIDs.*/
select 'Kundennummern' Kennzahl, count(distinct customerNo) Wert
from iw_customer

UNION

select 'RiskIDs', count(distinct riskID)
from iw_customer
;

/*B) Ermitteln Sie die durchschnittliche Anzahl der Konten pro Kunde.*/
select CAST(count(distinct customerNo) as numeric)/CAST(count(distinct riskID) as numeric) 'Konten pro Kunde'
from iw_customer
;


/*C) Erzeugen Sie einen KPI-Report (Key-Performance Indicator) auf der Basis uniquer Kunden mit folgenden Informationen: 
Jahr, Monat, Kunden, Kundenkonten, Bestellungen, Artikelmenge, Nettosumme, Warenkorb, Artikel_WK*/


Select 
	a.jahr, 
	a.Monat, 
	a.Kunden, 
	a.Kundenkonten,
	a.Bestellungen,
	a.Artikelmenge, 
	a.Nettosumme,
	cast(a.Nettosumme/a.Bestellungen as DECIMAL(10,2))Warenkorb,
	cast(a.Artikelmenge/a.Bestellungen as DECIMAL(10,2))Artikel_WK
from (
	select 
		DATEPART (YYYY, s.postingDate) Jahr,
		DATEPART (MM, s.postingDate) Monat,
		count (distinct c.riskID) Kunden, --unique Kunden
		count (distinct s.customerNo) Kundenkonten, 
		count (distinct s.orderNo) Bestellungen, 
		sum (s.quantity) Artikelmenge,
		sum (s.amount) Nettosumme
	from 
		iw_sales s, 
		iw_customer c
	where 
		s.type = 2
		and s.customerNo = c.customerNo
	group by 
		DATEPART (YYYY, s.postingDate),
		DATEPART (MM, s.postingDate)
) a
order by a.Jahr, a.Monat
;
---HIER FEHLEN NOCH: Nettosumme, Warenkorb, Artikel_WK, muss im Kopf der äußeren Abfrage passieren 



/*D) Geben Sie im Report Zwischenzeilen pro Jahr (für die verdichtete Auswertung auf Jahresbasis) aus sowie eine Zeile für die Ergebnisse im gesamten Zeitraum (Roll-Up).*/

Select 
	a.jahr, 
	a.Monat, 
	a.Kunden, 
	a.Kundenkonten,
	a.Bestellungen,
	a.Artikelmenge, 
	a.Nettosumme,
	cast(a.Nettosumme/a.Bestellungen as DECIMAL(10,2))Warenkorb,
	cast(a.Artikelmenge/a.Bestellungen as DECIMAL(10,2))Artikel_WK
from (
	select 
		DATEPART (YYYY, s.postingDate) Jahr,
		DATEPART (MM, s.postingDate) Monat,
		count (distinct c.riskID) Kunden, --unique Kunden
		count (distinct s.customerNo) Kundenkonten, 
		count (distinct s.orderNo) Bestellungen, 
		sum (s.quantity) Artikelmenge,
		sum (s.amount) Nettosumme
	from 
		iw_sales s, 
		iw_customer c
	where 
		s.type = 2
		and s.customerNo = c.customerNo
	--GROP-BY Argumente in ROLLUP packen.
	group by rollup(
		DATEPART (YYYY, s.postingDate),
		DATEPART (MM, s.postingDate)
	)
) a
order by a.Jahr, a.Monat
;
---Schon nicht schlecht, jetz NULL durch Strings ersetzen:

Select 
	a.jahr, 
	a.Monat, 
	a.Kunden, 
	a.Kundenkonten,
	a.Bestellungen,
	a.Artikelmenge, 
	a.Nettosumme,
	cast(a.Nettosumme/a.Bestellungen as DECIMAL(10,2))Warenkorb,
	cast(a.Artikelmenge/a.Bestellungen as DECIMAL(10,2))Artikel_WK
from (
	select 
		case when grouping(DATEPART (yyyy,s.postingDate)) = 1
			---Für Sortierung, muss "ALLE" und Zahlenwert auf gemeinsamen Typ gecastet werden:
			then cast('Alle' AS varchar)
			else cast(DATEPART (yyyy,s.postingDate) as varchar)
		end Jahr,
		case when grouping(DATEPART (mm,s.postingDate)) = 1
			---Für Sortierung, muss "ALLE" und Zahlenwert auf gemeinsamen Typ gecastet werden:
			then cast('Alle' AS varchar)
			else cast(DATEPART (mm,s.postingDate) as varchar)
		end Monat,
		count (distinct c.riskID) Kunden, --unique Kunden
		count (distinct s.customerNo) Kundenkonten, 
		count (distinct s.orderNo) Bestellungen, 
		sum (s.quantity) Artikelmenge,
		sum (s.amount) Nettosumme
	from 
		iw_sales s, 
		iw_customer c
	where 
		s.type = 2
		and s.customerNo = c.customerNo
	--GROP-BY Argumente in ROLLUP packen.
	group by rollup(
		DATEPART (YYYY, s.postingDate),
		DATEPART (MM, s.postingDate)
	)
) a
order by 
	a.Jahr, 
	---Hier noch ein Bisschen String-Voodo für korrekte Sortierung -> 5 als 05 behandeln. Nach 12 kommt Alle -> Passt mit der lexographischen Ordnung.
	right('0' + cast(a.Monat as varchar(2)),2)
;

/*Erweitern Sie den Report, so dass Sie auch die Ergebnisse auf Wochenbasis ausgeben können (Drill-Down).*/


Select 
	a.jahr, 
	a.Monat, 
	a.Woche,
	a.Kunden, 
	a.Kundenkonten,
	a.Bestellungen,
	a.Artikelmenge, 
	a.Nettosumme,
	cast(a.Nettosumme/a.Bestellungen as DECIMAL(10,2))Warenkorb,
	cast(a.Artikelmenge/a.Bestellungen as DECIMAL(10,2))Artikel_WK
from (
	select 
		case when grouping(DATEPART (yyyy,s.postingDate)) = 1
			---Für Sortierung, muss "ALLE" und Zahlenwert auf gemeinsamen Typ gecastet werden:
			then cast('Alle' AS varchar)
			else cast(DATEPART (yyyy,s.postingDate) as varchar)
		end Jahr,
		case when grouping(DATEPART (mm,s.postingDate)) = 1
			---Für Sortierung, muss "ALLE" und Zahlenwert auf gemeinsamen Typ gecastet werden:
			then cast('Alle' AS varchar)
			else cast(DATEPART (mm,s.postingDate) as varchar)
		end Monat,
		case when grouping(DATEPART (ISOWK,s.postingDate)) = 1
			---Für Sortierung, muss "ALLE" und Zahlenwert auf gemeinsamen Typ gecastet werden:
			then cast('Alle' AS varchar)
			else cast(DATEPART (ISOWK,s.postingDate) as varchar)
		end Woche,
		count (distinct c.riskID) Kunden, --unique Kunden
		count (distinct s.customerNo) Kundenkonten, 
		count (distinct s.orderNo) Bestellungen, 
		sum (s.quantity) Artikelmenge,
		sum (s.amount) Nettosumme
	from 
		iw_sales s, 
		iw_customer c
	where 
		s.type = 2
		and s.customerNo = c.customerNo
	--GROP-BY Argumente in ROLLUP packen.
	group by rollup(
		DATEPART (YYYY, s.postingDate),
		DATEPART (MM, s.postingDate),
		DATEPART (ISOWK, s.postingDate)
	)
) a
order by 
	a.Jahr, 
	---Hier noch ein Bisschen String-Voodo für korrekte Sortierung -> 5 als 05 behandeln. Nach 12 kommt Alle -> Passt mit der lexographischen Ordnung.
	right('0' + cast(a.Monat as varchar(2)),2),
	right('0' + cast(a.Woche as varchar(2)),2)
;



/*Aufgabe 02
Analyse von Neu- und Bestandskunden.
Ein Kunde ist in dem Monat Neukunde, wenn es sich um seine erste Bestellung handelt. 
Ein Bestandskunde besitzt mindestens einen weiteren Eintrag mit einem jüngeren Bestelldatum in der Datenbank.
*/

/*A) Ermitteln Sie die Anzahl der hinzugekommenen Neukunden pro Monat.*/
select 
	DATEPART(YYYY,a.CustRegistration),
	DATEPART(MM,a.CustRegistration),
	count(*)
from (
	select c.riskID, min(s.orderDate) CustRegistration
	from iw_customer c, iw_sales s
	where c.customerNo = s.customerNo
	group by c.riskID
) a
group by 
	DATEPART(YYYY,a.CustRegistration),
	DATEPART(MM,a.CustRegistration)
order by
	DATEPART(YYYY,a.CustRegistration),
	DATEPART(MM,a.CustRegistration)
;

