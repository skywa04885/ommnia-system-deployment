# Ommnia System Deployment

Deze repository bevat de deployment van het Ommnia System. Deze is opzichzelf incompleet, en zorgt enkel voor een draaiende versie. Alle andere dingen zoals SSL-Termination zullen op een reverse proxy plaatst moeten vinden. Deze deployment stelt enkel de applicatie beschikbaar.

# Overzicht

Hierdonder volgt een overzicht van wat deze deployment zal gaan bevatten.

## Poorten

Wanneer een deployment online is, zullen de volgende poorten door docker beschikbaar worden gesteld. 

| Poort | Omschrijving           |
| ----- | ---------------------- |
| 6379  | Redis                  |
| 5432  | PostgresQL             |
| 8086  | InfluxDB               |
| 80    | Applicatie (via NGINX) |

Mijn persoonlijk advies is om enkel poort `80` open te zetten (dit wordt later ook in de firewall configuratie gedaan).
Voor toegang tot de andere poorten is SSH-tunneling een veiligere optie. Zo'n tunnel kan met de volgende opdracht opgezet worden (voer deze opdracht uit *voordat* je een SSH-Shell het op de VPS). Vul de poort waarmee je wilt verbinden in voor de `<POORT>` placeholder, en het IP-Adres (of hostnaam) van de server in voor de placeholder `<SERVER>`.

```bash
ssh -L "<POORT>:<SERVER>:<POORT>" "<SERVER>"
```

# Installatie

Om een nieuwe VPS op te zetten moet de onderstaande handleiding gevolgd worden. Deze zou een volledig werkende VPS op moeten kunnen zetten (op het instellen van de reverse-proxy na).

## Voorbereiden van server

Deze handleiding is gemaakt voor Ubuntu Noble 24.04. Volg deze ook enkel op deze distributie. De kans is aanwezig dat deze handleiding anders niet werkt.

### Installeren van docker

Voeg docker aan de repository toe met de volgende opdracht.

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

Installeer alle benodigde software met de volgende opdracht.

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Inloggen op docker container registry

Volg de handleiding van [Github](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) om in te loggen op de container registry. Kijk specifiek naar _Authenticating with a personal access token (classic)_.

### Rechten tot docker krijgen

Tenzij je al in een root-account zit, moet de volgende opdracht uitgevoerd worden om rechten voor docker te verkrijgen.

```bash
sudo usermod -aG docker $USER
```

Log opnieuw in op de VPS om dit te laten reflecteren.

### Installeren van password generator

Om veilige wachtwoorden te genereren moet het volgende programma geinstalleerd worden. Doe dit door de volgende opdracht uit te voeren.

```bash
sudo apt-get install pwgen
```

### Instellen van firewall

Ten eerste moet SSH toegang aangezet worden. Als deze stap wordt vergeten verlies je de toegang tot de nieuwe VPS.

```bash
sudo ufw allow ssh
```

Om verbindingen toe te laten op poort 80 moet de volgende opdracht uitgevoerd worden. Vervang `<REVERSE_PROXY_IP>` met het IP-adres van de reverse-proxy die de SSL-termination uit gaat voeren.

```bash
sudo ufw allow from <REVERSE_PROXY_IP> proto tcp to any port 80
```

Tot slot moet de firewall aangezet worden de onderstaande opdracht.

```bash
sudo ufw enable
```

Dan zal er een waarschuwing gegeven worden, maar ga gewoon door door `y` in te tikken en dan op enter te drukken.

## Ophalen van deze repository

### Aanmaken van SSH-Sleutel

Als eerst moet de onderstaande opdracht uitgevoerd worden voor het aanmaken van een SSH-Sleutel. Deze zal twee bestanden aanmaken, namelijk `~/.ssh/id-github` e `~/.ssh/id-github.pub`. Deze moeten gebruikt worden voor het authenticeren op Github.

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id-github -N ""
```

### Registreren van het publieke SSH-sleutel segment

Voer de onderstaande opdracht uit om de publieke sleutel op te halen.

```bash
cat ~/.ssh/id-github.pub
```

Selecteer en kopieer het resultaat van de opdracht. Registreer deze onder de *SSH en GPG sleutels* sectie in de github instellingen.

### Aanmaken van SSH-configuratie

Voer als eerst de onderstaande opdracht uit, plaats je gebruikersnaam van github in de placeholder `<USERNAME>`.

```bash
export $GITHUB_USERNAME="<USERNAME>"
```

Voer daarna de volgende opdrachten uit, deze zullen de SSH configuratie opzetten. Deze pakt automatisch de net opgegeven gebruikersnaam en plaatst hem juist in het bestand.

```bash
echo "
Host github.com
  HostName github.com
  User $GITHUB_USERNAME
  IdentityFile ~/.ssh/id-github
