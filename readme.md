# Ommnia System Deployment

Deze repository bevat de deployment van het Ommnia System. Deze is opzichzelf incompleet, en zorgt enkel voor een draaiende versie. Alle andere dingen zoals SSL-Termination zullen op een reverse proxy plaatst moeten vinden. Deze deployment stelt enkel de applicatie beschikbaar.

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

Volg de handleiding van [Github](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) om in te loggen op de container registry. Kijk specifiek naar *Authenticating with a personal access token (classic)*.

### Installeren van password generator

Om veilige wachtwoorden te genereren moet het volgende programma geinstalleerd worden. Doe dit door de volgende opdracht uit te voeren.

```bash
sudo apt-get install pwgen
```

### Instellen van firewall

Om verbindingen toe te laten op poort 80 moet de volgende opdracht uitgevoerd worden. Vervang `<REVERSE_PROXY_IP>` met het IP-adres van de reverse-proxy die de SSL-termination uit gaat voeren.

```bash
sudo ufw allow from <REVERSE_PROXY_IP> proto tcp to any port 80
```

## Instellen van Redis.

In dezelfde map als het `compose.yml` bestand moet een bestand aangemaakt worden, namelijk `.env.redis-password`. Dit bestand moet het wachtwoord voor redis bevatten. Genereer dit bestand met de onderstaande opdracht.

```bash
pwgen 60 0 > .env.redis-password
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
pwgen 60 0 > .env.postgres-password
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
pwgen 60 0 > .env.influxdb2-admin-password
```

#### 3. Admin token

Tot slot moet er een admin token aangemaakt worden. Deze moet worden geplaatst in het `.env.influxdb2-admin-token` bestand. Gebruik de onderstaande opdracht om automatisch een veilige token te genereren en te plaatsen in het juiste bestand.

```bash
pwgen 120 0 > .env.influxdb2-admin-token
```

## Instellen van S3

### Opgeven van secrets

Het Ommnia Systeem maakt gebruik van S3. Hiervoor moeten enkele stappen ondernomen worden om deze in te stellen voor het gebruik. 

> Het is erg belangrijk dat iedere instantie van het ommnia system een *eigen* S3 bucket krijgt. Anders gaan er problemem ontstaan!

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
echo "ALARM_MANAGER_NOTIFICATIONS_EMAIL=<EMAIL>" >> .env
```

### 2. Opgeven van authenticatie notificatie email.

Het email adres waarover notificaties van de authenticatie verstuurd worden moet worden opgegeven. Doe dit met de onderstaande opdracht. Vervang `<EMAIL>` met het daadwerkelijke email adres.

```bash
echo "AUTH_NOTIFICATIONS_EMAIL=<EMAIL>" >> .env
```

## Online zetten

Voer de onderstaande opdracht uit om alles online te zetten.

```bash
sudo docker compose up -d
```

## Uitvoeren van database migrations

Om de database online te zetten moeten alle migrations uitgevoerd worden. Deze kunnen gevonden worden in [Ommnia System DB](https://github.com/skywa04885/ommnia-system-db).

Om deze migrations uit te voeren moet de volgende opdracht uitgevoerd worden. Dit opent een shell met de database.

```bash
sudo docker compose exec -it postgres psql -U `cat .env.postgres-user` -d ommnia_system
```

Voer alle migraties sequentieel op basis van de datum. Als ze al eerder uitgevoerd zijn en een update uitgevoerd moet worden, voer dan enkel de nieuwe uit.

Kopieer de inhoudt van de bestanden, plak ze in de shel, en druk op enter. Blijf dit doen totdat alle migraties zijn afgerond. Sluit daarna af met `exit`.

Herstart hierna het hele systeem.

## Herstarten

Om het hele systeem te herstarten voer de volgende opdracht uit.

```bash
sudo docker compose restart
```