# Flutter Web Deployment

This document describes how to build and deploy the Flutter web app to the Ubuntu server.

---

## Deployment Steps

### 1. Pull the Latest Code

```bash
git pull origin main
```

````

### 2. Clean Previous Build

```bash
flutter clean
```

### 3. Build Flutter Web

```bash
flutter build web
```

### 4. Deploy to Ubuntu Server

Open a terminal (Ubuntu) in the project directory and run:

```bash
rsync -avz --progress build/web/ <username>@<server>:/mnt/data/vantanceCA/vantanceCA-web/web_1
```


````