" >> ~/.ssh/config
```

### Inladen van repository

Als alle voorgaande stappen goed zijn verlopen, kan de repository nu worden ingeladen. Doe dit met de volgende opdracht.

```bash
git clone git@github.com:skywa04885/ommnia-system-deployment.git
```

## Betreden van repository

Momenteel ben sta je in de thuismap van je gebruiker. Om de repository te betreden moet de volgende opdracht uitgevoerd worden.

```bash
cd ommnia-system-deployment
```

Dit moet iedere keer als je iets omtrent deze repository wilt doen!

## Opgeven van versie

Omdat deze repository zowel voor de `development` als `release` build gebruikt kan worden, moet er opgegeven worden welke versie van de applicatie er opgehaald moet worden van de github container repository.
Zie de onderstaande opdrachten voor beide versies. Specifieke versies kunnen ook opgegeven worden, maar ik raad dit zelf persoonlijk af.

### Ontwikkeling

Voer de volgende opdracht uit om een ontwikkelingsversie te draaien.

```bash
echo "VERSION=development" > .env
```

### Productie

Voer de volgende opdracht uit om een productieversie te draaien.

```bash
echo "VERSION=release" >> .env
```

### Wisselen van versie

Om te wisselen van een versie moet je dit handmatig in het bestand aanpassen. De bovenstaande opdrachten zullen namelijk de `VERSION` regel toevoegen, zonder de bestaande aan te passen.
Om de bestaande aan te passen kan je de volgende opdracht gebruiken.

```bash
nano .env
```

Maar dit zou voor de meeste ICT'ers vanzelfsprekend moeten zijn.

## Instellen van Redis.

In dezelfde map als het `compose.yml` bestand moet een bestand aangemaakt worden, namelijk `.env.redis-password`. Dit bestand moet het wachtwoord voor redis bevatten. Genereer dit bestand met de onderstaande opdracht.

```bash
pwgen 60 1 > .env.redis-password
```

## Instellen van PostgreSQL

### Opgeven van secrets.

In dezelfde map als het `compose.yml` bestand moeten meerdere bestanden aangemaakt worden. Deze bestanden zullen de secrets bevatten voor de PostgreSQL instantie. Deze zullen dienen als de gebruiker en wachtwoord van de PostgreSQL database.

#### 1. Gebruiker

Om te beginnen moet de gebruiker voor opgegeven worden. Deze moet geplaatst worden in het `.env.postgres-user` bestand. Gebruik de onderstaande opdracht om dit te doen. Vervang de `<GEBRUIKERSNAAM>` placeholder met de daadwerkelijke gebruiker.

```bash
echo "<GEBRUIKERSNAAM>" > .env.postgres-user
```

#### 2. Wachtwoord

Er moet een wachtwoord voor de gebruiker aangemaakt worden en geplaatst worden in het `.env.postgres-password` bestand. Gebruik de onderstaande opdracht om automatisch een veilig wachtwoord te genereren en te plaatsen in het juiste bestand.

```bash
pwgen 60 1 > .env.postgres-password
```

## Instellen van InfluxDB2

### Opgeven van secrets

In dezelfde map als het `compose.yml` bestand moeten meerdere bestanden aangemaakt worden. Deze bestanden zullen de secrets bevatten voor de InfluxDB2 instantie. Deze secrets worden gebruikt voor het opzetten van het administrator account van de instantie. Om deze aan te maken, volg de onderstaande stappen:

#### 1. Admin gebruikersnaam

Om te beginnen moet de gebruikersnaam voor de admin opgegeven worden. Deze moet geplaatst worden in het `.env.influxdb2-admin-username` bestand. Gebruik de onderstaande opdracht om dit te doen. Vervang de `<GEBRUIKERSNAAM>` placeholder met de daadwerkelijke gebruikersnaam voor de administrator.

```bash
echo "<GEBRUIKERSNAAM>" > .env.influxdb2-admin-username
```

#### 2. Admin wachtwoord

Er moet een wachtwoord voor de admin gebruiker aangemaakt worden en geplaatst worden in het `.env.influxdb2-admin-password` bestand. Gebruik de onderstaande opdracht om automatisch een veilig wachtwoord te genereren en te plaatsen in het juiste bestand.

```bash
pwgen 60 1 > .env.influxdb2-admin-password
```

#### 3. Admin token

Tot slot moet er een admin token aangemaakt worden. Deze moet worden geplaatst in het `.env.influxdb2-admin-token` bestand. Gebruik de onderstaande opdracht om automatisch een veilige token te genereren en te plaatsen in het juiste bestand.

```bash
pwgen 120 1 > .env.influxdb2-admin-token
```

## Instellen van S3

### Opgeven van secrets

Het Ommnia Systeem maakt gebruik van S3. Hiervoor moeten enkele stappen ondernomen worden om deze in te stellen voor het gebruik.

> Het is erg belangrijk dat iedere instantie van het ommnia system een _eigen_ S3 bucket krijgt. Anders gaan er problemem ontstaan!

#### 1. S3 Regio

Om te beginnen moet de regio van de S3 bucket opgegeven worden. Deze moet geplaatst worden in het `.env.s3-region` bestand. Gebruik de onderstaande opdracht om dit te doen. Vervang de `<REGION>` placeholder met de daadwerkelijke regio voor de bucket.

```bash
echo "<REGION>" > .env.s3-region
```

#### 2. S3 Access Key

Verder moet de access key van S3 opgegeven worden. Deze moet geplaatst worden in het `.env.s3-access-key` bestand. Gebruik de onderstaande opdracht om dit te doen. Vervang de `<ACCESS_KEY>` placeholder met de daadwerkelijke access key van S3.

```bash
echo "<ACCESS_KEY>" > .env.s3-access-key
```

#### 3. S3 Secret Key

Verder moet de secret key van S3 opgegeven worden. Deze moet geplaatst worden in het `.env.s3-secret-key` bestand. Gebruik de onderstaande opdracht om dit te doen. Vervang de `<SECRET_KEY>` placeholder met de daadwerkelijke secret key van S3.

```bash
echo "<SECRET_KEY>" > .env.s3-secret-key
```

#### 4. S3 Endpoint

Verder moet de endpoint van S3 opgegeven worden. Deze moet geplaatst worden in het `.env.s3-endpoint` bestand. Gebruik de onderstaande opdracht om dit te doen. Vervang de `<ENDPOINT>` placeholder met de daadwerkelijke endpoint van S3.

```bash
echo "<ENDPOINT>" > .env.s3-endpoint
```

#### 5. S3 bucket

Tot slot moet de upload bucket van S3 opgegeven worden. Deze moet geplaatst worden in het `.env.s3-upload-bucket` bestand. Gebruik de onderstaande opdracht om dit te doen. Vervang de `<BUCKET>` placeholder met de daadwerkelijke bucket van S3.

```bash
echo "<BUCKET>" > .env.s3-upload-bucket
```

## Instellen van mailgun

### Opgeven van secrets

Het ommnia system moet emails kunnen versturen. Daarvoor moet mailgun ingesteld worden. Dit moet via de volgende stappen.

#### 1. Mailgun base URL

Om te beginnen moet de base url van mailgun opgegeven worden. Deze moet geplaatst worden in het `.env.mailgun-base-url` bestand. Gebruik de onderstaande opdracht om dit te doen. Vervang de `<BASE_URL>` placeholder met de daadwerkelijke base url voor mailgun.

> In de meeste gevallen zal dit `https://api.eu.mailgun.net/` moeten zijn. Tenzij wij ooit buiten europa gaan werken.

