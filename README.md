# README

## Media Catalog

This is a combination experiment and implementation of my local media library along with my collection records (LPs), CDs, and mp3 files.

### Rails Goals

- Use Rails 8 as vanilla as possible (.erb, test instead of rspec, rails 8 auth)  ✅
- Use Docker container to manage all dependencies inside container ✅
- Use Tailwindcss for styling  ✅
- Deploy using Kamal to external service

### Functional Goals (features)

- Show all Music Media from Vinyls, CDs, and mp3s 
- Possibly show DVDs and/or blu-rays (time permitting)
- User authentication to add media and add categories
- Default view to show all media
- Search functionality
- Import iTunes data to seed initial database  ✅
- Album art on main page
- Play counter to let me know how many times I've played an album
- maybe SPA up the site and not load pages
    - look into using the turbo / hotwire stuff for that

### RDBMS Structure

Since this is a trivial single use instance (for personal use only), going to use sqlite as I expect no more than 1 user at a time ... ME :)

After trial and error with Relational structure, going to follow approach recommened by Claude's analyis of Discogs' structure since that is the source I will be querying / inserting against.

[Table Structure](vendor/readme-assets/01.png)

[Sample Tree](vendor/readme-assets/02.png)

[Sample Tree](vendor/readme-assets/03.png)


# Local Dev instructions

- `overmind s`
- Since we are setup in a `.devcontainer` environment on VSCode, everything should be setup and ready to go locally
- directive(s) are stored in the `.overmind.env` file

### Credentials Edit

`EDITOR="code --wait" rails credentials:edit`

### Temporarily mount host Volumes

If we need access to the Host machine volumes (aka my local machine), run the following command:

- `docker run --mount type=bind,source=/Volumes,target=/mnt/volumes -it discogs_media-rails-app`

This will allow the root level `/Volumes` to be accesseable from inside the container in `/mnt/volumes`

## Deployment instructions

- TBD (waiting on analysis on what service provider to use)
- Cloud Platforms with Free Tiers
    - Fly.io
        - Free tier includes 3 shared CPUs, 256MB RAM, and 3GB storage.
        - Great for small apps and has built-in load balancing.
    - Railway.app
        - Offers a free $5 credit per month, which is enough for small deployments.
        - Supports Docker and has an easy deployment process.
    - Google Cloud Run
        - 1 million free requests per month.
        - Pay only for what you use beyond that.
        - Fully serverless, no need to manage infrastructure.
    - Render
        - Free for web services with 750 hours/month.
        - Auto-deploys from GitHub.
        - Supports background workers and databases.
    - Oracle Cloud Free Tier
        - Always free Arm-based compute instances (up to 4 vCPUs, 24GB RAM).
        -  Also includes free managed databases.
    - Microsoft Azure Container Apps (via free tier)
        - 12 months free, but usage is limited.
        - Free $200 credit for new accounts.
    - AWS ECS with Fargate (via free tier)
        - 750 free hours per month for Fargate.
        - Free tier valid for 12 months.
    - Other Free Hosting Options
        - Koyeb
            - Free tier with 512MB RAM and 1 vCPU.
            - Deploy from GitHub with automatic updates.
        - Clever Cloud
            - Free trial available with some limited usage.
        - Northflank
            - Free two services, build minutes included.
            - Great for containerized apps.