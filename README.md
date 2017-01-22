# ProjectiOS

## De app
Mijn project iOS voor het opleidingsonderdeel Native Apps II (iOS)

Voor mijn project heb ik besloten een app te maken voor een website die frequent bezoek, maar jammer genoeg nog geen app of zelfs een responsive website heeft. Deze website, [Mangaupdates](https://www.mangaupdates.com/), heeft dus ook geen API. We hebben het dus moeten stellen met HTML te parsen.

Met deze app zou ik de goudmijn aan informatie die deze website bevat proberen op een gebruikvriendelijke manier op het mobiele scherm te brengen. Er werd initieel vooral gefocust op de database van manga's. Deze app zal nog verder uitgewerkt worden om zo veel als mogelijk van de info op de site te porten naar de app. Maar momenteel is mogelijk:

- Home
  - Een overzicht van de releases van de dag zien
  - De verzameling van alle genres en links naar de respectievelijke lijsten van manga's met dit genre zien
  - Zoeken op naam van een manga
  
- Advanced search
  - Filteren op naam, genres en compleetheid van de scanlation

- Zoekresultaten
  - Sorteren van de resultaten van een specifieke filter op naam of score
  
- Detail manga
  - Naam(en gekende alternatieve namen), auteur, artiest, genres, samenvatting, score
  - Aanbevelingen voor gelijkaardige manga (related, category recommendation, recommendation)
  
## Gebruikte Frameworks
  [Kanna](https://cocoapods.org/pods/Kanna) : een HTML/XML-parser
  [SDWebImage](https://github.com/rs/SDWebImage) : Een asynchrone image-loader die url's toelaat

##### Deze app was niet mogelijk geweest zonder de fantastische informatie beschikbaar op [mangaupdates.com](https://www.mangaupdates.com/)

