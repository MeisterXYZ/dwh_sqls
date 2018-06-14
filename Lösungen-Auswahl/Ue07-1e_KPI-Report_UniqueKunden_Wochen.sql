use iw_shop
Select 
a.jahr, a.Monat, a.Woche, a.Kunden, a.Kundenkonten,a.Bestellungen,
a.Artikelmenge, a.Nettosumme,
cast(a.Nettosumme/a.Bestellungen as DECIMAL(10,2))Warenkorb,
cast(a.Artikelmenge/a.Bestellungen as DECIMAL(10,2))Artikel_WK
from
-- Inhalte/Berechnungen aus der Unterabfrage
(Select 
 case when grouping(DATEPART (yyyy,s.postingDate)) = 1
  then cast('Alle' AS varchar)
  else cast(DATEPART (yyyy,s.postingDate) as varchar)
 end Jahr,
 case when grouping(DATEPART (mm,s.postingDate)) = 1
  then cast('Alle' AS varchar)
  else cast(DATEPART (mm,s.postingDate) as varchar)
 end Monat,
 case when grouping(DATEPART (isowk,s.postingDate)) = 1
  then cast('Alle' AS varchar)
  else cast(DATEPART (isowk,s.postingDate) as varchar)
 end Woche,
count (distinct c.riskID) Kunden, -- unique Kunden
count (distinct s.customerNo) Kundenkonten, -- Kundenkonten
count (distinct s.orderNo) Bestellungen,
sum (s.quantity) Artikelmenge,
sum (s.amount) Nettosumme
FROM [dbo].[iw_sales]s, [dbo].[iw_customer]c
where s.type = 2
and s.customerNo = c.customerNo
-- Join der Tabellen Sales und customer
group by rollup (DATEPART (yyyy,s.postingDate),DATEPART (mm,s.postingDate),
      DATEPART (isowk,s.postingDate)))a
order by a.Jahr, right('0' + cast(a.Monat as varchar(2)),2),a.Woche