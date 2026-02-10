````markdown
## Deployment Instructions

### First-Time Setup

1. SSH into your VM:

   ```bash
   ssh <username>@<vm-ip-address>
   ```

2. Create the necessary directory:

   ```bash
   mkdir -p /mnt/data/binarysuccess/orchestration/services
   ```

3. Clone the repository:

   ```bash
   git clone https://<token>@github.com/colakin-devops/binarysuccess-orchestration.git .
   ```

4. Add the `.env` file to the project root.

5. Change to the `docker` directory:

   ```bash
   cd docker
   ```

6. Build the services:

   ```bash
   sudo docker compose -p binarysuccess-orchestration build
   ```

7. Start the services:

   ```bash
   sudo docker compose -p binarysuccess-orchestration up -d
   ```

---

### Regular Deployment

1. SSH into your VM:

   ```bash
   ssh <username>@<vm-ip-address>
   ```

2. Change to the project directory and pull the latest changes:

   ```bash
   cd /mnt/data/binarysuccess/orchestration/services
   git pull
   ```

3. Change to the `docker` directory:

   ```bash
   cd docker
   ```

4. Build the services:

   ```bash
   sudo docker compose -p binarysuccess-orchestration build
   ```

5. Restart the services:

   ```bash
   sudo docker compose -p binarysuccess-orchestration up -d
   ```

6. To stop the services:

   ```bash
   sudo docker compose -p binarysuccess-orchestration down
   ```
````