```bash
echo "<BASE_URL>" > .env.mailgun-base-url
```

#### 2. Mailgun API Key

Verder moet de api key van mailgun opgegeven worden. Deze moet geplaatst worden in het `.env.mailgun-api-key` bestand. Gebruik de onderstaande opdracht om dit te doen. Vervang de `<API_KEY>` placeholder met de daadwerkelijke api key van mailgun.

```bash
echo "<API_KEY>" > .env.mailgun-api-key
```

#### 3. Mailgun domain

Tot slot moet het domain in mailgun opgegeven worden. Deze moet geplaatst worden in het `.env.mailgun-domain` bestand. Gebruik de onderstaande opdracht om dit te doen. Vervang de `<DOMAIN>` placeholder met de daadwerkelijke domain in mailgun.

> In de meeste gevallen zal dit `ommnia.nl` zijn. Tenzij we via het domein van een klant willen gaan versturen.

```bash
echo "<DOMAIN>" > .env.mailgun-domain
```

## Afronden van instellingen

Om het instellen af te ronden, moet een environment bestand aangemaakt worden dat alle overige configuraties zal bevatten. Dit bestand moet `.env` heten. Voer de onderstaande stappen uit om deze aan te maken.

### 1. Opgeven van alarm manager notificatie email.

Het email adres waarover notificaties van de alarm manager verstuurd worden moet worden opgegeven. Doe dit met de onderstaande opdracht. Vervang `<EMAIL>` met het daadwerkelijke email adres.

```bash
echo "ALARM_MANAGER_NOTIFICATIONS_EMAIL=<EMAIL>" >> .env.api
```

### 2. Opgeven van authenticatie notificatie email.

Het email adres waarover notificaties van de authenticatie verstuurd worden moet worden opgegeven. Doe dit met de onderstaande opdracht. Vervang `<EMAIL>` met het daadwerkelijke email adres.

```bash
echo "AUTH_NOTIFICATIONS_EMAIL=<EMAIL>" >> .env.api
```

### 3. Opgeven van rapportage email adres

Het email adres waarmee de rapportages verstuurd worden moet worden opgegeven. Doe dit met de onderstaande opdracht. Vervang `<EMAIL>` met het daadwerkelijke email adres.

```bash
echo "REPORTING_EMAIL=<EMAIL>" >> .env.api
```

### 4. Opgeven van rapportage bucket

De bucket waarin de rapportages opgeslagen worden. Deze moet los van de andere bucket, omdat deze gegevens zal bevatten die niet publiek toegankelijk mogen zijn. Geef deze naam op met met de onderstaande opdracht. Vervang `<BUCKET>` met de daadwerkelijke naam van de bucket.

```bash
echo "REPORTING_BUCKET=<BUCKET>" >> .env.api
```

## Online zetten

Voer de onderstaande opdracht uit om alles online te zetten.

```bash
docker compose up -d
```

## Herstarten

Om het hele systeem te herstarten voer de volgende opdracht uit.

```bash
docker compose restart
```
